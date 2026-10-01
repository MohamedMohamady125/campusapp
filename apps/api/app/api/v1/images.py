"""DB-backed image endpoints.

Upload (auth) stores bytes in Postgres; read is public behind an
unguessable UUID — same trust model as a signed S3 URL, but with zero
object-storage dependency, so proofs/QRs work on bucket-less deployments.
"""

import base64
import binascii
import uuid

from fastapi import APIRouter, Depends, Response
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user
from app.core.errors import NotFoundError, ValidationAppError
from app.db.session import get_session
from app.integrations.storage.base import ALLOWED_CONTENT_TYPES, MAX_UPLOAD_BYTES
from app.integrations.storage.resolve import image_public_url
from app.models import StoredImage, User
from app.schemas.image import ImageUploadRequest, ImageUploadResponse

router = APIRouter(prefix="/images", tags=["images"])


@router.post("", response_model=ImageUploadResponse, status_code=201)
async def upload_image(
    body: ImageUploadRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> ImageUploadResponse:
    if body.content_type not in ALLOWED_CONTENT_TYPES:
        raise ValidationAppError(
            "Unsupported image type.",
            code="UNSUPPORTED_CONTENT_TYPE",
            details={"allowed": sorted(ALLOWED_CONTENT_TYPES)},
        )
    try:
        data = base64.b64decode(body.data_base64, validate=True)
    except (binascii.Error, ValueError) as exc:
        raise ValidationAppError("Invalid base64 image data.", code="INVALID_IMAGE_DATA") from exc
    if not data or len(data) > MAX_UPLOAD_BYTES:
        raise ValidationAppError("Image must be between 1 byte and 5MB.", code="IMAGE_TOO_LARGE")
    image = StoredImage(content_type=body.content_type, data=data, uploaded_by=str(user.id))
    session.add(image)
    await session.commit()
    await session.refresh(image)
    key = f"db/{image.id}"
    return ImageUploadResponse(key=key, url=image_public_url(key))


@router.get("/{image_id}")
async def get_image(
    image_id: uuid.UUID,
    session: AsyncSession = Depends(get_session),
) -> Response:
    image = (
        await session.execute(select(StoredImage).where(StoredImage.id == image_id))
    ).scalar_one_or_none()
    if image is None:
        raise NotFoundError("Image not found.", code="IMAGE_NOT_FOUND")
    return Response(
        content=image.data,
        media_type=image.content_type,
        headers={"Cache-Control": "public, max-age=31536000, immutable"},
    )
