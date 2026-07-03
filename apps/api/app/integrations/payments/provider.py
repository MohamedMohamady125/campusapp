"""Payments provider selection (spec §2.5): stub unless a human supplies Stripe keys in prod."""

from functools import lru_cache

from app.core.config import get_settings
from app.integrations.payments.base import PaymentsProvider
from app.integrations.payments.stripe import StripePaymentsProvider
from app.integrations.payments.stub import StubPaymentsProvider


@lru_cache
def get_payments_provider() -> PaymentsProvider:
    settings = get_settings()
    # Guardrail (spec §16): the real charge path requires prod env AND keys.
    if settings.is_prod and settings.stripe_secret_key:
        return StripePaymentsProvider(
            secret_key=settings.stripe_secret_key,
            webhook_secret=settings.stripe_webhook_secret,
        )
    return StubPaymentsProvider()
