from datetime import datetime
from typing import List, Optional

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
import cloudinary.uploader

from app.config.cloudinary_config import *
from app.db.daatabase import db
from app.models.review_models import PlaceReviewCreate, PackageReviewCreate, HotelReviewCreate
from app.utils.auth_dependency import get_current_user_or_admin, is_admin

router = APIRouter(prefix="/api/reviews", tags=["Listing Reviews"])

reviews_collection = db["listing_reviews"]
places_collection = db["places"]
hotels_collection = db["hotels"]
packages_collection = db["travel_packages"]


# ── helpers ──────────────────────────────────────────────────────────────

def ok(message: str, data=None):
    return {"result": True, "message": message, "data": data if data is not None else {}}


def err(message: str, status_code: int = 400):
    raise HTTPException(
        status_code=status_code,
        detail={"result": False, "message": message, "data": {}},
    )


def get_object_id(id_str: str, label: str = "ID") -> ObjectId:
    if not ObjectId.is_valid(id_str):
        err(f"Invalid {label}", 400)
    return ObjectId(id_str)


def serialize_review(r: dict) -> dict:
    return {
        "id": str(r["_id"]),
        "target_type": r.get("target_type"),
        "target_id": r.get("target_id"),
        "user_id": r.get("user_id"),
        "user_name": r.get("user_name", "Anonymous User"),
        "rating": r.get("rating"),
        "cleanliness": r.get("cleanliness"),
        "location": r.get("location"),
        "staff": r.get("staff"),
        "value": r.get("value"),
        "comment": r.get("comment"),
        "images": r.get("images", []),
        "stayed_date": r.get("stayed_date"),
        "helpful_count": len(r.get("helpful_user_ids", [])),
        "created_at": r.get("created_at"),
    }


async def recompute_star_rating(collection, target_id: ObjectId, target_type: str) -> None:
    """Simple 5-star average + histogram, used by Places and Packages."""
    reviews = await reviews_collection.find(
        {"target_type": target_type, "target_id": str(target_id)}
    ).to_list(None)

    count = len(reviews)
    avg = round(sum(r["rating"] for r in reviews) / count, 1) if count else 0

    histogram = {str(star): 0 for star in range(1, 6)}
    for r in reviews:
        histogram[str(r["rating"])] += 1

    await collection.update_one(
        {"_id": target_id},
        {"$set": {"rating": avg, "review_count": count, "rating_histogram": histogram}},
    )


async def recompute_hotel_rating(hotel_id: ObjectId) -> None:
    """10-point average with a per-category breakdown, used by Hotels."""
    reviews = await reviews_collection.find(
        {"target_type": "hotel", "target_id": str(hotel_id)}
    ).to_list(None)

    count = len(reviews)
    if count == 0:
        breakdown = {"cleanliness": 0, "location": 0, "staff": 0, "value": 0}
        await hotels_collection.update_one(
            {"_id": hotel_id},
            {"$set": {"rating": 0, "review_count": 0, "rating_breakdown": breakdown}},
        )
        return

    def avg(field: str) -> float:
        return round(sum(r[field] for r in reviews) / count, 1)

    breakdown = {
        "cleanliness": avg("cleanliness"),
        "location": avg("location"),
        "staff": avg("staff"),
        "value": avg("value"),
    }
    overall = round(sum(breakdown.values()) / 4, 1)

    await hotels_collection.update_one(
        {"_id": hotel_id},
        {"$set": {"rating": overall, "review_count": count, "rating_breakdown": breakdown}},
    )


async def get_review_summary(target_type: str, target_id: str) -> dict:
    reviews = await reviews_collection.find(
        {"target_type": target_type, "target_id": target_id}
    ).to_list(None)
    count = len(reviews)

    if target_type == "hotel":
        if count == 0:
            return {"overall": 0, "review_count": 0, "breakdown": {"cleanliness": 0, "location": 0, "staff": 0, "value": 0}}

        def avg(field: str) -> float:
            return round(sum(r[field] for r in reviews) / count, 1)

        breakdown = {"cleanliness": avg("cleanliness"), "location": avg("location"), "staff": avg("staff"), "value": avg("value")}
        overall = round(sum(breakdown.values()) / 4, 1)
        return {"overall": overall, "review_count": count, "breakdown": breakdown}

    # place / package: simple 5-star + histogram (matches the star-bar chart)
    histogram = {str(star): 0 for star in range(1, 6)}
    for r in reviews:
        histogram[str(r["rating"])] += 1
    overall = round(sum(r["rating"] for r in reviews) / count, 1) if count else 0
    return {"overall": overall, "review_count": count, "histogram": histogram}


# ── SHARED: image upload (Cloudinary) ────────────────────────────────────

@router.post("/upload-images/{target_type}/{target_id}", summary="Upload review images to Cloudinary")
async def upload_review_images(
    target_type: str,
    target_id: str,
    file1: UploadFile = File(...),
    file2: Optional[UploadFile] = File(None),
    file3: Optional[UploadFile] = File(None),
    file4: Optional[UploadFile] = File(None),
    file5: Optional[UploadFile] = File(None),
    current_user: dict = Depends(get_current_user_or_admin),
):
    """
    Upload up to 5 review photos to Cloudinary and get back their URLs.
    target_type must be 'place', 'hotel', or 'package', and target_id must be
    the real place/hotel/package ID the review is for — this is what lets us
    know *whose* review the images belong to (e.g. a specific hotel vs a
    specific package), and it organizes the Cloudinary folder accordingly.

    Uses individual file slots (not a list) so Swagger UI renders proper
    "Choose File" buttons for each, same as the profile avatar upload.

    Call this first, then pass the returned URLs in the `images` field when
    creating that place/hotel/package review.
    """
    collections = {
        "place": places_collection,
        "hotel": hotels_collection,
        "package": packages_collection,
    }
    if target_type not in collections:
        err("target_type must be 'place', 'hotel', or 'package'", 400)

    oid = get_object_id(target_id, f"{target_type} ID")
    if not await collections[target_type].find_one({"_id": oid}):
        err(f"{target_type.capitalize()} not found", 404)

    files = [f for f in [file1, file2, file3, file4, file5] if f is not None]

    urls = []
    try:
        for file in files:
            result = cloudinary.uploader.upload(
                file.file,
                folder=f"camexplore/reviews/{target_type}/{target_id}",
            )
            urls.append(result["secure_url"])
    except Exception as e:
        err(str(e), 500)

    return ok("Images uploaded successfully", {"images": urls})


# ── PLACE REVIEWS (5-star) ──────────────────────────────────────────────

@router.get("/place/{place_id}")
async def get_place_reviews(
    place_id: str,
    limit: int = Query(20, ge=1, le=100),
    skip: int = Query(0, ge=0),
):
    oid = get_object_id(place_id, "place ID")
    if not await places_collection.find_one({"_id": oid}):
        err("Place not found", 404)

    summary = await get_review_summary("place", place_id)
    cursor = reviews_collection.find({"target_type": "place", "target_id": place_id}).sort("created_at", -1).skip(skip).limit(limit)
    reviews = [serialize_review(r) async for r in cursor]

    return ok("Reviews fetched successfully", {"summary": summary, "items": reviews})


@router.post("/place/{place_id}")
async def create_place_review(
    place_id: str,
    payload: PlaceReviewCreate,
    current_user: dict = Depends(get_current_user_or_admin),
):
    oid = get_object_id(place_id, "place ID")
    if not await places_collection.find_one({"_id": oid}):
        err("Place not found", 404)

    now = datetime.utcnow()
    doc = {
        "target_type": "place",
        "target_id": place_id,
        "user_id": str(current_user["_id"]),
        "user_name": current_user.get("name", "Anonymous User"),
        "rating": payload.rating,
        "comment": payload.comment,
        "images": payload.images,
        "helpful_user_ids": [],
        "created_at": now,
    }
    result = await reviews_collection.insert_one(doc)
    await recompute_star_rating(places_collection, oid, "place")

    new_review = await reviews_collection.find_one({"_id": result.inserted_id})
    return ok("Review submitted successfully", serialize_review(new_review))


# ── PACKAGE REVIEWS (5-star) ─────────────────────────────────────────────

@router.get("/package/{package_id}")
async def get_package_reviews(
    package_id: str,
    limit: int = Query(20, ge=1, le=100),
    skip: int = Query(0, ge=0),
):
    oid = get_object_id(package_id, "package ID")
    if not await packages_collection.find_one({"_id": oid}):
        err("Package not found", 404)

    summary = await get_review_summary("package", package_id)
    cursor = reviews_collection.find({"target_type": "package", "target_id": package_id}).sort("created_at", -1).skip(skip).limit(limit)
    reviews = [serialize_review(r) async for r in cursor]

    return ok("Reviews fetched successfully", {"summary": summary, "items": reviews})


@router.post("/package/{package_id}")
async def create_package_review(
    package_id: str,
    payload: PackageReviewCreate,
    current_user: dict = Depends(get_current_user_or_admin),
):
    oid = get_object_id(package_id, "package ID")
    if not await packages_collection.find_one({"_id": oid}):
        err("Package not found", 404)

    now = datetime.utcnow()
    doc = {
        "target_type": "package",
        "target_id": package_id,
        "user_id": str(current_user["_id"]),
        "user_name": current_user.get("name", "Anonymous User"),
        "rating": payload.rating,
        "comment": payload.comment,
        "images": payload.images,
        "helpful_user_ids": [],
        "created_at": now,
    }
    result = await reviews_collection.insert_one(doc)
    await recompute_star_rating(packages_collection, oid, "package")

    new_review = await reviews_collection.find_one({"_id": result.inserted_id})
    return ok("Review submitted successfully", serialize_review(new_review))


# ── HOTEL REVIEWS (10-point, category breakdown) ─────────────────────────

@router.get("/hotel/{hotel_id}")
async def get_hotel_reviews(
    hotel_id: str,
    limit: int = Query(20, ge=1, le=100),
    skip: int = Query(0, ge=0),
):
    oid = get_object_id(hotel_id, "hotel ID")
    if not await hotels_collection.find_one({"_id": oid}):
        err("Hotel not found", 404)

    summary = await get_review_summary("hotel", hotel_id)
    cursor = reviews_collection.find({"target_type": "hotel", "target_id": hotel_id}).sort("created_at", -1).skip(skip).limit(limit)
    reviews = [serialize_review(r) async for r in cursor]

    return ok("Reviews fetched successfully", {"summary": summary, "items": reviews})


@router.post("/hotel/{hotel_id}")
async def create_hotel_review(
    hotel_id: str,
    payload: HotelReviewCreate,
    current_user: dict = Depends(get_current_user_or_admin),
):
    oid = get_object_id(hotel_id, "hotel ID")
    if not await hotels_collection.find_one({"_id": oid}):
        err("Hotel not found", 404)

    now = datetime.utcnow()
    doc = {
        "target_type": "hotel",
        "target_id": hotel_id,
        "user_id": str(current_user["_id"]),
        "user_name": current_user.get("name", "Anonymous User"),
        "rating": payload.rating,
        "cleanliness": payload.cleanliness,
        "location": payload.location,
        "staff": payload.staff,
        "value": payload.value,
        "comment": payload.comment,
        "images": payload.images,
        "stayed_date": payload.stayed_date,
        "helpful_user_ids": [],
        "created_at": now,
    }
    result = await reviews_collection.insert_one(doc)
    await recompute_hotel_rating(oid)

    new_review = await reviews_collection.find_one({"_id": result.inserted_id})
    return ok("Review submitted successfully", serialize_review(new_review))


# ── SHARED: helpful vote + delete ────────────────────────────────────────

@router.post("/{review_id}/helpful")
async def toggle_helpful(
    review_id: str,
    current_user: dict = Depends(get_current_user_or_admin),
):
    oid = get_object_id(review_id, "review ID")
    review = await reviews_collection.find_one({"_id": oid})
    if not review:
        err("Review not found", 404)

    user_id = str(current_user["_id"])
    already_marked = user_id in review.get("helpful_user_ids", [])

    if already_marked:
        await reviews_collection.update_one({"_id": oid}, {"$pull": {"helpful_user_ids": user_id}})
    else:
        await reviews_collection.update_one({"_id": oid}, {"$addToSet": {"helpful_user_ids": user_id}})

    updated = await reviews_collection.find_one({"_id": oid})
    return ok(
        "Removed helpful vote" if already_marked else "Marked as helpful",
        {"helpful_count": len(updated.get("helpful_user_ids", [])), "marked": not already_marked},
    )


@router.delete("/{review_id}")
async def delete_review(
    review_id: str,
    current_user: dict = Depends(get_current_user_or_admin),
):
    oid = get_object_id(review_id, "review ID")
    review = await reviews_collection.find_one({"_id": oid})
    if not review:
        err("Review not found", 404)

    if review.get("user_id") != str(current_user["_id"]) and not is_admin(current_user):
        err("You can only delete your own review", 403)

    await reviews_collection.delete_one({"_id": oid})

    target_type = review["target_type"]
    target_id = ObjectId(review["target_id"])
    if target_type == "hotel":
        await recompute_hotel_rating(target_id)
    elif target_type == "place":
        await recompute_star_rating(places_collection, target_id, "place")
    elif target_type == "package":
        await recompute_star_rating(packages_collection, target_id, "package")

    return ok("Review deleted successfully")