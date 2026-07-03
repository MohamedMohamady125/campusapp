# CampusConnect — RUN LOG

▶ NEXT: M8 — hardening (Redis caching, index/query audit, k6 smoke, owasp.md checklist, dependency scans, WS behind flags.realtime). Flutter still blocked on pub.dev — retry each milestone.

## Plan checklist
- [x] M0 — Foundation (repo, tooling, CI skeleton) — API side green; Flutter scaffold TODO(blocked): pub.dev unreachable
- [x] M1 — Data model & seed
- [x] M2 — Auth & identity — API done; Flutter screens TODO(blocked): pub.dev
- [ ] M3 — Design system + app shell (Flutter-blocked)
- [x] M4 — Marketplace core (J1 + browse) — API done; Flutter UI TODO(blocked)
- [x] M5 — Messaging + reputation — API done; Flutter UI TODO(blocked)
- [x] M6 — Tutoring — API done; Flutter UI TODO(blocked)
- [x] M7 — Community chats — API done; Flutter UI TODO(blocked)
- [ ] M8 — Hardening: perf, security, a11y
- [ ] M9 — Monetization & analytics rails (flags OFF)
- [ ] M10 — Deploy & docs

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
