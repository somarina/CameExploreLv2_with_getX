from datetime import date
from pydantic import BaseModel, Field, model_validator
from typing import Optional, Literal

BookingStatus = Literal["pending", "confirmed", "cancelled", "completed"]


class HotelBookingCreate(BaseModel):
    booking_type: Literal["hotel"] = "hotel"
    hotel_id: str
    room_type_id: str
    check_in: date
    check_out: date
    rooms_booked: int = Field(1, gt=0)
    number_of_people: int = Field(1, gt=0)   # ← new
    guest_note: Optional[str] = None

    @model_validator(mode="after")
    def check_dates(self):
        if self.check_out <= self.check_in:
            raise ValueError("check_out must be after check_in")
        return self


class PackageBookingCreate(BaseModel):
    booking_type: Literal["package"] = "package"
    package_id: str
    start_date: date
    number_of_people: int = Field(1, gt=0)
    guest_note: Optional[str] = None


class BookingStatusUpdate(BaseModel):
    status: BookingStatus
    note: Optional[str] = None
