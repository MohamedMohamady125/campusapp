"""Deduplicated notification dispatch (Sprint 6).

Chat and DM message notifications are collapsed per recipient: if the user
already has an UNREAD notification of the same type for the same context
(chat_id / conversation_id) created within the last 60 minutes, we update it
in place — bump `payload["count"]`, refresh the latest message/sender fields,
and reset `created_at` so it sorts to the top of the feed — instead of
inserting a new row. Mentions are never deduplicated (see chat_service).
"""

import uuid
from datetime import datetime, timedelta
from typing import Any

from app.models import Notification
from app.repositories.chat_repo import NotificationRepository

DEDUP_WINDOW_MINUTES = 60


async def upsert_deduped_notification(
    repo: NotificationRepository,
    *,
    user_id: uuid.UUID,
    type_: str,
    dedup_key: str,
    dedup_value: str,
    payload: dict[str, Any],
    now: datetime,
) -> None:
    """Insert a notification, or fold it into a recent unread one (see module doc)."""
    existing = await repo.find_recent_unread_by_payload(
        user_id=user_id,
        type_=type_,
        key=dedup_key,
        value=dedup_value,
        since=now - timedelta(minutes=DEDUP_WINDOW_MINUTES),
    )
    if existing is not None:
        merged = dict(existing.payload)
        count = int(merged.get("count", 1))
        merged.update(payload)
        merged["count"] = count + 1
        existing.payload = merged  # reassign so SQLAlchemy tracks the JSONB change
        existing.created_at = now  # bump to the top of the (created_at desc) feed
        return
    repo.add(Notification(user_id=user_id, type=type_, payload={**payload, "count": 1}))
