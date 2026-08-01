"""
auth_dashboard.py
Dashboard authentication for CamExplore.

IMPORTANT DESIGN CHANGE:
- Admin accounts now live in their own "admins" collection, completely
  separate from the "users" collection (personal/company accounts).
- This means an admin's email/password is fully isolated from any
  personal or company account, even if the same person's email was
  used for both in the past.
- There is still NO public /register/admin route. The very first admin
  is created once via seed_admin.py directly into the "admins" collection.
- Any existing admin can create further admin accounts through the
  protected POST /register/admin route (requires a valid admin token).

Company/personal accounts remain in "users" with a 'roles' array,
exactly as before — unchanged.
"""
import os
import secrets
import smtplib

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from datetime import datetime, timedelta
from fastapi import APIRouter, HTTPException, Depends

from app.db.daatabase import db
# from app.schemas.auth_schemas import RegisterCompanySchema, RegisterSchema, LoginSchema
from app.schemas.auth_schemas import (
    RegisterCompanySchema,
    RegisterSchema,
    LoginSchema,
    AdminForgotPasswordSchema,
    AdminVerifyOtpSchema,
    AdminResetPasswordSchema,
)
from app.utils.jwt import create_access_token, decode_access_token
from app.utils.password import hash_password, verify_password
from app.utils.auth_dependency import get_current_user
from app.utils.admin_dependency import get_current_admin

router = APIRouter(
    prefix="/api/dashboard/auth",
    tags=["Dashboard Authentication"]
)

users_collection = db["users"]
admins_collection = db["admins"]
admin_otp_collection = db["dashboard_admin_otp_codes"]


def ok(message: str, data: dict = None):
    return {"result": True, "message": message, "data": data or {}}


def err(message: str, status_code: int = 400):
    raise HTTPException(
        status_code=status_code,
        detail={"result": False, "message": message, "data": {}}
    )


def serialize_user(doc: dict, token: str = None, role: str = None):
    data = {
        "id": str(doc["_id"]),
        "name": doc.get("name", ""),
        "email": doc.get("email", ""),
        "phone": doc.get("phone", ""),
        "roles": doc.get("roles", [role] if role else []),
        "avatar": doc.get("profile_image", ""),
        "created_at": doc.get("created_at"),
        "updated_at": doc.get("updated_at"),
    }

    if token:
        data["token"] = token
    return data


def make_user_token(user: dict, active_role: str):
    return create_access_token({
        "user_id": str(user["_id"]),
        "email": user.get("email", ""),
        "roles": user.get("roles", []),
        "active_role": active_role,
        "type": "user",
    })


def make_admin_token(admin: dict):
    return create_access_token({
        "admin_id": str(admin["_id"]),
        "email": admin.get("email", ""),
        "type": "admin",
    })

def send_admin_reset_email(to_email: str, otp: str):

    sender = os.getenv("GMAIL_SENDER")
    app_password = os.getenv("GMAIL_APP_PASSWORD")

    if not sender or not app_password:
        return False


    text = f"""
Hello Admin,

We received a request to reset your CamExplore Dashboard password.

Your verification code is:

{otp}

This code expires in 3 minutes.

If you did not request this password reset, please ignore this email.

CamExplore Team
"""


    html = f"""
<!DOCTYPE html>
<html>

<head>
<meta charset="UTF-8">

<style>

body {{
    margin:0;
    padding:40px;
    background:#f4f6f9;
    font-family:Arial,Helvetica,sans-serif;
}}

.wrapper {{
    max-width:520px;
    margin:auto;
    background:white;
    border-radius:18px;
    overflow:hidden;
    box-shadow:0 8px 25px rgba(0,0,0,.08);
}}

.header {{
    background:#009A3F;
    color:white;
    text-align:center;
    padding:35px;
}}

.logo {{
    width:70px;
    height:70px;
    background:white;
    border-radius:50%;
    display:inline-flex;
    align-items:center;
    justify-content:center;
    font-size:32px;
    color:#009A3F;
}}

.content {{
    padding:35px;
}}

.title {{
    font-size:28px;
    font-weight:bold;
    color:#222;
}}

.desc {{
    color:#666;
    line-height:1.7;
}}

.otp-box {{
    margin:30px 0;
    padding:30px;
    background:#eefaf2;
    border-radius:14px;
    border:2px solid #d7f1df;
    text-align:center;
}}

.label {{
    color:#009A3F;
    font-size:13px;
    font-weight:bold;
    letter-spacing:2px;
}}

.otp {{
    margin-top:15px;
    font-size:42px;
    font-weight:bold;
    color:#009A3F;
    letter-spacing:12px;
}}

.warning {{
    background:#FFF8E8;
    border-left:5px solid #F4B400;
    padding:18px;
    border-radius:8px;
    color:#555;
}}

.footer {{
    text-align:center;
    padding:25px;
    color:#888;
    font-size:13px;
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

<h1>
CamExplore
</h1>

<p>
Dashboard Administration
</p>

</div>


<div class="content">


<div class="title">
Admin Password Reset
</div>


<br>


<div class="desc">

Hello Admin,

<br><br>

We received a request to reset your CamExplore Dashboard administrator password.

<br><br>

Use the verification code below to continue.

</div>



<div class="otp-box">

<div class="label">
ADMIN VERIFICATION CODE
</div>


<div class="otp">
{otp}
</div>


</div>



<p>
⏰ This code expires in <b>3 minutes</b>.
</p>


<div class="warning">

<b>Didn't request this?</b>

<br><br>

Ignore this email.

Your administrator password will remain unchanged.

</div>



<br>


<p style="color:#666;">

🔒 Never share this code with anyone.

CamExplore will never ask for your OTP.

</p>


</div>



<div class="footer">

© 2026 CamExplore

<br><br>

Dashboard Security System

</div>



</div>


</body>

</html>
"""


    msg = MIMEMultipart("alternative")

    msg["Subject"] = "CamExplore Admin | Password Reset Code"
    msg["From"] = f"CamExplore <{sender}>"
    msg["To"] = to_email


    msg.attach(
        MIMEText(text, "plain")
    )

    msg.attach(
        MIMEText(html, "html")
    )


    try:

        with smtplib.SMTP_SSL(
            "smtp.gmail.com",
            465
        ) as smtp:

            smtp.login(
                sender,
                app_password
            )

            smtp.sendmail(
                sender,
                to_email,
                msg.as_string()
            )


        return True


    except Exception as e:

        print("ADMIN EMAIL ERROR:", e)

        return False

# ====================== REGISTER PERSONAL ======================
@router.post("/register/personal")
async def register_personal(payload: RegisterSchema):

    email = payload.email.lower()
    existing = await users_collection.find_one({"email": email})

    if payload.password != payload.confirm_password:
        err("Password and confirm password do not match")

    if existing:
        if not existing.get("password") or not verify_password(payload.password, existing["password"]):
            err("This email is already registered. Enter the correct password to add the personal role.")

        if "user" in existing.get("roles", []):
            err("This email is already registered as a personal account")

        await users_collection.update_one(
            {"_id": existing["_id"]},
            {
                "$addToSet": {"roles": "user"},
                "$set": {"updated_at": datetime.utcnow()},
            }
        )
        user = await users_collection.find_one({"_id": existing["_id"]})
        return ok("Personal role added to your account", serialize_user(user, make_user_token(user, "user")))

    now = datetime.utcnow()
    new_user = {
        "name": payload.name,
        "gender": payload.gender,
        "email": email,
        "phone": payload.phone,
        "password": hash_password(payload.password),
        "profile_image": "",
        "roles": ["user"],
        "auth_provider": "email",
        "created_at": now,
        "updated_at": now,
    }

    result = await users_collection.insert_one(new_user)
    user = await users_collection.find_one({"_id": result.inserted_id})

    return ok("Register successful", serialize_user(user, make_user_token(user, "user")))


# ====================== REGISTER COMPANY ======================
@router.post("/register/company")
async def register_company(payload: RegisterCompanySchema):

    email = payload.email.lower()
    existing = await users_collection.find_one({"email": email})

    if payload.password != payload.confirm_password:
        err("Password and confirm password do not match")

    if existing:
        if not existing.get("password") or not verify_password(payload.password, existing["password"]):
            err("This email is already registered. Enter the correct password to add the company role.")

        if "company" in existing.get("roles", []):
            err("This email is already registered as a company account")

        await users_collection.update_one(
            {"_id": existing["_id"]},
            {
                "$addToSet": {"roles": "company"},
                "$set": {
                    "company_verified": existing.get("company_verified", False),
                    "updated_at": datetime.utcnow(),
                },
            }
        )
        user = await users_collection.find_one({"_id": existing["_id"]})
        return ok("Company role added to your account", serialize_user(user, make_user_token(user, "company")))

    now = datetime.utcnow()
    company = {
        "name": payload.name,
        "email": email,
        "phone": payload.phone,
        "business_type": payload.business_type,
        "address": payload.address,
        "password": hash_password(payload.password),
        "profile_image": "",
        "roles": ["company"],
        "company_verified": False,
        "auth_provider": "email",
        "created_at": now,
        "updated_at": now,
    }

    result = await users_collection.insert_one(company)
    user = await users_collection.find_one({"_id": result.inserted_id})

    return ok("Company registered successfully", serialize_user(user, make_user_token(user, "company")))


# ====================== REGISTER ADMIN (admin-only, NEVER public) ======================
@router.post("/register/admin")
async def register_admin(
    payload: RegisterSchema,
    current_admin: dict = Depends(get_current_admin),
):
    """
    Only a currently logged-in admin can call this. There is no way to
    reach this route without already holding a valid admin token, so
    it can never be used to self-register as admin from the outside.
    """
    if payload.password != payload.confirm_password:
        err("Password and confirm password do not match")

    email = payload.email.lower()
    existing = await admins_collection.find_one({"email": email})

    if existing:
        err("This email is already an admin")

    now = datetime.utcnow()
    new_admin = {
        "name": payload.name,
        "email": email,
        "phone": payload.phone,
        "password": hash_password(payload.password),
        "profile_image": "",
        "created_by": str(current_admin["_id"]),
        "created_at": now,
        "updated_at": now,
    }

    result = await admins_collection.insert_one(new_admin)
    admin = await admins_collection.find_one({"_id": result.inserted_id})

    return ok("New admin created successfully", serialize_user(admin, role="admin"))


# ====================== LOGIN ======================
@router.post("/login")
async def login(payload: LoginSchema):

    account = payload.email_or_phone.lower()

    # 1) Check the admins collection FIRST — fully separate from users.
    admin = await admins_collection.find_one({"email": account})
    if admin:
        if not verify_password(payload.password, admin["password"]):
            err("Invalid password")

        token = make_admin_token(admin)
        data = serialize_user(admin, token, role="admin")
        data["active_role"] = "admin"
        data["available_roles"] = ["admin"]
        return ok("Login successful", data)

    # 2) Not an admin -> check users collection for a company role.
    user = await users_collection.find_one({
        "$or": [
            {"email": account},
            {"phone": payload.email_or_phone}
        ]
    })

    if not user:
        err("Account not found", 404)

    if not user.get("password"):
        err("This account uses social login.")

    if not verify_password(payload.password, user["password"]):
        err("Invalid password")

    roles = user.get("roles", [])
    dashboard_roles = [r for r in roles if r == "company"]

    if not dashboard_roles:
        err("This account has no dashboard access", 403)

    active_role = "company"
    token = make_user_token(user, active_role)

    data = serialize_user(user, token)
    data["active_role"] = active_role
    data["available_roles"] = dashboard_roles

    return ok("Login successful", data)

# ====================== ADMIN FORGOT PASSWORD ======================

@router.post("/forgot-password")
async def admin_forgot_password(
    payload: AdminForgotPasswordSchema
):

    email = payload.email.lower()


    admin = await admins_collection.find_one(
        {
            "email": email
        }
    )


    if not admin:
        err(
            "Admin account not found",
            404
        )


    otp = str(
        secrets.randbelow(900000) + 100000
    )


    await admin_otp_collection.delete_many(
        {
            "email": email
        }
    )


    await admin_otp_collection.insert_one(
        {
            "email": email,
            "otp": otp,
            "verified": False,
            "expires_at": datetime.utcnow()
                + timedelta(minutes=3),
            "created_at": datetime.utcnow()
        }
    )


    sent = send_admin_reset_email(
        email,
        otp
    )


    if not sent:
        err(
            "Failed to send OTP",
            500
        )


    return ok(
        "OTP sent successfully"
    )



@router.post("/verify-otp")
async def admin_verify_otp(
    payload: AdminVerifyOtpSchema
):

    otp_data = await admin_otp_collection.find_one(
        {
            "email": payload.email.lower(),
            "otp": payload.otp
        }
    )


    if not otp_data:
        err(
            "Invalid OTP"
        )


    if otp_data["expires_at"] < datetime.utcnow():
        err(
            "OTP expired"
        )


    await admin_otp_collection.update_one(
        {
            "_id": otp_data["_id"]
        },
        {
            "$set":
            {
                "verified": True
            }
        }
    )


    return ok(
        "OTP verified successfully"
    )



@router.post("/reset-password")
async def admin_reset_password(
    payload: AdminResetPasswordSchema
):

    if payload.new_password != payload.confirm_password:
        err(
            "Password and confirm password do not match"
        )


    otp_data = await admin_otp_collection.find_one(
        {
            "email": payload.email.lower(),
            "otp": payload.otp,
            "verified": True
        }
    )


    if not otp_data:
        err(
            "OTP not verified"
        )


    result = await admins_collection.update_one(
        {
            "email": payload.email.lower()
        },
        {
            "$set":
            {
                "password":
                    hash_password(
                        payload.new_password
                    ),
                "updated_at":
                    datetime.utcnow()
            }
        }
    )


    if result.matched_count == 0:
        err(
            "Admin not found",
            404
        )


    await admin_otp_collection.delete_many(
        {
            "email": payload.email.lower()
        }
    )


    return ok(
        "Password reset successful"
    )

# ====================== CHANGE ADMIN PASSWORD ======================
from pydantic import BaseModel

class ChangePasswordSchema(BaseModel):
    current_password: str
    new_password: str
    confirm_password: str


@router.put("/change-password")
async def change_admin_password(
    payload: ChangePasswordSchema,
    current_admin: dict = Depends(get_current_admin),
):
    # Check current password
    if not verify_password(
        payload.current_password,
        current_admin["password"],
    ):
        err("Current password is incorrect")

    # Check confirmation
    if payload.new_password != payload.confirm_password:
        err("Password and confirm password do not match")

    # Prevent same password
    if verify_password(
        payload.new_password,
        current_admin["password"],
    ):
        err("New password cannot be the same as the current password")

    # Update password
    await admins_collection.update_one(
        {"_id": current_admin["_id"]},
        {
            "$set": {
                "password": hash_password(payload.new_password),
                "updated_at": datetime.utcnow(),
            }
        }
    )

    return ok("Password changed successfully")

# ====================== LOGOUT ======================
@router.delete("/logout")
async def logout():
    # Stateless JWTs: nothing to invalidate server-side.
    # Client is responsible for discarding the token.
    return ok("Logout successful")


# ====================== USER DASHBOARD ======================
@router.get("/user")
async def user_dashboard(current_user: dict = Depends(get_current_user)):
    if "user" not in current_user.get("roles", []):
        err("User only", 403)
    return ok("Welcome User", serialize_user(current_user))


# ====================== COMPANY DASHBOARD ======================
@router.get("/company")
async def company_dashboard(current_user: dict = Depends(get_current_user)):
    if "company" not in current_user.get("roles", []):
        err("Company only", 403)
    return ok("Welcome Company", serialize_user(current_user))


# ====================== ADMIN DASHBOARD ======================
@router.get("/admin")
async def admin_dashboard(current_admin: dict = Depends(get_current_admin)):
    return ok("Welcome Admin", serialize_user(current_admin, role="admin"))