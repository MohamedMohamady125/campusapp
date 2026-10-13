"""Cross-worker realtime hub for chat WebSockets (spec §14 M8, behind flags.realtime).

Local fan-out stays in-process (zero latency for sockets on this worker);
every publish is also mirrored to Redis pub/sub so sockets held by *other*
gunicorn workers see the event too. Envelopes carry an ``origin`` tag so the
Redis listener drops its own echoes. In tests the listener never starts, so
single-process in-memory behaviour is unchanged.
"""

import asyncio
import json
import uuid
from collections import defaultdict
from typing import Any

import redis.asyncio as aioredis
import structlog

from app.core.config import get_settings

log = structlog.get_logger()

_CHANNEL = "campusconnect:chat-events"
_RECONNECT_SECONDS = 2.0


class ChatHub:
    def __init__(self) -> None:
        self._subscribers: dict[uuid.UUID, set[asyncio.Queue[dict[str, Any]]]] = defaultdict(set)
        # Per-process identity so this worker ignores its own Redis echoes.
        self._origin = uuid.uuid4().hex
        self._redis: aioredis.Redis | None = None
        # Strong refs to fire-and-forget mirror tasks (asyncio only keeps weak ones).
        self._mirror_tasks: set[asyncio.Task[None]] = set()

    def subscribe(self, chat_id: uuid.UUID) -> asyncio.Queue[dict[str, Any]]:
        queue: asyncio.Queue[dict[str, Any]] = asyncio.Queue()
        self._subscribers[chat_id].add(queue)
        return queue

    def unsubscribe(self, chat_id: uuid.UUID, queue: asyncio.Queue[dict[str, Any]]) -> None:
        self._subscribers[chat_id].discard(queue)
        if not self._subscribers[chat_id]:
            del self._subscribers[chat_id]

    def publish(self, chat_id: uuid.UUID, event: dict[str, Any]) -> None:
        self._fan_out(chat_id, event)
        if self._redis is not None:
            # Fire-and-forget: local delivery already happened; a dropped
            # mirror only costs other workers one event, and chat clients
            # also poll.
            task = asyncio.get_event_loop().create_task(self._mirror(chat_id, event))
            self._mirror_tasks.add(task)
            task.add_done_callback(self._mirror_tasks.discard)

    def _fan_out(self, chat_id: uuid.UUID, event: dict[str, Any]) -> None:
        for queue in self._subscribers.get(chat_id, ()):
            queue.put_nowait(event)

    async def _mirror(self, chat_id: uuid.UUID, event: dict[str, Any]) -> None:
        envelope = json.dumps({"chat_id": str(chat_id), "origin": self._origin, "event": event})
        try:
            assert self._redis is not None
            await self._redis.publish(_CHANNEL, envelope)
        except Exception:
            log.exception("realtime.mirror_failed")

    async def redis_listener(self) -> None:
        """Forever task (started from the app lifespan, never in tests):
        subscribe to the shared channel and fan foreign events into local
        queues. Reconnects on any Redis hiccup."""
        while True:
            try:
                self._redis = aioredis.from_url(get_settings().redis_url)
                pubsub = self._redis.pubsub()
                await pubsub.subscribe(_CHANNEL)
                log.info("realtime.redis_listener_started", channel=_CHANNEL)
                async for message in pubsub.listen():
                    if message.get("type") != "message":
                        continue
                    self._handle(message["data"])
            except asyncio.CancelledError:
                raise
            except Exception:
                log.exception("realtime.redis_listener_failed")
                self._redis = None  # publish() stops mirroring until reconnected
                await asyncio.sleep(_RECONNECT_SECONDS)

    def _handle(self, raw: bytes | str) -> None:
        try:
            envelope = json.loads(raw)
            if envelope["origin"] == self._origin:
                return
            self._fan_out(uuid.UUID(envelope["chat_id"]), envelope["event"])
        except Exception:
            log.exception("realtime.bad_envelope")


hub = ChatHub()
