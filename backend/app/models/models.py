from pydantic import BaseModel, Field
from typing import Optional, List, Literal

PlaceStatus = Literal["pending", "approved", "rejected"]


class PlaceCreate(BaseModel):
    # Bilingual content (Cambodia tourism app -> English + Khmer required)
    name_en: str = Field(..., min_length=1, description="Place name in English")
    name_km: str = Field(..., min_length=1, description="Place name in Khmer")
    description_en: str = Field(..., min_length=1, description="Description in English")
    description_km: str = Field(..., min_length=1, description="Description in Khmer")

    province: str
    province_km: Optional[str] = None
    category: str
    category_km: Optional[str] = None

    address_en: Optional[str] = None
    address_km: Optional[str] = None

    image_url: Optional[str] = None
    images: Optional[List[str]] = []

    latitude: Optional[float] = None
    longitude: Optional[float] = None
    opening_hours: Optional[str] = None
    entry_fee: Optional[str] = None
    tags: Optional[List[str]] = []

    # Ignored/overridden server-side for company submissions (always forced
    # to "pending"). Only admins creating a place directly can set this.
    status: PlaceStatus = "approved"
    rating: Optional[float] = 0
    status: str = "approved"
    phoneNum: str
    rating_star: Optional[float] = None
    rating_star: Optional[float] = 0
    status: str = "approved"
    phoneNum: str

class PlaceUpdate(BaseModel):
    name_en: Optional[str] = None
    name_km: Optional[str] = None
    description_en: Optional[str] = None
    description_km: Optional[str] = None

    province: Optional[str] = None
    province_km: Optional[str] = None
    category: Optional[str] = None
    category_km: Optional[str] = None

    address_en: Optional[str] = None
    address_km: Optional[str] = None

    image_url: Optional[str] = None
    images: Optional[List[str]] = None

    latitude: Optional[float] = None
    longitude: Optional[float] = None

    opening_hours: Optional[str] = None
    entry_fee: Optional[str] = None
    tags: Optional[List[str]] = None

    status: Optional[PlaceStatus] = None
    # Admin-only: short note explaining an approval/rejection decision.
    review_note: Optional[str] = None



# from pydantic import BaseModel
# from typing import Optional

# class PlaceCreate(BaseModel):
#     name: str
#     description: str
#     province: str
#     category: str
#     image_url: Optional[str] = None
#     latitude: Optional[float] = None
#     longitude: Optional[float] = None
#     status: str = "approved"

# class PlaceUpdate(BaseModel):
#     name: Optional[str] = None
#     description: Optional[str] = None
#     province: Optional[str] = None
#     category: Optional[str] = None
#     image_url: Optional[str] = None
#     latitude: Optional[float] = None
#     longitude: Optional[float] = None
#     status: Optional[str] = None
    rating: Optional[float] = None
    status: Optional[str] = None
    status: Optional[str] = None
    phoneNum: Optional[str] = None
