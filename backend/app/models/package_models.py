from pydantic import BaseModel, Field
from typing import Optional, List, Literal

ListingStatus = Literal["pending", "approved", "rejected"]


class ItineraryItem(BaseModel):
    """One stop within a package's day-by-day plan, linking a real Place or Hotel."""
    day: int = Field(..., ge=1, description="Day number within the package, starting at 1")
    place_id: Optional[str] = None
    hotel_id: Optional[str] = None
    room_type_id: Optional[str] = Field(None, description="Which room type at hotel_id, if relevant")
    note_en: Optional[str] = None
    note_km: Optional[str] = None


class PackageCreate(BaseModel):
    name_en: str = Field(..., min_length=1)
    name_km: str = Field(..., min_length=1)
    description_en: str = Field(..., min_length=1)
    description_km: str = Field(..., min_length=1)

    duration_days: int = Field(..., gt=0)
    price_per_person: float = Field(..., gt=0)
    max_people: Optional[int] = Field(None, gt=0, description="Group size cap per booking, if any")

    image_url: Optional[str] = None
    images: Optional[List[str]] = []
    tags: Optional[List[str]] = []

    itinerary: List[ItineraryItem] = Field(..., min_length=1)

    status: ListingStatus = "approved"


class PackageUpdate(BaseModel):
    name_en: Optional[str] = None
    name_km: Optional[str] = None
    description_en: Optional[str] = None
    description_km: Optional[str] = None

    duration_days: Optional[int] = Field(None, gt=0)
    price_per_person: Optional[float] = Field(None, gt=0)
    max_people: Optional[int] = Field(None, gt=0)

    image_url: Optional[str] = None
    images: Optional[List[str]] = None
    tags: Optional[List[str]] = None

    itinerary: Optional[List[ItineraryItem]] = None

    status: Optional[ListingStatus] = None
    review_note: Optional[str] = None