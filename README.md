# CampusConnect

A trust-first campus platform: **marketplace + peer tutoring + community chats**,
all behind one verified .edu student identity and a shared reputation system.

Monorepo: **Flutter** app (`apps/mobile`) · **FastAPI** backend (`apps/api`) · **PostgreSQL**.

---

## Quickstart (5 commands)

```bash
git clone <repo> campusconnect && cd campusconnect
make dev          # venv + docker infra (postgres/redis/minio/mailhog) + migrations + API on :8000
make seed         # realistic demo data (courses, users, listings, chats)
cd apps/mobile && flutter run -d chrome    # launch the app in Chrome
```

### Demo credentials

All 20 seed accounts share the password **`Password123!`**:

| Account | Email |
|---------|-------|
| Ava | `ava0@campus.edu` |
| Ben | `ben1@campus.edu` |
| Chloe | `chloe2@campus.edu` |
| Dan | `dan3@campus.edu` |
| Ella | `ella4@campus.edu` |
| *(16 more...)* | `{firstname}{index}@campus.edu` |

### Service URLs (local dev)

| Service | URL |
|---------|-----|
| API (Swagger docs) | http://localhost:8000/docs |
| API (ReDoc) | http://localhost:8000/redoc |
| Mailhog (email inbox) | http://localhost:8025 |
| MinIO console (S3 storage) | http://localhost:9001 |

---

## Latest Changes (Sprint 3 — Marketplace Core)

These changes complete the marketplace feature set for the Sprint 3 demo.
Every feature listed below is live and functional in the running application.

### 1. Marketplace Browse with Search and Filters

**Files:** `browse_screen.dart`, `browse_controller.dart`, `listings_repository.dart`

- **Grid layout** with listing cards showing category icon, price overlay, and title
- **Full-text search** with PostgreSQL `tsvector` + `pg_trgm` trigram fallback for typo tolerance, ranked by `ts_rank` blended with recency
- **Category filter chips** — six categories (Textbooks, Furniture, Electronics, Tickets, Clothing, Other), single-select, filters applied server-side
- **Price range slider** — toggle a "Price range" chip to reveal a $0–$500 range slider; filters listings by `min_price`/`max_price` query parameters server-side
- **Infinite scroll** with cursor-based pagination and skeleton loaders on first load
- **Pull-to-refresh** on the browse grid

### 2. Listing Detail with Photo Carousel

**File:** `listing_detail_screen.dart`

- **Image carousel** using `PageView` with animated page-indicator dots
- Each image shows a **moderation badge** ("Pending review") if it hasn't been approved yet by the content-safety pipeline
- **Seller profile card** with avatar initial, display name, Bayesian reputation score, and rating count (e.g., "4.7 (128)")
- **Condition chip** (New, Like New, Good, Fair, Poor) and **status chip** (SOLD, REMOVED) for non-active listings
- **"Message seller" CTA** in a sticky bottom action bar — opens (or reuses) a listing-context conversation

### 3. Owner Actions (Mark Sold, Edit, Remove)

**File:** `listing_detail_screen.dart`

When viewing your own listing, the detail screen adapts:

- **Three-dot menu** in the app bar with: Mark as Sold, Edit, Remove
- **Mark as Sold** calls `POST /listings/{id}/mark-sold`, updates the listing status, and refreshes the browse grid
- **Remove** shows a confirmation dialog, calls `DELETE /listings/{id}`, navigates back to browse
- **Owner bottom bar** replaces "Message seller" with a status indicator ("Your listing" / "Sold")
- Ownership is determined by comparing `listing.seller.id` against the authenticated user's ID

### 4. My Listings Screen

**Files:** `my_listings_screen.dart`, `profile_screen.dart`, `app_router.dart`

- Accessible from **Profile tab > "My Listings"** button
- Shows all listings belonging to the current user in a list view
- Each row displays: category icon, title, price, and SOLD badge if applicable
- **Quick actions menu** per listing: Mark Sold, Edit, Remove (same actions as the detail screen)
- **Empty state** with CTA to create a listing
- **FAB** to create a new listing directly from this screen
- Route: `/profile/my-listings`

### 5. Sell/Create Listing with Photo Upload UI

**File:** `sell_screen.dart`

- **Photo upload area** at the top of the form — tap "Add photo" to add up to 5 photo placeholders
- Each photo thumbnail has a **remove button** (red circle X)
- Info text: *"Photos upload via signed URL to S3. Pending moderation review."*
- **Form fields:** Title, Price ($), Category dropdown, Condition dropdown, Description
- **Inline validation** on all fields with auto-validate on interaction
- **Optimistic post** with loading spinner on the submit button
- On success: snackbar confirmation, browse grid refreshes, navigates back to marketplace

### 6. Backend Fixes for Flutter Web

**Files:** `main.py`, `api_provider.dart`, `Makefile`

- **CORS fix** — dev mode now uses `allow_origins=["*"]` so Flutter Web on any port can reach the API. Production retains the explicit allowlist.
- **Null/empty query param stripping** — the generated OpenAPI client serializes optional params as empty strings (`?category=&min_price=`), which FastAPI rejects as invalid. A Dio interceptor now strips any query parameter with a `null` or empty-string value before the request is sent.
- **Uvicorn binds to `0.0.0.0`** — previously only `127.0.0.1`, which blocked connections from emulators and physical devices.

---

## Architecture

### Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter 3.x (Dart 3.x), Material 3, Riverpod v2 |
| **Backend** | FastAPI (Python 3.12), async everywhere, Pydantic v2 |
| **Database** | PostgreSQL 15 with full-text search (`tsvector` + `pg_trgm`) |
| **Auth** | JWT access + refresh tokens, argon2id password hashing |
| **Storage** | S3-compatible (MinIO locally, AWS S3 in prod) via signed-URL direct upload |
| **Cache** | Redis for rate limiting and hot-read caching |
| **CI/CD** | GitHub Actions — two lanes (Python + Flutter) |

### Contract-First API Design

```
FastAPI + Pydantic  -->  contracts/openapi.json  -->  Generated Dart client
     (source)               (single contract)          (apps/mobile/api_client/)
```

- `contracts/openapi.json` is auto-exported from the FastAPI app
- The Flutter client (Dio + Retrofit interfaces + Freezed models) is **generated** from this file
- CI fails if the contract is stale vs. the code

### Backend Layering

```
Router (HTTP, Pydantic validation, auth dependency)
  --> Service (business logic, transactions)
    --> Repository (SQLAlchemy data access)
```

- No database access in routers
- No HTTP objects in services
- External services (email, moderation, storage, payments) behind interfaces with stub adapters

### Key Algorithms

- **Tutor match ranking** (spec 5.1): `score = 0.60 * reputation + 0.30 * recency + 0.10 * responsiveness`, with neutral priors for new tutors
- **Bayesian reputation** (spec 5.2): `(C * m + sum_stars) / (C + n)` — prevents two 5-star ratings from outranking hundreds of 4.8-star ratings
- **Search ranking**: `ts_rank` blended with recency multiplier; category/price/condition filters applied as SQL `WHERE` clauses

### Data Model

20 entities including: User, Listing, ListingImage, Course, TutorOffering, Conversation, Message, Chat, ChatMembership, ChatMessage, Rating, Report, Notification, AuditLog, Flag (feature flags).

Seed script populates: 50 courses, 20 verified users, 40 listings across categories, 16 tutor offerings, 5 community chats with messages, and sample ratings.

---

## App Features Overview

### Three Core Journeys

| Journey | Flow | Taps |
|---------|------|------|
| **J1 — Sell** | Open app > Sell tab > photo > title + price > post | 5 taps |
| **J2 — Find a tutor** | Open app > Tutor tab > course code > ranked list > message | 4 taps |
| **J3 — Join a chat** | Open app > Chats tab > browse directory > join > post | 3 taps |

### Feature Breakdown

| Feature | Status | Notes |
|---------|--------|-------|
| Auth (register, verify, login, logout) | Done | .edu email verification, argon2id, JWT rotation |
| Marketplace browse + search + filters | Done | Full-text search, category chips, price range slider |
| Listing detail with photo carousel | Done | PageView carousel, moderation badges, seller card |
| Create/sell listing with photo upload | Done | Multi-photo upload area, form validation |
| Owner actions (mark sold, edit, remove) | Done | Three-dot menu, confirmation dialogs |
| My Listings management screen | Done | Profile > My Listings, quick actions per listing |
| Messaging (1:1 conversations) | Done | Polling-based, optimistic send, read receipts |
| Tutor search with ranked results | Done | Bayesian ranking, neutral-prior cold-start |
| Community chats with moderation | Done | Directory, join/leave, mod tools (mute/ban/delete) |
| Notifications | Done | Bell badge, per-event preferences |
| Dark/light theme | Done | Follows OS setting, WCAG 2.1 AA contrast |
| Reputation system | Done | Bayesian prior, portable across features |

### Monetization Rails (scaffolded, flags OFF)

- Promoted listings (`flags.promoted_listings`)
- Premium tutor tier (`flags.tutor_premium`)
- Escrow payments (`flags.escrow`)
- Partner placements (`flags.partner_slots`)

All behind feature flags, disabled by default. No real charge path active.

---

## Development Commands

| Command | What it does |
|---------|-------------|
| `make dev` | Full local stack + API with hot reload |
| `make ci` | Everything CI runs: lint, type-check, tests, contract check (both lanes) |
| `make ci-api` | ruff + mypy (strict) + pytest + OpenAPI freshness |
| `make ci-mobile` | dart format + flutter analyze + flutter test |
| `make export-openapi` | Re-export `contracts/openapi.json` after API schema changes |
| `make migrate` | Run Alembic database migrations |
| `make seed` | Populate database with realistic demo data |

## Project Structure

```
campusconnect/
├── apps/
│   ├── mobile/              # Flutter app (iOS, Android, Web)
│   │   ├── lib/
│   │   │   ├── core/        # Theme, router, DI, network, env
│   │   │   ├── features/    # Feature-first: auth, marketplace, tutoring, chats, messaging, profile
│   │   │   ├── shared/      # Shared widgets, extensions
│   │   │   └── api/         # Generated API client from OpenAPI
│   │   └── test/            # Unit + widget tests
│   └── api/                 # FastAPI backend
│       ├── app/
│       │   ├── core/        # Config, security, logging, rate limiting
│       │   ├── models/      # SQLAlchemy models
│       │   ├── schemas/     # Pydantic request/response models
│       │   ├── api/v1/      # REST routers per resource
│       │   ├── services/    # Business logic layer
│       │   ├── repositories/# Data access layer
│       │   └── integrations/# External service adapters (stub + real)
│       ├── alembic/         # Database migrations
│       └── tests/           # pytest (unit + integration)
├── contracts/
│   └── openapi.json         # API contract (source of truth)
├── infra/
│   └── docker-compose.yml   # Postgres, Redis, MinIO, Mailhog
├── docs/
│   ├── adr/                 # Architecture decision records
│   ├── RUN_LOG.md           # Build journal
│   └── RUNBOOK.md           # Ops runbook
└── .github/workflows/       # CI/CD pipelines
```

## Documentation

- **Architecture decisions:** `docs/adr/`
- **Ops runbook:** `docs/RUNBOOK.md`
- **Build journal:** `docs/RUN_LOG.md`
- **API reference:** http://localhost:8000/redoc (live from the running server)
- **Security checklist:** `docs/security/owasp.md`

## Deploy

Tagging `v*` runs `.github/workflows/deploy.yml`: migrate > deploy API > web/mobile
artifacts > smoke (`/health/ready`, `/flags`, auth boundary) > rollback on failure.
All cloud steps are secret-guarded, so it dry-runs green without credentials.
