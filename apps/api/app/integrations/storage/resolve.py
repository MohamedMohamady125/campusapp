"""Resolve a stored-image key to a public URL.

Two key namespaces coexist:
- "db/{uuid}"  — bytes live in Postgres (stored_images), served by this API.
- anything else — an object-storage key resolved by the configured provider.

DB-backed keys exist so image features (payment proofs, payment QR codes)
work on deployments without an S3 bucket.
"""

from app.core.config import get_settings
from app.integrations.storage.provider import get_storage_provider

DB_KEY_PREFIX = "db/"


def image_public_url(key: str) -> str:
    if key.startswith(DB_KEY_PREFIX):
        base = get_settings().public_base_url.rstrip("/")
        return f"{base}/api/v1/images/{key[len(DB_KEY_PREFIX) :]}"
    return get_storage_provider().public_url(key)
