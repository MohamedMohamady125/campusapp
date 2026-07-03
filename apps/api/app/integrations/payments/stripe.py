"""Stripe adapter (spec §13) via REST + httpx — no SDK dependency.

NEVER active without STRIPE_SECRET_KEY set by a human (guardrail §16:
no real charge path in v1). Uses Stripe idempotency headers; webhook
signatures verified per https://stripe.com/docs/webhooks/signatures.
"""

import hashlib
import hmac
import time

import httpx

from app.integrations.payments.base import ChargeResult, PaymentsProvider

_API = "https://api.stripe.com/v1"
_TOLERANCE_SECONDS = 300


class StripePaymentsProvider(PaymentsProvider):
    def __init__(self, *, secret_key: str, webhook_secret: str) -> None:
        self._secret_key = secret_key
        self._webhook_secret = webhook_secret

    async def charge(
        self, *, idempotency_key: str, amount_cents: int, currency: str, description: str
    ) -> ChargeResult:
        async with httpx.AsyncClient() as client:
            resp = await client.post(
                f"{_API}/payment_intents",
                auth=(self._secret_key, ""),
                headers={"Idempotency-Key": idempotency_key},
                data={
                    "amount": amount_cents,
                    "currency": currency,
                    "description": description,
                    "automatic_payment_methods[enabled]": "true",
                },
            )
        body = resp.json()
        return ChargeResult(
            provider="stripe",
            provider_ref=str(body.get("id", "")),
            succeeded=resp.status_code == 200,
        )

    async def subscribe(
        self, *, idempotency_key: str, plan: str, customer_email: str
    ) -> ChargeResult:
        async with httpx.AsyncClient() as client:
            customer = await client.post(
                f"{_API}/customers",
                auth=(self._secret_key, ""),
                headers={"Idempotency-Key": f"{idempotency_key}:customer"},
                data={"email": customer_email},
            )
            resp = await client.post(
                f"{_API}/subscriptions",
                auth=(self._secret_key, ""),
                headers={"Idempotency-Key": idempotency_key},
                data={
                    "customer": str(customer.json().get("id", "")),
                    "items[0][price]": plan,
                },
            )
        body = resp.json()
        return ChargeResult(
            provider="stripe",
            provider_ref=str(body.get("id", "")),
            succeeded=resp.status_code == 200,
        )

    def verify_webhook(self, *, payload: bytes, signature: str) -> bool:
        # Header format: "t=<ts>,v1=<hex>,..."
        parts = dict(p.split("=", 1) for p in signature.split(",") if "=" in p)
        ts, v1 = parts.get("t"), parts.get("v1")
        if not ts or not v1 or abs(time.time() - int(ts)) > _TOLERANCE_SECONDS:
            return False
        expected = hmac.new(
            self._webhook_secret.encode(), f"{ts}.".encode() + payload, hashlib.sha256
        ).hexdigest()
        return hmac.compare_digest(expected, v1)
