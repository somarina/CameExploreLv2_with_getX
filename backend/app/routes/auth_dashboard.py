"""
auth_dashboard.py
Dashboard authentication for CamExplore.
Designed to follow the style of auth.py.

NOTE:
- Uses 'roles' (list) instead of single 'role' string.
- One email = one identity, can hold multiple roles (user, company, admin).
- Adding a new role to an existing email requires correct password.
"""

from datetime import datetime
from fastapi import APIRouter, HTTPException, Depends

from app.db.daatabase import db
from app.schemas.auth_schemas import RegisterSchema, LoginSchema
from app.utils.jwt import create_access_token
from app.utils.password import hash_password, verify_password
from app.utils.auth_dependency import get_current_user

router = APIRouter(
    prefix="/api/dashboard/auth",
    tags=["Dashboard Authentication"]
)

users_collection = db["users"]


def ok(message: str, data: dict = None):
    return {"result": True, "message": message, "data": data or {}}


def err(message: str, status_code: int = 400):
    raise HTTPException(
        status_code=status_code,
        detail={"result": False, "message": message, "data": {}}
    )


def serialize_user(user: dict, token: str = None):
    data = {
        "id": str(user["_id"]),
        "name": user.get("name", ""),
        "email": user.get("email", ""),
        "phone": user.get("phone", ""),
        "roles": user.get("roles", []),
        "avatar": user.get("profile_image", ""),
        "created_at": user.get("created_at"),
        "updated_at": user.get("updated_at"),
    }

    if token:
        data["token"] = token
    return data


def make_token(user: dict, active_role: str = None):
    roles = user.get("roles", [])
    return create_access_token({
        "user_id": str(user["_id"]),
        "email": user.get("email", ""),
        "roles": roles,
        "active_role": active_role or (roles[0] if roles else "user"),
    })


# ====================== REGISTER PERSONAL ======================
@router.post("/register/personal")
async def register_personal(payload: RegisterSchema):

    email = payload.email.lower()
    existing = await users_collection.find_one({"email": email})

    if payload.password != payload.confirm_password:
        err("Password and confirm password do not match")

    if existing:
        # Email already exists -> verify ownership before adding a role
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
        return ok("Personal role added to your account", serialize_user(user, make_token(user, "user")))

    # No existing account -> create new
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

    return ok("Register successful", serialize_user(user, make_token(user, "user")))


# ====================== REGISTER COMPANY ======================
@router.post("/register/company")
async def register_company(payload: RegisterSchema):

    email = payload.email.lower()
    existing = await users_collection.find_one({"email": email})

    if payload.password != payload.confirm_password:
        err("Password and confirm password do not match")

    if existing:
        # Email already exists -> verify ownership before adding a role
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
        return ok("Company role added to your account", serialize_user(user, make_token(user, "company")))

    # No existing account -> create new
    now = datetime.utcnow()
    company = {
        "name": payload.name,
        "gender": payload.gender,
        "email": email,
        "phone": payload.phone,
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

    return ok("Company registered successfully", serialize_user(user, make_token(user, "company")))


# ====================== LOGIN ======================
@router.post("/login")
async def login(payload: LoginSchema):

    account = payload.email_or_phone.lower()

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

    # Dashboard is only for company/admin roles
    dashboard_roles = [r for r in roles if r in ("company", "admin")]

    if not dashboard_roles:
        err("This account has no dashboard access", 403)

    # If user has both company and admin, default to admin; otherwise pick the only one
    active_role = "admin" if "admin" in dashboard_roles else dashboard_roles[0]

    token = make_token(user, active_role)

    data = serialize_user(user, token)
    data["active_role"] = active_role
    data["available_roles"] = dashboard_roles

    return ok("Login successful", data)


# ====================== LOGOUT ======================

@router.delete("/logout")
async def logout(current_user: dict = Depends(get_current_user)):
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
async def admin_dashboard(current_user: dict = Depends(get_current_user)):

    if "admin" not in current_user.get("roles", []):
        err("Admin only", 403)

    return ok("Welcome Admin", serialize_user(current_user))