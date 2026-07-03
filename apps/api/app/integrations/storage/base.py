"""Object storage interface (spec §2.5): signed-URL direct upload;
the backend never proxies binaries."""

from abc import ABC, abstractmethod

from pydantic import BaseModel

MAX_UPLOAD_BYTES = 5 * 1024 * 1024  # spec §8 uploads: ≤ 5MB
ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/png", "image/webp"}


class SignedUpload(BaseModel):
    url: str
    fields: dict[str, str]
    key: str


class StorageProvider(ABC):
    @abstractmethod
    async def create_signed_upload(self, *, key: str, content_type: str) -> SignedUpload:
        """Presigned POST for direct client upload."""

    @abstractmethod
    def public_url(self, key: str) -> str:
        """URL clients can read the object from (CDN/bucket URL)."""
