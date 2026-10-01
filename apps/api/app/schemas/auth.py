"""Auth request/response contracts (spec §4.1 Auth)."""

import re
import uuid

from pydantic import BaseModel, EmailStr, Field, field_validator


def _check_password_complexity(value: str) -> str:
    """Industry-standard complexity: ≥8 chars with upper, lower and a digit.

    Mirrored client-side as a live checklist on the registration screen —
    keep the two in sync.
    """
    if not re.search(r"[A-Z]", value):
        raise ValueError("Password needs at least one uppercase letter.")
    if not re.search(r"[a-z]", value):
        raise ValueError("Password needs at least one lowercase letter.")
    if not re.search(r"\d", value):
        raise ValueError("Password needs at least one number.")
    return value


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    display_name: str = Field(min_length=2, max_length=80)

    _complexity = field_validator("password")(_check_password_complexity)


class RegisterResponse(BaseModel):
    user_id: uuid.UUID
    message: str


class VerifyRequest(BaseModel):
    email: EmailStr
    code: str = Field(pattern=r"^\d{6}$")


class ResendCodeRequest(BaseModel):
    email: EmailStr


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class RefreshRequest(BaseModel):
    refresh_token: str


class LogoutRequest(BaseModel):
    refresh_token: str


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    email: EmailStr
    code: str = Field(pattern=r"^\d{6}$")
    new_password: str = Field(min_length=8, max_length=128)

    _complexity = field_validator("new_password")(_check_password_complexity)


class CheckEmailRequest(BaseModel):
    email: EmailStr


class CheckEmailResponse(BaseModel):
    """Whether an account exists for this email (login/registration UX hint).

    Campus-scoped app: accounts are .edu-verified peers, so email-existence
    disclosure is an accepted trade-off for a far clearer sign-in flow.
    """

    exists: bool


class MessageResponse(BaseModel):
    message: str
