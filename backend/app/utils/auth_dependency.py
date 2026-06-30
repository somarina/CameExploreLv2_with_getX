from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from bson import ObjectId
from app.db.daatabase import db
from app.utils.jwt import decode_access_token

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