"""Database-backed image storage.

Small user images (payment proofs, payment QR codes) are stored directly in
Postgres and served by the API at GET /api/v1/images/{id}. This removes the
hard dependency on an S3 bucket for deployments that don't have one (the
Railway demo stack has no object storage, so signed-URL uploads silently
produced dead links). Keys for these images use the "db/{uuid}" prefix so
URL resolution can route them to the API instead of S3.
"""

from sqlalchemy import LargeBinary, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import TimestampedBase


class StoredImage(TimestampedBase):
    __tablename__ = "stored_images"

    content_type: Mapped[str] = mapped_column(String(100))
    # Raw image bytes — capped at upload time (≤5MB), so rows stay small.
    data: Mapped[bytes] = mapped_column(LargeBinary)
    # Who uploaded it (audit / future cleanup); not an authz gate — the id
    # itself is an unguessable UUID, same trust model as a signed S3 URL.
    uploaded_by: Mapped[str | None] = mapped_column(String(64))
