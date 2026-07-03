"""Shared FastAPI dependencies: auth, roles (spec §8 AuthZ central policy layer)."""

import uuid
from typing import Any

import jwt as pyjwt
from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import ForbiddenError, UnauthenticatedError
from app.core.security import decode_access_token
from app.db.session import get_session
from app.models import User
from app.models.enums import UserRole, UserStatus
from app.repositories.user_repo import UserRepository

_bearer = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer),
    session: AsyncSession = Depends(get_session),
) -> User:
    if credentials is None:
        raise UnauthenticatedError("Missing bearer token.", code="MISSING_TOKEN")
    try:
        payload = decode_access_token(credentials.credentials)
    except pyjwt.PyJWTError as exc:
        raise UnauthenticatedError("Invalid or expired token.", code="TOKEN_INVALID") from exc
    if payload.get("type") != "access":
        raise UnauthenticatedError("Invalid token type.", code="TOKEN_INVALID")
    user = await UserRepository(session).get_by_id(uuid.UUID(payload["sub"]))
    if user is None or user.status != UserStatus.active:
        raise UnauthenticatedError("Account is not active.", code="ACCOUNT_INACTIVE")
    return user


def require_role(*roles: UserRole) -> Any:  # FastAPI Depends marker
    async def _checker(user: User = Depends(get_current_user)) -> User:
        if user.role not in roles:
            raise ForbiddenError("Insufficient permissions.", code="INSUFFICIENT_ROLE")
        return user

    return Depends(_checker)
