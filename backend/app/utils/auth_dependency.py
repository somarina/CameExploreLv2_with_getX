from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from bson import ObjectId
from app.db.daatabase import db
from app.utils.jwt import decode_access_token

security = HTTPBearer()
optional_security = HTTPBearer(auto_error=False)
users_collection = db["users"]


def is_admin(user: dict) -> bool:
    """Works with both the legacy single 'role' string and the newer 'roles' list."""
    roles = user.get("roles")
    if isinstance(roles, list):
        return "admin" in roles
    return user.get("role") == "admin"


def is_company(user: dict) -> bool:
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


async def require_admin(current_user: dict = Depends(get_current_user)):
    """Dependency that only lets 'admin' accounts through."""
    if not is_admin(current_user):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={"result": False, "message": "Admin access required", "data": {}},
        )
    return current_user


async def require_company_or_admin(current_user: dict = Depends(get_current_user)):
    """Dependency for endpoints organizations use to submit/manage place requests."""
    if not (is_company(current_user) or is_admin(current_user)):
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