from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List, Literal

ListingStatus = Literal["pending", "approved", "rejected"]


class RoomType(BaseModel):
    """A bookable room option within a hotel, e.g. 'Deluxe Twin'."""
    name_en: str = Field(..., min_length=1)
    name_km: str = Field(..., min_length=1)
    description_en: Optional[str] = None
    description_km: Optional[str] = None

    price_per_night: float = Field(..., gt=0)
    capacity: int = Field(..., gt=0, description="Max guests per room")
    total_rooms: int = Field(..., gt=0, description="How many rooms of this type the hotel has")

    image_url: Optional[str] = None
    amenities: Optional[List[str]] = []


class RoomTypeWithId(RoomType):
    id: str


class HotelCreate(BaseModel):
    name_en: str = Field(..., min_length=1)
    name_km: str = Field(..., min_length=1)
    description_en: str = Field(..., min_length=1)
    description_km: str = Field(..., min_length=1)

    province: str
    province_km: Optional[str] = None
    address_en: Optional[str] = None
    address_km: Optional[str] = None

    # Contact info so guests can reach the hotel directly to book/inquire.
    phoneNum: Optional[str] = None
    email: Optional[EmailStr] = None

    star_rating: Optional[float] = Field(None, ge=0, le=5)
    image_url: Optional[str] = None
    images: Optional[List[str]] = []
    amenities: Optional[List[str]] = []

    latitude: Optional[float] = None
    longitude: Optional[float] = None

    room_types: List[RoomType] = Field(..., min_length=1)

    status: ListingStatus = "approved"


class HotelUpdate(BaseModel):
    name_en: Optional[str] = None
    name_km: Optional[str] = None
    description_en: Optional[str] = None
    description_km: Optional[str] = None

    province: Optional[str] = None
    province_km: Optional[str] = None
    address_en: Optional[str] = None
    address_km: Optional[str] = None

    phoneNum: Optional[str] = None
    email: Optional[EmailStr] = None

    star_rating: Optional[float] = Field(None, ge=0, le=5)
    image_url: Optional[str] = None
    images: Optional[List[str]] = None
    amenities: Optional[List[str]] = None

    latitude: Optional[float] = None
    longitude: Optional[float] = None

    room_types: Optional[List[RoomType]] = None

    status: Optional[ListingStatus] = None
    review_note: Optional[str] = None
