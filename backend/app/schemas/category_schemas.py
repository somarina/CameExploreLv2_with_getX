from typing import Optional
from pydantic import BaseModel, Field


class CategoryCreate(BaseModel):
    name: str = Field(..., min_length=1, description="English display name, e.g. 'Waterpark'")
    name_km: str = Field(..., min_length=1, description="Khmer display name")
    icon: Optional[str] = Field(
        None,
        description="Local Flutter asset key fallback (e.g. 'waterpark'). "
                     "Defaults to the lowercased name if omitted.",
    )


class CategoryUpdate(BaseModel):
    name: Optional[str] = None
    name_km: Optional[str] = None
    icon: Optional[str] = None
