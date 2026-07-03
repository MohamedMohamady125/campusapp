"""Monetization rails (spec §13): payment ledger + subscriptions. All flag-gated, off in v1."""

import uuid
from datetime import datetime
from typing import Any

from sqlalchemy import DateTime, Enum, ForeignKey, Index, Integer, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import TimestampedBase
from app.models.enums import PaymentPurpose, PaymentStatus, SubscriptionPlan, SubscriptionStatus


class Payment(TimestampedBase):
    """Ledger row for every money movement (spec §13: auditability).

    idempotency_key is unique — retried charges reuse the existing row
    instead of double-charging.
    """

    __tablename__ = "payments"
    __table_args__ = (Index("ix_payments_user_created", "user_id", "created_at"),)

    user_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), index=True
    )
    purpose: Mapped[PaymentPurpose] = mapped_column(Enum(PaymentPurpose, name="payment_purpose"))
    amount_cents: Mapped[int] = mapped_column(Integer)
    currency: Mapped[str] = mapped_column(String(3), default="usd")
    status: Mapped[PaymentStatus] = mapped_column(
        Enum(PaymentStatus, name="payment_status"), default=PaymentStatus.pending
    )
    provider: Mapped[str] = mapped_column(String(20))  # "stub" | "stripe"
    provider_ref: Mapped[str | None] = mapped_column(String(255))
    idempotency_key: Mapped[str] = mapped_column(String(255), unique=True)
    metadata_: Mapped[dict[str, Any]] = mapped_column("metadata", JSONB, default=dict)


class Subscription(TimestampedBase):
    """Entitlement scaffold (spec §13.2 tutor premium). One active row per (user, plan)."""

    __tablename__ = "subscriptions"
    __table_args__ = (UniqueConstraint("user_id", "plan", name="uq_subscription_user_plan"),)

    user_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    plan: Mapped[SubscriptionPlan] = mapped_column(Enum(SubscriptionPlan, name="subscription_plan"))
    status: Mapped[SubscriptionStatus] = mapped_column(
        Enum(SubscriptionStatus, name="subscription_status"), default=SubscriptionStatus.active
    )
    current_period_end: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    provider_ref: Mapped[str | None] = mapped_column(String(255))
