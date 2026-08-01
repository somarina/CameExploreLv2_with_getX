from datetime import datetime
from math import radians, sin, cos, sqrt, atan2
from typing import Optional

from fastapi import APIRouter, Query, Depends, UploadFile, File, HTTPException
import cloudinary.uploader

from app.config.cloudinary_config import *
from app.data.provinces import PROVINCES
from app.db.daatabase import db
from app.routes.places import serialize_place
from app.schemas.category_schemas import CategoryCreate, CategoryUpdate
from app.utils.auth_dependency import require_admin

router = APIRouter(prefix="/api/categories", tags=["Categories"])

places_collection = db["places"]
categories_collection = db["categories"]

# Used ONLY to seed the "categories" collection the very first time the app
# runs against an empty database, so existing behavior doesn't change on
# upgrade. After that, this list is never read again — everything lives in
# Mongo and admins manage it through the endpoints below, no code changes
# or redeploys needed to add/edit/remove a category.
DEFAULT_CATEGORIES = [
    {"name": "Temple", "name_km": "ប្រាសាទ", "icon": "temple"},
    {"name": "Beach", "name_km": "ឆ្នេរសមុទ្រ", "icon": "beach"},
    {"name": "Nature", "name_km": "ធម្មជាតិ", "icon": "nature"},
    {"name": "City", "name_km": "ទីក្រុង", "icon": "city"},
    {"name": "Food", "name_km": "អាហារ", "icon": "food"},
    {"name": "Market", "name_km": "ផ្សារ", "icon": "market"},
    {"name": "Museum", "name_km": "សារមន្ទីរ", "icon": "museum"},
    {"name": "Waterfall", "name_km": "ទឹកជ្រោះ", "icon": "waterfall"},
]


def ok(message: str, data=None):
    return {"result": True, "message": message, "data": data if data is not None else {}}


def err(message: str, status_code: int = 400):
    raise HTTPException(
        status_code=status_code,
        detail={"result": False, "message": message, "data": {}},
    )


def serialize_category(cat: dict, place_count: Optional[int] = None) -> dict:
    data = {
        "name": cat["name"],
        "name_km": cat.get("name_km", ""),
        "icon": cat.get("icon", ""),
        "icon_url": cat.get("icon_url"),
    }
    if place_count is not None:
        data["place_count"] = place_count
    return data


async def ensure_seeded() -> None:
    """One-time seed so upgrading from the old hardcoded list is seamless.
    Safe to call on every request — no-op once categories already exist."""
    if await categories_collection.count_documents({}) == 0:
        now = datetime.utcnow()
        await categories_collection.insert_many([
            {**cat, "icon_url": None, "created_at": now, "updated_at": now}
            for cat in DEFAULT_CATEGORIES
        ])


def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371.0  # Earth radius in km
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat / 2) ** 2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon / 2) ** 2
    return R * (2 * atan2(sqrt(a), sqrt(1 - a)))


# ── PUBLIC ────────────────────────────────────────────────────────────────

@router.get("/")
async def get_categories(
    search: Optional[str] = Query(None, description="Search bar: filter category tiles by name (EN/KM)"),
):
    """List every category with a live count of approved places in it."""
    await ensure_seeded()

    query = {}
    if search:
        query["$or"] = [
            {"name": {"$regex": search, "$options": "i"}},
            {"name_km": {"$regex": search, "$options": "i"}},
        ]

    data = []
    async for cat in categories_collection.find(query).sort("name", 1):
        count = await places_collection.count_documents({
            "category": {"$regex": f"^{cat['name']}$", "$options": "i"},
            "status": "approved",
        })
        data.append(serialize_category(cat, count))

    return ok("Categories fetched successfully", data)


@router.get("/nearby")
async def nearby_provinces(
    lat: Optional[float] = Query(None, description="User's current latitude"),
    lng: Optional[float] = Query(None, description="User's current longitude"),
    limit: int = Query(10, ge=1, le=25),
):
    """
    'Nearby' screen: provinces ranked by distance from the user, each with
    a live count of approved places ('activities') and their average rating.
    If lat/lng aren't provided, falls back to sorting by activity count.
    """
    results = []
    for province in PROVINCES:
        activity_count = await places_collection.count_documents({
            "province": {"$regex": f"^{province['name']}$", "$options": "i"},
            "status": "approved",
        })

        ratings = await places_collection.find(
            {"province": {"$regex": f"^{province['name']}$", "$options": "i"}, "status": "approved"},
            {"rating": 1},
        ).to_list(None)
        avg_rating = round(sum(r.get("rating", 0) for r in ratings) / len(ratings), 1) if ratings else 0

        entry = {
            "province": province["name"],
            "province_km": province["name_km"],
            "latitude": province["latitude"],
            "longitude": province["longitude"],
            "activity_count": activity_count,
            "rating": avg_rating,
        }

        if lat is not None and lng is not None:
            entry["distance_km"] = round(haversine_km(lat, lng, province["latitude"], province["longitude"]), 1)

        results.append(entry)

    if lat is not None and lng is not None:
        results.sort(key=lambda r: r["distance_km"])
    else:
        results.sort(key=lambda r: r["activity_count"], reverse=True)

    results = results[:limit]

    return ok("Nearby provinces fetched successfully", {
        "items": results,
        "radius_km": results[-1]["distance_km"] if results and "distance_km" in results[0] else None,
        "total_activities": sum(r["activity_count"] for r in results),
    })


# ── ADMIN: manage categories ─────────────────────────────────────────────

@router.post("/", summary="Admin: create a new category")
async def create_category(
    payload: CategoryCreate,
    current_user: dict = Depends(require_admin),
):
    await ensure_seeded()

    existing = await categories_collection.find_one({
        "name": {"$regex": f"^{payload.name}$", "$options": "i"}
    })
    if existing:
        err(f"Category '{payload.name}' already exists")

    now = datetime.utcnow()
    doc = {
        "name": payload.name,
        "name_km": payload.name_km,
        "icon": payload.icon or payload.name.lower(),
        "icon_url": None,
        "created_at": now,
        "updated_at": now,
    }
    await categories_collection.insert_one(doc)

    return ok("Category created successfully", serialize_category(doc, place_count=0))


@router.put("/{category_name}", summary="Admin: rename / edit a category")
async def update_category(
    category_name: str,
    payload: CategoryUpdate,
    current_user: dict = Depends(require_admin),
):
    category = await categories_collection.find_one({
        "name": {"$regex": f"^{category_name}$", "$options": "i"}
    })
    if not category:
        err("Category not found", 404)

    update_data = {k: v for k, v in payload.model_dump().items() if v is not None}
    if not update_data:
        err("No fields provided to update", 400)

    if "name" in update_data and update_data["name"].lower() != category["name"].lower():
        clash = await categories_collection.find_one({
            "name": {"$regex": f"^{update_data['name']}$", "$options": "i"}
        })
        if clash:
            err(f"Category '{update_data['name']}' already exists")

    update_data["updated_at"] = datetime.utcnow()
    await categories_collection.update_one({"_id": category["_id"]}, {"$set": update_data})
    updated = await categories_collection.find_one({"_id": category["_id"]})

    count = await places_collection.count_documents({
        "category": {"$regex": f"^{updated['name']}$", "$options": "i"},
        "status": "approved",
    })
    return ok("Category updated successfully", serialize_category(updated, count))


@router.put("/{category_name}/icon", summary="Admin: upload/replace a category's icon image")
async def upload_category_icon(
    category_name: str,
    file: UploadFile = File(...),
    current_user: dict = Depends(require_admin),
):
    category = await categories_collection.find_one({
        "name": {"$regex": f"^{category_name}$", "$options": "i"}
    })
    if not category:
        err(f"Unknown category: {category_name}", 404)

    result = cloudinary.uploader.upload(
        file.file,
        folder="camexplore/categories",
    )
    icon_url = result["secure_url"]

    await categories_collection.update_one(
        {"_id": category["_id"]},
        {"$set": {"icon_url": icon_url, "updated_at": datetime.utcnow()}},
    )

    return ok("Category icon updated successfully", {"name": category["name"], "icon_url": icon_url})


@router.delete("/{category_name}", summary="Admin: delete a category")
async def delete_category(
    category_name: str,
    current_user: dict = Depends(require_admin),
):
    category = await categories_collection.find_one({
        "name": {"$regex": f"^{category_name}$", "$options": "i"}
    })
    if not category:
        err("Category not found", 404)

    in_use = await places_collection.count_documents({
        "category": {"$regex": f"^{category['name']}$", "$options": "i"},
    })
    if in_use > 0:
        err(
            f"Can't delete '{category['name']}' — {in_use} place(s) still use it. "
            "Reassign or remove those places first.",
            409,
        )

    await categories_collection.delete_one({"_id": category["_id"]})
    return ok("Category deleted successfully")


# NOTE: this dynamic route must stay LAST — FastAPI matches routes in
# declaration order, so static paths like "/nearby" above have to be
# declared before this one, or they'd get swallowed as a category name.

@router.get("/{category_name}")
async def get_places_by_category(
    category_name: str,
    lang: Optional[str] = Query(None, description="'en' or 'km'"),
    province: Optional[str] = Query(None),
    search: Optional[str] = Query(None, description="Search bar: filter places within this category by name/address/tags"),
    limit: int = Query(50, ge=1, le=200),
    skip: int = Query(0, ge=0),
):
    """Tap a category tile -> get every approved place under it, optionally filtered by a search bar."""
    query = {
        "category": {"$regex": f"^{category_name}$", "$options": "i"},
        "status": "approved",
    }
    if province:
        query["province"] = {"$regex": f"^{province}$", "$options": "i"}

    if search:
        query["$or"] = [
            {f: {"$regex": search, "$options": "i"}}
            for f in ("name_en", "name_km", "address_en", "address_km", "tags")
        ]

    total = await places_collection.count_documents(query)
    cursor = places_collection.find(query).skip(skip).limit(limit)
    places = [serialize_place(p, lang) async for p in cursor]

    return ok(f"Places in '{category_name}' fetched successfully", {
        "items": places, "total": total, "limit": limit, "skip": skip,
    })