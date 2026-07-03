"""In-process realtime hub for chat WebSockets (spec §14 M8, behind flags.realtime).

Single-process pub/sub: fine for dev/tests and single-worker deploys.
TODO(post-v1): back with Redis pub/sub so multiple API workers share events.
"""

import asyncio
import uuid
from collections import defaultdict
from typing import Any


class ChatHub:
    def __init__(self) -> None:
        self._subscribers: dict[uuid.UUID, set[asyncio.Queue[dict[str, Any]]]] = defaultdict(set)

    def subscribe(self, chat_id: uuid.UUID) -> asyncio.Queue[dict[str, Any]]:
        queue: asyncio.Queue[dict[str, Any]] = asyncio.Queue()
        self._subscribers[chat_id].add(queue)
        return queue

    def unsubscribe(self, chat_id: uuid.UUID, queue: asyncio.Queue[dict[str, Any]]) -> None:
        self._subscribers[chat_id].discard(queue)
        if not self._subscribers[chat_id]:
            del self._subscribers[chat_id]

    def publish(self, chat_id: uuid.UUID, event: dict[str, Any]) -> None:
        for queue in self._subscribers.get(chat_id, ()):
            queue.put_nowait(event)


hub = ChatHub()
