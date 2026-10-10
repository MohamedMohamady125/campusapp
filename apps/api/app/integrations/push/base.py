"""Push notification interface (spec §2.5 interface + stub rule).

One `PushMessage` fans out to every registered device of a user. Providers
are best-effort: a push is a nicety, never a source of truth — the in-app
notification row (and its 15s poll) is the durable record.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass, field


@dataclass(frozen=True)
class PushMessage:
    title: str
    body: str
    # Deep-link payload the app routes on (type, run_id, chat_id, ...).
    data: dict[str, str] = field(default_factory=dict)
    # Same key replaces the previous undelivered push for that context —
    # one banner per run/chat, never a pile (anti-spam, DoorDash-style).
    collapse_key: str | None = None
    # Time-sensitive interruption level (iOS): runner-arrived etc.
    critical: bool = False


class PushProvider(ABC):
    @abstractmethod
    async def send(self, *, tokens: list[str], message: PushMessage) -> list[str]:
        """Deliver to each token. Returns tokens the provider reported dead
        (unregistered/expired) so the caller can prune them. Never raises."""
