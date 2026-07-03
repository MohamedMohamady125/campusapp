"""Transactional email interface (spec §2.5 interface + stub rule)."""

from abc import ABC, abstractmethod


class EmailProvider(ABC):
    @abstractmethod
    async def send(self, *, to: str, subject: str, body: str) -> None:
        """Send a transactional email. Must not raise on provider hiccups in dev."""
