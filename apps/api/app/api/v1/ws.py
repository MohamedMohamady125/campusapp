"""Chat WebSocket endpoint (spec §14 M8) — dark unless flags.realtime is on.

Auth is a `token` query param (browsers/Flutter ws clients cannot set
Authorization headers on the upgrade request). Close codes mirror HTTP:
4401 unauthenticated, 4403 forbidden (flag off / not a member), 4404 not found.
"""

import asyncio
import uuid

import jwt as pyjwt
from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from app.core.security import decode_access_token
from app.db.session import async_session_factory
from app.models import User
from app.models.enums import UserStatus
from app.repositories.chat_repo import ChatRepository
from app.repositories.user_repo import UserRepository
from app.services.flag_service import is_enabled
from app.services.realtime import hub

router = APIRouter(tags=["realtime"])

WS_UNAUTHENTICATED = 4401
WS_FORBIDDEN = 4403
WS_NOT_FOUND = 4404


async def _authorize(websocket: WebSocket, chat_id: uuid.UUID, token: str) -> User | None:
    """Returns the user when allowed, otherwise closes the socket and returns None."""
    try:
        payload = decode_access_token(token)
    except pyjwt.PyJWTError:
        await websocket.close(code=WS_UNAUTHENTICATED)
        return None
    if payload.get("type") != "access":
        await websocket.close(code=WS_UNAUTHENTICATED)
        return None
    async with async_session_factory() as session:
        user = await UserRepository(session).get_by_id(uuid.UUID(payload["sub"]))
        if user is None or user.status != UserStatus.active:
            await websocket.close(code=WS_UNAUTHENTICATED)
            return None
        if not await is_enabled(session, "realtime", user_id=user.id):
            await websocket.close(code=WS_FORBIDDEN)
            return None
        repo = ChatRepository(session)
        if await repo.get(chat_id) is None:
            await websocket.close(code=WS_NOT_FOUND)
            return None
        membership = await repo.get_membership(chat_id, user.id)
        if membership is None or membership.banned_at is not None:
            await websocket.close(code=WS_FORBIDDEN)
            return None
        return user


@router.websocket("/ws/chats/{chat_id}")
async def chat_ws(websocket: WebSocket, chat_id: uuid.UUID, token: str = "") -> None:
    await websocket.accept()
    user = await _authorize(websocket, chat_id, token)
    if user is None:
        return
    queue = hub.subscribe(chat_id)

    async def _relay() -> None:
        while True:
            await websocket.send_json(await queue.get())

    relay = asyncio.create_task(_relay())
    try:
        while True:
            # Client frames are ignored (posting stays on HTTP); this detects disconnect.
            await websocket.receive_text()
    except WebSocketDisconnect:
        pass
    finally:
        relay.cancel()
        hub.unsubscribe(chat_id, queue)
