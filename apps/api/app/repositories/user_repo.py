"""User + auth-token data access (spec §2.4 repository layer)."""

import uuid
from datetime import datetime

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import RefreshToken, User, VerificationCode
from app.models.enums import VerificationPurpose


class UserRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def get_by_email(self, email: str) -> User | None:
        result = await self._session.execute(
            select(User).where(User.email == email, User.deleted_at.is_(None))
        )
        return result.scalar_one_or_none()

    async def get_by_id(self, user_id: uuid.UUID) -> User | None:
        result = await self._session.execute(
            select(User).where(User.id == user_id, User.deleted_at.is_(None))
        )
        return result.scalar_one_or_none()

    def add(self, user: User) -> None:
        self._session.add(user)

    # --- Verification codes ---

    def add_code(self, code: VerificationCode) -> None:
        self._session.add(code)

    async def latest_active_code(
        self, user_id: uuid.UUID, purpose: VerificationPurpose, now: datetime
    ) -> VerificationCode | None:
        result = await self._session.execute(
            select(VerificationCode)
            .where(
                VerificationCode.user_id == user_id,
                VerificationCode.purpose == purpose,
                VerificationCode.consumed_at.is_(None),
                VerificationCode.expires_at > now,
            )
            .order_by(VerificationCode.created_at.desc())
            .limit(1)
        )
        return result.scalar_one_or_none()

    # --- Refresh tokens ---

    def add_refresh_token(self, token: RefreshToken) -> None:
        self._session.add(token)

    async def get_refresh_token(self, token_hash: str) -> RefreshToken | None:
        result = await self._session.execute(
            select(RefreshToken).where(RefreshToken.token_hash == token_hash)
        )
        return result.scalar_one_or_none()

    async def revoke_all_for_user(self, user_id: uuid.UUID, now: datetime) -> None:
        """Revoke every active refresh token for a user (e.g., after password reset)."""
        result = await self._session.execute(
            select(RefreshToken).where(
                RefreshToken.user_id == user_id, RefreshToken.revoked_at.is_(None)
            )
        )
        for token in result.scalars():
            token.revoked_at = now

    async def revoke_family(self, family_id: uuid.UUID, now: datetime) -> None:
        """Revoke every token in a family — reuse detection response (spec §8)."""
        result = await self._session.execute(
            select(RefreshToken).where(
                RefreshToken.family_id == family_id, RefreshToken.revoked_at.is_(None)
            )
        )
        for token in result.scalars():
            token.revoked_at = now
