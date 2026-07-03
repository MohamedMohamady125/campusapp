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
