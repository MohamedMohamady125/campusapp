# CampusConnect — RUN LOG

▶ NEXT: Flutter M4 — marketplace browse (GET /listings via generated client, infinite scroll, skeletons) + listing detail; then tutoring/chats/messaging UIs (M5–M7 Flutter). Note: background shells lose Makefile env — `export PUB_HOSTED_URL=https://pub.flutter-io.cn FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn` before any flutter/dart pub command.

## Plan checklist
- [x] M0 — Foundation (repo, tooling, CI skeleton) — API green; Flutter scaffold UNBLOCKED + green via pub mirror
- [x] M1 — Data model & seed
- [x] M2 — Auth & identity — API done; Flutter done (c8ef080): generated campus_api client (§2.3), secure tokens, refresh interceptor, auth screens + router guard, 9 widget tests green
- [x] M3 — Design system + app shell — theme tokens, shell, generated client wired; widget library grows per-feature
- [x] M4 — Marketplace core (J1 + browse) — API done; Flutter UI TODO(blocked)
- [x] M5 — Messaging + reputation — API done; Flutter UI TODO(blocked)
- [x] M6 — Tutoring — API done; Flutter UI TODO(blocked)
- [x] M7 — Community chats — API done; Flutter UI TODO(blocked)
- [x] M8 — Hardening: perf, security — API done; a11y + Flutter scans TODO(blocked)
- [x] M9 — Monetization & analytics rails (flags OFF) — API done; admin dashboard UI TODO(blocked)
- [x] M10 — Deploy & docs — API side done; web/mobile deploy legs guarded + TODO(blocked)

## Journal

### 2026-07-03 — session start
- Environment: Flutter 3.35.3, Python 3.12.11, Docker Desktop (starting).
- `campusconnect/` was not a git repo (parent home dir was). Ran `git init -b main` inside it to isolate.
- Created monorepo layout per §2.2. Beginning M0.

### M0 — Foundation (partial: API green, Flutter blocked)
- FastAPI app factory + /health + /health/ready, error envelope §4.2, structlog, CORS+gzip.
- docker-compose infra all healthy. NOTE: host port 5433 was taken → Postgres mapped to **5434**.
- ruff + mypy(strict) + pytest green (3 tests). OpenAPI exported to contracts/openapi.json.
- CI lanes written (.github/workflows/ci-api.yml, ci-mobile.yml). Makefile targets work.
- TODO(blocked): `flutter create` hangs/fails — pub.dev unreachable from this network
  ("Got socket error trying to find package test at https://pub.dev"). Docker Hub also flaky
  (pull needed retry). Will retry Flutter scaffold periodically; proceeding with backend milestones.

### M1 — Data model & seed ✅
- All §3 models in SQLAlchemy 2.0 typed style: users, verification_codes, refresh_tokens,
  listings (+images, tsvector generated column, pg_trgm index), courses, tutor_offerings,
  conversations/participants/messages, chats/memberships/chat_messages, ratings, reports,
  audit_logs, notifications/preferences, flags.
- Migration e7043368b2f4 applied on clean DB; `alembic check` = no drift.
- Seed: 50 courses, 20 verified users, 40 listings w/ images, 16 tutor offerings, 5 chats
  (33 memberships, 25 messages), 30 ratings, 5 feature flags (all off). Idempotent (skips if users exist).
- Acceptance: scripts/row_counts.py prints all tables populated ✓; seed rerun skips ✓; pytest green ✓.

### M2 — Auth & identity (API ✅, Flutter blocked)
- Full flow: register (campus.edu gate) → email code verify (stub provider, sha256 at rest,
  10-min TTL, single-use) → login (argon2id) → JWT access (~15 min) + rotating refresh with
  family reuse detection (reuse revokes whole family, code REFRESH_REUSED) → logout → password
  reset (revokes all sessions). Rate limits: login 5/15min, code requests 3/15min → 429 + Retry-After.
- Public profile endpoint never returns email. 10 tests green; committed 23249e0.

### M4 — Marketplace core (API ✅, Flutter blocked)
- Listing CRUD with ownership checks (403 NOT_OWNER), 90-day TTL, soft delete.
- Search §5.3: FTS (generated tsvector, plainto_tsquery + ts_rank) blended with pg_trgm
  similarity (>0.2) for typo tolerance; all filters are SQL WHERE clauses. Recency feed uses
  keyset cursor (created_at,id); ranked search returns no cursor by design.
- Signed uploads §2.5: presigned POST via storage interface (S3/MinIO real, stub in tests),
  5MB cap, jpeg/png/webp allowlist; moderation gate — images invisible until approved
  (stub rejects keys containing "reject"). TODO: real deployments move review to Celery webhook.
- Celery §5.4: beat 3:00/3:15/3:30 — expire_listings, recompute_global_mean (seed 4.0),
  purge_verification_codes. Job bodies are plain async fns, tested idempotent.
- N+1 guard: selectinload(seller, images) + query-count assertion test (≤5 SELECTs).
- Lane green: ruff ✓ mypy strict ✓ 19 tests ✓. OpenAPI re-exported.

### M5 — Messaging + reputation (API ✅, Flutter blocked)
- Conversations §4.1: get-or-create per (context, participant pair) — no duplicate threads;
  participant-gated (403 NOT_PARTICIPANT on cross-user access); keyset-cursor pagination on
  conversation list + messages; POST /read sets last_read_at + marks others' messages read.
  Message spam rate-limited (30/min per user, spec §8).
- Ratings §5.2: POST /ratings validates context (real listing), blocks self-rating (422
  SELF_RATING) and double-rating (409 ALREADY_RATED via unique (rater, context));
  cached reputation_score + rating_count recomputed **inside the rating transaction** with
  Bayesian (C*m + sum)/(C + n), C=8, m=live global mean seeded 4.0. Constants centralized
  in app/core/scoring.py (also holds §5.1 weights for M6); jobs.py imports from there.
- Reports: POST /reports; GET/PATCH /admin/reports gated by require_role(moderator, admin);
  every status change writes an AuditLog row.
- Acceptance: two users exchange messages E2E ✓; reputation unit tests incl. cold-start
  (neutral prior, 2×5★ < 200×4.8★) ✓; rating updates cached score in txn (visible on
  profile immediately) ✓; cross-user conversation access 403 ✓.
- Lane green: ruff ✓ mypy strict ✓ 30 tests ✓. OpenAPI re-exported.
- Note: framework boundary validation returns envelope 400 (not FastAPI's default 422).

### M6 — Tutoring (API ✅, Flutter blocked)
- Endpoints §4.1: GET /courses (autocomplete: code prefix + title substring, limit 10),
  POST/DELETE /tutoring/offerings (unique per tutor+course → 409 ALREADY_OFFERING; delete
  deactivates, owner-only 403 NOT_OWNER), GET /tutoring/tutors?course=CS250 (ranked §5.1).
- Ranking §5.1 in pure module app/services/tutor_ranking.py (unit-testable, no DB):
  0.60*reputation + 0.30*recency + 0.10*responsiveness, all min-max normalized over the
  candidate pool. Responsiveness = median reply latency last 30 days (computed from M5
  messages), inverted; tutors with no data get the pool median (neutral prior — never
  floored to last). Degenerate all-equal pools norm to 1.0 (nobody penalized).
  Tie-break: rating_count desc → last_active_at desc. Weights live in app/core/scoring.py.
- Acceptance: E2E J2 (course code → ranked list → message top tutor via M5 conversation
  with tutoring context) ✓; ranking unit tests assert weights + tie-breaks ✓; new tutor not
  floored ✓.
- Lane green: ruff ✓ mypy strict ✓ 39 tests ✓. OpenAPI re-exported.

### M7 — Community chats (API ✅, Flutter blocked)
- Endpoints §4.1: GET /chats (mine), GET /chats/directory (private hidden), POST /chats
  (auto-slug w/ uniquing, creator becomes owner), join/leave, chat messages (cursor),
  mod actions delete/mute/ban, notifications feed + read + preferences.
- Rules: member_cap enforced (422 CHAT_FULL); private → 403 PRIVATE_CHAT; request
  visibility gated 422 JOIN_REQUIRES_APPROVAL (TODO: approval queue post-v1); banned users
  cannot rejoin (403 BANNED); owner cannot leave; owner cannot be moderated; muted members
  blocked from posting (403 MUTED); chat spam rate-limited 30/min.
- Moderation: every delete/mute/ban writes AuditLog (action, target, metadata).
- Notifications: per-event fan-out to members on new chat message, honoring per-type
  preferences (default enabled); GET /notifications returns unread_count for bell badge;
  POST /notifications/read marks selected/all.
- Acceptance: E2E J3 (browse→join→post) ✓; mod delete/mute/ban with audit entries ✓;
  notifications fire per preferences ✓; caps + visibility ✓.
- Lane green: ruff ✓ mypy strict ✓ 43 tests ✓. OpenAPI re-exported.

### M8 — Hardening (API ✅; a11y/Flutter scans blocked)
- Security headers: pure-ASGI middleware (nosniff, DENY frames, no-referrer, HSTS 2y,
  permissions-policy) — leaves WebSocket scopes untouched.
- GET /flags (spec §4.1 Meta) + flag_service.is_enabled(session, key, user_id=None):
  deterministic sha256 rollout bucketing per (flag, user); partial rollouts stay dark for
  anonymous callers. invalidate_flags_cache() for M9 admin writes.
- app/core/cache.py: Redis JSON cache w/ TTL + delete_prefix; in-memory fallback in test env
  (mirrors rate_limit.py pattern); reset_cache() wired into conftest. Consumers: flags (30s),
  tutor ranked search (30s, key tutors:{CODE}, invalidated on offering create/deactivate).
- WebSocket /api/v1/ws/chats/{id}?token= behind **flags.realtime** (dark by default): close
  codes 4401/4403/4404 mirror HTTP; re-validates token + flag + membership + ban; in-process
  ChatHub pub/sub — chat_service publishes after commit. TODO(post-v1): Redis pub/sub for
  multi-worker fan-out. Flutter ws transport TODO(blocked): pub.dev.
- Index/query audit: all hot paths already covered by composite indexes (chat_messages
  chat_id+created_at, notifications user_id+created_at, messages conversation_id+created_at,
  listings GIN tsvector + trgm + status/created + category/price, offerings course+active,
  ratings/reports/audit) — no new migration needed.
- docs/owasp.md: Top-10 checklist complete; open items flagged for M10 (disable /docs in
  prod, init Sentry, CI pip-audit lane). pip-audit: **no known vulnerabilities**.
- infra/k6/smoke.js (5 VUs/30s, p95<250ms per §7, error rate<1%) + `make k6-smoke`;
  `make audit-api` runs pip-audit.
- JWT dev/default secrets lengthened to ≥32 bytes (RFC 7518 §3.2 warning gone in prod paths).
- Tests +5 (48 total): headers, flags endpoint + cache staleness/reset, rollout determinism,
  WS gating (dark without flag, 4401 bad token, live message over WS after flag on —
  starlette TestClient), tutor-search cache invalidation on offering create.

### M9 — Monetization & analytics rails (API ✅; admin dashboard UI blocked)
- **All rails dark by default** (guardrail §16): promoted_listings + tutor_premium behind
  flags; escrow + partner_slots remain design-only stubs (PaymentPurpose.escrow reserved).
  No real charge path: get_payments_provider() returns Stripe adapter ONLY if
  is_prod AND stripe_secret_key set; otherwise StubPaymentsProvider (deterministic
  sha256 refs). Stripe adapter is raw httpx REST + HMAC webhook verify (300s tolerance).
- Ledger: Payment table with **unique idempotency_key** — retries reuse the existing row,
  never double-charge. Subscription table unique (user_id, plan).
- Promoted listings (§13.1): POST /listings/{id}/promote — flag-gated (403
  FEATURE_DISABLED), owner-only (403 NOT_OWNER), $3/7d via stub. Boost is single-active:
  promoting an already-boosted listing is an idempotent no-op. Ranked text search
  prepends `case(boosted_until > now())` desc when the flag is on; recency feed keyset
  order untouched.
- Tutor premium (§13.2): POST/DELETE /tutoring/premium/subscription — $5/30d, idempotent
  while active; cancel keeps entitlement until period end (has_tutor_premium checks
  active|canceled + period_end > now). Ranked tutors expose `premium` badge when flag on.
- Analytics (§12): AnalyticsProvider interface + DbAnalyticsProvider (writes in caller's
  txn, never raises). Emissions: signup_completed, listing_created, message_sent,
  chat_joined, rating_submitted, tutor_match_viewed. aggregate_daily_metrics_job:
  idempotent delete-and-rewrite per day incl. active_peers (distinct users); Celery beat
  nightly 03:45. GET /admin/metrics (moderator/admin) → totals + daily series for the
  Flutter-web dashboard (UI TODO(blocked): pub.dev).
- Migration 53a611bb60bc (payments, subscriptions, analytics_events, daily_metrics) —
  applied, `alembic check` clean.
- Acceptance §14 M9: flag on → promoted listing outranks newer sibling ✓; analytics events
  land in table ✓; admin metrics endpoint serves dashboard data ✓; no real charge path ✓.
- Tests +6 (54 total). Lane green: ruff ✓ format ✓ mypy strict ✓ pytest 54 ✓. OpenAPI
  re-exported.

### M10 — Deploy & docs (API ✅; web/mobile deploy legs blocked)
- .github/workflows/deploy.yml (spec §11): tag `v*` or manual dispatch → **migrate →
  deploy API → deploy web + mobile artifacts → smoke → rollback-on-failure**. Every cloud
  step is guarded by its secret (PROD_DATABASE_URL, RENDER_DEPLOY_HOOK, PROD_API_URL,
  VERCEL_DEPLOY_HOOK, RENDER_ROLLBACK_HOOK) so the pipeline **dry-runs green with zero
  credentials** — acceptance "deploy pipeline dry-run/documented" ✓. Web/mobile leg skips
  itself while apps/mobile has no pubspec.lock (TODO(blocked): pub.dev).
- Smoke gate: /health/ready 200 (retries 2 min) + public /flags read + unauthenticated
  /listings must be 401 (auth boundary probe). Same checks documented for manual runs.
- docs/RUNBOOK.md: environments, full prod env-var table (incl. §16 warning on Stripe
  keys), deploy + manual deploy commands (gunicorn/uvicorn workers, celery worker+beat),
  **forward-only migration rollback policy**, flag-flip instant rollback, routine ops
  (migrations, seed, flags, nightly jobs, backups, k6, pip-audit), incident quick
  reference, and the human plug-in list.
- Prod hardening (closes owasp.md 🟡 items): Swagger UI off when APP_ENV=prod (**/redoc
  stays served** per M10 "OpenAPI/redoc served"); Sentry initialized at startup when
  SENTRY_DSN set (sentry-sdk dep added — justification: prod crash reporting §8).
- README: quickstart already ≤5 commands (clone → make dev → make seed → flutter run);
  added deploy section + ReDoc pointer.
- Final lane green: ruff ✓ format ✓ mypy strict ✓ **pytest 54/54 ✓**. Tagged v1.0.0-rc1.

## Handoff summary (spec §17 step 5)

**Done (API, all green):** M0–M2, M4–M10 backend: verified .edu auth (argon2 + JWT
rotation + email verify), marketplace (listings, images w/ moderation gate, FTS + trgm
search, cursor pagination, expiry sweep), messaging + Bayesian reputation, tutoring
(offerings + ranked match + premium badge), community chats (mod tools, notifications),
hardening (headers, flags w/ % rollout, Redis cache, WS realtime behind flag, k6,
owasp.md), monetization rails **dark** (promoted listings, tutor premium, Payment ledger
w/ idempotency), analytics events + nightly daily_metrics + /admin/metrics, CI (ci-api,
ci-mobile, deploy). 54 tests; contracts/openapi.json current.

**Stubbed (interface + stub adapter, real adapter activates via env key):** email
(SMTP/Mailhog stub), moderation (allow-all stub w/ audit), payments (stub provider; Stripe
adapter exists but requires APP_ENV=prod + key + flag + human review per §16), analytics
(DB table adapter), storage (MinIO dev; real S3 via env).

**Blocked (pub.dev unreachable all session — retried every milestone):** the entire
Flutter app: M0 scaffold, M2 auth screens, M3 design system/app shell, M4–M7 UIs, M8 a11y
scans, M9 admin dashboard (Flutter-web), M10 web/mobile deploy legs. First unblocked
steps: `flutter create` per spec layout → generate dart-dio client from
contracts/openapi.json → proceed M2→M3→… UI work.

**A human must plug in:** real S3 + email + moderation keys, Stripe keys (only with §16
review), SENTRY_DSN, deploy-hook secrets (PROD_DATABASE_URL, RENDER_DEPLOY_HOOK,
PROD_API_URL, VERCEL_DEPLOY_HOOK), FCM/APNs certs (post-v1 push), DNS/TLS, app-store
credentials, production CAMPUS_EMAIL_DOMAIN, instructor GitHub invite.

**How to run:** `make dev` (API :8000 + Postgres/Redis/MinIO/Mailhog) → `make seed` →
`make ci` for the full verification lane. Ops: docs/RUNBOOK.md.

### Flutter M0 — scaffold UNBLOCKED (pub mirror)
- Root cause found: pub.dev's GCP IP is blocked from this network while the rest of the
  internet works. Official community mirror pub.flutter-io.cn + storage.flutter-io.cn is
  reachable → exported PUB_HOSTED_URL / FLUTTER_STORAGE_BASE_URL in the Makefile
  (overridable; GitHub CI still uses pub.dev).
- `flutter create` (ios/android/web, org edu.campus) ✓. Deps per spec §2.1 pinned to the
  Riverpod v2 + freezed v2 codegen line (build_runner ^2.4 — 2.15's build 4.x conflicts
  with the v2 generators; json_annotation ^4.9 for freezed 2.5 compat).
- Strict lints: very_good_analysis (flutter_lints dropped), generated files excluded.
- Spec layout started: core/{env,theme,router,network} + features/{marketplace,tutoring,
  chats,profile}/presentation + shared/widgets. Material 3 seeded light+dark themes with
  spacing/radius tokens (§6.1); go_router StatefulShellRoute bottom nav (Market/Tutors/
  Chats/Profile, §6.3 thumb zone); EmptyState widget (never a dead end); dio provider
  reading API_BASE_URL dart-define.
- Tests: 3 widget tests incl. tab switching and a11y tap-target/labeled guidelines ✓.
- `make ci-mobile` green (format ✓ analyze 0 issues ✓ tests ✓); `flutter build web` ✓.

### Flutter M2 — auth & identity UI (commit c8ef080)
- Generated typed client from contracts/openapi.json via openapi-generator dart-dio
  (`apps/mobile/api_client`, package `campus_api`) — spec §2.3, no hand-written models.
- TokenStorage on flutter_secure_storage (§8); AuthInterceptor (QueuedInterceptor):
  Bearer attach, transparent 401 → refresh-rotate → retry once, clear tokens on refresh failure.
- Login / register (.edu enforced) / verify-code screens, inline validation (§6.3);
  AuthController bootstraps session from storage; go_router guard redirects anon → /login.
- Profile screen shows identity + reputation "x.x ★ (n)" + sign out.
- 9 widget tests green (guard redirect, form validation, sign-out, a11y guidelines);
  flutter analyze 0 issues; `flutter build web` compiles.
- Gotcha logged: Makefile env exports don't reach standalone shells — export the pub
  mirror vars explicitly before flutter commands.
