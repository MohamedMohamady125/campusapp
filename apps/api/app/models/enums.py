"""Enum types shared across models (spec §3)."""

import enum


class UserRole(enum.StrEnum):
    student = "student"
    moderator = "moderator"
    admin = "admin"


class UserStatus(enum.StrEnum):
    active = "active"
    suspended = "suspended"
    banned = "banned"


class VerificationPurpose(enum.StrEnum):
    email_verify = "email_verify"
    password_reset = "password_reset"


class ListingCategory(enum.StrEnum):
    textbooks = "textbooks"
    furniture = "furniture"
    electronics = "electronics"
    tickets = "tickets"
    clothing = "clothing"
    other = "other"


class ListingCondition(enum.StrEnum):
    new = "new"
    like_new = "like_new"
    good = "good"
    fair = "fair"
    poor = "poor"


class ListingStatus(enum.StrEnum):
    active = "active"
    sold = "sold"
    removed = "removed"


class ModerationStatus(enum.StrEnum):
    pending = "pending"
    approved = "approved"
    rejected = "rejected"


class ConversationContext(enum.StrEnum):
    listing = "listing"
    tutoring = "tutoring"
    direct = "direct"
    run = "run"


class ChatVisibility(enum.StrEnum):
    open = "open"
    request = "request"
    private = "private"


class ChatRole(enum.StrEnum):
    member = "member"
    mod = "mod"
    owner = "owner"


class RatingContext(enum.StrEnum):
    listing = "listing"
    tutoring = "tutoring"
    run = "run"


class FoodSpotCategory(enum.StrEnum):
    campus = "campus"
    off_campus = "off_campus"


class RunStatus(enum.StrEnum):
    """Food run lifecycle (food-runs spec).

    open → locked → at_store → delivering → done
    Terminal alternates: expired (nobody joined / runner ghosted), cancelled.
    """

    open = "open"
    locked = "locked"
    at_store = "at_store"
    delivering = "delivering"
    done = "done"
    expired = "expired"
    cancelled = "cancelled"


class RunOrderStatus(enum.StrEnum):
    """Per-order lifecycle within a run.

    requested → accepted | declined | cancelled
    accepted → delivered → received | no_show
    """

    requested = "requested"
    accepted = "accepted"
    declined = "declined"
    cancelled = "cancelled"
    delivered = "delivered"
    received = "received"
    no_show = "no_show"


class ReportTargetType(enum.StrEnum):
    listing = "listing"
    message = "message"
    chat_message = "chat_message"
    user = "user"


class ReportStatus(enum.StrEnum):
    open = "open"
    reviewing = "reviewing"
    actioned = "actioned"
    dismissed = "dismissed"


class PaymentPurpose(enum.StrEnum):
    promoted_listing = "promoted_listing"
    tutor_premium = "tutor_premium"
    escrow = "escrow"


class PaymentStatus(enum.StrEnum):
    pending = "pending"
    succeeded = "succeeded"
    failed = "failed"
    refunded = "refunded"


class SubscriptionPlan(enum.StrEnum):
    tutor_premium = "tutor_premium"


class SubscriptionStatus(enum.StrEnum):
    active = "active"
    canceled = "canceled"
    expired = "expired"
