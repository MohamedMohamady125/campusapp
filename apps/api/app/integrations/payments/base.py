"""Payments interface (spec §13): all money flows through this — PCI stays with the provider.

The backend never touches raw card data; charges are provider-side sessions.
Every call carries an idempotency key.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass


@dataclass(frozen=True)
class ChargeResult:
    provider: str
    provider_ref: str
    succeeded: bool


class PaymentsProvider(ABC):
    @abstractmethod
    async def charge(
        self, *, idempotency_key: str, amount_cents: int, currency: str, description: str
    ) -> ChargeResult:
        """Create a charge. Must be idempotent per idempotency_key."""

    @abstractmethod
    async def subscribe(
        self, *, idempotency_key: str, plan: str, customer_email: str
    ) -> ChargeResult:
        """Create a subscription with the provider."""

    @abstractmethod
    def verify_webhook(self, *, payload: bytes, signature: str) -> bool:
        """Verify a webhook signature before trusting its payload."""
