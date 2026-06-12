from typing import Optional, Literal
from pydantic import BaseModel, EmailStr, Field, field_validator
import re


class RegisterSchema(BaseModel):
    name: str
    gender: str
    email: EmailStr
    phone: str

    password: str = Field(..., min_length=8, max_length=72)
    confirm_password: str = Field(..., min_length=8, max_length=72)

    @field_validator("password")
    @classmethod
    def validate_password(cls, value):

        # at least 1 number
        if not re.search(r"\d", value):
            raise ValueError(
                "Password must contain at least 1 number"
            )

        # at least 2 letters
        letters = re.findall(r"[a-zA-Z]", value)

        if len(letters) < 2:
            raise ValueError(
                "Password must contain at least 2 letters"
            )

        return value


class LoginSchema(BaseModel):
    email_or_phone: str
    password: str


class GoogleLoginSchema(BaseModel):
    google_id: str
    name: str
    email: EmailStr
    profile_image: Optional[str] = ""


class TelegramLoginSchema(BaseModel):
    id: int
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    username: Optional[str] = None
    photo_url: Optional[str] = None
    auth_date: int
    hash: str


class ForgotPasswordSchema(BaseModel):
    email: EmailStr

class VerifyOtpSchema(BaseModel):
    email: EmailStr
    otp: str = Field(min_length=6, max_length=6)


class ResetPasswordSchema(BaseModel):
    email: EmailStr
    otp: str = Field(min_length=6, max_length=6)
    new_password: str = Field(min_length=6)
    confirm_password: str = Field(min_length=6)


class EditProfileSchema(BaseModel):
    profile_image: Optional[str] = None
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    gender: Optional[str] = None


class ChangePasswordSchema(BaseModel):
    current_password: str
    new_password: str = Field(min_length=6)
    confirm_password: str = Field(min_length=6)
