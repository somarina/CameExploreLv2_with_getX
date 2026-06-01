import hashlib
import hmac
import os
import secrets
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


def ok(message: str, data: dict = None):
    """Standard success response matching teacher's API style."""
    return {
        "result": True,
        "message": message,
        "data": data or {},
    }


def err(message: str, status_code: int = 400):
    """Raise a standard error with teacher's API style."""
    raise HTTPException(
        status_code=status_code,
        detail={
            "result": False,
            "message": message,
            "data": {},
        }
    )


def serialize_user(user: dict, token: str = None) -> dict:
    """Serialize user to match teacher's API data shape."""
    result = {
        "id": str(user["_id"]),
        "name": user.get("name", ""),
        "avatar": user.get("profile_image", ""),
        "email": user.get("email", ""),
        "phone": user.get("phone", ""),
        "gender": user.get("gender", ""),
        "role": user.get("role", "user"),
        "auth_provider": user.get("auth_provider", "email"),
        "created_at": user.get("created_at"),
        "updated_at": user.get("updated_at"),
    }
    if token is not None:
        result["token"] = token
    return result


def make_token(user: dict) -> str:
    return create_access_token({
        "user_id": str(user["_id"]),
        "email": user.get("email", ""),
    })


# ─── Register ────────────────────────────────────────────────────────────────

@router.post("/register", summary="to register new account")
async def register_user(payload: RegisterSchema):
    if payload.password != payload.confirm_password:
        err("Password and confirm password do not match")

    if await users_collection.find_one({"email": payload.email.lower()}):
        err("Email already registered")

    if await users_collection.find_one({"phone": payload.phone}):
        err("Phone number already registered")

    now = datetime.utcnow()
    new_user = {
        "name": payload.name,
        "gender": payload.gender,
        "email": payload.email.lower(),
        "phone": payload.phone,
        "password": hash_password(payload.password),
        "profile_image": "",
        "role": "user",
        "auth_provider": "email",
        "created_at": now,
        "updated_at": now,
    }

    result = await users_collection.insert_one(new_user)
    user = await users_collection.find_one({"_id": result.inserted_id})
    token = make_token(user)
    return ok("Register successful", serialize_user(user, token))


# ─── Login ────────────────────────────────────────────────────────────────────

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
        err("Account not found", 404)

    if not user.get("password"):
        err("This account uses social login. Please login with Google or Telegram.")

    if not verify_password(payload.password, user["password"]):
        err("Invalid password")

    token = make_token(user)
    return ok("Login successful", serialize_user(user, token))


# ─── Google Login ─────────────────────────────────────────────────────────────

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
            "role": "user",
            "auth_provider": "google",
            "created_at": now,
            "updated_at": now,
        }
        result = await users_collection.insert_one(new_user)
        user = await users_collection.find_one({"_id": result.inserted_id})

    token = make_token(user)
    return ok("Google login successful", serialize_user(user, token))


# ─── Telegram Login ───────────────────────────────────────────────────────────

def verify_telegram_payload(data: dict) -> bool:
    bot_token = os.getenv("TELEGRAM_BOT_TOKEN")
    if not bot_token:
        return False

    data = data.copy()
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
    if not verify_telegram_payload(payload.model_dump()):
        err("Invalid Telegram login data", 401)

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
            "role": "user",
            "auth_provider": "telegram",
            "created_at": now,
            "updated_at": now,
        }
        result = await users_collection.insert_one(new_user)
        user = await users_collection.find_one({"_id": result.inserted_id})

    token = make_token(user)
    return ok("Telegram login successful", serialize_user(user, token))


# ─── Forgot Password ──────────────────────────────────────────────────────────

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
        err("Account not found", 404)

    # Use secrets module for cryptographically secure OTP
    otp = str(secrets.randbelow(90000) + 10000)

    await otp_collection.delete_many({"email_or_phone": payload.email_or_phone})
    await otp_collection.delete_many({"email_or_phone": account})

    await otp_collection.insert_one({
        "email_or_phone": payload.email_or_phone,
        "otp": otp,
        "expires_at": datetime.utcnow() + timedelta(minutes=5),
        "verified": False,
        "created_at": datetime.utcnow(),
    })

    # TODO: replace dev_otp with real Email/SMS sender before production
    return ok("OTP sent successfully", {
        "dev_otp": otp,
        "expires_in_minutes": 5,
    })


# ─── Verify OTP ───────────────────────────────────────────────────────────────

@router.post("/verify-otp", summary="to verify OTP code")
async def verify_otp(payload: VerifyOtpSchema):
    otp_data = await otp_collection.find_one({
        "email_or_phone": payload.email_or_phone,
        "otp": payload.otp,
    })

    if not otp_data:
        err("Invalid OTP")

    if otp_data["expires_at"] < datetime.utcnow():
        err("OTP expired")

    await otp_collection.update_one(
        {"_id": otp_data["_id"]},
        {"$set": {"verified": True}}
    )

    return ok("OTP verified successfully")


# ─── Reset Password ───────────────────────────────────────────────────────────

@router.post("/reset-password", summary="to reset password")
async def reset_password(payload: ResetPasswordSchema):
    if payload.new_password != payload.confirm_password:
        err("Password and confirm password do not match")

    otp_data = await otp_collection.find_one({
        "email_or_phone": payload.email_or_phone,
        "otp": payload.otp,
        "verified": True,
    })

    if not otp_data:
        err("OTP not verified")

    if otp_data["expires_at"] < datetime.utcnow():
        err("OTP expired")

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
        err("Account not found", 404)

    await otp_collection.delete_many({"email_or_phone": payload.email_or_phone})

    return ok("Password reset successfully")


# ─── Logout ───────────────────────────────────────────────────────────────────

@router.delete("/logout", summary="to logout from system")
async def logout(current_user: dict = Depends(get_current_user)):
    # Stateless JWT: client should discard the token.
    # For true invalidation, add a token blacklist collection.
    return ok("Logout successful")
