"""Stub storage adapter: deterministic URLs, no network (spec §2.5)."""

import structlog

from app.integrations.storage.base import SignedUpload, StorageProvider

log = structlog.get_logger()


class StubStorageProvider(StorageProvider):
    async def create_signed_upload(self, *, key: str, content_type: str) -> SignedUpload:
        log.info("storage.stub_signed_upload", key=key, content_type=content_type)
        return SignedUpload(
            url="http://stub-storage.local/upload",
            fields={"key": key, "Content-Type": content_type},
            key=key,
        )

    def public_url(self, key: str) -> str:
        return f"http://stub-storage.local/{key}"
