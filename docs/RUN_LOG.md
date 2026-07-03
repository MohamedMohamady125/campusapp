# CampusConnect — RUN LOG

▶ NEXT: M0 — scaffold backend + Flutter, get `make ci` green.

## Plan checklist
- [ ] M0 — Foundation (repo, tooling, CI skeleton)
- [ ] M1 — Data model & seed
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
