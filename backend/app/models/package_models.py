from pydantic import BaseModel, Field
from typing import Optional, List, Literal

ListingStatus = Literal["pending", "approved", "rejected"]


class ItineraryItem(BaseModel):
    """One stop within a package's day-by-day plan.

    Stops are free-standing (title/description you type in) — they don't
    have to already exist as a Place. If a stop *does* correspond to a real
    Place or Hotel in your catalog, you can still link it via place_id /
    hotel_id (e.g. to show a map pin or the hotel's photos), but it's
    optional either way.
    """
    day: int = Field(..., ge=1, description="Day number within the package, starting at 1")

    title_en: str = Field(..., min_length=1, description="Stop name, e.g. 'Angkor Wat Sunrise'")
    title_km: Optional[str] = None

    stop_type: Literal["main", "other"] = Field(
        "other", description="'main' shows a pin icon, 'other' shows a plain dot — matches the app's itinerary legend"
    )

    note_en: Optional[str] = Field(None, description="Description shown under the stop title")
    note_km: Optional[str] = None

    pickup_locations: Optional[List[str]] = Field(
        None, description="Only set on pickup-type stops, e.g. ['Krong Siem Reap', 'Krong Siem Reap']"
    )

    transport_mode: Optional[str] = Field(
        None, description="How you get to THIS stop from the previous one, e.g. 'Bus/coach', 'Walking', 'Boat'"
    )
    transport_duration_minutes: Optional[int] = Field(
        None, gt=0, description="Travel time to this stop from the previous one, in minutes"
    )

    # Optional links to your existing catalog — leave blank for a stop that
    # isn't (yet) one of your listed Places/Hotels.
    place_id: Optional[str] = None
    hotel_id: Optional[str] = None
    room_type_id: Optional[str] = Field(None, description="Which room type at hotel_id, if relevant")


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
    review_count: Optional[int] = Field(0, ge=0)


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
    review_count: Optional[int] = Field(None, ge=0)