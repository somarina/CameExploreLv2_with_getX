from datetime import datetime

from fastapi import APIRouter, Depends

from app.db.daatabase import db
from app.schemas.review_schemas import ReviewCreate
from app.utils.auth_dependency import get_current_user

router = APIRouter(
    prefix="/api/reviews",
    tags=["Feedback"],
)

reviews_collection = db["app_reviews"]

def serialize_review(review: dict):
    return {
        "id": str(review["_id"]),
        "user_id": review.get("user_id"),
        "rating": review.get("rating"),
        "review_type": review.get("review_type"),
        "name": review.get("name"),
        "email": review.get("email"),
        "comment": review.get("comment"),
        "created_at": review.get("created_at"),
    }

@router.post("/create", summary="to write app feedback")
async def create_review(
    payload: ReviewCreate,
    current_user: dict = Depends(get_current_user),
):
    review = {
        "user_id": str(current_user["_id"]),
        "rating": payload.rating,
        "review_type": payload.review_type,
        "name": payload.name,
        "email": payload.email.lower(),
        "comment": payload.comment,
        "created_at": datetime.utcnow(),
    }

    result = await reviews_collection.insert_one(review)

    created_review = await reviews_collection.find_one({
        "_id": result.inserted_id
    })

    return serialize_review(created_review)


@router.get("/all", summary="to get all app feedback")
async def get_all_reviews():
    reviews = []

    cursor = reviews_collection.find().sort("created_at", -1)

    async for review in cursor:
        reviews.append(serialize_review(review))

    return reviews