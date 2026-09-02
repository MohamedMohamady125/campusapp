"""Application configuration via Pydantic Settings (spec §2.1, §8 secrets)."""

from functools import lru_cache
from typing import Literal

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """All configuration comes from the environment; see /.env.example."""

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_env: Literal["dev", "test", "prod"] = "dev"
    app_name: str = "CampusConnect API"

    database_url: str = "postgresql+asyncpg://campus:campus@localhost:5434/campusconnect"

    @field_validator("database_url", mode="after")
    @classmethod
    def _use_async_driver(cls, v: str) -> str:
        # Managed Postgres (Railway/Render/Heroku) injects a sync-driver URL like
        # `postgres://` or `postgresql://`; our async stack (asyncpg) needs the
        # `+asyncpg` dialect. Rewrite the scheme so the platform URL works as-is.
        if v.startswith("postgres://"):
            return "postgresql+asyncpg://" + v[len("postgres://") :]
        if v.startswith("postgresql://"):
            return "postgresql+asyncpg://" + v[len("postgresql://") :]
        return v

    redis_url: str = "redis://localhost:6380/0"

    jwt_secret: str = "dev-secret-do-not-use-in-prod-0123456789ab"  # >=32 bytes (RFC 7518 §3.2)
    access_token_ttl_minutes: int = 15
    refresh_token_ttl_days: int = 30
    campus_email_domain: str = "campus.edu"

    s3_endpoint_url: str = "http://localhost:9000"
    s3_access_key: str = "minioadmin"
    s3_secret_key: str = "minioadmin"
    s3_bucket: str = "campusconnect"
    s3_region: str = "us-east-1"

    email_provider_api_key: str = ""
    email_from: str = "no-reply@campus.edu"
    smtp_host: str = "localhost"
    smtp_port: int = 1025

    moderation_api_key: str = ""

    stripe_secret_key: str = ""
    stripe_webhook_secret: str = ""

    sentry_dsn: str = ""

    cors_origins: str = "http://localhost:3000,http://localhost:8080"

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @property
    def is_prod(self) -> bool:
        return self.app_env == "prod"


@lru_cache
def get_settings() -> Settings:
    return Settings()
