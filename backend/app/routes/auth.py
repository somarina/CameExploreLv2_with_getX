import hashlib
import hmac
import os
import random
import time
from datetime import datetime, timedelta
from typing import Optional

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException
from app.db.daatabase import db
from app.schemas.auth_schemas import (
    RegisterSchema,
    LoginSchema,
    GoogleLoginSchema,
    TelegramLoginSchema,
    ForgotPasswordSchema,
    VerifyOtpSchema,
    ResetPasswordSchema,
    EditProfileSchema,
    ChangePasswordSchema,
)
from app.utils.auth_dependency import get_current_user
from app.utils.jwt import create_access_token
from app.utils.password import hash_password, verify_password

router = APIRouter(
    prefix="/api/auth",
    tags=["Authentication"]
)

users_collection = db["users"]
otp_collection = db["otp_codes"]


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


def auth_response(user: dict, message: str):
    token = create_access_token({
        "user_id": str(user["_id"]),
        "email": user.get("email", ""),
    })
    return {
        "message": message,
        "access_token": token,
        "token_type": "bearer",
        "user": serialize_user(user),
    }


@router.post("/register", summary="to register new account")
async def register_user(payload: RegisterSchema):
    if payload.password != payload.confirm_password:
        raise HTTPException(status_code=400, detail="Password and confirm password do not match")

    if await users_collection.find_one({"email": payload.email.lower()}):
        raise HTTPException(status_code=400, detail="Email already registered")

    if await users_collection.find_one({"phone": payload.phone}):
        raise HTTPException(status_code=400, detail="Phone number already registered")

    now = datetime.utcnow()
    new_user = {
        "name": payload.name,
        "gender": payload.gender,
        "email": payload.email.lower(),
        "phone": payload.phone,
        "password": hash_password(payload.password),
        "profile_image": "",
        "auth_provider": "email",
        "created_at": now,
        "updated_at": now,
    }

    result = await users_collection.insert_one(new_user)
    user = await users_collection.find_one({"_id": result.inserted_id})
    return auth_response(user, "Register successful")


@router.post("/login", summary="to login into system")
async def login_user(payload: LoginSchema):
    account = payload.email_or_phone.lower()

    user = await users_collection.find_one({
        "$or": [
            {"email": account},
            {"phone": payload.email_or_phone},
        ]
    })

    if not user:
        raise HTTPException(status_code=404, detail="Account not found")

    if not user.get("password"):
        raise HTTPException(status_code=400, detail="This account uses social login")

    if not verify_password(payload.password, user["password"]):
        raise HTTPException(status_code=400, detail="Invalid password")

    return auth_response(user, "Login successful")


@router.post("/google-login", summary="to login with Google")
async def google_login(payload: GoogleLoginSchema):
    user = await users_collection.find_one({"google_id": payload.google_id})

    if not user:
        user = await users_collection.find_one({"email": payload.email.lower()})

    now = datetime.utcnow()

    if user:
        await users_collection.update_one(
            {"_id": user["_id"]},
            {"$set": {
                "google_id": payload.google_id,
                "name": payload.name or user.get("name", ""),
                "profile_image": payload.profile_image or user.get("profile_image", ""),
                "auth_provider": "google",
                "updated_at": now,
            }}
        )
        user = await users_collection.find_one({"_id": user["_id"]})
    else:
        new_user = {
            "name": payload.name,
            "gender": "",
            "email": payload.email.lower(),
            "phone": "",
            "password": None,
            "profile_image": payload.profile_image or "",
            "google_id": payload.google_id,
            "auth_provider": "google",
            "created_at": now,
            "updated_at": now,
        }
        result = await users_collection.insert_one(new_user)
        user = await users_collection.find_one({"_id": result.inserted_id})

    return auth_response(user, "Google login successful")


def verify_telegram_payload(data: dict) -> bool:
    bot_token = os.getenv("TELEGRAM_BOT_TOKEN")
    if not bot_token:
        return False

    received_hash = data.pop("hash", None)
    if not received_hash:
        return False

    data_check_string = "\n".join(
        f"{key}={value}"
        for key, value in sorted(data.items())
        if value is not None
    )

    secret_key = hashlib.sha256(bot_token.encode()).digest()
    calculated_hash = hmac.new(
        secret_key,
        data_check_string.encode(),
        hashlib.sha256,
    ).hexdigest()

    if not hmac.compare_digest(calculated_hash, received_hash):
        return False

    if time.time() - int(data.get("auth_date", 0)) > 86400:
        return False

    return True


@router.post("/telegram-login", summary="to login with Telegram")
async def telegram_login(payload: TelegramLoginSchema):
    data = payload.model_dump()
    if not verify_telegram_payload(data.copy()):
        raise HTTPException(status_code=401, detail="Invalid Telegram login data")

    telegram_id = str(payload.id)
    user = await users_collection.find_one({"telegram_id": telegram_id})
    now = datetime.utcnow()

    full_name = " ".join(filter(None, [payload.first_name, payload.last_name])).strip()
    name = full_name or payload.username or f"Telegram {telegram_id}"

    if user:
        await users_collection.update_one(
            {"_id": user["_id"]},
            {"$set": {
                "name": name,
                "profile_image": payload.photo_url or user.get("profile_image", ""),
                "telegram_username": payload.username,
                "auth_provider": "telegram",
                "updated_at": now,
            }}
        )
        user = await users_collection.find_one({"_id": user["_id"]})
    else:
        new_user = {
            "name": name,
            "gender": "",
            "email": "",
            "phone": "",
            "password": None,
            "profile_image": payload.photo_url or "",
            "telegram_id": telegram_id,
            "telegram_username": payload.username,
            "auth_provider": "telegram",
            "created_at": now,
            "updated_at": now,
        }
        result = await users_collection.insert_one(new_user)
        user = await users_collection.find_one({"_id": result.inserted_id})

    return auth_response(user, "Telegram login successful")


@router.post("/forgot-password", summary="to request OTP for password reset")
async def forgot_password(payload: ForgotPasswordSchema):
    account = payload.email_or_phone.lower()

    user = await users_collection.find_one({
        "$or": [
            {"email": account},
            {"phone": payload.email_or_phone},
        ]
    })

    if not user:
        raise HTTPException(status_code=404, detail="Account not found")

    otp = str(random.randint(10000, 99999))

    await otp_collection.delete_many({"email_or_phone": payload.email_or_phone})
    await otp_collection.delete_many({"email_or_phone": account})

    await otp_collection.insert_one({
        "email_or_phone": payload.email_or_phone,
        "otp": otp,
        "expires_at": datetime.utcnow() + timedelta(minutes=5),
        "verified": False,
        "created_at": datetime.utcnow(),
    })

    # For Swagger/testing. Later replace with real Email/SMS sender.
    return {
        "message": "OTP sent successfully",
        "dev_otp": otp,
        "expires_in_minutes": 5,
    }


@router.post("/verify-otp", summary="to verify OTP code")
async def verify_otp(payload: VerifyOtpSchema):
    otp_data = await otp_collection.find_one({
        "email_or_phone": payload.email_or_phone,
        "otp": payload.otp,
    })

    if not otp_data:
        raise HTTPException(status_code=400, detail="Invalid OTP")

    if otp_data["expires_at"] < datetime.utcnow():
        raise HTTPException(status_code=400, detail="OTP expired")

    await otp_collection.update_one(
        {"_id": otp_data["_id"]},
        {"$set": {"verified": True}}
    )

    return {"message": "OTP verified successfully"}


@router.post("/reset-password", summary="to reset password")
async def reset_password(payload: ResetPasswordSchema):
    if payload.new_password != payload.confirm_password:
        raise HTTPException(status_code=400, detail="Password and confirm password do not match")

    otp_data = await otp_collection.find_one({
        "email_or_phone": payload.email_or_phone,
        "otp": payload.otp,
        "verified": True,
    })

    if not otp_data:
        raise HTTPException(status_code=400, detail="OTP not verified")

    if otp_data["expires_at"] < datetime.utcnow():
        raise HTTPException(status_code=400, detail="OTP expired")

    account = payload.email_or_phone.lower()

    result = await users_collection.update_one(
        {
            "$or": [
                {"email": account},
                {"phone": payload.email_or_phone},
            ]
        },
        {"$set": {
            "password": hash_password(payload.new_password),
            "updated_at": datetime.utcnow(),
        }}
    )

    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Account not found")

    await otp_collection.delete_many({"email_or_phone": payload.email_or_phone})

    return {"message": "Password reset successfully"}

@router.delete(
    "/logout",
    summary="to logout from system"
)
async def logout():
    return {
        "message": "Logout successful"
    }