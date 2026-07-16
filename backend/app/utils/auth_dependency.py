from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from bson import ObjectId
from app.db.daatabase import db
from app.utils.jwt import decode_access_token

security = HTTPBearer()
optional_security = HTTPBearer(auto_error=False)
users_collection = db["users"]
admins_collection = db["admins"]


def is_admin(user: dict) -> bool:
    """Works with both the legacy single 'role' string and the newer 'roles' list,
    as well as an admin-collection user (which carries active_role='admin' but
    has no 'role'/'roles' field of its own)."""
    if user.get("active_role") == "admin":
        return True
    roles = user.get("roles")
    if isinstance(roles, list):
        return "admin" in roles
    return user.get("role") == "admin"


def is_company(user: dict) -> bool:
    """Works with both the legacy single 'role' string and the newer 'roles' list,
    as well as an admin-collection user carrying active_role."""
    if user.get("active_role") == "company":
        return True
    roles = user.get("roles")
    if isinstance(roles, list):
        return "company" in roles
    return user.get("role") == "company"


async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    payload = decode_access_token(token)

    if not payload or "user_id" not in payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )

    user_id = payload["user_id"]
    if not ObjectId.is_valid(user_id):
        raise HTTPException(status_code=401, detail="Invalid user token")

    user = await users_collection.find_one({"_id": ObjectId(user_id)})
    if not user:
        raise HTTPException(status_code=401, detail="User not found")

    # Carry the active_role from the JWT onto the user dict
    # so endpoints can check "which hat" this session is using.
    user["active_role"] = payload.get("active_role")

    return user


async def get_current_user_optional(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(optional_security),
):
    if not credentials:
        return None

    payload = decode_access_token(credentials.credentials)
    if not payload or "user_id" not in payload:
        return None

    user_id = payload["user_id"]
    if not ObjectId.is_valid(user_id):
        return None

    user = await users_collection.find_one({"_id": ObjectId(user_id)})
    if not user:
        return None

    user["active_role"] = payload.get("active_role")
    return user


async def _load_admin_from_payload(payload: dict):
    """Looks up the 'admins' collection for a token issued by
    make_admin_token() (payload has admin_id / type=admin).
    Returns the admin dict (with active_role='admin') or None if the
    payload isn't an admin-shaped token."""
    if payload.get("type") != "admin" or "admin_id" not in payload:
        return None

    admin_id = payload["admin_id"]
    if not ObjectId.is_valid(admin_id):
        raise HTTPException(status_code=401, detail="Invalid admin token")

    admin = await admins_collection.find_one({"_id": ObjectId(admin_id)})
    if not admin:
        raise HTTPException(status_code=401, detail="Admin not found")

    admin["active_role"] = "admin"
    return admin


async def require_admin(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Dependency that only lets admin accounts through. Accepts both an
    admin-collection token (type=admin, from auth_dashboard.py login) and
    a legacy users-collection account whose role/roles include 'admin'."""
    payload = decode_access_token(credentials.credentials)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    admin = await _load_admin_from_payload(payload)
    if admin:
        return admin

    if "user_id" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    current_user = await get_current_user(credentials)
    if not is_admin(current_user):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={"result": False, "message": "Admin access required", "data": {}},
        )
    return current_user


async def require_company_or_admin(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Dependency for endpoints organizations use to submit/manage place
    requests. Accepts an admin-collection token OR a users-collection
    account with the 'company' role."""
    payload = decode_access_token(credentials.credentials)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    admin = await _load_admin_from_payload(payload)
    if admin:
        return admin

    if "user_id" not in payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    current_user = await get_current_user(credentials)
    if not is_company(current_user):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={"result": False, "message": "Organization or admin access required", "data": {}},
        )
    return current_user


'''
security = HTTPBearer()
users_collection = db["users"]


async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    payload = decode_access_token(token)

    if not payload or "user_id" not in payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )

    user_id = payload["user_id"]
    if not ObjectId.is_valid(user_id):
        raise HTTPException(status_code=401, detail="Invalid user token")

    user = await users_collection.find_one({"_id": ObjectId(user_id)})
    if not user:
        raise HTTPException(status_code=401, detail="User not found")

    # Carry the active_role from the JWT onto the user dict
    # so endpoints can check "which hat" this session is using.
    user["active_role"] = payload.get("active_role")

    return user
'''