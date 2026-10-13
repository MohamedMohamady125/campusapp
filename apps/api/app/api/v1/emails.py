"""One-click email unsubscribe (CAN-SPAM) — public, token-authenticated.

The link in every marketing / run-alert footer lands here. The token is an
HMAC-signed (user_id, scope) pair minted in email_program — no login needed,
because the person clicking may not have the app installed anymore. Flips the
matching NotificationPreference row to disabled; the in-app preference screen
can re-enable it later.
"""

from fastapi import APIRouter, Depends
from fastapi.responses import HTMLResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.models import NotificationPreference
from app.services.email_program import PREF_MARKETING, PREF_RUN_POSTED, parse_unsubscribe_token

router = APIRouter(tags=["emails"])

_PAGE = """<!doctype html>
<html><head><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Trot</title></head>
<body style="font-family:-apple-system,sans-serif;background:#FAF6F0;color:#2B2B2B;
display:flex;align-items:center;justify-content:center;min-height:90vh;text-align:center">
<div><h2>{heading}</h2><p>{message}</p></div></body></html>"""

_SCOPE_LABELS = {
    PREF_MARKETING: "marketing emails",
    PREF_RUN_POSTED: "new-run alerts",
}


@router.get("/emails/unsubscribe", response_class=HTMLResponse)
async def unsubscribe(token: str, session: AsyncSession = Depends(get_session)) -> HTMLResponse:
    parsed = parse_unsubscribe_token(token)
    if parsed is None or parsed[1] not in _SCOPE_LABELS:
        return HTMLResponse(
            _PAGE.format(heading="Link not valid", message="This unsubscribe link is invalid."),
            status_code=400,
        )
    user_id, scope = parsed
    existing = (
        (
            await session.execute(
                select(NotificationPreference).where(
                    NotificationPreference.user_id == user_id,
                    NotificationPreference.type == scope,
                )
            )
        )
        .scalars()
        .first()
    )
    if existing is not None:
        existing.enabled = False
    else:
        session.add(NotificationPreference(user_id=user_id, type=scope, enabled=False))
    await session.commit()
    return HTMLResponse(
        _PAGE.format(
            heading="You're unsubscribed",
            message=f"You won't get {_SCOPE_LABELS[scope]} from Trot anymore.",
        )
    )
