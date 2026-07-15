from typing import Optional

from fastapi import APIRouter, Query
from app.db.daatabase import db
from app.routes.places import serialize_place

router = APIRouter(
    prefix="/api/discover",
    tags=["Discover"]
)

@router.get("/home")
async def discover_home(lang: Optional[str] = Query(None)):

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
                serialize_place(p, lang)
                for p in most_search
            ],
            "popular_places": [
                serialize_place(p, lang)
                for p in popular_places
            ]
        }
    }