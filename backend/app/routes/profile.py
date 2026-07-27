from datetime import datetime

from fastapi import APIRouter, Depends

from app.db.daatabase import db
from app.schemas.auth_schemas import EditProfileSchema, ChangePasswordSchema
from app.utils.auth_dependency import get_current_user
from app.utils.password import hash_password, verify_password
from fastapi import UploadFile, File
import cloudinary.uploader

from app.config.cloudinary_config import *

from app.utils.logger import (
    log_success,
    log_error,
    log_info,
    log_upload
)

router = APIRouter(
    prefix="/api/profile",
    tags=["Profile"]
)

users_collection = db["users"]

def ok(message: str, data=None):
    return {
        "result": True,
        "message": message,
        "data": data or {},
    }

def err(message: str, status_code: int = 400):
    from fastapi import HTTPException
    raise HTTPException(
        status_code=status_code,
        detail={
            "result": False,
            "message": message,
            "data": {},
        }
    )

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


# ====================== MAIN ROUTES ======================
@router.get("/me", summary="to get my own profile")
async def get_my_profile(
    current_user: dict = Depends(get_current_user)
):
    return ok("Profile fetched successfully", serialize_user(current_user))


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

        if await users_collection.find_one({"email": email, "_id": {"$ne": current_user["_id"]}}):
            err("Email already used")

        update_data["email"] = email

    if payload.phone is not None and payload.phone.strip() != "":
        if await users_collection.find_one({"phone": payload.phone, "_id": {"$ne": current_user["_id"]}}):
            err("Phone already used")

        update_data["phone"] = payload.phone

    if not update_data:
        return ok("Nothing to update", serialize_user(current_user))

    update_data["updated_at"] = datetime.utcnow()

    await users_collection.update_one(
        {"_id": current_user["_id"]},
        {"$set": update_data},
    )

    updated_user = await users_collection.find_one({"_id": current_user["_id"]})
    return ok("Profile updated successfully", serialize_user(updated_user))


@router.put("/change-password", summary="to update password")
async def change_password(
    payload: ChangePasswordSchema,
    current_user: dict = Depends(get_current_user),
):
    if not current_user.get("password"):
        err("Social login account has no password")

    if not verify_password(payload.current_password, current_user["password"]):
        err("Current password is incorrect")

    if payload.new_password != payload.confirm_password:
        err("Password and confirm password do not match")

    await users_collection.update_one(
        {"_id": current_user["_id"]},
        {"$set": {
            "password": hash_password(payload.new_password),
            "updated_at": datetime.utcnow(),
        }},
    )

    return ok("Password changed successfully")


@router.post("/avatar/upload", summary="Upload profile avatar")
async def upload_avatar(
    file: UploadFile = File(...),
    current_user: dict = Depends(get_current_user),
):
    try:
        # print("===== UPLOAD AVATAR =====")
        # print("USER ID:", current_user["_id"])
        # print("FILE:", file.filename)

        log_info("Avatar Upload Started")

        log_info(
            f"User ID: {current_user['_id']}"
        )

        log_upload(file.filename)


        result = cloudinary.uploader.upload(
            file.file,
            folder="camexplore/profile"
        )

        image_url = result["secure_url"]

        log_success(
            f"Cloudinary Upload Success\n{image_url}"
        )

        log_info("CLOUDINARY RESULT:")
        log_info(result)

        image_url = result["secure_url"]

        await users_collection.update_one(
            {"_id": current_user["_id"]},
            {
                "$set": {
                    "profile_image": image_url,
                    "updated_at": datetime.utcnow(),
                }
            }
        )

        log_success(
            "MongoDB Profile Updated"
        )

        updated_user = await users_collection.find_one(
            {"_id": current_user["_id"]}
        )

        return ok(
            "Avatar uploaded successfully",
            serialize_user(updated_user)
        )

    except Exception as e:
        print("UPLOAD ERROR:", str(e))
        err(str(e), 500)
    # return {
    #     "result": True,
    #     "message": "Avatar uploaded successfully",
    #     "data": serialize_user(updated_user)
    # }

@router.delete("/avatar", summary="to delete profile avatar")
async def delete_avatar(
    current_user: dict = Depends(get_current_user)
):
    await users_collection.update_one(
        {"_id": current_user["_id"]},
        {"$set": {
            "profile_image": "",
            "updated_at": datetime.utcnow(),
        }},
    )

    updated_user = await users_collection.find_one({"_id": current_user["_id"]})
    return ok("Avatar deleted successfully", serialize_user(updated_user))