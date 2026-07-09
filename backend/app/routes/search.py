from typing import Optional

from fastapi import APIRouter, Query

from app.db.daatabase import db
from app.routes.places import serialize_place
from app.routes.hotels import serialize_hotel
from app.routes.packages import serialize_package

router = APIRouter(prefix="/api/search", tags=["Search"])

places_collection = db["places"]
hotels_collection = db["hotels"]
packages_collection = db["packages"]


def keyword_query(keyword: str, fields: list[str]) -> dict:
    return {
        "$and": [
            {"status": "approved"},
            {"$or": [{f: {"$regex": keyword, "$options": "i"}} for f in fields]},
        ]
    }


PLACE_SEARCH_FIELDS = [
    "name_en", "name_km", "description_en", "description_km",
    "province", "province_km", "category", "category_km", "tags",
]
HOTEL_SEARCH_FIELDS = [
    "name_en", "name_km", "description_en", "description_km",
    "province", "province_km", "amenities",
]
PACKAGE_SEARCH_FIELDS = [
    "name_en", "name_km", "description_en", "description_km", "tags",
]


@router.get("/")
async def search_all(
    keyword: str = Query(..., min_length=1),
    lang: Optional[str] = Query(None, description="'en' or 'km'"),
    type: Optional[str] = Query(None, description="Filter to one type: place | hotel | package"),
    limit: int = Query(20, ge=1, le=100, description="Max results per type"),
):
    results = {}

    if type in (None, "place"):
        cursor = places_collection.find(keyword_query(keyword, PLACE_SEARCH_FIELDS)).limit(limit)
        results["places"] = [serialize_place(p, lang) async for p in cursor]

    if type in (None, "hotel"):
        cursor = hotels_collection.find(keyword_query(keyword, HOTEL_SEARCH_FIELDS)).limit(limit)
        results["hotels"] = [serialize_hotel(h, lang) async for h in cursor]

    if type in (None, "package"):
        cursor = packages_collection.find(keyword_query(keyword, PACKAGE_SEARCH_FIELDS)).limit(limit)
        results["packages"] = [serialize_package(p, lang) async for p in cursor]

    total = sum(len(v) for v in results.values())

    return {
        "result": True,
        "message": "Search success" if total else "No results found",
        "data": results,
    }


@router.get("/popular")
async def popular_places(
    lang: Optional[str] = Query(None),
    limit: int = Query(10, ge=1, le=50),
):
    """Ranked by search_count then rating — actual popularity, not insertion order."""
    cursor = (
        places_collection.find({"status": "approved"})
        .sort([("search_count", -1), ("rating", -1)])
        .limit(limit)
    )
    places = [serialize_place(p, lang) async for p in cursor]

    return {
        "result": True,
        "message": "Popular places",
        "data": places,
    }
