# CampusConnect — RUN LOG

▶ NEXT: M2 — auth & identity (API side first; Flutter blocked on pub.dev network).

## Plan checklist
- [x] M0 — Foundation (repo, tooling, CI skeleton) — API side green; Flutter scaffold TODO(blocked): pub.dev unreachable
- [x] M1 — Data model & seed
- [ ] M2 — Auth & identity (API + Flutter)
- [ ] M3 — Design system + app shell
- [ ] M4 — Marketplace core (J1 + browse)
- [ ] M5 — Messaging + reputation
- [ ] M6 — Tutoring
- [ ] M7 — Community chats
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
