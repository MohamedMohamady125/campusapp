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
- ✅ (M10) Swagger UI (`/docs`) disabled in prod; `/redoc` intentionally kept for published API docs.

## A06 — Vulnerable & Outdated Components 🟡
- `pip-audit` run in M8 (see RUN_LOG for findings/date) and in CI (`ci-api.yml` audit step).
- Flutter dependency scan TODO(blocked): pub.dev unreachable from this network.

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
