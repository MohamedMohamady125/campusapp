"""Cursor pagination (spec §2.4: every list endpoint is cursor-paginated).

Cursor encodes (created_at, id) of the last row, base64url. Stable under
inserts, no OFFSET scans.
"""

import base64
import binascii
import uuid
from datetime import datetime

from pydantic import BaseModel

from app.core.errors import ValidationAppError

DEFAULT_PAGE_SIZE = 20
MAX_PAGE_SIZE = 50


class Page[T](BaseModel):
    items: list[T]
    next_cursor: str | None


def encode_cursor(created_at: datetime, item_id: uuid.UUID) -> str:
    raw = f"{created_at.isoformat()}|{item_id}"
    return base64.urlsafe_b64encode(raw.encode()).decode()


def decode_cursor(cursor: str) -> tuple[datetime, uuid.UUID]:
    try:
        raw = base64.urlsafe_b64decode(cursor.encode()).decode()
        ts, item_id = raw.split("|", 1)
        return datetime.fromisoformat(ts), uuid.UUID(item_id)
    except (ValueError, binascii.Error) as exc:
        raise ValidationAppError("Invalid cursor.", code="INVALID_CURSOR") from exc


def clamp_limit(limit: int) -> int:
    return max(1, min(limit, MAX_PAGE_SIZE))
