"""Auth business logic (spec §14 M2, security rules §8).

Flow: register (.edu check) → 6-digit verification code (hashed at rest,
10-min expiry, single use) → login (argon2id) → JWT access + rotating
refresh tokens with family-reuse detection → logout revokes the family.
"""

import secrets
import uuid
from datetime import UTC, datetime, timedelta

import structlog
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.errors import (
    BusinessRuleError,
    ConflictError,
    UnauthenticatedError,
)
from app.core.rate_limit import enforce_rate_limit
from app.core.security import (
    create_access_token,
    hash_opaque_token,
    hash_password,
    verify_password,
)
from app.integrations.email.base import EmailProvider
from app.models import AuditLog, RefreshToken, User, VerificationCode
from app.models.enums import UserStatus, VerificationPurpose
from app.repositories.user_repo import UserRepository

log = structlog.get_logger()

CODE_TTL_MINUTES = 10
LOGIN_LIMIT = 5  # failed logins / window / account (spec §8)
LOGIN_WINDOW_SECONDS = 15 * 60
CODE_REQUEST_LIMIT = 3
CODE_REQUEST_WINDOW_SECONDS = 15 * 60


class AuthService:
    def __init__(self, session: AsyncSession, email_provider: EmailProvider) -> None:
        self._session = session
        self._repo = UserRepository(session)
        self._email = email_provider

    # --- Registration & verification ---

    async def register(self, *, email: str, password: str, display_name: str) -> User:
        settings = get_settings()
        domain = email.rsplit("@", 1)[-1].lower()
        if domain != settings.campus_email_domain:
            raise BusinessRuleError(
                f"Registration requires a @{settings.campus_email_domain} email.",
                code="EMAIL_DOMAIN_NOT_ALLOWED",
            )
        if await self._repo.get_by_email(email):
            raise ConflictError("An account with this email already exists.", code="EMAIL_TAKEN")

        user = User(
            email=email.lower(),
            password_hash=hash_password(password),
            display_name=display_name,
        )
        self._repo.add(user)
        await self._session.flush()
        await self._issue_code(user, VerificationPurpose.email_verify)
        self._session.add(
            AuditLog(
                actor_id=user.id, action="auth.register", target_type="user", target_id=user.id
            )
        )
        await self._session.commit()
        return user

    async def _issue_code(self, user: User, purpose: VerificationPurpose) -> None:
        await enforce_rate_limit(
            f"code:{user.id}:{purpose}",
            limit=CODE_REQUEST_LIMIT,
            window_seconds=CODE_REQUEST_WINDOW_SECONDS,
        )
        code = f"{secrets.randbelow(1_000_000):06d}"
        self._repo.add_code(
            VerificationCode(
                user_id=user.id,
                code_hash=hash_opaque_token(code),
                purpose=purpose,
                expires_at=datetime.now(UTC) + timedelta(minutes=CODE_TTL_MINUTES),
            )
        )
        subject = (
            "Verify your CampusConnect email"
            if purpose == VerificationPurpose.email_verify
            else "Reset your CampusConnect password"
        )
        await self._email.send(to=user.email, subject=subject, body=f"Your code is {code}.")

    async def resend_code(self, *, email: str) -> None:
        user = await self._repo.get_by_email(email.lower())
        # Do not reveal whether the account exists (spec §8).
        if user and user.email_verified_at is None:
            await self._issue_code(user, VerificationPurpose.email_verify)
            await self._session.commit()

    async def verify_email(self, *, email: str, code: str) -> None:
        user = await self._repo.get_by_email(email.lower())
        if not user:
            raise UnauthenticatedError("Invalid code.", code="CODE_INVALID")
        record = await self._consume_code(user, code, VerificationPurpose.email_verify)
        if record is None:
            raise UnauthenticatedError("Invalid or expired code.", code="CODE_INVALID")
        user.email_verified_at = datetime.now(UTC)
        await self._session.commit()

    async def _consume_code(
        self, user: User, code: str, purpose: VerificationPurpose
    ) -> VerificationCode | None:
        now = datetime.now(UTC)
        record = await self._repo.latest_active_code(user.id, purpose, now)
        if record is None or record.code_hash != hash_opaque_token(code):
            return None
        record.consumed_at = now  # single use
        return record

    # --- Login / tokens ---

    async def login(self, *, email: str, password: str) -> tuple[str, str]:
        await enforce_rate_limit(
            f"login:{email.lower()}", limit=LOGIN_LIMIT, window_seconds=LOGIN_WINDOW_SECONDS
        )
        user = await self._repo.get_by_email(email.lower())
        if not user or not verify_password(password, user.password_hash):
            raise UnauthenticatedError("Invalid email or password.", code="INVALID_CREDENTIALS")
        if user.email_verified_at is None:
            raise UnauthenticatedError("Email not verified.", code="EMAIL_NOT_VERIFIED")
        if user.status != UserStatus.active:
            raise UnauthenticatedError("Account is not active.", code="ACCOUNT_INACTIVE")
        user.last_active_at = datetime.now(UTC)
        tokens = await self._mint_tokens(user, family_id=uuid.uuid4())
        await self._session.commit()
        return tokens

    async def _mint_tokens(self, user: User, *, family_id: uuid.UUID) -> tuple[str, str]:
        settings = get_settings()
        refresh_raw = secrets.token_urlsafe(48)
        self._repo.add_refresh_token(
            RefreshToken(
                user_id=user.id,
                token_hash=hash_opaque_token(refresh_raw),
                family_id=family_id,
                expires_at=datetime.now(UTC) + timedelta(days=settings.refresh_token_ttl_days),
            )
        )
        return create_access_token(user.id, user.role.value), refresh_raw

    async def refresh(self, *, refresh_token: str) -> tuple[str, str]:
        """Rotate the refresh token; a reused token revokes its whole family (spec §8)."""
        now = datetime.now(UTC)
        record = await self._repo.get_refresh_token(hash_opaque_token(refresh_token))
        if record is None:
            raise UnauthenticatedError("Invalid refresh token.", code="REFRESH_INVALID")
        if record.revoked_at is not None or record.replaced_by_hash is not None:
            # Reuse detected — the family is compromised.
            await self._repo.revoke_family(record.family_id, now)
            await self._session.commit()
            log.warning("auth.refresh_reuse_detected", user_id=str(record.user_id))
            raise UnauthenticatedError("Refresh token reuse detected.", code="REFRESH_REUSED")
        if record.expires_at < now:
            raise UnauthenticatedError("Refresh token expired.", code="REFRESH_EXPIRED")
        user = await self._repo.get_by_id(record.user_id)
        if user is None or user.status != UserStatus.active:
            raise UnauthenticatedError("Account is not active.", code="ACCOUNT_INACTIVE")
        access, new_refresh = await self._mint_tokens(user, family_id=record.family_id)
        record.revoked_at = now
        record.replaced_by_hash = hash_opaque_token(new_refresh)
        await self._session.commit()
        return access, new_refresh

    async def logout(self, *, refresh_token: str) -> None:
        record = await self._repo.get_refresh_token(hash_opaque_token(refresh_token))
        if record is not None:
            await self._repo.revoke_family(record.family_id, datetime.now(UTC))
            await self._session.commit()

    # --- Password reset ---

    async def forgot_password(self, *, email: str) -> None:
        user = await self._repo.get_by_email(email.lower())
        # Never reveal whether the account exists.
        if user:
            await self._issue_code(user, VerificationPurpose.password_reset)
            await self._session.commit()

    async def reset_password(self, *, email: str, code: str, new_password: str) -> None:
        user = await self._repo.get_by_email(email.lower())
        if not user:
            raise UnauthenticatedError("Invalid or expired code.", code="CODE_INVALID")
        record = await self._consume_code(user, code, VerificationPurpose.password_reset)
        if record is None:
            raise UnauthenticatedError("Invalid or expired code.", code="CODE_INVALID")
        user.password_hash = hash_password(new_password)
        await self._repo.revoke_all_for_user(user.id, datetime.now(UTC))
        await self._session.commit()
