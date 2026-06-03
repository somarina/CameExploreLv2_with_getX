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

import smtplib
from email.mime.text import MIMEText
import httpx
from twilio.rest import Client  # Added for SMS

router = APIRouter(
    prefix="/api/auth",
    tags=["Authentication"]
)

users_collection = db["users"]
otp_collection = db["otp_codes"]
otp_attempts_collection = db["otp_attempts"]  # Rate limiting

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


# ====================== RATE LIMITING ======================
async def check_otp_rate_limit(identifier: str) -> None:
    """Prevent abuse: max 3 OTPs per 10 minutes, 5 per hour"""
    now = datetime.utcnow()
    window_10min = now - timedelta(minutes=10)
    window_1hour = now - timedelta(hours=1)

    recent_attempts = await otp_attempts_collection.count_documents({
        "identifier": identifier.lower(),
        "created_at": {"$gte": window_10min}
    })

    if recent_attempts >= 3:
        err("Too many OTP requests. Please try again in 10 minutes.", 429)

    hour_attempts = await otp_attempts_collection.count_documents({
        "identifier": identifier.lower(),
        "created_at": {"$gte": window_1hour}
    })

    if hour_attempts >= 5:
        err("Too many OTP requests. Please try again later.", 429)


async def cleanup_old_attempts():
    """Clean up old rate limit records (older than 1 day)"""
    try:
        one_day_ago = datetime.utcnow() - timedelta(days=1)
        result = await otp_attempts_collection.delete_many({
            "created_at": {"$lt": one_day_ago}
        })
        print(f"🧹 Cleaned up {result.deleted_count} old OTP attempt records")
    except Exception as e:
        print(f"Cleanup failed: {e}")


# ====================== SEND OTP HELPERS ======================
async def send_otp_telegram(telegram_id: str, otp: str):
    bot_token = os.getenv("TELEGRAM_BOT_TOKEN")
    if not bot_token:
        return False
    message = f"""🔐 *CamExplore OTP*

                Your verification code is: `{otp}`

                ⏰ This code expires in 3 minutes.
                Do not share this code with anyone."""
    
    url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    async with httpx.AsyncClient() as client:
        res = await client.post(url, json={
            "chat_id": telegram_id,
            "text": message,
            "parse_mode": "Markdown",
        })
    return res.status_code == 200


def send_otp_email(to_email: str, otp: str):
    sender = os.getenv("GMAIL_SENDER")
    app_password = os.getenv("GMAIL_APP_PASSWORD")
    if not sender or not app_password:
        return False
    
    body = f"""Your CamExplore OTP code is: {otp}

This code expires in 3 minutes. Do not share it with anyone."""
    
    msg = MIMEText(body)
    msg["Subject"] = "CamExplore - Password Reset OTP"
    msg["From"] = sender
    msg["To"] = to_email
    
    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as smtp:
            smtp.login(sender, app_password)
            smtp.sendmail(sender, to_email, msg.as_string())
        return True
    except Exception as e:
        print(f"Email send failed: {e}")
        return False


# def send_otp_sms(phone: str, otp: str):
#     """Send OTP via Twilio SMS"""
#     account_sid = os.getenv("TWILIO_ACCOUNT_SID")
#     auth_token = os.getenv("TWILIO_AUTH_TOKEN")
#     twilio_phone = os.getenv("TWILIO_PHONE_NUMBER")

#     if not all([account_sid, auth_token, twilio_phone]):
#         return False

#     try:
#         client = Client(account_sid, auth_token)
#         message = client.messages.create(
#             body=f"Your CamExplore OTP is: {otp}. Expires in 5 minutes.",
#             from_=twilio_phone,
#             to=phone
#         )
#         return True
#     except Exception as e:
#         print(f"Twilio SMS failed: {e}")
#         return False


# ====================== MAIN ROUTES ======================

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


# ====================== FORGOT PASSWORD (NOW SUPPORTS PHONE PROPERLY) ======================
# @router.post("/forgot-password", summary="to request OTP for password reset")
# async def forgot_password(payload: ForgotPasswordSchema):
#     account = payload.email_or_phone.lower()

#     user = await users_collection.find_one({
#         "$or": [
#             {"email": account},
#             {"phone": payload.email_or_phone},
#         ]
#     })

#     if not user:
#         err("Account not found", 404)

#     # Rate Limiting
#     await check_otp_rate_limit(account)

#     otp = str(secrets.randbelow(900000) + 100000)

#     # Clean old OTPs
#     await otp_collection.delete_many({"email_or_phone": payload.email_or_phone})
#     await otp_collection.delete_many({"email_or_phone": account})

#     # Save new OTP
#     await otp_collection.insert_one({
#         "email_or_phone": payload.email_or_phone,
#         "otp": otp,
#         "expires_at": datetime.utcnow() + timedelta(minutes=5),
#         "verified": False,
#         "created_at": datetime.utcnow(),
#     })

#     # Record attempt
#     await otp_attempts_collection.insert_one({
#         "identifier": account,
#         "created_at": datetime.utcnow()
#     })

#     sent = False
#     channel = "unknown"
#     is_email = "@" in payload.email_or_phone

#     if is_email:
#         sent = send_otp_email(user.get("email", ""), otp)
#         channel = "email"
#     # else:
#     #     # Phone number - Try SMS first
#     #     phone = payload.email_or_phone
#     #     if phone.startswith("0"):
#     #         phone = "+855" + phone[1:]  # Convert Cambodian 0XX to +855XX

#     #     sent = send_otp_sms(phone, otp)
#     #     channel = "sms"

#     #     # Fallback to Telegram if SMS not configured or failed
#     #     if not sent:
#     #         telegram_id = user.get("telegram_id")
#     #         if telegram_id:
#     #             sent = await send_otp_telegram(telegram_id, otp)
#     #             channel = "telegram"
#     else:
#         email = user.get("email")

#         if not email:
#             err(
#                 "This account has no email address linked."
#             )

#     sent = send_otp_email(email, otp)
#     channel = "email"
#     if not sent:
#         err("Failed to send OTP. Please try again later.")

#     return ok(f"OTP sent via {channel}", {
#         "channel": channel,
#         "message": f"Check your {channel} for the verification code"
#     })

@router.post("/forgot-password", summary="to request OTP for password reset")
async def forgot_password(payload: ForgotPasswordSchema):
    try:
        email = payload.email.strip().lower()

        # Find user
        user = await users_collection.find_one({
            "email": email
        })

        if not user:
            err("Account not found", 404)

        # Rate limiting
        await check_otp_rate_limit(email)

        # Generate OTP
        otp = str(secrets.randbelow(900000) + 100000)

        # Delete old OTPs
        await otp_collection.delete_many({
            "email": email
        })

        # Save new OTP
        await otp_collection.insert_one({
            "email": email,
            "otp": otp,
            "expires_at": datetime.utcnow() + timedelta(minutes=3),
            "verified": False,
            "created_at": datetime.utcnow(),
        })

        # Record request for rate limiting
        await otp_attempts_collection.insert_one({
            "identifier": email,
            "created_at": datetime.utcnow()
        })

        # Send email
        sent = send_otp_email(email, otp)

        if not sent:
            err(
                "Failed to send OTP. Check GMAIL_SENDER and GMAIL_APP_PASSWORD",
                500
            )

        return ok(
            "OTP sent successfully",
            {
                "channel": "email",
                "message": "Check your email for the verification code"
            }
        )

    except HTTPException:
        raise

    except Exception as e:
        print("FORGOT PASSWORD ERROR:", str(e))
        raise HTTPException(
            status_code=500,
            detail=f"Internal error: {str(e)}"
        )
    
@router.post("/verify-otp", summary="to verify OTP code")
async def verify_otp(payload: VerifyOtpSchema):
    otp_data = await otp_collection.find_one({
        "email": payload.email.lower(),
        "otp": payload.otp,
    })

    if not otp_data:
        err("Invalid OTP")

    if otp_data["expires_at"] < datetime.utcnow():
        err("OTP has expired")

    await otp_collection.update_one(
        {"_id": otp_data["_id"]},
        {"$set": {"verified": True}}
    )

    return ok("OTP verified successfully")

@router.post("/reset-password", summary="to reset password")
async def reset_password(payload: ResetPasswordSchema):
    if payload.new_password != payload.confirm_password:
        err("Password and confirm password do not match")

    otp_data = await otp_collection.find_one({
        "email": payload.email.lower(),
        "otp": payload.otp,
        "verified": True,
    })

    if not otp_data:
        err("OTP not verified or invalid")

    if otp_data["expires_at"] < datetime.utcnow():
        err("OTP has expired")

    email = payload.email.strip().lower()

    result = await users_collection.update_one(
        {"email": email},
        {
            "$set": {
                "password": hash_password(payload.new_password),
                "updated_at": datetime.utcnow(),
            }
        }
    )

    if result.matched_count == 0:
        err("Account not found", 404)

    await otp_collection.delete_many({
        "email": payload.email.lower()
    })

    return ok("Password reset successful")


@router.delete("/logout", summary="to logout from system")
async def logout(current_user: dict = Depends(get_current_user)):
    return ok("Logout successful")


# Helper function for Telegram verification
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