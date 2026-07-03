"""Listing contracts (spec §4.1 Listings)."""

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field

from app.models.enums import ListingCategory, ListingCondition, ListingStatus, ModerationStatus
from app.schemas.user import UserPublicResponse


class ListingCreateRequest(BaseModel):
    title: str = Field(min_length=3, max_length=120)
    description: str = Field(min_length=1, max_length=5000)
    price_cents: int = Field(ge=0, le=10_000_000)
    category: ListingCategory
    condition: ListingCondition


class ListingUpdateRequest(BaseModel):
    title: str | None = Field(default=None, min_length=3, max_length=120)
    description: str | None = Field(default=None, min_length=1, max_length=5000)
    price_cents: int | None = Field(default=None, ge=0, le=10_000_000)
    category: ListingCategory | None = None
    condition: ListingCondition | None = None


class ListingImageResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    s3_key: str
    order: int
    moderation_status: ModerationStatus


class ListingResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    seller: UserPublicResponse
    title: str
    description: str
    price_cents: int
    category: ListingCategory
    condition: ListingCondition
    status: ListingStatus
    expires_at: datetime
    created_at: datetime
    images: list[ListingImageResponse]


class ListingPageResponse(BaseModel):
    items: list[ListingResponse]
    next_cursor: str | None


class ImageUploadUrlResponse(BaseModel):
    upload_url: str
    fields: dict[str, str]
    image_id: uuid.UUID
    key: str
