"""SMTP adapter — used locally against mailhog when configured."""

import smtplib
from email.message import EmailMessage

import anyio
import structlog

from app.core.config import get_settings
from app.integrations.email.base import EmailProvider

log = structlog.get_logger()


class SmtpEmailProvider(EmailProvider):
    async def send(self, *, to: str, subject: str, body: str) -> None:
        settings = get_settings()

        def _send_sync() -> None:
            msg = EmailMessage()
            msg["From"] = settings.email_from
            msg["To"] = to
            msg["Subject"] = subject
            msg.set_content(body)
            with smtplib.SMTP(settings.smtp_host, settings.smtp_port, timeout=5) as smtp:
                smtp.send_message(msg)

        try:
            # smtplib is sync; keep it off the event loop (spec §7.2).
            await anyio.to_thread.run_sync(_send_sync)
        except OSError:
            log.warning("email.smtp_failed", to=to, subject=subject)
