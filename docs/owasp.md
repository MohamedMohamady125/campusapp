# OWASP Top 10 (2021) checklist — CampusConnect API (M8)

Status legend: ✅ addressed · 🟡 partial (noted follow-up) · N/A not applicable to v1 scope.

## A01 — Broken Access Control ✅
- Central authz layer: `get_current_user` / `require_role` in `app/core/deps.py`; routers never trust client-supplied user ids.
- Object-level checks in services: listing ownership (`NOT_OWNER`), conversation participants (`NOT_PARTICIPANT`), chat membership/mod gates (`NOT_MEMBER`, `NOT_CHAT_MOD`, `CANNOT_MODERATE_OWNER`), offering ownership.
- Admin/moderator surfaces (`/admin/reports`) gated by `require_role(moderator, admin)`.
- WebSocket `/ws/chats/{id}` re-validates token, flag, and membership before subscribing.

## A02 — Cryptographic Failures ✅
- Passwords: argon2id (passlib). Verification codes stored as sha256 digests, 10-min TTL, single-use.
- Refresh tokens stored hashed; rotation with family reuse detection (reuse revokes family).
- JWT secret from env only (`.env` never committed); HSTS header set (TLS termination at the edge in deploy).

## A03 — Injection ✅
- All SQL through SQLAlchemy bound parameters — no string-built SQL anywhere (`grep` clean).
- Search input passed to `plainto_tsquery` / `similarity()` as bind params.
- No shell-outs from request paths.

## A04 — Insecure Design ✅
- Rate limits (spec §8): login 5/15min, verification codes 3/15min, messages + chat posts 30/min → 429 + Retry-After.
- Email enumeration: register/verify/reset responses do not reveal account existence beyond spec behavior.
- Bayesian reputation resists single-rating manipulation; ratings unique per (rater, context).

## A05 — Security Misconfiguration ✅
- Security headers middleware: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: no-referrer`, `Strict-Transport-Security`, `Permissions-Policy`.
- CORS restricted to configured origins (no `*` with credentials).
- Error envelope hides internals; framework 500s return generic `INTERNAL` (no stack traces to clients).
- Content-Security-Policy: deny-all (`default-src 'none'; frame-ancestors 'none'`) on all JSON/API responses; relaxed CDN allowlist only on `/docs`, `/redoc`, `/openapi.json` (`security_headers.py`).
- ✅ (M10) Swagger UI (`/docs`) disabled in prod; `/redoc` intentionally kept for published API docs.

## A06 — Vulnerable & Outdated Components ✅
- `pip-audit` run in M8 and in CI (`ci-api.yml` audit step).
- 2026-10-11 audit: pyjwt 2.13.0 (8 PYSEC advisories) → upgraded to 2.15.1; urllib3 2.7.0 (3 PYSEC advisories) → upgraded to 2.8.0. Pins raised in `pyproject.toml`; re-audit clean (0 known vulnerabilities).
- 2026-10-11 Flutter scan: `dart pub outdated` run — no security advisories against current pins; upgrades available are feature/major bumps only (riverpod 3, freezed 3) deferred deliberately.

## A07 — Identification & Authentication Failures ✅
- Access tokens ~15 min; refresh rotation + reuse detection; logout and password reset revoke sessions.
- Login rate-limited; campus-domain email gate + mandatory email verification before login.
- Account status checked on every request (`ACCOUNT_INACTIVE`).

## A08 — Software & Data Integrity Failures ✅
- Signed upload flow: presigned POST with 5MB cap and jpeg/png/webp allowlist; images invisible until moderation approves.
- Alembic migrations reviewed & checked (`alembic check` drift gate); CI runs full lane on every push.

## A09 — Security Logging & Monitoring Failures ✅
- structlog everywhere; JSON logs in prod.
- AuditLog rows for every moderation action (report status changes, chat delete/mute/ban).
- ✅ (M10) Sentry initialized at app startup when `SENTRY_DSN` is set (no-op otherwise).

## A10 — Server-Side Request Forgery N/A
- API makes no requests to user-supplied URLs. Image fetching is client→S3 via presigned URLs only.
