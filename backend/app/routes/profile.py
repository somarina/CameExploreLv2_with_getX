from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException

from app.db.daatabase import db
from app.schemas.auth_schemas import EditProfileSchema, ChangePasswordSchema
from app.utils.auth_dependency import get_current_user
from app.utils.password import hash_password, verify_password

router = APIRouter(
    prefix="/api/profile",
    tags=["Profile"]
)

users_collection = db["users"]


def serialize_user(user: dict):
    return {
        "id": str(user["_id"]),
        "name": user.get("name", ""),
        "gender": user.get("gender", ""),
        "email": user.get("email", ""),
        "phone": user.get("phone", ""),
        "profile_image": user.get("profile_image", ""),
        "auth_provider": user.get("auth_provider", "email"),
        "created_at": user.get("created_at"),
        "updated_at": user.get("updated_at"),
    }


@router.get("/me", summary="to get my own profile")
async def get_my_profile(
    current_user: dict = Depends(get_current_user)
):
    return serialize_user(current_user)


@router.put("/info", summary="to update profile info")
async def update_profile_info(
    payload: EditProfileSchema,
    current_user: dict = Depends(get_current_user),
):
    update_data = {}

    if payload.name is not None:
        update_data["name"] = payload.name

    if payload.gender is not None:
        update_data["gender"] = payload.gender

    if payload.profile_image is not None:
        update_data["profile_image"] = payload.profile_image

    if payload.email is not None:
        email = payload.email.lower()

        existing_email = await users_collection.find_one({
            "email": email,
            "_id": {"$ne": current_user["_id"]}
        })

        if existing_email:
            raise HTTPException(
                status_code=400,
                detail="Email already used"
            )

        update_data["email"] = email

    if payload.phone is not None:
        existing_phone = await users_collection.find_one({
            "phone": payload.phone,
            "_id": {"$ne": current_user["_id"]}
        })

        if existing_phone:
            raise HTTPException(
                status_code=400,
                detail="Phone already used"
            )

        update_data["phone"] = payload.phone

    if not update_data:
        return serialize_user(current_user)

    update_data["updated_at"] = datetime.utcnow()

    await users_collection.update_one(
        {"_id": current_user["_id"]},
        {"$set": update_data},
    )

    updated_user = await users_collection.find_one({
        "_id": current_user["_id"]
    })

    return serialize_user(updated_user)


@router.put("/change-password", summary="to update password")
async def change_password(
    payload: ChangePasswordSchema,
    current_user: dict = Depends(get_current_user),
):
    if not current_user.get("password"):
        raise HTTPException(
            status_code=400,
            detail="Social login account has no password"
        )

    if not verify_password(
        payload.current_password,
        current_user["password"]
    ):
        raise HTTPException(
            status_code=400,
            detail="Current password is incorrect"
        )

    if payload.new_password != payload.confirm_password:
        raise HTTPException(
            status_code=400,
            detail="Password and confirm password do not match"
        )

    await users_collection.update_one(
        {"_id": current_user["_id"]},
        {
            "$set": {
                "password": hash_password(payload.new_password),
                "updated_at": datetime.utcnow(),
            }
        },
    )

    return {
        "message": "Password changed successfully"
    }


@router.put("/avatar", summary="to update profile avatar")
async def update_avatar(
    payload: EditProfileSchema,
    current_user: dict = Depends(get_current_user),
):
    if payload.profile_image is None:
        raise HTTPException(
            status_code=400,
            detail="Profile image is required"
        )

    await users_collection.update_one(
        {"_id": current_user["_id"]},
        {
            "$set": {
                "profile_image": payload.profile_image,
                "updated_at": datetime.utcnow(),
            }
        },
    )

    updated_user = await users_collection.find_one({
        "_id": current_user["_id"]
    })

    return serialize_user(updated_user)


@router.delete("/avatar", summary="to delete profile avatar")
async def delete_avatar(
    current_user: dict = Depends(get_current_user)
):
    await users_collection.update_one(
        {"_id": current_user["_id"]},
        {
            "$set": {
                "profile_image": "",
                "updated_at": datetime.utcnow(),
            }
        },
    )

    updated_user = await users_collection.find_one({
        "_id": current_user["_id"]
    })

    return serialize_user(updated_user)