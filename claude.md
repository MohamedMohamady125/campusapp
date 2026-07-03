# CampusConnect — Enterprise Build Specification & Autonomous Execution Plan
### Stack: Flutter (Dart) · FastAPI (Python) · PostgreSQL

> **Audience:** Claude Code, running unattended (overnight, multi-hour).
> **Mission:** Build CampusConnect — a verified-student campus platform (marketplace + peer tutoring + community chats) — to production quality, from an empty repository, following this document as the single source of truth.
> **Read this entire file before writing any code.** When this document and your own assumptions disagree, this document wins. When this document is silent, follow the "Decision defaults" in §2 and record the decision in `/docs/adr/`.

---

## 0. How to use this document (read first)

You are an autonomous senior engineering team compressed into one agent. You will work in **ordered milestones** (§14). Each milestone has an explicit **Definition of Done (DoD)** and **acceptance checks you can run yourself**. Do not advance to the next milestone until the current one's checks pass green.

**Golden rules for the overnight run:**

1. **Never leave the tree broken.** Every commit must build, type-check (mypy + dart analyze), lint (ruff + dart format), and pass tests. If you can't make something pass, revert to the last green commit and leave a `TODO(blocked):` note in `/docs/RUN_LOG.md` with the exact error.
2. **Small, frequent commits.** One logical change per commit, conventional-commit format (§9.4). Push after every milestone.
3. **Write the test with the code, not after.** No feature is "done" without tests (§10).
4. **Self-verify before advancing.** Run the milestone's acceptance script. Paste the result into `/docs/RUN_LOG.md`.
5. **Prefer boring, proven technology** over clever novelty. This is an enterprise build, not a demo.
6. **Security and data-privacy are not optional** (§8). A feature that ships a vulnerability is not done.
7. **When genuinely blocked**, do not hallucinate an API key, a paid service, or a schema you can't verify. Stub it behind an interface (§2.4), document it, and keep moving.
8. **Keep a running journal** in `/docs/RUN_LOG.md`: timestamp, milestone, what you did, what passed, what's blocked.

### 0.1 Run continuity — surviving usage limits & interruptions (IMPORTANT)

This is a long unattended run. You **will** likely hit a usage/rate limit or get interrupted mid-way. Handle it so the night keeps making progress:

- **If you hit a usage limit or rate limit:** do not stop for the night and do not consider the task failed. **Wait and retry.** Keep retrying on a short interval (e.g., every few minutes) until the limit resets, then **continue exactly where you left off.** If your environment supports it, back off progressively (e.g., 2 → 5 → 10 minutes) rather than hammering. Treat the limit as a pause, never as "done."
- **Never leave work half-committed when you sense you're near a limit.** Finish the current small step, commit it green, and update `RUN_LOG.md` **before** you pause, so a resume is clean.
- **Always resume from state, not from memory.** On every start or restart, before doing anything else: (1) read `docs/RUN_LOG.md` to find the last completed milestone and any `TODO(blocked)` notes; (2) run `git log --oneline -20` and `git status` to see the last green commit; (3) run `make ci` to confirm the tree is green; (4) then continue at the next incomplete milestone in §14. Do **not** restart from M0 or redo completed milestones.
- **Make resumption cheap for yourself:** at the end of every milestone (and before any pause) write a one-line "▶ NEXT: <milestone + first concrete step>" at the top of `RUN_LOG.md` so a fresh session knows the exact next action in one glance.
- **If a specific step keeps failing across retries** (not a limit, a real error), don't loop forever — stub it behind an interface (§2.5), log `TODO(blocked)` with the error, and move to the next milestone. Come back to blocked items at the end.

> Note for whoever launches this run: an agent that has actually been cut off cannot retry itself while it is stopped. For a truly hands-off overnight run, launch Claude Code with an auto-resume/`--continue` loop (or a wrapper script/cron that re-invokes it every few minutes until the limit resets). This document instructs the agent to resume cleanly from `RUN_LOG.md` + git state the moment it is back.

---

## 1. Product vision

**CampusConnect** is a trust-first platform for a single university campus that unifies three student needs behind one verified identity:

1. **Marketplace** — buy/sell textbooks, furniture, electronics, tickets between students.
2. **Peer tutoring** — find and connect with students who have taken and done well in a course.
3. **Community chats** — topic/major/interest group chat rooms with moderation.

The connective tissue across all three is **verified .edu identity + a shared reputation system + in-app messaging**. The core product thesis: *students transact and collaborate more when everyone is a verified peer and reputation is portable across features.*

**Non-negotiable product principles**
- **Trust over scale.** Every account is a verified student. No anonymous strangers.
- **Simplicity over feature-count.** The three core journeys must each be completable in under 60 seconds of active effort. Ruthlessly cut friction.
- **One identity, one reputation.** A user's reputation earned selling carries into tutoring and chat credibility.
- **Mobile-first, native-fast.** This is a **Flutter mobile app first** (iOS + Android), with **Flutter Web** as a secondary target. Most usage is on phones between classes.

**The three "must-be-frictionless" journeys** (memorize these; they are the product):
- **J1 — Sell:** open app → "Sell" tab → snap photo → title + price auto-suggested → post. ≤ 5 taps.
- **J2 — Find a tutor:** open app → "Tutor" tab → type course code → ranked list → message top match. ≤ 4 taps.
- **J3 — Join a chat:** open app → "Chats" tab → browse directory → join → post. ≤ 3 taps.

---

## 2. Architecture & technology decisions

These are **locked decisions** (from ADR-001). Do not substitute without writing a superseding ADR.

### 2.1 Stack (locked)
| Layer | Choice | Notes |
|---|---|---|
| **Frontend** | **Flutter 3.x (Dart 3.x)** | Single codebase → iOS, Android, and Flutter Web. Material 3. |
| App state | **Riverpod (v2, code-gen)** | `@riverpod` providers. No `setState` for app/server state. |
| Networking | **dio** + **retrofit** (typed clients) generated from the OpenAPI contract | Interceptors for auth, retry, logging. |
| Models/serialization | **freezed** + **json_serializable** | Immutable data classes; `fromJson`/`toJson` generated. |
| Routing | **go_router** | Declarative, deep-link + guard aware. Route-level lazy loading. |
| Local persistence | **flutter_secure_storage** (tokens) + **Hive/Isar** (cache) | Never store tokens in plain prefs. |
| **Backend** | **FastAPI (Python 3.12)** on **Uvicorn** (Gunicorn workers in prod) | Async everywhere (`async def`). REST + WebSocket. |
| API structure | Layered: **router → service → repository** | No DB access in routers; no HTTP objects in services. |
| Validation/schemas | **Pydantic v2** | Every request/response is a Pydantic model → auto OpenAPI. |
| ORM | **SQLAlchemy 2.0 (async, `asyncpg`)** | Typed models, `Mapped[...]` style. |
| Migrations | **Alembic** | Autogenerate + hand-review; history checked into repo. |
| **Database** | **PostgreSQL 15** | Single source of truth. |
| Auth | **JWT access + refresh**, **argon2id** (via `argon2-cffi`/`passlib`) | httpOnly refresh cookie for web; secure storage on mobile. `python-jose`/`pyjwt` for tokens. |
| Object storage | **S3-compatible** (AWS S3 in prod; **MinIO** locally), via **boto3** | Signed-URL direct upload; backend never proxies binaries. |
| Image safety | **Content-moderation provider behind an interface** (§2.4) | AWS Rekognition or equivalent; stubbed locally. |
| Email | **Transactional email behind an interface** (Postmark/Resend via HTTP) | Stubbed to console/log locally. |
| Realtime | **Polling in v1**, **FastAPI WebSockets** (Starlette) as a feature-flagged upgrade (§7.4) | Don't block core features on realtime. |
| Cache/queues | **Redis** (cache, rate-limit store) + **Celery** (or `arq`) workers for background jobs | |
| Hosting | **Mobile:** App Store / Play (TestFlight/internal track for v1). **Flutter Web:** Vercel/Firebase Hosting. **API:** Render or Railway (Docker, Uvicorn+Gunicorn). **DB:** managed Postgres. | |
| CI/CD | **GitHub Actions** | Two lanes: Python (ruff, mypy, pytest, alembic check) and Flutter (analyze, format-check, test). |
| Observability | **structlog** (structured JSON logs) + **OpenTelemetry** traces + **Sentry** (Python + Flutter SDKs) | |
| Containerization | **Docker + docker-compose** for local parity | Postgres, Redis, MinIO, mailhog. Flutter runs on host/emulator. |

### 2.2 Repository shape (locked) — polyglot monorepo
```
campusconnect/
├─ apps/
│  ├─ mobile/          # Flutter app (iOS, Android, Web)
│  │  ├─ lib/
│  │  │  ├─ core/        # theme, router, di, network, error, env
│  │  │  ├─ features/    # feature-first: auth/ marketplace/ tutoring/ chats/ messaging/ profile/
│  │  │  │   └─ <feature>/{data,domain,presentation}/
│  │  │  ├─ shared/      # shared widgets, extensions, utils
│  │  │  └─ api/         # generated dio/retrofit client + freezed models (from OpenAPI)
│  │  ├─ test/           # unit + widget tests
│  │  ├─ integration_test/  # end-to-end (Patrol/integration_test)
│  │  └─ pubspec.yaml
│  └─ api/             # FastAPI backend
│     ├─ app/
│     │  ├─ main.py        # FastAPI app factory
│     │  ├─ core/          # config, security, logging, deps, rate-limit, errors
│     │  ├─ db/            # engine, session, base
│     │  ├─ models/        # SQLAlchemy models
│     │  ├─ schemas/       # Pydantic request/response models (the contract)
│     │  ├─ api/v1/        # routers per resource
│     │  ├─ services/      # business logic (transactions live here)
│     │  ├─ repositories/  # SQLAlchemy data access
│     │  ├─ integrations/  # email/, moderation/, storage/, payments/, analytics/ (interface + stub + real)
│     │  ├─ workers/       # Celery tasks
│     │  └─ seed.py        # DB seeding
│     ├─ alembic/          # migrations
│     ├─ tests/            # pytest (unit + integration via httpx)
│     └─ pyproject.toml    # ruff, mypy, pytest config
├─ contracts/
│  └─ openapi.json        # exported from FastAPI; source for the Flutter client (§2.3)
├─ infra/
│  ├─ docker-compose.yml  # postgres, redis, minio, mailhog
│  └─ terraform/          # optional IaC (stub acceptable in v1)
├─ docs/
│  ├─ adr/                # architecture decision records
│  ├─ api/                # API guides
│  ├─ RUN_LOG.md          # YOUR overnight journal
│  └─ RUNBOOK.md          # ops runbook
├─ .github/workflows/     # ci-api.yml, ci-mobile.yml, deploy.yml
├─ Makefile               # one-command dev/test/ci targets
└─ CLAUDE.md              # copy of this file's operating rules
```

### 2.3 The contract: OpenAPI is the single source of truth between Flutter and FastAPI
- FastAPI + Pydantic **auto-generate `/openapi.json`**. Export it to `contracts/openapi.json` on every API change (`make export-openapi`).
- The Flutter client (`apps/mobile/lib/api/`) — dio/retrofit interfaces + freezed models — is **generated from that OpenAPI file** (via `openapi-generator` `dart-dio` or `swagger_dart_code_generator`). Never hand-write request/response models on the Flutter side.
- This gives you one contract, generated on both ends: change a Pydantic schema → re-export → regenerate Dart → the app is type-safe against the new API. A CI check fails if `contracts/openapi.json` is stale vs. the code.

### 2.4 Cross-cutting architectural rules
- **Layered backend:** `router` (HTTP, Pydantic validation, auth dep) → `service` (business logic, transactions) → `repository` (SQLAlchemy). No SQLAlchemy in routers. No `Request`/`Response` objects in services.
- **Every list endpoint is cursor-paginated** from day one. No unbounded queries ever reach production.
- **Every mutation touching >1 table runs in a transaction** (`async with session.begin()`), and is idempotent where feasible.
- **Feature flags** via a `flags` table + a `useFlag` provider on Flutter and a `require_flag` dependency on the API, so half-built features ship dark.
- **Flutter architecture:** feature-first folders, each with `data/` (repositories, dio calls), `domain/` (entities, use-cases where useful), `presentation/` (screens, widgets, Riverpod controllers). Keep business logic out of widgets.

### 2.5 The "interface + stub" rule for external services
Any third-party dependency (email, image moderation, object storage, payments, push, analytics) is accessed **only through a Python interface** (abstract base class) in `apps/api/app/integrations/<name>/`. Provide:
- a **real adapter** (used when env keys are present), and
- a **stub adapter** (used in dev/test/CI) that logs and returns deterministic success.

This lets you build and test the *entire* app overnight with zero paid credentials, and lets a human drop in real keys later without code changes. Selection is by env (`APP_ENV`/presence of keys) via the DI/deps layer.

---

## 3. Data model (authoritative)

Model in **SQLAlchemy 2.0** (typed `Mapped[...]`), migrations via **Alembic**. All tables have `id` (UUID pk), `created_at`, `updated_at`. Use soft-delete (`deleted_at`) on user-content tables (listings, messages, chats, ratings). Index every foreign key and every column used in a `WHERE`/`ORDER BY` of a listed endpoint. Use Postgres enums (or checked varchar) for enum fields.

**Entities and key fields:**

- **User** — `email` (unique, must match campus .edu domain), `password_hash`, `email_verified_at`, `display_name`, `year`, `major`, `bio`, `avatar_key`, `reputation_score` (cached, see §5.2), `rating_count`, `role` (`student` | `moderator` | `admin`), `status` (`active` | `suspended` | `banned`), `last_active_at`.
- **VerificationCode** — `user_id`, `code_hash`, `purpose` (`email_verify` | `password_reset`), `expires_at`, `consumed_at`. 6-digit, 10-min expiry, single use, rate-limited.
- **Listing** — `seller_id`, `title`, `description`, `price_cents`, `category` (enum), `condition` (enum), `status` (`active` | `sold` | `removed`), `expires_at` (90 days), `search_vector` (tsvector, generated). Has many **ListingImage** (`listing_id`, `s3_key`, `order`, `moderation_status`).
- **Course** — `code` (e.g., `CS250`), `title`, `department`. Seeded (≥ 50 rows).
- **TutorOffering** — `tutor_id`, `course_id`, `term_taken`, `grade_received`, `blurb`, `active`. Unique on (`tutor_id`, `course_id`).
- **Conversation** — `context_type` (`listing` | `tutoring` | `direct`), `context_id` (nullable), plus **ConversationParticipant** (`conversation_id`, `user_id`, `last_read_at`).
- **Message** — `conversation_id`, `sender_id`, `body`, `attachment_key?`, `read_at?`.
- **Chat** — `name`, `slug`, `description`, `visibility` (`open` | `request` | `private`), `created_by_id`, `member_cap`. Plus **ChatMembership** (`chat_id`, `user_id`, `role` = `member` | `mod` | `owner`, `muted_until?`, `banned_at?`) and **ChatMessage** (`chat_id`, `sender_id`, `body`, `attachment_key?`, `deleted_at?`).
- **Rating** — `rater_id`, `rated_user_id`, `context_type`, `context_id`, `stars` (1–5), `comment?`. Unique on (`rater_id`, `context_type`, `context_id`) so you can't double-rate one transaction.
- **Report** — `reporter_id`, `target_type` (`listing` | `message` | `chat_message` | `user`), `target_id`, `reason`, `status` (`open` | `reviewing` | `actioned` | `dismissed`), `handled_by_id?`.
- **Notification** — `user_id`, `type`, `payload` (jsonb), `read_at?`. Plus **NotificationPreference** per user per type.
- **AuditLog** — `actor_id`, `action`, `target_type`, `target_id`, `metadata` (jsonb). Write on every moderation/admin action and every auth-sensitive event.
- **Flag** (feature flags) — `key`, `enabled`, `rollout_percent`.

Provide an **async seed script** (`app/seed.py`) that creates: ~50 courses, 20 demo users (verified), ~40 listings across categories with placeholder images, a handful of tutor offerings, 5 open chats with messages, and sample ratings — so every screen has realistic data on first run.

---

## 4. API surface (REST, versioned under `/api/v1`)

All endpoints: Pydantic-validated input, typed response model, cursor pagination on lists, standard error envelope (§4.2), auth dependency unless marked public. FastAPI auto-documents everything at `/docs` (Swagger) and `/redoc`.

### 4.1 Endpoint map
**Auth** — `POST /auth/register`, `POST /auth/verify`, `POST /auth/resend-code`, `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout`, `POST /auth/forgot-password`, `POST /auth/reset-password`.
**Users** — `GET /users/me`, `PATCH /users/me`, `GET /users/{id}` (public profile), `GET /users/me/avatar-upload-url`.
**Listings** — `GET /listings` (search/filter/paginate), `POST /listings`, `GET /listings/{id}`, `PATCH /listings/{id}`, `DELETE /listings/{id}`, `POST /listings/{id}/mark-sold`, `POST /listings/{id}/image-upload-url`.
**Tutoring** — `GET /courses` (autocomplete), `POST /tutoring/offerings`, `DELETE /tutoring/offerings/{id}`, `GET /tutoring/tutors?course=CS250` (ranked, §5.1).
**Conversations** — `GET /conversations`, `POST /conversations` (or auto-created from a listing/tutor CTA), `GET /conversations/{id}/messages`, `POST /conversations/{id}/messages`, `POST /conversations/{id}/read`.
**Chats** — `GET /chats` (mine), `GET /chats/directory`, `POST /chats`, `POST /chats/{id}/join`, `POST /chats/{id}/leave`, `GET /chats/{id}/messages`, `POST /chats/{id}/messages`, `POST /chats/{id}/messages/{mid}/delete` (mod), `POST /chats/{id}/members/{uid}/mute`, `POST /chats/{id}/members/{uid}/ban`.
**Ratings** — `POST /ratings`, `GET /users/{id}/ratings`.
**Reports** — `POST /reports`, `GET /admin/reports` (mod/admin), `PATCH /admin/reports/{id}`.
**Notifications** — `GET /notifications`, `POST /notifications/read`, `PATCH /notifications/preferences`.
**Realtime (flagged)** — `WS /ws` (auth via token query/subprotocol) for messages & chat, behind `flags.realtime`.
**Meta** — `GET /health` (liveness), `GET /health/ready` (DB+Redis check), `GET /flags`.

### 4.2 Standard error envelope
```json
{ "error": { "code": "LISTING_NOT_FOUND", "message": "Human readable.", "details": {} } }
```
Implement via a FastAPI exception handler mapping custom `AppError` subclasses. Use stable machine `code`s (the app switches on these, never on message text). HTTP status maps: 400 validation, 401 unauthenticated, 403 unauthorized, 404 not found, 409 conflict, 422 business-rule, 429 rate-limited, 500 internal.

### 4.3 Contract export
`make export-openapi` writes `contracts/openapi.json`. CI fails if it's stale. The Flutter client is regenerated from it (§2.3).

---

## 5. Core computations (implement exactly, with unit tests and code comments citing this section)

### 5.1 Tutor match ranking
For a queried course, score each candidate tutor:
```
score = 0.60 * reputation_norm
      + 0.30 * recency_norm
      + 0.10 * responsiveness_norm
```
- `reputation_norm` = Bayesian reputation (§5.2) scaled to [0,1] over the candidate pool.
- `recency_norm` = how recently they took the course (term recency), normalized [0,1].
- `responsiveness_norm` = median reply time over last 30 days, inverted & normalized [0,1]; new tutors get the pool median (neutral prior), not 0.
Return ranked, with tie-break on `rating_count` desc then `last_active_at` desc. **Never rank a brand-new tutor last purely for lack of data** — the neutral prior prevents cold-start punishment. Document weights as named constants in one config module.

### 5.2 Reputation aggregation (Bayesian prior — solves small-sample problem)
```
reputation = (C * m + sum_of_stars) / (C + n)
```
where `n` = number of ratings, `sum_of_stars` = total stars received, `m` = global mean rating across the platform (recomputed nightly, seeded to 4.0), `C` = prior strength (start at 8). A user with two 5★ ratings should not outrank a user with two hundred 4.8★ ratings. Recompute a user's cached `reputation_score` on each new rating (inside the rating transaction) and expose both the score and `rating_count` so the UI can show "4.7 ★ (128)".

### 5.3 Search
Postgres full-text: maintain `search_vector` (generated column) on listings from `title` + `description`; add a `pg_trgm` GIN index for fuzzy/typo tolerance. Rank by `ts_rank` blended with recency. Filters (category, price range, condition) are SQL `WHERE` clauses, not post-filtering. Query via SQLAlchemy Core/text with bound params — never string-built SQL.

### 5.4 Listing expiry & background jobs (Celery)
Nightly jobs: expire listings past `expires_at`, recompute global mean `m`, purge consumed/expired verification codes, aggregate daily metrics (§12). Every task is idempotent and logged. Schedule with Celery beat (or a cron-triggered management command).

---

## 6. Design system, UI & UX (this is a native product, make it feel premium)

Flutter, **Material 3**, mobile-first. Build a lean in-house design layer on top of Material.

### 6.1 Design tokens (define once in `core/theme/`, expose via `ThemeExtension`s)
- **Type scale:** 12 / 14 / 16 / 20 / 24 / 32 / 40 (`TextTheme` + custom tokens). Base 16, line-height 1.5 body / 1.2 headings. One family (Inter via `google_fonts` or bundled) + a mono for course codes.
- **Spacing:** 4px base grid (4, 8, 12, 16, 24, 32, 48, 64) as named constants.
- **Radius:** sm 6 / md 10 / lg 16 / full. **Elevation:** 3 levels, used sparingly.
- **Color:** neutral gray ramp + one brand seed color (Material 3 `ColorScheme.fromSeed`) + semantic success/warning/danger/info. Ship **light and dark themes** from day one; respect the OS setting. Meet **WCAG 2.1 AA** contrast (≥ 4.5:1 text).

### 6.2 Component/widget library (build in `shared/widgets/`, all accessible)
AppButton (variants: primary/secondary/ghost/danger, sizes, loading state), AppTextField/AppTextArea/AppDropdown/CourseCombobox, AppCheckbox/Radio/Switch, AppModal/BottomSheet, AppToast/SnackBar, AppTooltip, Avatar, Badge, AppCard, Tabs, Shimmer/Skeleton loader, EmptyState, PaginatedListView (infinite scroll with `ScrollController`), StarRating, ImageUploader (pick + client-side crop/compress via `image_picker` + `image`), MessageBubble, ChatComposer. Every widget: typed params, a usage example in a `widgetbook`/gallery screen, and an accessibility pass (semantics labels, min 48×48 tap targets, focus order).

### 6.3 UX laws to enforce (these are acceptance criteria, not suggestions)
- **Perceived speed:** optimistic UI on every mutation (send a message, mark sold, join a chat) via Riverpod controllers with rollback on failure. Skeletons/shimmer, never a bare spinner on a blank screen, for initial loads.
- **Never a dead end:** every empty state has a primary action ("No listings yet — post the first one").
- **Forgiving forms:** inline validation on blur, human error text, preserve input on failure, disable submit only while in-flight.
- **Zero-jank images:** `cached_network_image` with fixed aspect-ratio boxes; blur-up/placeholder; responsive sizes; lazy in lists.
- **Reachable one-handed:** primary actions in the thumb zone; a **bottom NavigationBar** for the 3 core areas + profile.
- **Instant feedback:** every tap shows a press/ripple within 100ms; every action confirms within 1s or shows progress.
- **Respect motion & platform:** honor `MediaQuery.disableAnimations`/reduce-motion; use platform-adaptive scroll physics; 60fps target (no jank in the DevTools timeline on core screens).

### 6.4 Key screens (build to the journeys in §1)
Auth (sign-up, verify-code, login, forgot/reset), Home (activity hub across all 3 features), Marketplace browse + filters, Listing detail (gallery, seller card w/ reputation, "Message seller" CTA), Sell/Edit listing (camera-first, price suggestion), Tutor search (course combobox → ranked cards), Tutor/Seller profile, Conversations list + thread, Chat directory + chat room, Notifications, Settings (profile, notification prefs, theme). Every screen responsive from small phones to tablets/web width.

---

## 7. Performance & speed (budgets are enforced where possible)

### 7.1 Flutter app budgets
- **Cold start to first meaningful frame < 2.0s** on a mid-tier device; **jank-free 60fps** scrolling on Browse and chat lists (verify with DevTools timeline; no frames > 16ms on core flows).
- **Release APK/IPA size kept lean** (strip unused assets/fonts, `--split-per-abi`, tree-shake icons). Track size in CI and flag regressions.
- Lazy route loading via go_router; build only visible list items (`ListView.builder`/slivers); `const` constructors everywhere possible; avoid rebuilding whole trees (scoped Riverpod `select`).
- Images: `cached_network_image`, correctly sized thumbnails from the API/CDN, decode at display size.
- **Flutter Web:** deferred imports for heavy routes, canvaskit vs html renderer chosen per target; Lighthouse mobile Performance ≥ 85 / Accessibility ≥ 95 on Browse and Detail.

### 7.2 Backend budgets (FastAPI)
- **p95 API latency < 200ms** for reads, **< 400ms** for writes (excluding third-party calls), measured under seed data.
- **Fully async** request path (async SQLAlchemy, `asyncpg`, async httpx for integrations). No blocking/sync DB calls in async routes.
- No N+1 queries — use `selectinload`/`joinedload` deliberately; assert query counts in integration tests for list endpoints.
- Redis cache for hot reads (course list, chat directory, a user's reputation) with explicit TTLs and invalidation on write.
- Connection pooling (SQLAlchemy async pool) sized and documented; PgBouncer in front for prod.
- Gzip responses (Starlette `GZipMiddleware`); ETag on cacheable GETs.

### 7.3 Scale posture (v1 targets, designed to 10× without rewrite)
- Stateless API (JWT + Redis) → run multiple Uvicorn/Gunicorn workers behind a load balancer, scale horizontally.
- All heavy/slow work (email, moderation, metrics) offloaded to **Celery workers**, never inline in the request path.
- DB: correct indexes, cursor pagination, read-replica-ready repository layer (route reads through a `read_session` even if it points at primary in v1).

### 7.4 Realtime upgrade path
Ship **polling** (smart interval + backoff, pause when app is backgrounded via `AppLifecycleState`) in v1 behind a `messagesProvider`. Implement **FastAPI WebSocket** endpoints + a Flutter `web_socket_channel` transport behind `flags.realtime`, so flipping the flag swaps transport with no UI change. Do not let realtime block messaging.

---

## 8. Security, privacy & trust (a vulnerability = not done)

- **AuthN:** argon2id hashing (tuned params) via `argon2-cffi`/`passlib`; JWT access (~15min) + rotating refresh token. On **web**, refresh token in httpOnly+Secure+SameSite cookie; on **mobile**, refresh token in `flutter_secure_storage` (Keychain/Keystore). Refresh-token reuse detection (revoke family on reuse).
- **AuthZ:** central policy layer (FastAPI dependencies). Ownership checks on every mutating resource endpoint (a user can only edit *their* listing, read *their* conversations, moderate only chats they mod). Add tests asserting cross-user access returns 403/404.
- **Input:** validate everything with Pydantic at the boundary; SQLAlchemy parametrized queries only. No f-string SQL. Treat message/bio/chat text as plain text (escape on display); if rich text is ever added, allowlist-sanitize server-side.
- **Rate limiting:** Redis-backed (e.g., `slowapi` or custom middleware). Strict on auth (5 failed logins / 15min / IP+account), verification-code requests, message/report spam. Return 429 with `Retry-After`.
- **Uploads:** signed-URL direct-to-S3 (boto3 presign); enforce content-type + size (≤ 5MB) + dimension caps; run every image through the moderation interface before it's publicly visible (`moderation_status` gate).
- **Secrets:** never in the repo. `.env.example` documents every var; real values via host env store / secrets manager. CI uses stub adapters — no real secrets needed. Pydantic `Settings` loads config.
- **Headers/transport:** security middleware — CSP (web), HSTS, X-Content-Type-Options, Referrer-Policy, frameguard; CORS allowlist for the web build. Certificate pinning optional on mobile.
- **PII & privacy:** collect the minimum; document data retention; provide account deletion (soft-delete + scrubbing Celery job); never log secrets or full tokens; hash verification codes at rest.
- **Abuse & safety:** reporting on all user content; moderator tools (mute/ban/delete) with `AuditLog`; block/hide flows; escalation states on reports.
- **Dependencies:** `pip-audit` (Python) + `dart pub outdated`/OSV scan (Flutter) + Dependabot; fail CI on high/critical. Pin versions (lockfiles committed: `uv.lock`/`poetry.lock`/`requirements.txt`, `pubspec.lock`).
- **OWASP Top-10 checklist** lives in `docs/security/owasp.md`; tick each item with where it's mitigated.

---

## 9. Code quality & engineering standards

### 9.1 Python (backend)
Type hints everywhere; **mypy strict** passes (no `Any` leaks on external data). Async-first. `ruff` for lint + import order, `black`/`ruff format` for formatting. Pydantic v2 for all boundaries. Functions do one thing; files ≤ ~300 lines. No business logic in routers; no I/O in pure helpers.

### 9.2 Dart/Flutter (frontend)
`analysis_options.yaml` with **`very_good_analysis`** (or equally strict) — zero analyzer warnings in CI. `dart format` enforced. Prefer `const`; immutable models via freezed; no logic in widgets (push to Riverpod controllers/use-cases). Handle every async state (loading/data/error) explicitly — no unhandled `Future`s, no silent catch.

### 9.3 Structure & naming
Backend: `router → service → repository`. Flutter: feature-first `data/domain/presentation`. Name by intent. Comments explain *why*, not *what*; every non-obvious algorithm cites its spec section.

### 9.4 Commits & branches (Conventional Commits)
`feat(marketplace): add listing search endpoint`, `fix(auth): rotate refresh token on reuse`, `test`, `chore`, `docs`, `perf`, `refactor`. Solo autonomous run on `main` is fine **but** every commit is green. Tag each completed milestone (`m3-marketplace-core`).

### 9.5 Docs to keep current as you go
`README.md` (setup in ≤ 5 commands via `Makefile`), `docs/RUNBOOK.md` (deploy, rollback, env), `docs/adr/*` (every non-trivial decision), `contracts/openapi.json` (exported), `docs/RUN_LOG.md` (your journal), docstrings on public service functions and Dart controllers.

---

## 10. Testing strategy (no feature is done without these)

### 10.1 Backend (pytest)
- **Unit:** all computations (§5) with edge cases — Bayesian priors, cold-start tutor, expiry boundaries, pagination cursors. Target ≥ 80% coverage on `services/` and computations.
- **Integration:** every endpoint via `httpx.AsyncClient` against a **real ephemeral Postgres** (Testcontainers or the docker-compose DB with a test schema) — happy path, validation failure, auth failure, cross-user authorization (must be 403/404), pagination, query-count assertions (no N+1).
- Fixtures/factories for users, listings, chats; transactional test isolation (rollback per test).

### 10.2 Flutter
- **Unit:** Riverpod controllers, mappers, and any client-side logic (with mocked repositories via `mocktail`).
- **Widget tests:** key components and forms — find by semantics label, verify keyboard/tap interaction, optimistic update + rollback, error states.
- **Golden tests** (optional but encouraged) for core components in light/dark to catch visual regressions.

### 10.3 End-to-end
- **integration_test / Patrol:** the three journeys J1/J2/J3 driven on a real device/emulator against the running API (seeded), plus auth (register→verify→login→logout) and a moderation flow. Run headless in CI where feasible.

### 10.4 Accessibility & performance
- Flutter accessibility guidelines checks in widget tests (`meetsGuideline(textContrastGuideline)`, `tapTargetGuideline`, `labeledTapTargetGuideline`); zero violations on core screens.
- Backend perf: a **k6** (or `locust`) smoke script hitting top read endpoints asserting p95 (§7.2). Flutter Web: Lighthouse-CI budget gate on Browse/Detail.

All suites run in CI (§11) and must pass before a milestone is marked done.

---

## 11. CI/CD (GitHub Actions — two lanes)

**`ci-api.yml` (Python):** set up Python 3.12 + cache deps → `ruff check` + format check → `mypy` (strict) → spin Postgres + Redis services → `pytest` (unit + integration, coverage) → `alembic upgrade head` on a clean DB + **autogenerate check** (no un-migrated model drift) → **OpenAPI export check** (fail if `contracts/openapi.json` is stale) → `pip-audit`. Upload coverage artifact.

**`ci-mobile.yml` (Flutter):** set up Flutter → `dart format --set-exit-if-changed` → `flutter analyze` (zero warnings) → **codegen check** (build_runner + OpenAPI-generated client are up to date) → `flutter test` (unit + widget, coverage) → `flutter build apk --debug` (and `flutter build web`) to prove it compiles → integration_test on emulator where feasible → Lighthouse-CI on the web build.

**`deploy.yml` (on tag/main green):** run Alembic migrations against prod DB (guarded) → build & deploy API container (Render/Railway) → build & deploy Flutter Web (Vercel/Firebase) and upload mobile builds to TestFlight/Play internal track → post-deploy smoke test hitting `/health/ready` and one read endpoint → auto-rollback on smoke failure. Document manual rollback in RUNBOOK.

Everything must be runnable **locally with one command** (`make ci` / `make dev`) so you can self-verify overnight without cloud.

---

## 12. Analytics, metrics & product instrumentation

- **Event tracking behind an interface** (§2.5): emit typed events (`listing_created`, `tutor_match_viewed`, `message_sent`, `chat_joined`, `signup_completed`, `rating_submitted`) from both API (server events) and Flutter (client events via the same interface). Stub = write to an `analytics_events` table / log; prod adapter = your chosen provider.
- **Funnel metrics** for the three journeys (start → complete) so you can measure the "≤ N taps" promise.
- **North-star metric:** *Weekly Verified Active Peers who complete ≥1 core action.* Secondary: listings posted, tutor connections made, messages sent, D1/D7 retention.
- **Admin dashboard:** a `/admin` area — build it as **Flutter Web routes gated to `admin` role** (reuses the same app + API), covering moderation queue, key metrics, and user/listing search.
- Nightly metrics aggregation (Celery) writes to a `daily_metrics` table for cheap dashboarding.

---

## 13. Monetization & revenue (build the rails now, keep them off by default)

Design revenue features **behind feature flags, disabled in v1**, so the platform can switch them on without a rewrite. Keep the student-trust ethos: never sell user data, never inject dark patterns, keep the core free.

**Revenue streams to scaffold (interfaces + flags, minimal UI, off by default):**
1. **Promoted listings** — a seller pays a small fee to pin/boost a listing in search for N days. Build the `listing.boosted_until` field, the ranking hook, and a payments interface (Stripe adapter + stub). Flag: `flags.promoted_listings`.
2. **Verified tutor / premium tutor tier** — optional subscription giving tutors a badge, higher placement weight cap, and scheduling tools. Model `subscription` + entitlement checks. Flag: `flags.tutor_premium`.
3. **Marketplace transaction fee (optional, opt-in escrow)** — an optional protected-payment flow taking a small percentage; only where both parties opt in. Keep P2P free by default. Flag: `flags.escrow`.
4. **Campus/partner placements** — sanctioned, clearly-labeled listings from campus orgs/bookstores in a dedicated slot (never disguised as peer content). Flag: `flags.partner_slots`.
5. **Job/gig board** (expansion) — employers post student gigs for a fee. Separate module, later.

**Payments architecture:** all money flows through a single `PaymentsService` Python interface (Stripe adapter + stub). PCI scope stays with Stripe — on Flutter use the **`flutter_stripe`** SDK / Stripe Checkout; the backend never touches raw card data. Idempotency keys on every charge. Webhooks verified by signature, processed via Celery, idempotent. Ledger table for auditability. **Do not enable any real charge path without a human turning on the flag and providing keys** — scaffold and test with the stub only.

---

## 14. Execution plan — ordered milestones (this is your night)

Work top to bottom. Each milestone: build → test → run its acceptance check → log result in `RUN_LOG.md` → tag → next. If a milestone's third-party need isn't available, use the stub (§2.5) and continue.

**M0 — Foundation (repos, tooling, CI skeleton)**
Monorepo layout; FastAPI app factory + config (Pydantic Settings) + `/health` + `/health/ready`; ruff/mypy/pytest configured; Flutter app scaffold (go_router shell, theme, Riverpod, dio) that runs; Docker-compose (Postgres/Redis/MinIO/mailhog); Alembic init; `Makefile`; both CI lanes running (analyze/lint/typecheck + one test each); `.env.example`; OpenAPI export wired.
*DoD / acceptance:* fresh clone → `make dev` brings up API + infra; `flutter run` launches the shell; `make ci` (API lint+type+test and Flutter analyze+test) is green; `/health/ready` returns ok.

**M1 — Data model & seed**
All SQLAlchemy models (§3), Alembic migration, indexes, generated search vector, async seed script.
*Acceptance:* `alembic upgrade head` on a clean DB + seed populates every table; a script prints row counts; autogenerate shows no drift.

**M2 — Auth & identity (API + Flutter)**
Register (.edu check) → verification code (stub email) → login → refresh rotation → logout. argon2id, rate limits, auth dependency, ownership-policy scaffold. Flutter auth screens + secure-storage token handling + auth guard on router. Auth integration tests + Flutter widget tests + one E2E.
*Acceptance:* E2E register→verify→login→access guarded route→logout passes; brute-force returns 429; cross-user access returns 403; tokens persist across app restart (secure storage).

**M3 — Design system + app shell**
Theme tokens (light/dark), widget library (§6.2), bottom NavigationBar shell, go_router routes, dio interceptors (auth/refresh/error→toast), Riverpod providers, error boundary, shimmer skeletons, widgetbook/gallery. Generate the Flutter API client from OpenAPI.
*Acceptance:* widget + a11y tests pass; shell renders on small phone → tablet/web; theme follows OS; generated client compiles and calls `/health`.

**M4 — Marketplace core (J1 + browse)**
Listing CRUD + ownership, image signed-URL upload + moderation gate (stub), search/filter/paginate (§5.3), browse grid (infinite scroll), listing detail, sell/edit flow (camera-first, price suggestion), expiry Celery job.
*Acceptance:* E2E J1 (post a listing in ≤5 taps equivalent) passes; search returns ranked filtered results; no N+1 on `GET /listings` (asserted in tests); image uploads via signed URL and appears after moderation-approve.

**M5 — Messaging + reputation**
Conversations + messages (polling provider), optimistic send + rollback, read state; rating submission + Bayesian reputation (§5.2) shown on profiles/seller cards; report + basic moderation.
*Acceptance:* two seeded users exchange messages in E2E; reputation unit tests pass (incl. cold-start); rating updates cached score in a transaction; cross-user conversation access returns 403.

**M6 — Tutoring**
Course autocomplete, tutor offerings, ranked tutor search (§5.1) with neutral-prior cold-start, tutor profile, "message tutor" reuses M5 messaging.
*Acceptance:* E2E J2 (course code → ranked list → message) passes; ranking unit tests assert weights and tie-breaks; new tutor is not floored to last.

**M7 — Community chats**
Directory, create/join/leave (caps + visibility), chat messaging, moderation (delete/mute/ban) with AuditLog, per-event notifications + bell badge, notification preferences.
*Acceptance:* E2E J3 (browse→join→post) passes; a mod can delete/mute/ban with audit entries; notifications fire on new chat message per preferences.

**M8 — Hardening: perf, security, a11y**
Redis caching + TTLs, index/query audit for p95 budgets, k6 smoke gate, OWASP checklist completed, dependency scans clean (pip-audit + Flutter), full accessibility pass on all core screens, FastAPI WebSocket + Flutter ws transport behind `flags.realtime`, Flutter Web Lighthouse gate.
*Acceptance:* k6 meets p95; `owasp.md` fully ticked; audits clean of high/critical; a11y guideline tests pass on core screens; enabling `flags.realtime` swaps messaging to WS with no UI change.

**M9 — Monetization & analytics rails (flags OFF)**
PaymentsService + Stripe stub (+ `flutter_stripe` wiring behind flag), promoted-listing hook, subscription/entitlement scaffold, analytics event pipeline + `daily_metrics` job, `/admin` Flutter-web dashboard (moderation + metrics).
*Acceptance:* enabling `flags.promoted_listings` in a test boosts a listing's rank; analytics events land in the table; admin dashboard renders metrics; **no real charge path active**.

**M10 — Deploy & docs**
`deploy.yml` (migrate→deploy API→deploy web + mobile build artifacts→smoke→rollback), production `.env` documented, RUNBOOK, README quickstart, OpenAPI/redoc served, final full-suite green, tag `v1.0.0-rc1`.
*Acceptance:* deploy pipeline dry-run/documented; smoke test passes against a running stack; `README` gets a fresh machine to a running API + `flutter run` in ≤5 commands.

**Stretch (only if all above are green):** WebSocket realtime on by default, saved-search push alerts (FCM/APNs), calendar-based tutor scheduling, offline cache/queue, i18n (`flutter_localizations` + `intl`), deep links/app links.

---

## 15. Definition of Done (applies to every unit of work)

A thing is **done** only when: it builds (API imports + `flutter build` succeed); mypy + `flutter analyze` pass; ruff + dart format clean; unit + integration + relevant E2E pass; it's accessible (Flutter a11y guidelines clean on affected UI); it meets the perf budget if on a hot path; it's authorized & Pydantic-validated if it touches data; the OpenAPI contract + generated client are in sync; it has docs/ADR if it made a decision; it's committed in conventional format on a green tree; and its milestone acceptance check is logged in `RUN_LOG.md`.

---

## 16. Guardrails — what NOT to do

- Do **not** invent or hardcode secrets/API keys, or enable any real payment/charge path. Stub it.
- Do **not** ship an unbounded query, an unauthenticated mutation, a sync DB call in an async route, or a leaked `Any`.
- Do **not** hand-write Flutter request/response models — generate them from OpenAPI.
- Do **not** mark a milestone done with a red test or a skipped auth check.
- Do **not** add a dependency (pip or pub) you can't justify in one sentence; prefer stdlib/framework.
- Do **not** break the three core journeys for the sake of a new feature.
- Do **not** silently swallow errors — log structured (structlog), surface to the user humanely (toast/snackbar), report to Sentry (stub).
- If stuck > ~30 min of wall-clock on one problem, stub behind an interface, write `TODO(blocked)` + the error in `RUN_LOG.md`, and move to the next milestone. Keep the night productive.

---

## 17. First actions when you start

1. Read this whole file. Restate the plan in `docs/RUN_LOG.md` as a checklist.
2. Create `docs/adr/0001-stack.md` capturing §2 decisions (Flutter + FastAPI + Postgres, OpenAPI contract).
3. Scaffold M0. Get `make ci` green and `flutter run` launching the shell from a clean clone.
4. Proceed through M1…M10 in order, self-verifying and journaling each. Re-export OpenAPI and regenerate the Flutter client whenever an API schema changes.
5. At the end (or when blocked everywhere), write a **handoff summary** in `RUN_LOG.md`: what's done, what's stubbed, what a human must plug in (real S3/email/moderation/Stripe keys, FCM/APNs certs, app-store credentials, DNS, instructor GitHub invite), and how to run it.

*Build it like it has to survive real students using it on day one. Trust, speed, and simplicity first — everything else serves those.*