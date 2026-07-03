"""Stub payments provider (spec §2.5, §13): deterministic, in-memory, no real charges."""

import hashlib

from app.integrations.payments.base import ChargeResult, PaymentsProvider


class StubPaymentsProvider(PaymentsProvider):
    def __init__(self) -> None:
        self.charges: list[dict[str, object]] = []

    async def charge(
        self, *, idempotency_key: str, amount_cents: int, currency: str, description: str
    ) -> ChargeResult:
        # Idempotent: the same key always maps to the same fake ref.
        ref = "stub_ch_" + hashlib.sha256(idempotency_key.encode()).hexdigest()[:16]
        if not any(c["ref"] == ref for c in self.charges):
            self.charges.append(
                {"ref": ref, "amount_cents": amount_cents, "description": description}
            )
        return ChargeResult(provider="stub", provider_ref=ref, succeeded=True)

    async def subscribe(
        self, *, idempotency_key: str, plan: str, customer_email: str
    ) -> ChargeResult:
        ref = "stub_sub_" + hashlib.sha256(idempotency_key.encode()).hexdigest()[:16]
        return ChargeResult(provider="stub", provider_ref=ref, succeeded=True)

    def verify_webhook(self, *, payload: bytes, signature: str) -> bool:
        return signature == "stub-signature"
