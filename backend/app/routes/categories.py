from math import radians, sin, cos, sqrt, atan2
from typing import Optional

from fastapi import APIRouter, Query

from app.data.provinces import PROVINCES
from app.db.daatabase import db
from app.routes.places import serialize_place

router = APIRouter(prefix="/api/categories", tags=["Categories"])

places_collection = db["places"]

# Matches the icon row in the Discover screen. 'icon' is just a key —
# map it to whatever icon asset your Flutter app uses for that name.
CATEGORIES = [
    {"name": "Temple", "name_km": "ប្រាសាទ", "icon": "temple"},
    {"name": "Beach", "name_km": "ឆ្នេរសមុទ្រ", "icon": "beach"},
    {"name": "Nature", "name_km": "ធម្មជាតិ", "icon": "nature"},
    {"name": "City", "name_km": "ទីក្រុង", "icon": "city"},
    {"name": "Food", "name_km": "អាហារ", "icon": "food"},
    {"name": "Market", "name_km": "ផ្សារ", "icon": "market"},
    {"name": "Museum", "name_km": "សារមន្ទីរ", "icon": "museum"},
    {"name": "Waterfall", "name_km": "ទឹកជ្រោះ", "icon": "waterfall"},
]


def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371.0  # Earth radius in km
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat / 2) ** 2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon / 2) ** 2
    return R * (2 * atan2(sqrt(a), sqrt(1 - a)))


@router.get("/")
async def get_categories():
    """List every category with a live count of approved places in it."""
    data = []
    for cat in CATEGORIES:
        count = await places_collection.count_documents({
            "category": {"$regex": f"^{cat['name']}$", "$options": "i"},
            "status": "approved",
        })
        data.append({**cat, "place_count": count})

    return {"result": True, "message": "Categories fetched successfully", "data": data}


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

    return {
        "result": True,
        "message": "Nearby provinces fetched successfully",
        "data": {
            "items": results,
            "radius_km": results[-1]["distance_km"] if results and "distance_km" in results[0] else None,
            "total_activities": sum(r["activity_count"] for r in results),
        },
    }


# NOTE: this dynamic route must stay LAST — FastAPI matches routes in
# declaration order, so static paths like "/nearby" above have to be
# declared before this one, or they'd get swallowed as a category name.
@router.get("/{category_name}")
async def get_places_by_category(
    category_name: str,
    lang: Optional[str] = Query(None, description="'en' or 'km'"),
    province: Optional[str] = Query(None),
    limit: int = Query(50, ge=1, le=200),
    skip: int = Query(0, ge=0),
):
    """Tap a category tile -> get every approved place under it."""
    query = {
        "category": {"$regex": f"^{category_name}$", "$options": "i"},
        "status": "approved",
    }
    if province:
        query["province"] = {"$regex": f"^{province}$", "$options": "i"}

    total = await places_collection.count_documents(query)
    cursor = places_collection.find(query).skip(skip).limit(limit)
    places = [serialize_place(p, lang) async for p in cursor]

    return {
        "result": True,
        "message": f"Places in '{category_name}' fetched successfully",
        "data": {"items": places, "total": total, "limit": limit, "skip": skip},
    }
