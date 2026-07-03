"""S3/MinIO adapter using boto3 presigned POSTs."""

from typing import Any

import anyio

from app.core.config import get_settings
from app.integrations.storage.base import MAX_UPLOAD_BYTES, SignedUpload, StorageProvider


class S3StorageProvider(StorageProvider):
    def _client(self) -> Any:
        import boto3

        settings = get_settings()
        return boto3.client(
            "s3",
            endpoint_url=settings.s3_endpoint_url,
            aws_access_key_id=settings.s3_access_key,
            aws_secret_access_key=settings.s3_secret_key,
            region_name=settings.s3_region,
        )

    async def create_signed_upload(self, *, key: str, content_type: str) -> SignedUpload:
        settings = get_settings()

        def _presign() -> dict[str, Any]:
            result: dict[str, Any] = self._client().generate_presigned_post(
                Bucket=settings.s3_bucket,
                Key=key,
                Fields={"Content-Type": content_type},
                Conditions=[
                    {"Content-Type": content_type},
                    ["content-length-range", 1, MAX_UPLOAD_BYTES],
                ],
                ExpiresIn=600,
            )
            return result

        # boto3 is sync; keep it off the event loop (spec §7.2).
        data = await anyio.to_thread.run_sync(_presign)
        return SignedUpload(url=data["url"], fields=dict(data["fields"]), key=key)

    def public_url(self, key: str) -> str:
        settings = get_settings()
        return f"{settings.s3_endpoint_url}/{settings.s3_bucket}/{key}"
