"""Server-side push copy — mirrors the Flutter notification_presenter titles.

Push is reserved for actionable moments (DoorDash/Uber Eats discipline):
`chat_message` room chatter stays in the in-app feed only, and the dedup
layer guarantees at most one push per context per hour (push fires on
insert, never when a notification folds into an existing unread one).
"""

from typing import Any

from app.integrations.push.base import PushMessage

# Types that interrupt the phone. Everything else is feed-only.
PUSH_TYPES: frozenset[str] = frozenset(
    {
        "run_request",
        "run_request_accepted",
        "run_request_declined",
        "run_status",
        "run_completed",
        "run_runner_arrived",
        "run_no_show",
        "run_payment_submitted",
        "run_payment_confirmed",
        "run_price_final",
        "dm_message",
        "chat_mention",
    }
)

# iOS time-sensitive interruption level: the 5-minute pickup window.
CRITICAL_TYPES: frozenset[str] = frozenset({"run_runner_arrived"})


def _str(payload: dict[str, Any], key: str) -> str | None:
    value = payload.get(key)
    return value if isinstance(value, str) and value else None


def _collapse_key(type_: str, payload: dict[str, Any]) -> str | None:
    """One banner per context: newer pushes replace undelivered older ones."""
    if type_ == "dm_message":
        cid = _str(payload, "conversation_id")
        return f"dm:{cid}" if cid else None
    if type_ == "chat_mention":
        cid = _str(payload, "chat_id")
        return f"chat:{cid}" if cid else None
    rid = _str(payload, "run_id")
    return f"run:{rid}" if rid else None


def render_push(type_: str, payload: dict[str, Any]) -> PushMessage | None:
    """Title/body per type; returns None for feed-only or malformed payloads."""
    if type_ not in PUSH_TYPES:
        return None
    spot = _str(payload, "spot_name")
    runner = _str(payload, "runner_name")
    title: str | None = None
    body = ""
    match type_:
        case "run_request":
            requester = _str(payload, "requester_name")
            title = (
                f"{requester} wants in on your {spot} run"
                if requester and spot
                else "New order request"
            )
            body = "Open the order to accept or decline."
        case "run_request_accepted":
            title = (
                f"You're in! Your {spot} order was accepted"
                if spot
                else "You're in! Your order was accepted"
            )
            body = "Track your run for live updates."
        case "run_request_declined":
            title = (
                f"The runner couldn't take your {spot} order"
                if spot
                else "The runner couldn't take your order"
            )
            body = "Browse open runs to try another."
        case "run_status":
            title, body = _run_status_copy(payload, spot=spot, runner=runner)
        case "run_completed":
            title = "Run complete — rate your runner"
            body = f"Your {spot} run is done. Leave a quick rating." if spot else ""
        case "run_runner_arrived":
            dropoff = _str(payload, "dropoff")
            title = (
                f"Your runner is at {dropoff} — you have 5 minutes!"
                if dropoff
                else "Your runner is here — you have 5 minutes!"
            )
            body = "Meet them now or your order can be marked a no-show."
        case "run_no_show":
            title = "Your order was marked a no-show"
            # Money copy stays loud: the requester may have prepaid.
            body = (
                "The 5-minute window passed. If you already paid, "
                "message the runner — you can also rate or report."
            )
        case "run_payment_submitted":
            requester = _str(payload, "requester_name")
            title = f"{requester} sent payment proof" if requester else "Payment proof received"
            body = "Review and confirm it in your run."
        case "run_payment_confirmed":
            title = "Runner confirmed your payment"
            body = "You're all set."
        case "run_price_final":
            # Money copy stays loud (payment-terms rule): the exact delta vs
            # the requester's estimate, in dollars, right in the banner.
            title, body = _price_final_copy(payload, spot=spot)
        case "dm_message":
            sender = _str(payload, "sender_name")
            title = f"{sender} sent you a message" if sender else "New message"
            body = "Open the chat to reply."
        case "chat_mention":
            sender = _str(payload, "sender_name")
            chat = _str(payload, "chat_name")
            title = f"{sender} mentioned you in {chat}" if sender and chat else "You were mentioned"
            body = "Jump back into the conversation."
    if title is None:
        return None
    data = {k: v for k, v in payload.items() if isinstance(v, str)}
    data["type"] = type_
    return PushMessage(
        title=title,
        body=body,
        data=data,
        collapse_key=_collapse_key(type_, payload),
        critical=type_ in CRITICAL_TYPES,
    )


def _price_final_copy(payload: dict[str, Any], *, spot: str | None) -> tuple[str, str]:
    title = f"Final price for your {spot} order" if spot else "Final price for your order"
    try:
        delta = int(payload.get("delta_cents", ""))
        actual = int(payload.get("actual_price_cents", ""))
    except ValueError:
        return title, "Open your order for the settle-up amount."
    actual_str = f"${actual / 100:.2f}"
    if delta > 0:
        return title, f"Items came to {actual_str} — you owe ${delta / 100:.2f} more."
    if delta < 0:
        return title, f"Items came to {actual_str} — the runner owes you ${-delta / 100:.2f} back."
    return title, f"Items came to {actual_str} — exactly your estimate. You're all set."


def _run_status_copy(
    payload: dict[str, Any], *, spot: str | None, runner: str | None
) -> tuple[str, str]:
    match _str(payload, "run_status"):
        case "at_store":
            title = f"Your runner is at {spot}" if spot else "Your runner is at the store"
            return title, "They're grabbing the order now."
        case "delivering":
            body = f"{runner} is heading to your dropoff." if runner else ""
            return "Your order is on its way", body
        case "cancelled":
            title = f"The {spot} run was cancelled" if spot else "That run was cancelled"
            # Money copy stays loud (payment-terms rule): tell prepayers what to do.
            return title, "If you already paid, message the runner to settle up."
    return "Your run has an update", ""
