"""User contracts (spec §4.1 Users)."""

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

from app.models.enums import PaymentMethodType, UserRole

# Bounded, printable set covering every rail's handle shape: Venmo/Zelle
# tags (@foo), Cash App cashtags ($foo), phones (+1 (555) 1234), emails
# (a@b.co) and PayPal.me links (paypal.me/foo). Rejects control chars /
# injection payloads.
_HANDLE_CHARS = "@._+-()$/: "


class PaymentMethod(BaseModel):
    """One off-app payment rail a runner advertises (food-runs spec).

    `handle` is a plain-text phone / email / username for the third-party
    app; it is escaped on display and never used to move money in-app.
    Optionally the runner attaches their app's QR code image (`qr_key`,
    uploaded via /users/me/payment-qr-upload-url) so payers can just scan.
    """

    model_config = ConfigDict(from_attributes=True)

    type: PaymentMethodType
    handle: str = Field(min_length=2, max_length=64)
    # S3 key of the runner's payment QR code image (optional).
    qr_key: str | None = Field(default=None, max_length=300)
    # Read-only: public URL derived from qr_key; never stored.
    qr_url: str | None = None

    @field_validator("handle")
    @classmethod
    def _clean_handle(cls, value: str) -> str:
        cleaned = value.strip()
        if not all(c.isalnum() or c in _HANDLE_CHARS for c in cleaned):
            raise ValueError("Handle has unsupported characters.")
        return cleaned

    @field_validator("qr_key")
    @classmethod
    def _own_namespace(cls, value: str | None) -> str | None:
        # Only keys minted by the payment-QR upload endpoint are accepted, so
        # a handle can never point at someone else's private object.
        if value is not None and not value.startswith("payment-qr/"):
            raise ValueError("Invalid QR key.")
        return value

    @model_validator(mode="after")
    def _derive_qr_url(self) -> "PaymentMethod":
        if self.qr_key:
            # Local import: schemas must not pull integrations at module load.
            from app.integrations.storage.provider import get_storage_provider

            self.qr_url = get_storage_provider().public_url(self.qr_key)
        return self


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


class PaymentQrUploadUrlRequest(BaseModel):
    """Runner asks for a signed URL to upload a payment-app QR code image."""

    content_type: str


class PaymentQrUploadUrlResponse(BaseModel):
    upload_url: str
    fields: dict[str, str]
    key: str


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
