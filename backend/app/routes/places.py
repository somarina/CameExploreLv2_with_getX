from datetime import datetime
from typing import Optional

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query
from pymongo import ReturnDocument

from app.db.daatabase import db
from app.models.models import PlaceCreate, PlaceUpdate
from app.utils.auth_dependency import require_admin

router = APIRouter(prefix="/places", tags=["Places"])

places_collection = db["places"]


# ── response helpers (same style as auth.py / auth_dashboard.py) ────────────

def ok(message: str, data=None):
    return {"result": True, "message": message, "data": data if data is not None else {}}


def err(message: str, status_code: int = 400):
    raise HTTPException(
        status_code=status_code,
        detail={"result": False, "message": message, "data": {}},
    )


def get_object_id(place_id: str) -> ObjectId:
    if not ObjectId.is_valid(place_id):
        err("Invalid place ID", 400)
    return ObjectId(place_id)


def serialize_place(place: dict, lang: Optional[str] = None) -> dict:
    """
    Always returns both languages. If `lang` is 'en' or 'km', also adds
    convenience 'name'/'description' fields localized to that language,
    for clients that don't want to deal with *_en / *_km themselves.
    """
    name_en = place.get("name_en") or place.get("name", "")
    name_km = place.get("name_km", "")
    description_en = place.get("description_en") or place.get("description", "")
    description_km = place.get("description_km", "")

    data = {
        "id": str(place["_id"]),
        "name_en": name_en,
        "name_km": name_km,
        "description_en": description_en,
        "description_km": description_km,
        "province": place.get("province"),
        "province_km": place.get("province_km"),
        "category": place.get("category"),
        "category_km": place.get("category_km"),
        "address_en": place.get("address_en"),
        "address_km": place.get("address_km"),
        "image_url": place.get("image_url"),
        "images": place.get("images", []),
        "latitude": place.get("latitude"),
        "longitude": place.get("longitude"),
        "opening_hours": place.get("opening_hours"),
        "entry_fee": place.get("entry_fee"),
        "tags": place.get("tags", []),
        "rating": place.get("rating", 0),
        "review_count": place.get("review_count", 0),
        "rating_histogram": place.get("rating_histogram"),
        "search_count": place.get("search_count", 0),
        "status": place.get("status", "approved"),
        "created_at": place.get("created_at"),
        "updated_at": place.get("updated_at"),
    }

    if lang in ("en", "km"):
        data["name"] = name_en if lang == "en" else (name_km or name_en)
        data["description"] = (
            description_en if lang == "en" else (description_km or description_en)
        )

    return data


# ── PUBLIC ──────────────────────────────────────────────────────────────

@router.get("/")
async def get_places(
    lang: Optional[str] = Query(None, description="'en' or 'km' to localize name/description"),
    province: Optional[str] = Query(None),
    category: Optional[str] = Query(None),
    limit: int = Query(50, ge=1, le=200),
    skip: int = Query(0, ge=0),
):
    query = {"status": "approved"}
    if province:
        query["province"] = {"$regex": f"^{province}$", "$options": "i"}
    if category:
        query["category"] = {"$regex": f"^{category}$", "$options": "i"}

    total = await places_collection.count_documents(query)
    cursor = places_collection.find(query).skip(skip).limit(limit)
    places = [serialize_place(p, lang) async for p in cursor]

    return ok("Places fetched successfully", {
        "items": places,
        "total": total,
        "limit": limit,
        "skip": skip,
    })


@router.get("/{place_id}")
async def get_place(place_id: str, lang: Optional[str] = Query(None)):
    oid = get_object_id(place_id)

    # Every detail view counts toward this place's popularity — this is what
    # 'Most search' / 'Popular places' rank by (via /api/search/popular).
    place = await places_collection.find_one_and_update(
        {"_id": oid},
        {"$inc": {"search_count": 1}},
        return_document=ReturnDocument.AFTER,
    )

    if not place:
        err("Place not found", 404)

    return ok("Place fetched successfully", serialize_place(place, lang))


# ── ADMIN ONLY ──────────────────────────────────────────────────────────────
# Places (temples, provinces, general tourism spots) are reference data —
# no organization "owns" a temple, so there's no submit-for-review flow here.
# Only Hotels and Packages use that, since real businesses submit those.

@router.post("/")
async def create_place(
    payload: PlaceCreate,
    current_user: dict = Depends(require_admin),
):
    now = datetime.utcnow()
    doc = payload.model_dump()

    # Keep legacy flat fields in sync — search.py / discover.py / favorites.py
    # read place["name"] / place["description"] directly from Mongo.
    doc["name"] = doc["name_en"]
    doc["description"] = doc["description_en"]

    doc["rating"] = 0
    doc["search_count"] = 0
    doc["created_by"] = str(current_user["_id"])
    doc["created_at"] = now
    doc["updated_at"] = now

    result = await places_collection.insert_one(doc)
    new_place = await places_collection.find_one({"_id": result.inserted_id})

    return ok("Place created successfully", serialize_place(new_place))


@router.put("/{place_id}")
async def update_place(
    place_id: str,
    payload: PlaceUpdate,
    current_user: dict = Depends(require_admin),
):
    oid = get_object_id(place_id)

    update_data = {k: v for k, v in payload.model_dump().items() if v is not None}
    if not update_data:
        err("No fields provided to update", 400)

    if "name_en" in update_data:
        update_data["name"] = update_data["name_en"]
    if "description_en" in update_data:
        update_data["description"] = update_data["description_en"]

    update_data["updated_at"] = datetime.utcnow()

    result = await places_collection.update_one({"_id": oid}, {"$set": update_data})
    if result.matched_count == 0:
        err("Place not found", 404)

    updated_place = await places_collection.find_one({"_id": oid})
    return ok("Place updated successfully", serialize_place(updated_place))


@router.delete("/{place_id}")
async def delete_place(
    place_id: str,
    current_user: dict = Depends(require_admin),
):
    oid = get_object_id(place_id)
    result = await places_collection.delete_one({"_id": oid})

    if result.deleted_count == 0:
        err("Place not found", 404)

    return ok("Place deleted successfully")
