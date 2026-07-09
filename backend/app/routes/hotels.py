import uuid
from datetime import datetime
from typing import Optional

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query

from app.db.daatabase import db
from app.models.hotel_models import HotelCreate, HotelUpdate
from app.utils.auth_dependency import (
    get_current_user_optional,
    require_admin,
    require_company_or_admin,
    is_admin,
)

router = APIRouter(prefix="/hotels", tags=["Hotels"])

hotels_collection = db["hotels"]


# ── helpers ──────────────────────────────────────────────────────────────

def ok(message: str, data=None):
    return {"result": True, "message": message, "data": data if data is not None else {}}


def err(message: str, status_code: int = 400):
    raise HTTPException(
        status_code=status_code,
        detail={"result": False, "message": message, "data": {}},
    )


def get_object_id(hotel_id: str) -> ObjectId:
    if not ObjectId.is_valid(hotel_id):
        err("Invalid hotel ID", 400)
    return ObjectId(hotel_id)


def with_room_type_ids(room_types: list) -> list:
    """Assign a stable id to each room type so bookings can reference it."""
    result = []
    for rt in room_types:
        rt_dict = dict(rt)
        rt_dict.setdefault("id", uuid.uuid4().hex[:12])
        result.append(rt_dict)
    return result


def serialize_hotel(hotel: dict, lang: Optional[str] = None) -> dict:
    name_en = hotel.get("name_en", "")
    name_km = hotel.get("name_km", "")
    description_en = hotel.get("description_en", "")
    description_km = hotel.get("description_km", "")

    data = {
        "id": str(hotel["_id"]),
        "name_en": name_en,
        "name_km": name_km,
        "description_en": description_en,
        "description_km": description_km,
        "province": hotel.get("province"),
        "province_km": hotel.get("province_km"),
        "address_en": hotel.get("address_en"),
        "address_km": hotel.get("address_km"),
        "star_rating": hotel.get("star_rating"),
        "image_url": hotel.get("image_url"),
        "images": hotel.get("images", []),
        "amenities": hotel.get("amenities", []),
        "latitude": hotel.get("latitude"),
        "longitude": hotel.get("longitude"),
        "room_types": hotel.get("room_types", []),
        "rating": hotel.get("rating", 0),
        "review_count": hotel.get("review_count", 0),
        "rating_breakdown": hotel.get("rating_breakdown"),
        "status": hotel.get("status", "approved"),
        "review_note": hotel.get("review_note"),
        "owner_id": hotel.get("owner_id"),
        "created_at": hotel.get("created_at"),
        "updated_at": hotel.get("updated_at"),
    }

    if lang in ("en", "km"):
        data["name"] = name_en if lang == "en" else (name_km or name_en)
        data["description"] = description_en if lang == "en" else (description_km or description_en)

    return data


# ── PUBLIC / MIXED ──────────────────────────────────────────────────────────

@router.get("/")
async def get_hotels(
    lang: Optional[str] = Query(None),
    province: Optional[str] = Query(None),
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

    if province:
        query["province"] = {"$regex": f"^{province}$", "$options": "i"}

    total = await hotels_collection.count_documents(query)
    cursor = hotels_collection.find(query).skip(skip).limit(limit)
    hotels = [serialize_hotel(h, lang) async for h in cursor]

    return ok("Hotels fetched successfully", {
        "items": hotels, "total": total, "limit": limit, "skip": skip,
    })


@router.get("/mine")
async def get_my_hotels(
    lang: Optional[str] = Query(None),
    status: Optional[str] = Query(None),
    limit: int = Query(50, ge=1, le=200),
    skip: int = Query(0, ge=0),
    current_user: dict = Depends(require_company_or_admin),
):
    query = {"owner_id": str(current_user["_id"])}
    if status:
        query["status"] = status

    total = await hotels_collection.count_documents(query)
    cursor = hotels_collection.find(query).skip(skip).limit(limit)
    hotels = [serialize_hotel(h, lang) async for h in cursor]

    return ok("Your hotels fetched successfully", {
        "items": hotels, "total": total, "limit": limit, "skip": skip,
    })


@router.get("/{hotel_id}")
async def get_hotel(
    hotel_id: str,
    lang: Optional[str] = Query(None),
    current_user: Optional[dict] = Depends(get_current_user_optional),
):
    oid = get_object_id(hotel_id)
    hotel = await hotels_collection.find_one({"_id": oid})
    if not hotel:
        err("Hotel not found", 404)

    if hotel.get("status") != "approved":
        is_owner = current_user and hotel.get("owner_id") == str(current_user["_id"])
        if not (is_owner or (current_user and is_admin(current_user))):
            err("Hotel not found", 404)

    return ok("Hotel fetched successfully", serialize_hotel(hotel, lang))


# ── ORGANIZATION (company) + ADMIN: submit a hotel listing ─────────────────

@router.post("/")
async def create_hotel(
    payload: HotelCreate,
    current_user: dict = Depends(require_company_or_admin),
):
    now = datetime.utcnow()
    doc = payload.model_dump()
    doc["room_types"] = with_room_type_ids(doc["room_types"])

    if not is_admin(current_user):
        doc["status"] = "pending"
        doc["review_note"] = None

    doc["owner_id"] = str(current_user["_id"])
    doc["created_at"] = now
    doc["updated_at"] = now

    result = await hotels_collection.insert_one(doc)
    new_hotel = await hotels_collection.find_one({"_id": result.inserted_id})

    message = (
        "Hotel created successfully" if is_admin(current_user)
        else "Hotel listing submitted — pending admin review"
    )
    return ok(message, serialize_hotel(new_hotel))


@router.put("/{hotel_id}")
async def update_hotel(
    hotel_id: str,
    payload: HotelUpdate,
    current_user: dict = Depends(require_company_or_admin),
):
    oid = get_object_id(hotel_id)
    hotel = await hotels_collection.find_one({"_id": oid})
    if not hotel:
        err("Hotel not found", 404)

    update_data = {k: v for k, v in payload.model_dump().items() if v is not None}

    if not is_admin(current_user):
        if hotel.get("owner_id") != str(current_user["_id"]):
            err("You can only edit your own hotel listings", 403)
        if hotel.get("status") != "pending":
            err("This hotel has already been reviewed and can no longer be edited. Contact an admin.", 403)
        update_data.pop("status", None)
        update_data.pop("review_note", None)

    if not update_data:
        err("No fields provided to update", 400)

    if "room_types" in update_data:
        update_data["room_types"] = with_room_type_ids(update_data["room_types"])

    update_data["updated_at"] = datetime.utcnow()

    await hotels_collection.update_one({"_id": oid}, {"$set": update_data})
    updated_hotel = await hotels_collection.find_one({"_id": oid})
    return ok("Hotel updated successfully", serialize_hotel(updated_hotel))


# ── ADMIN ONLY ──────────────────────────────────────────────────────────────

@router.delete("/{hotel_id}")
async def delete_hotel(
    hotel_id: str,
    current_user: dict = Depends(require_admin),
):
    oid = get_object_id(hotel_id)
    result = await hotels_collection.delete_one({"_id": oid})
    if result.deleted_count == 0:
        err("Hotel not found", 404)
    return ok("Hotel deleted successfully")
