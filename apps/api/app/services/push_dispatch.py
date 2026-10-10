"""Push fan-out: deliver a freshly inserted notification to the user's devices.

Called from notification_dispatch on INSERT only — a notification that folds
into an existing unread row never re-pushes (the anti-spam core). Delivery is
best-effort and off the request path in prod (fire-and-forget task); in tests
it's awaited inline so the stub provider is deterministic to assert against.
"""

import asyncio
import uuid
from typing import Any

import structlog
from sqlalchemy import delete

from app.core.config import get_settings
from app.integrations.push.base import PushMessage
from app.integrations.push.provider import get_push_provider
from app.models import DeviceToken
from app.repositories.chat_repo import NotificationRepository
from app.services.push_copy import render_push

log = structlog.get_logger()

# Keep strong refs to in-flight fire-and-forget tasks (asyncio GC rule).
_background_tasks: set[asyncio.Task[None]] = set()


async def send_push_for_notification(
    repo: NotificationRepository,
    *,
    user_id: uuid.UUID,
    type_: str,
    payload: dict[str, Any],
) -> None:
    message = render_push(type_, payload)
    if message is None:
        return
    tokens = await repo.device_tokens_for(user_id)
    if not tokens:
        return
    if get_settings().app_env == "test":
        await _deliver(tokens, message)
        return
    task = asyncio.create_task(_deliver(tokens, message))
    _background_tasks.add(task)
    task.add_done_callback(_background_tasks.discard)


async def _deliver(tokens: list[str], message: PushMessage) -> None:
    provider = get_push_provider()
    dead = await provider.send(tokens=tokens, message=message)
    if dead:
        await _prune_dead_tokens(dead)


async def _prune_dead_tokens(tokens: list[str]) -> None:
    """Remove tokens FCM reported unregistered (uses its own session: the
    request session that triggered the push is long gone by delivery time)."""
    from app.db.session import async_session_factory

    try:
        async with async_session_factory() as session:
            await session.execute(delete(DeviceToken).where(DeviceToken.token.in_(tokens)))
            await session.commit()
        log.info("push.pruned_dead_tokens", count=len(tokens))
    except Exception as exc:
        log.warning("push.prune_failed", error=str(exc))
