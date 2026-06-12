from fastapi import APIRouter

from app.db.daatabase import db
from app.routes.search import serialize_place


router = APIRouter(
    prefix="/api/categories",
    tags=["Categories"]
)

@router.get("/")
async def get_categories():

    return {
        "result": True,
        "message": "Categories",
        "data": [
            {
                "name": "Temple",
                "icon": "temple"
            },
            {
                "name": "Museum",
                "icon": "museum"
            },
            {
                "name": "Beach",
                "icon": "beach"
            },
            {
                "name": "Island",
                "icon": "island"
            },
            {
                "name": "Mountain",
                "icon": "mountain"
            },
            {
                "name": "Market",
                "icon": "market"
            }
        ]
    }

@router.get("/nearby")
async def nearby_places():

    places = await db.places.find().limit(20).to_list(20)

    return {
        "result": True,
        "message": "Nearby Places",
        "data": [
            serialize_place(p)
            for p in places
        ]
    }