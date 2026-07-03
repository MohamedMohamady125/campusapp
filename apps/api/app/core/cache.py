"""Redis-backed JSON cache with TTLs (spec §14 M8 hardening).

In test env falls back to an in-memory store so tests need no Redis
(same pattern as app.core.rate_limit).
"""

import json
import time
from typing import Any, Protocol

import redis.asyncio as aioredis

from app.core.config import get_settings


class _Store(Protocol):
    async def get(self, key: str) -> str | None: ...
    async def set(self, key: str, value: str, ttl_seconds: int) -> None: ...
    async def delete_prefix(self, prefix: str) -> None: ...


class _RedisStore:
    def __init__(self, url: str) -> None:
        self._client: aioredis.Redis = aioredis.from_url(url)

    async def get(self, key: str) -> str | None:
        raw = await self._client.get(f"cache:{key}")
        if raw is None:
            return None
        return raw.decode() if isinstance(raw, bytes) else str(raw)

    async def set(self, key: str, value: str, ttl_seconds: int) -> None:
        await self._client.set(f"cache:{key}", value, ex=ttl_seconds)

    async def delete_prefix(self, prefix: str) -> None:
        async for found in self._client.scan_iter(match=f"cache:{prefix}*"):
            await self._client.delete(found)


class _MemoryStore:
    def __init__(self) -> None:
        self._items: dict[str, tuple[str, float]] = {}

    async def get(self, key: str) -> str | None:
        item = self._items.get(key)
        if item is None:
            return None
        value, expires_at = item
        if time.monotonic() >= expires_at:
            del self._items[key]
            return None
        return value

    async def set(self, key: str, value: str, ttl_seconds: int) -> None:
        self._items[key] = (value, time.monotonic() + ttl_seconds)

    async def delete_prefix(self, prefix: str) -> None:
        for key in [k for k in self._items if k.startswith(prefix)]:
            del self._items[key]


_store: _Store | None = None


def _get_store() -> _Store:
    global _store
    if _store is None:
        settings = get_settings()
        _store = _MemoryStore() if settings.app_env == "test" else _RedisStore(settings.redis_url)
    return _store


def reset_cache() -> None:
    """Test helper: drop the in-memory store."""
    global _store
    _store = None


async def cache_get_json(key: str) -> Any | None:
    raw = await _get_store().get(key)
    return json.loads(raw) if raw is not None else None


async def cache_set_json(key: str, value: Any, *, ttl_seconds: int) -> None:
    await _get_store().set(key, json.dumps(value), ttl_seconds)


async def cache_invalidate_prefix(prefix: str) -> None:
    await _get_store().delete_prefix(prefix)
