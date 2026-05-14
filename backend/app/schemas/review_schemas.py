from pydantic import BaseModel, EmailStr, Field


class ReviewCreate(BaseModel):
    rating: int = Field(ge=1, le=5)
    review_type: str
    name: str
    email: EmailStr
    comment: str = Field(min_length=3)
