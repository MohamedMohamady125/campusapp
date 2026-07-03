"""User endpoints (spec §4.1 Users)."""

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user
from app.core.errors import NotFoundError
from app.db.session import get_session
from app.models import User
from app.repositories.user_repo import UserRepository
from app.schemas.user import UserMeResponse, UserPublicResponse, UserUpdateRequest

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=UserMeResponse)
async def get_me(user: User = Depends(get_current_user)) -> User:
    return user


@router.patch("/me", response_model=UserMeResponse)
async def update_me(
    body: UserUpdateRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> User:
    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(user, field, value)
    await session.commit()
    await session.refresh(user)
    return user


@router.get("/{user_id}", response_model=UserPublicResponse)
async def get_public_profile(
    user_id: uuid.UUID,
    _: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
) -> User:
    target = await UserRepository(session).get_by_id(user_id)
    if target is None:
        raise NotFoundError("User not found.", code="USER_NOT_FOUND")
    return target
