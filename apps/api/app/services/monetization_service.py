"""Monetization rails (spec §13) — every path flag-gated and dark in v1.

All money flows through the PaymentsProvider interface; every charge writes
a Payment ledger row keyed by a unique idempotency key (retries reuse the
existing row instead of double-charging). No real charge path exists unless
a human enables the flag AND provides Stripe keys in prod (guardrail §16).
"""

import uuid
from datetime import UTC, datetime, timedelta

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import ForbiddenError, NotFoundError
from app.integrations.payments.provider import get_payments_provider
from app.models import Listing, Payment, Subscription, User
from app.models.enums import PaymentPurpose, PaymentStatus, SubscriptionPlan, SubscriptionStatus
from app.repositories.listing_repo import ListingRepository
from app.services.flag_service import is_enabled

PROMOTED_LISTING_PRICE_CENTS = 300
PROMOTED_LISTING_DAYS = 7
TUTOR_PREMIUM_PRICE_CENTS = 500
TUTOR_PREMIUM_PERIOD_DAYS = 30


class MonetizationService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session
        self._payments = get_payments_provider()

    async def _existing_payment(self, idempotency_key: str) -> Payment | None:
        result = await self._session.execute(
            select(Payment).where(Payment.idempotency_key == idempotency_key)
        )
        return result.scalar_one_or_none()

    async def promote_listing(self, *, listing_id: uuid.UUID, user: User) -> Listing:
        if not await is_enabled(self._session, "promoted_listings", user_id=user.id):
            raise ForbiddenError("Promoted listings are not available.", code="FEATURE_DISABLED")
        listing = await ListingRepository(self._session).get(listing_id)
        if listing is None:
            raise NotFoundError("Listing not found.", code="LISTING_NOT_FOUND")
        if listing.seller_id != user.id:
            raise ForbiddenError("You can only promote your own listings.", code="NOT_OWNER")

        now = datetime.now(UTC)
        # One boost at a time — promoting an already-boosted listing is a no-op,
        # so retries are idempotent (no second charge, no double extension).
        if listing.boosted_until is not None and listing.boosted_until > now:
            return listing
        window = listing.boosted_until.isoformat() if listing.boosted_until else "first"
        idempotency_key = f"promote:{listing.id}:{window}"
        if await self._existing_payment(idempotency_key) is not None:
            return listing

        result = await self._payments.charge(
            idempotency_key=idempotency_key,
            amount_cents=PROMOTED_LISTING_PRICE_CENTS,
            currency="usd",
            description=f"Promoted listing {listing.id} for {PROMOTED_LISTING_DAYS} days",
        )
        self._session.add(
            Payment(
                user_id=user.id,
                purpose=PaymentPurpose.promoted_listing,
                amount_cents=PROMOTED_LISTING_PRICE_CENTS,
                currency="usd",
                status=PaymentStatus.succeeded if result.succeeded else PaymentStatus.failed,
                provider=result.provider,
                provider_ref=result.provider_ref,
                idempotency_key=idempotency_key,
                metadata_={"listing_id": str(listing.id)},
            )
        )
        if result.succeeded:
            listing.boosted_until = now + timedelta(days=PROMOTED_LISTING_DAYS)
        await self._session.commit()
        return listing

    async def subscribe_tutor_premium(self, *, user: User) -> Subscription:
        if not await is_enabled(self._session, "tutor_premium", user_id=user.id):
            raise ForbiddenError("Tutor premium is not available.", code="FEATURE_DISABLED")
        now = datetime.now(UTC)
        existing = await self._get_subscription(user.id, SubscriptionPlan.tutor_premium)
        if (
            existing is not None
            and existing.status == SubscriptionStatus.active
            and existing.current_period_end > now
        ):
            return existing  # idempotent: already entitled

        idempotency_key = f"sub:{user.id}:tutor_premium:{now.date().isoformat()}"
        result = await self._payments.subscribe(
            idempotency_key=idempotency_key,
            plan=SubscriptionPlan.tutor_premium,
            customer_email=user.email,
        )
        if await self._existing_payment(idempotency_key) is None:
            self._session.add(
                Payment(
                    user_id=user.id,
                    purpose=PaymentPurpose.tutor_premium,
                    amount_cents=TUTOR_PREMIUM_PRICE_CENTS,
                    currency="usd",
                    status=PaymentStatus.succeeded if result.succeeded else PaymentStatus.failed,
                    provider=result.provider,
                    provider_ref=result.provider_ref,
                    idempotency_key=idempotency_key,
                )
            )
        period_end = now + timedelta(days=TUTOR_PREMIUM_PERIOD_DAYS)
        if existing is None:
            existing = Subscription(
                user_id=user.id,
                plan=SubscriptionPlan.tutor_premium,
                status=SubscriptionStatus.active,
                current_period_end=period_end,
                provider_ref=result.provider_ref,
            )
            self._session.add(existing)
        else:
            existing.status = SubscriptionStatus.active
            existing.current_period_end = period_end
            existing.provider_ref = result.provider_ref
        await self._session.commit()
        return existing

    async def cancel_tutor_premium(self, *, user: User) -> Subscription:
        existing = await self._get_subscription(user.id, SubscriptionPlan.tutor_premium)
        if existing is None:
            raise NotFoundError("No subscription found.", code="SUBSCRIPTION_NOT_FOUND")
        # Entitlement runs to the end of the paid period.
        existing.status = SubscriptionStatus.canceled
        await self._session.commit()
        return existing

    async def _get_subscription(
        self, user_id: uuid.UUID, plan: SubscriptionPlan
    ) -> Subscription | None:
        result = await self._session.execute(
            select(Subscription).where(Subscription.user_id == user_id, Subscription.plan == plan)
        )
        return result.scalar_one_or_none()


async def has_tutor_premium(session: AsyncSession, user_id: uuid.UUID) -> bool:
    """Entitlement check (spec §13.2). Canceled subs keep access until period end."""
    result = await session.execute(
        select(Subscription).where(
            Subscription.user_id == user_id,
            Subscription.plan == SubscriptionPlan.tutor_premium,
            Subscription.status.in_([SubscriptionStatus.active, SubscriptionStatus.canceled]),
            Subscription.current_period_end > datetime.now(UTC),
        )
    )
    return result.scalar_one_or_none() is not None
