import hashlib
import hmac
import os
import secrets
import time
from datetime import datetime, timedelta
from typing import Optional

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import RedirectResponse
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

import resend

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import httpx
from twilio.rest import Client

router = APIRouter(
    prefix="/api/auth",
    tags=["Authentication"]
)

users_collection = db["users"]
otp_collection = db["otp_codes"]
otp_attempts_collection = db["otp_attempts"]

resend.api_key = os.getenv("RESEND_API_KEY")

def ok(message: str, data: dict = None):
    return {
        "result": True,
        "message": message,
        "data": data or {},
    }


def err(message: str, status_code: int = 400):
    raise HTTPException(
        status_code=status_code,
        detail={
            "result": False,
            "message": message,
            "data": {},
        }
    )


def serialize_user(user: dict, token: str = None) -> dict:
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

# //////////////////////////////////////////////
# def send_otp_email(to_email: str, otp: str):

#     html = f"""
#     <html>

#     <body style="background:#f5f5f5;font-family:Arial;padding:40px;">

#         <div style="
#             max-width:520px;
#             margin:auto;
#             background:white;
#             border-radius:16px;
#             overflow:hidden;
#             box-shadow:0 8px 30px rgba(0,0,0,.08);
#         ">

#             <div style="
#                 background:#009A3F;
#                 color:white;
#                 text-align:center;
#                 padding:40px;
#             ">

#                 <h1>CamExplore</h1>

#                 <p>Explore Cambodia with confidence</p>

#             </div>

#             <div style="padding:35px;">

#                 <h2>Password Reset</h2>

#                 <p>
#                 We received a request to reset your password.
#                 </p>

#                 <div style="
#                     background:#EEF8F2;
#                     padding:25px;
#                     border-radius:12px;
#                     text-align:center;
#                     margin:30px 0;
#                 ">

#                     <div
#                     style="
#                     color:#009A3F;
#                     font-size:42px;
#                     font-weight:bold;
#                     letter-spacing:12px;
#                     ">
#                         {otp}
#                     </div>

#                 </div>

#                 <p>

#                 This code expires in
#                 <b>3 minutes</b>.

#                 </p>

#                 <p>

#                 Never share this code with anyone.

#                 </p>

#             </div>

#         </div>

#     </body>

#     </html>
#     """

#     try:

#         resend.Emails.send({

#             "from": "CamExplore <onboarding@resend.dev>",

#             "to": [to_email],

#             "subject": "CamExplore | Password Reset Code",

#             "html": html

#         })

#         return True

#     except Exception as e:

#         print(e)

#         return False

def send_otp_email(to_email: str, otp: str):
    sender = os.getenv("GMAIL_SENDER")
    app_password = os.getenv("GMAIL_APP_PASSWORD")

    if not sender or not app_password:
        return False

    text = f"""
        Hello,

        Your CamExplore verification code is:

        {otp}

        This code expires in 3 minutes.

        If you didn't request this, you can safely ignore this email.

        CamExplore Team
        """

    html = f"""
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <style>

        body{{
            margin:0;
            padding:40px;
            background:#f4f6f9;
            font-family:Arial,Helvetica,sans-serif;
        }}

        .wrapper{{
            max-width:520px;
            margin:auto;
            background:#ffffff;
            border-radius:18px;
            overflow:hidden;
            box-shadow:0 8px 25px rgba(0,0,0,.08);
        }}

        .header{{
            background:#009A3F;
            color:white;
            padding:35px;
            text-align:center;
        }}

        .logo{{
            width:70px;
            height:70px;
            border-radius:50%;
            background:white;
            color:#009A3F;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            font-size:34px;
            font-weight:bold;
            margin-bottom:15px;
        }}

        .content{{
            padding:35px;
        }}

        .title{{
            font-size:28px;
            color:#222;
            margin-bottom:10px;
        }}

        .desc{{
            color:#666;
            line-height:1.7;
        }}

        .otp-box{{
            margin:35px 0;
            background:#eefaf2;
            border:2px solid #d7f1df;
            border-radius:14px;
            text-align:center;
            padding:30px;
        }}

        .otp-label{{
            color:#009A3F;
            font-size:13px;
            font-weight:bold;
            letter-spacing:2px;
        }}

        .otp{{
            font-size:42px;
            font-weight:bold;
            color:#009A3F;
            letter-spacing:12px;
            margin-top:12px;
        }}

        .warning{{
            background:#FFF8E8;
            border-left:5px solid #F4B400;
            padding:18px;
            border-radius:8px;
            color:#555;
            margin-top:25px;
        }}

        .footer{{
            text-align:center;
            color:#888;
            font-size:13px;
            padding:25px;
            border-top:1px solid #eee;
        }}

        </style>
        </head>

        <body>

        <div class="wrapper">

        <div class="header">

        <div class="logo">
        🌿
        </div>

        <h1 style="margin:0;">
        CamExplore
        </h1>

        <p style="margin-top:8px;">
        Explore Cambodia with confidence
        </p>

        </div>

        <div class="content">

        <div class="title">
        Password Reset
        </div>

        <div class="desc">

        Hello,

        <br><br>

        We received a request to reset your CamExplore password.

        <br><br>

        Use the verification code below to continue.

        </div>

        <div class="otp-box">

        <div class="otp-label">
        YOUR VERIFICATION CODE
        </div>

        <div class="otp">
        {otp}
        </div>

        </div>

        <p>

        ⏰ This code expires in <b>3 minutes</b>.

        </p>

        <div class="warning">

        <b>Didn't request this?</b><br><br>

        You can safely ignore this email.

        Your password will remain unchanged.

        </div>

        <p style="margin-top:30px;color:#666;">

        🔒 Never share this code with anyone.

        CamExplore will never ask for your OTP.

        </p>

        </div>

        <div class="footer">

        © 2026 CamExplore

        <br><br>

        Need help?

        <a href="mailto:camexplore.app.kh@gmail.com"
        style="color:#009A3F;text-decoration:none;">

        Contact Support

        </a>

        </div>

        </div>

        </body>
        </html>
    """

    msg = MIMEMultipart("alternative")

    msg["Subject"] = "CamExplore | Password Reset Code"
    # msg["From"] = sender
    msg["From"] = f"CamExplore <{sender}>"
    msg["To"] = to_email

    msg.attach(MIMEText(text, "plain"))
    msg.attach(MIMEText(html, "html"))

    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as smtp:
            smtp.login(sender, app_password)
            smtp.sendmail(sender, to_email, msg.as_string())

        return True

    except Exception as e:
        print("Email send failed:", e)
        return False

# def send_otp_email(to_email: str, otp: str):
#     sender = os.getenv("GMAIL_SENDER")
#     app_password = os.getenv("GMAIL_APP_PASSWORD")
#     if not sender or not app_password:
#         return False
#     body = f"""Your CamExplore OTP code is: {otp}
# This code expires in 3 minutes. Do not share it with anyone."""
#     msg = MIMEText(body)
#     msg["Subject"] = "CamExplore - Password Reset OTP"
#     msg["From"] = sender
#     msg["To"] = to_email
#     try:
#         with smtplib.SMTP_SSL("smtp.gmail.com", 465) as smtp:
#             smtp.login(sender, app_password)
#             smtp.sendmail(sender, to_email, msg.as_string())
#         return True
#     except Exception as e:
#         print(f"Email send failed: {e}")
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


# ====================== TELEGRAM CALLBACK (bridge for deep link) ======================
@router.get("/telegram-callback", summary="Telegram OAuth callback bridge")
async def telegram_callback(request: Request):
    params = dict(request.query_params)
    query_string = "&".join(f"{k}={v}" for k, v in params.items())
    deep_link = f"camexplore://telegram-login?{query_string}"
    print(f"📲 Telegram callback → redirecting to: {deep_link}")
    return RedirectResponse(
        url=deep_link,
        headers={"ngrok-skip-browser-warning": "true"},  # ← add this
    )

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


@router.post("/forgot-password", summary="to request OTP for password reset")
async def forgot_password(payload: ForgotPasswordSchema):
    try:
        email = payload.email.strip().lower()

        user = await users_collection.find_one({"email": email})

        if not user:
            err("Account not found", 404)

        await check_otp_rate_limit(email)

        otp = str(secrets.randbelow(900000) + 100000)

        await otp_collection.delete_many({"email": email})

        await otp_collection.insert_one({
            "email": email,
            "otp": otp,
            "expires_at": datetime.utcnow() + timedelta(minutes=3),
            "verified": False,
            "created_at": datetime.utcnow(),
        })

        await otp_attempts_collection.insert_one({
            "identifier": email,
            "created_at": datetime.utcnow()
        })

        sent = send_otp_email(email, otp)

        if not sent:
            err("Failed to send OTP. Check GMAIL_SENDER and GMAIL_APP_PASSWORD", 500)

        return ok("OTP sent successfully", {
            "channel": "email",
            "message": "Check your email for the verification code"
        })

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

    await otp_collection.delete_many({"email": payload.email.lower()})

    return ok("Password reset successful")


@router.delete("/logout", summary="to logout from system")
async def logout(current_user: dict = Depends(get_current_user)):
    return ok("Logout successful")


# ====================== TELEGRAM HASH VERIFICATION ======================
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