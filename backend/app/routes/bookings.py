from datetime import datetime, date, timedelta
from typing import Optional

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query

from app.db.daatabase import db
from app.models.booking_models import (
    HotelBookingCreate,
    PackageBookingCreate,
    BookingStatusUpdate,
)
from app.utils.auth_dependency import get_current_user_or_admin, require_company_or_admin, is_admin

router = APIRouter(prefix="/bookings", tags=["Bookings"])

bookings_collection = db["bookings"]
hotels_collection = db["hotels"]
packages_collection = db["travel_packages"]

ACTIVE_STATUSES = ("pending", "confirmed")


# ── helpers ──────────────────────────────────────────────────────────────

def ok(message: str, data=None):
    return {"result": True, "message": message, "data": data if data is not None else {}}


def err(message: str, status_code: int = 400):
    raise HTTPException(
        status_code=status_code,
        detail={"result": False, "message": message, "data": {}},
    )


def get_object_id(booking_id: str) -> ObjectId:
    if not ObjectId.is_valid(booking_id):
        err("Invalid booking ID", 400)
    return ObjectId(booking_id)


def serialize_booking(b: dict) -> dict:
    return {
        "id": str(b["_id"]),
        "booking_type": b.get("booking_type"),
        "hotel_id": b.get("hotel_id"),
        "room_type_id": b.get("room_type_id"),
        "package_id": b.get("package_id"),
        "check_in": b.get("check_in"),
        "check_out": b.get("check_out"),
        "start_date": b.get("start_date"),
        "end_date": b.get("end_date"),
        "rooms_booked": b.get("rooms_booked"),
        "number_of_people": b.get("number_of_people"),
        "total_price": b.get("total_price"),
        "status": b.get("status"),
        "guest_note": b.get("guest_note"),
        "payment_method": b.get("payment_method", "KHQR"),
        "payment_status": b.get("payment_status", "pending"),
        "review_note": b.get("review_note"),
        "user_id": b.get("user_id"),
        "created_at": b.get("created_at"),
        "updated_at": b.get("updated_at"),
    }


async def owns_booking_target(user_id: str, booking: dict) -> bool:
    """Does this user own the hotel/package a booking was made against?"""
    if booking.get("hotel_id"):
        hotel = await hotels_collection.find_one({"_id": ObjectId(booking["hotel_id"])})
        return bool(hotel and hotel.get("owner_id") == user_id)
    if booking.get("package_id"):
        package = await packages_collection.find_one({"_id": ObjectId(booking["package_id"])})
        return bool(package and package.get("owner_id") == user_id)
    return False


# ── CREATE (any logged-in user or admin) ────────────────────────────────

@router.post("/hotel")
async def book_hotel(
    payload: HotelBookingCreate,
    current_user: dict = Depends(get_current_user_or_admin),
):
    if not ObjectId.is_valid(payload.hotel_id):
        err("Invalid hotel_id", 400)

    hotel = await hotels_collection.find_one({"_id": ObjectId(payload.hotel_id)})
    if not hotel or hotel.get("status") != "approved":
        err("Hotel not found or not available for booking", 404)

    room_type = next((rt for rt in hotel.get("room_types", []) if rt.get("id") == payload.room_type_id), None)
    if not room_type:
        err("Room type not found on this hotel", 404)

    # Availability: sum rooms already booked by overlapping, non-cancelled bookings
    overlapping = bookings_collection.find({
        "hotel_id": payload.hotel_id,
        "room_type_id": payload.room_type_id,
        "status": {"$in": ACTIVE_STATUSES},
        "check_in": {"$lt": payload.check_out.isoformat()},
        "check_out": {"$gt": payload.check_in.isoformat()},
    })
    already_booked = 0
    async for existing in overlapping:
        already_booked += existing.get("rooms_booked", 0)

    if already_booked + payload.rooms_booked > room_type["total_rooms"]:
        remaining = max(room_type["total_rooms"] - already_booked, 0)
        err(f"Not enough rooms available for those dates (only {remaining} left)", 409)

    nights = (payload.check_out - payload.check_in).days
    total_price = room_type["price_per_night"] * nights * payload.rooms_booked

    now = datetime.utcnow()
    doc = {
        "booking_type": "hotel",
        "hotel_id": payload.hotel_id,
        "room_type_id": payload.room_type_id,
        "check_in": payload.check_in.isoformat(),
        "check_out": payload.check_out.isoformat(),
        "rooms_booked": payload.rooms_booked,
        "number_of_people": payload.number_of_people,   # ← new
        "total_price": total_price,
        "status": "pending",
        "guest_note": payload.guest_note,
        "payment_method": payload.payment_method,
        "payment_status": payload.payment_status,
        "review_note": None,
        "user_id": str(current_user["_id"]),
        "created_at": now,
        "updated_at": now,
    }

    result = await bookings_collection.insert_one(doc)
    new_booking = await bookings_collection.find_one({"_id": result.inserted_id})
    return ok("Hotel booking created — pending confirmation", serialize_booking(new_booking))


@router.post("/package")
async def book_package(
    payload: PackageBookingCreate,
    current_user: dict = Depends(get_current_user_or_admin),
):
    if not ObjectId.is_valid(payload.package_id):
        err("Invalid package_id", 400)

    package = await packages_collection.find_one({"_id": ObjectId(payload.package_id)})
    if not package or package.get("status") != "approved":
        err("Package not found or not available for booking", 404)

    max_people = package.get("max_people")
    if max_people and payload.number_of_people > max_people:
        err(f"This package allows a maximum of {max_people} people per booking", 400)

    end_date = payload.start_date + timedelta(days=package["duration_days"])
    total_price = package["price_per_person"] * payload.number_of_people

    now = datetime.utcnow()
    doc = {
        "booking_type": "package",
        "package_id": payload.package_id,
        "start_date": payload.start_date.isoformat(),
        "end_date": end_date.isoformat(),
        "number_of_people": payload.number_of_people,
        "total_price": total_price,
        "status": "pending",
        "guest_note": payload.guest_note,
        "payment_method": payload.payment_method,
        "payment_status": payload.payment_status,
        "review_note": None,
        "user_id": str(current_user["_id"]),
        "created_at": now,
        "updated_at": now,
    }

    result = await bookings_collection.insert_one(doc)
    new_booking = await bookings_collection.find_one({"_id": result.inserted_id})
    return ok("Package booking created — pending confirmation", serialize_booking(new_booking))


# ── VIEW ─────────────────────────────────────────────────────────────────

@router.get("/mine")
async def get_my_bookings(
    status: Optional[str] = Query(None),
    limit: int = Query(50, ge=1, le=200),
    skip: int = Query(0, ge=0),
    current_user: dict = Depends(get_current_user_or_admin),
):
    query = {"user_id": str(current_user["_id"])}
    if status:
        query["status"] = status

    total = await bookings_collection.count_documents(query)
    cursor = bookings_collection.find(query).sort("created_at", -1).skip(skip).limit(limit)
    bookings = [serialize_booking(b) async for b in cursor]

    return ok("Your bookings fetched successfully", {
        "items": bookings, "total": total, "limit": limit, "skip": skip,
    })


@router.get("/received")
async def get_received_bookings(
    status: Optional[str] = Query(None),
    limit: int = Query(50, ge=1, le=200),
    skip: int = Query(0, ge=0),
    current_user: dict = Depends(require_company_or_admin),
):
    """Bookings made against listings owned by the current company (or all, for admin)."""
    if is_admin(current_user):
        query = {}
    else:
        owner_id = str(current_user["_id"])
        owned_hotel_ids = [
            str(h["_id"]) async for h in hotels_collection.find({"owner_id": owner_id}, {"_id": 1})
        ]
        owned_package_ids = [
            str(p["_id"]) async for p in packages_collection.find({"owner_id": owner_id}, {"_id": 1})
        ]
        query = {"$or": [
            {"hotel_id": {"$in": owned_hotel_ids}},
            {"package_id": {"$in": owned_package_ids}},
        ]}

    if status:
        query["status"] = status

    total = await bookings_collection.count_documents(query)
    cursor = bookings_collection.find(query).sort("created_at", -1).skip(skip).limit(limit)
    bookings = [serialize_booking(b) async for b in cursor]

    return ok("Bookings fetched successfully", {
        "items": bookings, "total": total, "limit": limit, "skip": skip,
    })


@router.get("/{booking_id}")
async def get_booking(
    booking_id: str,
    current_user: dict = Depends(get_current_user_or_admin),
):
    oid = get_object_id(booking_id)
    booking = await bookings_collection.find_one({"_id": oid})
    if not booking:
        err("Booking not found", 404)

    user_id = str(current_user["_id"])
    is_own = booking.get("user_id") == user_id
    if not (is_own or is_admin(current_user) or await owns_booking_target(user_id, booking)):
        err("Booking not found", 404)

    return ok("Booking fetched successfully", serialize_booking(booking))


# ── STATUS UPDATES ───────────────────────────────────────────────────────

@router.put("/{booking_id}/status")
async def update_booking_status(
    booking_id: str,
    payload: BookingStatusUpdate,
    current_user: dict = Depends(get_current_user_or_admin),
):
    oid = get_object_id(booking_id)
    booking = await bookings_collection.find_one({"_id": oid})
    if not booking:
        err("Booking not found", 404)

    user_id = str(current_user["_id"])
    is_own = booking.get("user_id") == user_id
    admin = is_admin(current_user)
    owns_target = await owns_booking_target(user_id, booking)

    if admin or owns_target:
        pass  # admin, or the hotel/package owner, can set any status
    elif is_own and payload.status == "cancelled":
        pass  # a user can always cancel their own booking
    else:
        err("You don't have permission to change this booking's status", 403)

    await bookings_collection.update_one(
        {"_id": oid},
        {"$set": {
            "status": payload.status,
            "review_note": payload.note,
            "updated_at": datetime.utcnow(),
        }},
    )
    updated = await bookings_collection.find_one({"_id": oid})
    return ok("Booking status updated", serialize_booking(updated))


# ── DELETE (admin only) ──────────────────────────────────────────────────

@router.delete("/{booking_id}")
async def delete_booking(
    booking_id: str,
    current_user: dict = Depends(get_current_user_or_admin),
):
    """
    Permanently remove a booking record. Admin-only.

    Regular users and business (hotel/package) owners should use
    PUT /{booking_id}/status with status="cancelled" instead — that keeps
    the record (price, dates, payment trail) for history/reporting/support,
    it just marks it cancelled. This DELETE is a hard delete with no undo,
    reserved for admin cleanup (test data, spam, legal removal requests).
    """
    oid = get_object_id(booking_id)
    booking = await bookings_collection.find_one({"_id": oid})
    if not booking:
        err("Booking not found", 404)

    if not is_admin(current_user):
        err("Only admins can delete a booking. Use status=cancelled to cancel it instead.", 403)

    await bookings_collection.delete_one({"_id": oid})
    return ok("Booking deleted successfully")