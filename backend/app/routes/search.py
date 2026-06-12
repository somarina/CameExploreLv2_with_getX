from fastapi import APIRouter, Query
from app.db.daatabase import db

router = APIRouter(
    prefix="/api/search",
    tags=["Search"]
)


def serialize_place(place):
    return {
        "id": str(place["_id"]),
        "name": place.get("name"),
        "description": place.get("description"),
        "province": place.get("province"),
        "category": place.get("category"),
        "image_url": place.get("image_url"),
        "latitude": place.get("latitude"),
        "longitude": place.get("longitude"),
        "status": place.get("status", "approved"),
    }


@router.get("/")
async def search_places(
    keyword: str = Query(...)
):
    print(f"🔍 SEARCH KEYWORD: {keyword}")

    query = {
    "$or": [
        {"name": {"$regex": keyword, "$options": "i"}},
        {"description": {"$regex": keyword, "$options": "i"}},
        {"province": {"$regex": keyword, "$options": "i"}},
        {"category": {"$regex": keyword, "$options": "i"}},
        {"tags": {"$regex": keyword, "$options": "i"}}
    ]
}
    places = await db.places.find(query).to_list(20)

    return {
        "result": True,
        "message": "Search success",
        "data": [
            serialize_place(place)
            for place in places
        ]
    }


@router.get("/popular")
async def popular_places():

    places = await db.places.find().limit(10).to_list(10)

    return {
        "result": True,
        "message": "Popular places",
        "data": [
            serialize_place(place)
            for place in places
        ]
    }