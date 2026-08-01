from pydantic import BaseModel, Field
from typing import Optional, List


class PlaceReviewCreate(BaseModel):
    rating: int = Field(..., ge=1, le=5)
    comment: str = Field(..., min_length=3)
    images: Optional[List[str]] = []


class PackageReviewCreate(BaseModel):
    rating: int = Field(..., ge=1, le=5)
    comment: str = Field(..., min_length=3)
    images: Optional[List[str]] = []


class HotelReviewCreate(BaseModel):
    rating: int = Field(..., ge=1, le=5)
    cleanliness: int = Field(..., ge=1, le=10)
    location: int = Field(..., ge=1, le=10)
    staff: int = Field(..., ge=1, le=10)
    value: int = Field(..., ge=1, le=10)
    comment: str = Field(..., min_length=3)
    images: Optional[List[str]] = []
    stayed_date: Optional[str] = Field(None, description="e.g. 'April 2026'")
