from datetime import datetime
from typing import Optional, List

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query

from app.db.daatabase import db
from app.models.package_models import PackageCreate, PackageUpdate
from app.utils.auth_dependency import (
    get_current_user_optional,
    require_admin,
    require_company_or_admin,
    is_admin,
)

router = APIRouter(prefix="/travel_packages", tags=["Travel Packages"])

packages_collection = db["travel_packages"]
places_collection = db["places"]
hotels_collection = db["hotels"]


# ── helpers ──────────────────────────────────────────────────────────────

def ok(message: str, data=None):
    return {"result": True, "message": message, "data": data if data is not None else {}}


def err(message: str, status_code: int = 400):
    raise HTTPException(
        status_code=status_code,
        detail={"result": False, "message": message, "data": {}},
    )


def get_object_id(package_id: str) -> ObjectId:
    if not ObjectId.is_valid(package_id):
        err("Invalid package ID", 400)
    return ObjectId(package_id)


async def validate_itinerary(itinerary: list) -> None:
    """Every place_id/hotel_id/room_type_id in the itinerary must actually exist."""
    for item in itinerary:
        place_id = item.get("place_id")
        hotel_id = item.get("hotel_id")

        if place_id:
            if not ObjectId.is_valid(place_id):
                err(f"Invalid place_id in itinerary: {place_id}", 400)
            place = await places_collection.find_one({"_id": ObjectId(place_id)})
            if not place:
                err(f"Itinerary references a place that doesn't exist: {place_id}", 400)

        if hotel_id:
            if not ObjectId.is_valid(hotel_id):
                err(f"Invalid hotel_id in itinerary: {hotel_id}", 400)
            hotel = await hotels_collection.find_one({"_id": ObjectId(hotel_id)})
            if not hotel:
                err(f"Itinerary references a hotel that doesn't exist: {hotel_id}", 400)

            room_type_id = item.get("room_type_id")
            if room_type_id:
                room_ids = {rt.get("id") for rt in hotel.get("room_types", [])}
                if room_type_id not in room_ids:
                    err(f"room_type_id '{room_type_id}' does not belong to hotel {hotel_id}", 400)


def serialize_package(package: dict, lang: Optional[str] = None) -> dict:
    name_en = package.get("name_en", "")
    name_km = package.get("name_km", "")
    description_en = package.get("description_en", "")
    description_km = package.get("description_km", "")

    data = {
        "id": str(package["_id"]),
        "name_en": name_en,
        "name_km": name_km,
        "description_en": description_en,
        "description_km": description_km,
        "duration_days": package.get("duration_days"),
        "price_per_person": package.get("price_per_person"),
        "max_people": package.get("max_people"),
        "start_time": package.get("start_time", []),  
        "image_url": package.get("image_url"),
        "images": package.get("images", []),
        "tags": package.get("tags", []),
        "itinerary": package.get("itinerary", []),
        "rating": package.get("rating", 0),
        "review_count": package.get("review_count", 0),
        "rating_histogram": package.get("rating_histogram"),
        "status": package.get("status", "approved"),
        "review_note": package.get("review_note"),
        "owner_id": package.get("owner_id"),
        "created_at": package.get("created_at"),
        "updated_at": package.get("updated_at"),
    }

    if lang in ("en", "km"):
        data["name"] = name_en if lang == "en" else (name_km or name_en)
        data["description"] = description_en if lang == "en" else (description_km or description_en)

    return data


# ── PUBLIC / MIXED ──────────────────────────────────────────────────────────

@router.get("/")
async def get_packages(
    lang: Optional[str] = Query(None),
    status: Optional[str] = Query(None, description="admin only: pending | approved | rejected"),
    limit: int = Query(50, ge=1, le=200),
    skip: int = Query(0, ge=0),
    current_user: Optional[dict] = Depends(get_current_user_optional),
):
    query = {}
    if current_user and is_admin(current_user):
        if status:
            query["status"] = status
    else:
        query["status"] = "approved"

    total = await packages_collection.count_documents(query)
    cursor = packages_collection.find(query).skip(skip).limit(limit)
    packages = [serialize_package(p, lang) async for p in cursor]

    return ok("Packages fetched successfully", {
        "items": packages, "total": total, "limit": limit, "skip": skip,
    })


@router.get("/mine")
async def get_my_packages(
    lang: Optional[str] = Query(None),
    status: Optional[str] = Query(None),
    limit: int = Query(50, ge=1, le=200),
    skip: int = Query(0, ge=0),
    current_user: dict = Depends(require_company_or_admin),
):
    query = {"owner_id": str(current_user["_id"])}
    if status:
        query["status"] = status

    total = await packages_collection.count_documents(query)
    cursor = packages_collection.find(query).skip(skip).limit(limit)
    packages = [serialize_package(p, lang) async for p in cursor]

    return ok("Your packages fetched successfully", {
        "items": packages, "total": total, "limit": limit, "skip": skip,
    })


@router.get("/{package_id}")
async def get_package(
    package_id: str,
    lang: Optional[str] = Query(None),
    current_user: Optional[dict] = Depends(get_current_user_optional),
):
    oid = get_object_id(package_id)
    package = await packages_collection.find_one({"_id": oid})
    if not package:
        err("Package not found", 404)

    if package.get("status") != "approved":
        is_owner = current_user and package.get("owner_id") == str(current_user["_id"])
        if not (is_owner or (current_user and is_admin(current_user))):
            err("Package not found", 404)

    return ok("Package fetched successfully", serialize_package(package, lang))


# ── ORGANIZATION (company) + ADMIN: submit a package ────────────────────────

@router.post("/")
async def create_package(
    payload: PackageCreate,
    current_user: dict = Depends(require_company_or_admin),
):
    doc = payload.model_dump()
    await validate_itinerary(doc["itinerary"])

    now = datetime.utcnow()
    if not is_admin(current_user):
        doc["status"] = "pending"
        doc["review_note"] = None

    doc["owner_id"] = str(current_user["_id"])
    doc["created_at"] = now
    doc["updated_at"] = now

    result = await packages_collection.insert_one(doc)
    new_package = await packages_collection.find_one({"_id": result.inserted_id})

    message = (
        "Package created successfully" if is_admin(current_user)
        else "Package submitted — pending admin review"
    )
    return ok(message, serialize_package(new_package))


@router.put("/{package_id}")
async def update_package(
    package_id: str,
    payload: PackageUpdate,
    current_user: dict = Depends(require_company_or_admin),
):
    oid = get_object_id(package_id)
    package = await packages_collection.find_one({"_id": oid})
    if not package:
        err("Package not found", 404)

    update_data = {k: v for k, v in payload.model_dump().items() if v is not None}

    if not is_admin(current_user):
        if package.get("owner_id") != str(current_user["_id"]):
            err("You can only edit your own packages", 403)
        if package.get("status") != "pending":
            err("This package has already been reviewed and can no longer be edited. Contact an admin.", 403)
        update_data.pop("status", None)
        update_data.pop("review_note", None)

    if not update_data:
        err("No fields provided to update", 400)

    if "itinerary" in update_data:
        await validate_itinerary(update_data["itinerary"])

    update_data["updated_at"] = datetime.utcnow()

    await packages_collection.update_one({"_id": oid}, {"$set": update_data})
    updated_package = await packages_collection.find_one({"_id": oid})
    return ok("Package updated successfully", serialize_package(updated_package))


# ── ADMIN ONLY ──────────────────────────────────────────────────────────────

@router.delete("/{package_id}")
async def delete_package(
    package_id: str,
    current_user: dict = Depends(require_admin),
):
    oid = get_object_id(package_id)
    result = await packages_collection.delete_one({"_id": oid})
    if result.deleted_count == 0:
        err("Package not found", 404)
    return ok("Package deleted successfully")