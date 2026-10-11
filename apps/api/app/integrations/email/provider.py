"""Email provider selection by environment (spec §2.5)."""

from functools import lru_cache

from app.core.config import get_settings
from app.integrations.email.base import EmailProvider
from app.integrations.email.resend import ResendEmailProvider
from app.integrations.email.smtp import SmtpEmailProvider
from app.integrations.email.stub import StubEmailProvider


@lru_cache
def get_email_provider() -> EmailProvider:
    settings = get_settings()
    if settings.app_env == "test":
        return StubEmailProvider()
    if settings.email_provider_api_key:
        # Real HTTP provider: Resend (works in any env once a key is set).
        return ResendEmailProvider()
    if settings.app_env == "dev":
        # mailhog runs in docker-compose; falls back to warning log on failure.
        return SmtpEmailProvider()
    return StubEmailProvider()
