from typing import List, Literal, Optional

from pydantic import BaseModel, Field


class AiChatMessage(BaseModel):
    role: Literal["user", "model"]
    text: str = Field(..., min_length=1, max_length=4000)


class AiChatSchema(BaseModel):
    message: str = Field(..., min_length=1, max_length=1000)
    history: Optional[List[AiChatMessage]] = Field(default=None, max_length=20)
    lang: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None