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

from datetime import datetime
from fastapi import APIRouter, HTTPException, Depends

from app.db.daatabase import db
from app.schemas.auth_schemas import RegisterCompanySchema, RegisterSchema, LoginSchema
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