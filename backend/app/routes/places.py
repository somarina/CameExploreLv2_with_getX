from fastapi import APIRouter, HTTPException
from bson import ObjectId
from app.db.daatabase import db
from app.models.models import PlaceCreate, PlaceUpdate

router = APIRouter(prefix="/places", tags=["Places"])

def serialize_place(place):
    return {
        "id": str(place["_id"]),
        "name": place["name"],
        "description": place["description"],
        "province": place["province"],
        "category": place["category"],
        "image_url": place.get("image_url"),
        "latitude": place.get("latitude"),
        "longitude": place.get("longitude"),
        "status": place.get("status", "approved"),
        "rating": place.get("rating", 0),
        "phoneNum": place.get("phoneNum"),
    }

@router.post("/")
async def create_place(place: PlaceCreate):
    result = await db.places.insert_one(place.model_dump())
    new_place = await db.places.find_one({"_id": result.inserted_id})
    return serialize_place(new_place)

@router.get("/")
async def get_places():
    places = []
    cursor = db.places.find()
    async for place in cursor:
        places.append(serialize_place(place))
    return places

@router.get("/{place_id}")
async def get_place(place_id: str):
    if not ObjectId.is_valid(place_id):
        raise HTTPException(status_code=400, detail="Invalid place ID")

    place = await db.places.find_one({"_id": ObjectId(place_id)})

    if not place:
        raise HTTPException(status_code=404, detail="Place not found")

    return serialize_place(place)

@router.put("/{place_id}")
async def update_place(place_id: str, place: PlaceUpdate):
    if not ObjectId.is_valid(place_id):
        raise HTTPException(status_code=400, detail="Invalid place ID")

    update_data = {
        key: value
        for key, value in place.model_dump().items()
        if value is not None
    }

    await db.places.update_one(
        {"_id": ObjectId(place_id)},
        {"$set": update_data}
    )

    updated_place = await db.places.find_one({"_id": ObjectId(place_id)})

    if not updated_place:
        raise HTTPException(status_code=404, detail="Place not found")

    return serialize_place(updated_place)

@router.delete("/{place_id}")
async def delete_place(place_id: str):
    if not ObjectId.is_valid(place_id):
        raise HTTPException(status_code=400, detail="Invalid place ID")

    result = await db.places.delete_one({"_id": ObjectId(place_id)})

    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Place not found")

    return {"message": "Place deleted successfully"}