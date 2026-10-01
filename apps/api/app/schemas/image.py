"""DB-backed image upload contracts (payment proofs, payment QR codes)."""

from pydantic import BaseModel, Field


class ImageUploadRequest(BaseModel):
    """Direct image upload: base64 body, stored in Postgres.

    Base64 inflates ~33%, so the field cap is above the 5MB binary limit;
    the decoded size is enforced server-side.
    """

    content_type: str
    data_base64: str = Field(min_length=1, max_length=8 * 1024 * 1024)


class ImageUploadResponse(BaseModel):
    # Key in the "db/{uuid}" namespace — pass it to the existing submit
    # endpoints (payment proof, payment method qr_key).
    key: str
    url: str
