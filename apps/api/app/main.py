"""FastAPI app factory (spec §2.2)."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware

from app.api.v1.admin_metrics import router as admin_metrics_router
from app.api.v1.auth import router as auth_router
from app.api.v1.chats import router as chats_router
from app.api.v1.conversations import router as conversations_router
from app.api.v1.flags import router as flags_router
from app.api.v1.health import router as health_router
from app.api.v1.images import router as images_router
from app.api.v1.listings import router as listings_router
from app.api.v1.notifications import router as notifications_router
from app.api.v1.ratings import router as ratings_router
from app.api.v1.reports import router as reports_router
from app.api.v1.runs import router as runs_router
from app.api.v1.tutoring import router as tutoring_router
from app.api.v1.users import router as users_router
from app.api.v1.ws import router as ws_router
from app.core.config import get_settings
from app.core.errors import register_error_handlers
from app.core.logging import configure_logging
from app.core.security_headers import SecurityHeadersMiddleware


def _init_sentry(dsn: str, environment: str) -> None:
    """Crash reporting (spec §8). No-op unless SENTRY_DSN is provided."""
    if not dsn:
        return
    import sentry_sdk

    sentry_sdk.init(dsn=dsn, environment=environment, traces_sample_rate=0.1)


def create_app() -> FastAPI:
    settings = get_settings()
    configure_logging(json_logs=settings.is_prod)
    _init_sentry(settings.sentry_dsn, settings.app_env)

    app = FastAPI(
        title=settings.app_name,
        version="0.1.0",
        # Swagger UI is a dev tool (docs/owasp.md); ReDoc stays served in prod (spec M10).
        docs_url=None if settings.is_prod else "/docs",
        redoc_url="/redoc",
    )

    app.add_middleware(SecurityHeadersMiddleware)
    app.add_middleware(GZipMiddleware, minimum_size=1024)
    # In dev, allow any origin so Flutter web on any port works.
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"] if not settings.is_prod else settings.cors_origin_list,
        allow_credentials=settings.is_prod,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    register_error_handlers(app)

    app.include_router(health_router, prefix="/api/v1")
    app.include_router(flags_router, prefix="/api/v1")
    app.include_router(ws_router, prefix="/api/v1")
    app.include_router(auth_router, prefix="/api/v1")
    app.include_router(users_router, prefix="/api/v1")
    app.include_router(images_router, prefix="/api/v1")
    app.include_router(listings_router, prefix="/api/v1")
    app.include_router(conversations_router, prefix="/api/v1")
    app.include_router(ratings_router, prefix="/api/v1")
    app.include_router(reports_router, prefix="/api/v1")
    app.include_router(runs_router, prefix="/api/v1")
    app.include_router(tutoring_router, prefix="/api/v1")
    app.include_router(chats_router, prefix="/api/v1")
    app.include_router(notifications_router, prefix="/api/v1")
    app.include_router(admin_metrics_router, prefix="/api/v1")

    return app


app = create_app()
