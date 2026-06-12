from fastapi import APIRouter
from app.db.daatabase import db

router = APIRouter(
    prefix="/api/discover",
    tags=["Discover"]
)

def serialize_place(place):
    return {
        "id": str(place["_id"]),
        "name": place.get("name"),
        "province": place.get("province"),
        "category": place.get("category"),
        "rating": place.get("rating", 0),
        "image_url": place.get("image_url"),
        "search_count": place.get("search_count", 0),
    }

@router.get("/home")
async def discover_home():

    most_search = await db.places.find().sort(
        "search_count", -1
    ).limit(5).to_list(5)

    popular_places = await db.places.find().sort(
        "rating", -1
    ).limit(10).to_list(10)

    return {
        "result": True,
        "message": "Discover Home",
        "data": {
            "most_search": [
                serialize_place(p)
                for p in most_search
            ],
            "popular_places": [
                serialize_place(p)
                for p in popular_places
            ]
        }
    }