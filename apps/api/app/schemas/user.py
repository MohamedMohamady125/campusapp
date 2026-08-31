"""User contracts (spec §4.1 Users)."""

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field

from app.models.enums import UserRole


class UserMeResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    email: str
    display_name: str
    year: str | None
    major: str | None
    bio: str | None
    avatar_key: str | None
    venmo_handle: str | None
    reputation_score: float
    rating_count: int
    role: UserRole
    created_at: datetime


class UserPublicResponse(BaseModel):
    """Public profile — never exposes email (spec §8 PII minimum)."""

    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    display_name: str
    year: str | None
    major: str | None
    bio: str | None
    avatar_key: str | None
    reputation_score: float
    rating_count: int
    created_at: datetime


class UserUpdateRequest(BaseModel):
    display_name: str | None = Field(default=None, min_length=2, max_length=80)
    year: str | None = Field(default=None, max_length=20)
    major: str | None = Field(default=None, max_length=120)
    bio: str | None = Field(default=None, max_length=1000)
    venmo_handle: str | None = Field(
        default=None, max_length=30, pattern=r"^@?[A-Za-z0-9_-]{3,30}$"
    )
