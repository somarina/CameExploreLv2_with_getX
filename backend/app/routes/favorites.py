from datetime import datetime

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException

from app.db.daatabase import db
from app.utils.auth_dependency import get_current_user

from app.schemas.favorite_schemas import (
    CreateListSchema,
    RenameListSchema,
    AddFavoriteItemSchema
)

router = APIRouter(
    prefix="/api/favorites",
    tags=["Favorites"]
)

favorite_lists = db["favorite_lists"]
favorite_items = db["favorite_items"]
places_collection = db["places"]


async def _get_owned_list(list_id: str, current_user: dict):
    """Fetch a favorites list and verify it belongs to current_user.
    Raises 404 if it doesn't exist or belongs to someone else — same
    response either way, so we don't leak which list_ids exist."""
    if not ObjectId.is_valid(list_id):
        raise HTTPException(status_code=404, detail="List not found")

    lst = await favorite_lists.find_one({
        "_id": ObjectId(list_id),
        "user_id": str(current_user["_id"]),
    })
    if not lst:
        raise HTTPException(status_code=404, detail="List not found")
    return lst


# ------------------------------------------
@router.post("/lists")
async def create_list(
    payload: CreateListSchema,
    current_user: dict = Depends(get_current_user)
):

    data = {
        "user_id": str(current_user["_id"]),
        "name": payload.name,
        "created_at": datetime.utcnow()
    }

    result = await favorite_lists.insert_one(data)

    return {
        "result": True,
        "message": "List created successfully",
        "list_id": str(result.inserted_id)
    }

# ------------------------------------------
@router.get("/lists")
async def get_lists(
    current_user: dict = Depends(get_current_user)
):

    lists = []

    cursor = favorite_lists.find({
        "user_id": str(current_user["_id"])
    })

    async for item in cursor:
        lists.append({
            "id": str(item["_id"]),
            "name": item["name"]
        })

    return lists

# ------------------------------------------
@router.put("/lists/{list_id}")
async def rename_list(
    list_id: str,
    payload: RenameListSchema,
    current_user: dict = Depends(get_current_user)
):

    await favorite_lists.update_one(
        {
            "_id": ObjectId(list_id),
            "user_id": str(current_user["_id"])
        },
        {
            "$set": {
                "name": payload.name
            }
        }
    )

    return {
        "result": True,
        "message": "List renamed successfully"
    }

# ------------------------------------------
@router.delete("/lists/{list_id}")
async def delete_list(
    list_id: str,
    current_user: dict = Depends(get_current_user)
):

    await favorite_items.delete_many({
        "list_id": list_id
    })

    await favorite_lists.delete_one({
        "_id": ObjectId(list_id),
        "user_id": str(current_user["_id"])
    })

    return {
        "result": True,
        "message": "List deleted successfully"
    }

# ------------------------------------------
@router.post("/lists/{list_id}/items")
async def add_item(
    list_id: str,
    payload: AddFavoriteItemSchema,
    current_user: dict = Depends(get_current_user)
):
    await _get_owned_list(list_id, current_user)

    if not ObjectId.is_valid(payload.place_id):
        raise HTTPException(status_code=404, detail="Place not found")

    place = await places_collection.find_one({
        "_id": ObjectId(payload.place_id)
    })

    if not place:
        raise HTTPException(
            status_code=404,
            detail="Place not found"
        )

    existing = await favorite_items.find_one({
        "list_id": list_id,
        "place_id": payload.place_id
    })

    if existing:
        raise HTTPException(
            status_code=400,
            detail="Place already saved"
        )

    await favorite_items.insert_one({
        "list_id": list_id,
        "place_id": payload.place_id,
        "created_at": datetime.utcnow()
    })

    return {
        "result": True,
        "message": "Place saved successfully"
    }

# ------------------------------------------
@router.get("/lists/{list_id}/items")
async def get_items(
    list_id: str,
    current_user: dict = Depends(get_current_user)
):
    await _get_owned_list(list_id, current_user)

    results = []

    cursor = favorite_items.find({
        "list_id": list_id
    })

    async for item in cursor:

        place = await places_collection.find_one({
            "_id": ObjectId(item["place_id"])
        })

        if place:
            results.append({
                "place_id": str(place["_id"]),
                "name": place.get("name_en") or place.get("name"),
                "province": place.get("province"),
                "category": place.get("category"),
                "image_url": place.get("image_url"),
                "rating": place.get("rating", 0),
                "review_count": place.get("review_count", 0),
                "saved_at": item.get("created_at"),
            })

    return results


@router.delete("/lists/{list_id}/items/{place_id}")
async def delete_item(
    list_id: str,
    place_id: str,
    current_user: dict = Depends(get_current_user)
):
    await _get_owned_list(list_id, current_user)

    await favorite_items.delete_one({
        "list_id": list_id,
        "place_id": place_id
    })

    return {
        "result": True,
        "message": "Place removed successfully"
    }

# ------------------------------------------