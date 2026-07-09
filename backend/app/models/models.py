from pydantic import BaseModel
from typing import Optional

class PlaceCreate(BaseModel):
    name: str
    description: str
    province: str
    category: str
    image_url: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    status: str = "approved"
    rating_star: Optional[float] = None
    rating_star: Optional[float] = 0
    status: str = "approved"
    phoneNum: str
       

class PlaceUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    province: Optional[str] = None
    category: Optional[str] = None
    image_url: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    status: Optional[str] = None
    status: Optional[str] = None
    phoneNum: Optional[str] = None