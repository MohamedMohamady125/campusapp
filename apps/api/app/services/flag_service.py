"""Feature flag reads (spec §2.4): half-built features ship dark.

Flag list is cached (30s TTL) — flags change rarely and are read on
every client boot, so this is the first M8 cache consumer.
"""

import hashlib
import uuid
from typing import Any

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.cache import cache_get_json, cache_invalidate_prefix, cache_set_json
from app.models import Flag

FLAGS_CACHE_KEY = "flags:all"
FLAGS_CACHE_TTL_SECONDS = 30


async def list_flags(session: AsyncSession) -> list[dict[str, Any]]:
    cached = await cache_get_json(FLAGS_CACHE_KEY)
    if cached is not None:
        return list(cached)
    rows = (await session.execute(select(Flag).order_by(Flag.key))).scalars()
    flags = [
        {"key": f.key, "enabled": f.enabled, "rollout_percent": f.rollout_percent} for f in rows
    ]
    await cache_set_json(FLAGS_CACHE_KEY, flags, ttl_seconds=FLAGS_CACHE_TTL_SECONDS)
    return flags


async def is_enabled(session: AsyncSession, key: str, *, user_id: uuid.UUID | None = None) -> bool:
    """True when the flag exists, is enabled, and the user falls in the rollout.

    Rollout bucketing is deterministic per (flag, user): the same user always
    gets the same answer while rollout_percent is unchanged.
    """
    for flag in await list_flags(session):
        if flag["key"] != key:
            continue
        if not flag["enabled"]:
            return False
        percent = int(flag["rollout_percent"])
        if percent >= 100:
            return True
        if percent <= 0 or user_id is None:
            # partial rollout needs a user to bucket; anonymous callers stay dark
            return False
        digest = hashlib.sha256(f"{key}:{user_id}".encode()).digest()
        return digest[0] % 100 < percent
    return False


async def invalidate_flags_cache() -> None:
    await cache_invalidate_prefix(FLAGS_CACHE_KEY)
