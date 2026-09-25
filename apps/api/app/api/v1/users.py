"""User endpoints (spec §4.1 Users)."""

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user
from app.core.errors import NotFoundError, ValidationAppError
from app.db.session import get_session
from app.integrations.storage.base import ALLOWED_CONTENT_TYPES
from app.integrations.storage.provider import get_storage_provider
from app.models import User
from app.repositories.user_repo import UserRepository
from app.schemas.user import (
    PaymentQrUploadUrlRequest,
    PaymentQrUploadUrlResponse,
    UserMeResponse,
    UserPublicResponse,
    UserUpdateRequest,
)

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=UserMeResponse)
async def get_me(user: User = Depends(get_current_user)) -> User:
    return user


@router.patch("/me", response_model=UserMeResponse)
async def update_me(
    body: UserUpdateRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> User:
    # mode="json" coerces PaymentMethod enums to their string values so the
    # JSONB column stores plain {type, handle, qr_key} dicts. qr_url is
    # derived from qr_key at read time — never persist it.
    for field, value in body.model_dump(mode="json", exclude_unset=True).items():
        if field == "payment_methods" and value is not None:
            for method in value:
                method.pop("qr_url", None)
        setattr(user, field, value)
    await session.commit()
    await session.refresh(user)
    return user


@router.post("/me/payment-qr-upload-url", response_model=PaymentQrUploadUrlResponse)
async def payment_qr_upload_url(
    body: PaymentQrUploadUrlRequest,
    user: User = Depends(get_current_user),
) -> PaymentQrUploadUrlResponse:
    """Signed-URL direct upload for a payment-app QR code image (food-runs
    spec: payment is off-app — the QR just lets a requester scan-to-pay)."""
    if body.content_type not in ALLOWED_CONTENT_TYPES:
        raise ValidationAppError(
            "Unsupported image type.",
            code="UNSUPPORTED_CONTENT_TYPE",
            details={"allowed": sorted(ALLOWED_CONTENT_TYPES)},
        )
    ext = body.content_type.split("/")[-1]
    key = f"payment-qr/{user.id}/{uuid.uuid4()}.{ext}"
    signed = await get_storage_provider().create_signed_upload(
        key=key, content_type=body.content_type
    )
    return PaymentQrUploadUrlResponse(upload_url=signed.url, fields=signed.fields, key=signed.key)


@router.get("/{user_id}", response_model=UserPublicResponse)
async def get_public_profile(
    user_id: uuid.UUID,
    _: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> User:
    target = await UserRepository(session).get_by_id(user_id)
    if target is None:
        raise NotFoundError("User not found.", code="USER_NOT_FOUND")
    return target
