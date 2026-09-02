"""User contracts (spec §4.1 Users)."""

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.models.enums import PaymentMethodType, UserRole


class PaymentMethod(BaseModel):
    """One off-app payment rail a runner advertises (food-runs spec).

    `handle` is a plain-text tag / phone / email for the third-party app;
    it is escaped on display and never used to move money in-app.
    """

    model_config = ConfigDict(from_attributes=True)

    type: PaymentMethodType
    handle: str = Field(min_length=2, max_length=64)

    @field_validator("handle")
    @classmethod
    def _clean_handle(cls, value: str) -> str:
        cleaned = value.strip()
        # Bounded, printable set covering tags (@foo), phones (+1 (555) 1234)
        # and emails (a@b.co). Rejects control chars / injection payloads.
        if not all(c.isalnum() or c in "@._+-() " for c in cleaned):
            raise ValueError("Handle has unsupported characters.")
        return cleaned


class UserMeResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    email: str
    display_name: str
    year: str | None
    major: str | None
    bio: str | None
    avatar_key: str | None
    payment_methods: list[PaymentMethod]
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
    # Full replacement of the runner's payment rails (max 6, one per type).
    payment_methods: list[PaymentMethod] | None = Field(default=None, max_length=6)

    @field_validator("payment_methods")
    @classmethod
    def _unique_types(cls, value: list[PaymentMethod] | None) -> list[PaymentMethod] | None:
        if value is not None:
            types = [m.type for m in value]
            if len(types) != len(set(types)):
                raise ValueError("Only one handle per payment type.")
        return value
