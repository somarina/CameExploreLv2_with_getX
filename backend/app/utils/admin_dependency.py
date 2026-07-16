from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from bson import ObjectId
from app.db.daatabase import db
from app.utils.jwt import decode_access_token

security = HTTPBearer()
admins_collection = db["admins"]


async def get_current_admin(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    payload = decode_access_token(token)

    if not payload or payload.get("type") != "admin" or "admin_id" not in payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired admin token",
        )

    admin_id = payload["admin_id"]
    if not ObjectId.is_valid(admin_id):
        raise HTTPException(status_code=401, detail="Invalid admin token")

    admin = await admins_collection.find_one({"_id": ObjectId(admin_id)})
    if not admin:
        raise HTTPException(status_code=401, detail="Admin not found")

    return admin