"""Admin broadcast: staff-authored announcements, delivered as in-app feed
notifications + push to every chosen recipient (or the whole campus).

Unlike product notifications, the copy is free-form: the admin writes the
exact title/body and the client renders it verbatim.
"""

import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import AuditLog, Notification, User
from app.models.enums import UserStatus
from app.repositories.chat_repo import NotificationRepository
from app.services.push_dispatch import send_push_for_notification

NOTIFICATION_TYPE_ADMIN_MESSAGE = "admin_message"


async def send_admin_broadcast(
    session: AsyncSession,
    *,
    actor: User,
    title: str,
    body: str,
    emails: list[str] | None,
) -> tuple[int, list[str]]:
    """Deliver the announcement; returns (sent_count, unknown_emails).

    Empty/None `emails` → every active user except the sender. Suspended and
    banned accounts never receive broadcasts.
    """
    if emails:
        wanted = [e.strip().lower() for e in emails if e.strip()]
        users = (
            (
                await session.execute(
                    select(User).where(User.email.in_(wanted), User.status == UserStatus.active)
                )
            )
            .scalars()
            .all()
        )
        missing = sorted(set(wanted) - {u.email for u in users})
    else:
        users = (
            (
                await session.execute(
                    select(User).where(User.status == UserStatus.active, User.id != actor.id)
                )
            )
            .scalars()
            .all()
        )
        missing = []

    repo = NotificationRepository(session)
    payload = {"broadcast_id": str(uuid.uuid4()), "title": title, "body": body}
    for user in users:
        repo.add(
            Notification(
                user_id=user.id,
                type=NOTIFICATION_TYPE_ADMIN_MESSAGE,
                payload={**payload, "count": 1},
            )
        )
        await send_push_for_notification(
            repo, user_id=user.id, type_=NOTIFICATION_TYPE_ADMIN_MESSAGE, payload=payload
        )
    session.add(
        AuditLog(
            actor_id=actor.id,
            action="admin.broadcast",
            target_type="user",
            target_id=None,
            metadata_={"title": title, "recipients": len(users), "targeted": bool(emails)},
        )
    )
    await session.commit()
    return len(users), missing
