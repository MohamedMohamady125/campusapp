"""Auth endpoints (spec §4.1 Auth)."""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.integrations.email.provider import get_email_provider
from app.schemas.auth import (
    ForgotPasswordRequest,
    LoginRequest,
    LogoutRequest,
    MessageResponse,
    RefreshRequest,
    RegisterRequest,
    RegisterResponse,
    ResendCodeRequest,
    ResetPasswordRequest,
    TokenResponse,
    VerifyRequest,
)
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["auth"])


def _service(session: AsyncSession = Depends(get_session)) -> AuthService:
    return AuthService(session, get_email_provider())


@router.post("/register", response_model=RegisterResponse, status_code=201)
async def register(body: RegisterRequest, svc: AuthService = Depends(_service)) -> RegisterResponse:
    user = await svc.register(
        email=body.email, password=body.password, display_name=body.display_name
    )
    return RegisterResponse(user_id=user.id, message="Verification code sent to your email.")


@router.post("/verify", response_model=MessageResponse)
async def verify(body: VerifyRequest, svc: AuthService = Depends(_service)) -> MessageResponse:
    await svc.verify_email(email=body.email, code=body.code)
    return MessageResponse(message="Email verified. You can now log in.")


@router.post("/resend-code", response_model=MessageResponse)
async def resend_code(
    body: ResendCodeRequest, svc: AuthService = Depends(_service)
) -> MessageResponse:
    await svc.resend_code(email=body.email)
    return MessageResponse(message="If the account exists, a new code has been sent.")


@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest, svc: AuthService = Depends(_service)) -> TokenResponse:
    access, refresh = await svc.login(email=body.email, password=body.password)
    return TokenResponse(access_token=access, refresh_token=refresh)


@router.post("/refresh", response_model=TokenResponse)
async def refresh(body: RefreshRequest, svc: AuthService = Depends(_service)) -> TokenResponse:
    access, new_refresh = await svc.refresh(refresh_token=body.refresh_token)
    return TokenResponse(access_token=access, refresh_token=new_refresh)


@router.post("/logout", response_model=MessageResponse)
async def logout(body: LogoutRequest, svc: AuthService = Depends(_service)) -> MessageResponse:
    await svc.logout(refresh_token=body.refresh_token)
    return MessageResponse(message="Logged out.")


@router.post("/forgot-password", response_model=MessageResponse)
async def forgot_password(
    body: ForgotPasswordRequest, svc: AuthService = Depends(_service)
) -> MessageResponse:
    await svc.forgot_password(email=body.email)
    return MessageResponse(message="If the account exists, a reset code has been sent.")


@router.post("/reset-password", response_model=MessageResponse)
async def reset_password(
    body: ResetPasswordRequest, svc: AuthService = Depends(_service)
) -> MessageResponse:
    await svc.reset_password(email=body.email, code=body.code, new_password=body.new_password)
    return MessageResponse(message="Password updated. Please log in.")
