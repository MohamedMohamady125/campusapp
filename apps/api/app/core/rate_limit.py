"""Redis-backed fixed-window rate limiting (spec §8).

In test env falls back to an in-memory store so tests need no Redis.
"""

import time
from typing import Protocol

import redis.asyncio as aioredis

from app.core.config import get_settings
from app.core.errors import RateLimitedError


class _Store(Protocol):
    async def incr_window(self, key: str, window_seconds: int) -> int: ...


class _RedisStore:
    def __init__(self, url: str) -> None:
        self._client: aioredis.Redis = aioredis.from_url(url)

    async def incr_window(self, key: str, window_seconds: int) -> int:
        bucket = f"rl:{key}:{int(time.time()) // window_seconds}"
        pipe = self._client.pipeline()
        pipe.incr(bucket)
        pipe.expire(bucket, window_seconds)
        count, _ = await pipe.execute()
        return int(count)


class _MemoryStore:
    def __init__(self) -> None:
        self._counts: dict[str, tuple[int, int]] = {}

    async def incr_window(self, key: str, window_seconds: int) -> int:
        bucket_id = int(time.time()) // window_seconds
        count, existing_bucket = self._counts.get(key, (0, bucket_id))
        if existing_bucket != bucket_id:
            count = 0
        count += 1
        self._counts[key] = (count, bucket_id)
        return count


_store: _Store | None = None


def _get_store() -> _Store:
    global _store
    if _store is None:
        settings = get_settings()
        _store = _MemoryStore() if settings.app_env == "test" else _RedisStore(settings.redis_url)
    return _store


def reset_rate_limits() -> None:
    """Test helper: clear in-memory counters."""
    global _store
    _store = None


async def enforce_rate_limit(key: str, *, limit: int, window_seconds: int) -> None:
    """Raise RateLimitedError (429 + Retry-After) when `key` exceeds limit/window."""
    count = await _get_store().incr_window(key, window_seconds)
    if count > limit:
        raise RateLimitedError(retry_after=window_seconds)
