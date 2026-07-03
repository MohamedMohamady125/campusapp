"""Storage provider selection by environment (spec §2.5)."""

from functools import lru_cache

from app.core.config import get_settings
from app.integrations.storage.base import StorageProvider
from app.integrations.storage.s3 import S3StorageProvider
from app.integrations.storage.stub import StubStorageProvider


@lru_cache
def get_storage_provider() -> StorageProvider:
    settings = get_settings()
    if settings.app_env == "test":
        return StubStorageProvider()
    # dev uses MinIO from docker-compose; prod uses real S3 creds from env.
    return S3StorageProvider()
