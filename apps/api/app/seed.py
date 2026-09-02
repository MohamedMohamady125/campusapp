"""Async demo-data seed (spec §3): courses, users, listings, tutors, chats, ratings.

Run with: python -m app.seed
Idempotent: skips seeding if any user already exists.
"""

import asyncio
import random
import uuid
from datetime import UTC, datetime, timedelta

import structlog
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import hash_password
from app.db.session import async_session_factory
from app.models import (
    Chat,
    ChatMembership,
    ChatMessage,
    Course,
    Flag,
    FoodSpot,
    Listing,
    ListingImage,
    Rating,
    Run,
    RunOrder,
    TutorOffering,
    User,
)
from app.models.enums import (
    ChatRole,
    FoodSpotCategory,
    ListingCategory,
    ListingCondition,
    ModerationStatus,
    RatingContext,
    RunOrderStatus,
    RunStatus,
)

log = structlog.get_logger()

rng = random.Random(42)  # deterministic seed data

_DEPARTMENTS = {
    "CS": "Computer Science",
    "MATH": "Mathematics",
    "PHYS": "Physics",
    "CHEM": "Chemistry",
    "BIO": "Biology",
    "ECON": "Economics",
    "PSY": "Psychology",
    "ENG": "English",
    "HIST": "History",
    "STAT": "Statistics",
}

_COURSE_TITLES = [
    "Intro to {}",
    "Intermediate {}",
    "Advanced {}",
    "Topics in {}",
    "Foundations of {}",
]

_FIRST = [
    "Ava",
    "Ben",
    "Chloe",
    "Dan",
    "Ella",
    "Finn",
    "Grace",
    "Hugo",
    "Iris",
    "Jack",
    "Kara",
    "Liam",
    "Maya",
    "Noah",
    "Olive",
    "Pete",
    "Quinn",
    "Rosa",
    "Sam",
    "Tess",
]

_LISTING_SEEDS: list[tuple[str, str, ListingCategory, int]] = [
    (
        "Calculus Early Transcendentals 9th ed",
        "Barely used, no highlights.",
        ListingCategory.textbooks,
        4500,
    ),
    (
        "Organic Chemistry textbook + model kit",
        "Includes solutions manual.",
        ListingCategory.textbooks,
        6000,
    ),
    ("IKEA desk (white)", "Sturdy, minor scratch on leg.", ListingCategory.furniture, 3500),
    ("Mini fridge 3.2 cu ft", "Works great, moving out sale.", ListingCategory.electronics, 8000),
    (
        "TI-84 Plus CE calculator",
        "Perfect condition with charger.",
        ListingCategory.electronics,
        9000,
    ),
    ("Dorm futon", "Comfy, folds flat, smoke-free room.", ListingCategory.furniture, 5000),
    ("Basketball game tickets (2)", "Section 104, this Saturday.", ListingCategory.tickets, 3000),
    (
        "Noise-cancelling headphones",
        "Sony WH-1000XM4, light use.",
        ListingCategory.electronics,
        15000,
    ),
    ("Physics for Scientists 4th ed", "Some notes in margins.", ListingCategory.textbooks, 4000),
    ("Desk lamp with USB port", "LED, three brightness levels.", ListingCategory.furniture, 1200),
]

_CHATS = [
    ("CS Majors", "cs-majors", "Everything computer science."),
    ("Campus Housing", "campus-housing", "Sublets, roommates, housing tips."),
    ("Intramural Sports", "intramural-sports", "Pickup games and team signups."),
    ("Study Abroad", "study-abroad", "Programs, visas, packing lists."),
    ("Free Food Alerts", "free-food-alerts", "Events with free food. The essentials."),
]

_FLAGS = [
    ("realtime", False),
    ("promoted_listings", False),
    ("tutor_premium", False),
    ("escrow", False),
    ("partner_slots", False),
    # Runs-first launch (food-runs spec): only the hero tab is visible; the
    # rest re-appear by flipping these rows — zero code changes.
    ("tab_food_runs", True),
    ("tab_marketplace", False),
    ("tab_tutoring", False),
    ("tab_chats", False),
]

# GCU launch catalog: Lopes Way venues + walkable off-campus staples.
_FOOD_SPOTS: list[tuple[str, FoodSpotCategory, str]] = [
    ("Chick-fil-A (Lopes Way)", FoodSpotCategory.campus, "Closed Sundays. Lines get long at noon."),
    ("Panda Express (Lopes Way)", FoodSpotCategory.campus, "Orange chicken never misses."),
    ("Qdoba (Lopes Way)", FoodSpotCategory.campus, "Burritos, bowls, queso."),
    ("Subway (Lopes Way)", FoodSpotCategory.campus, "Footlongs on Lopes Way."),
    ("Pita Jungle (GCU)", FoodSpotCategory.campus, "Fresh Mediterranean on campus."),
    ("Canyon Pizza Co.", FoodSpotCategory.campus, "Late-night slices."),
    ("The Grid (POD Market)", FoodSpotCategory.campus, "Snacks, drinks, essentials."),
    ("Chipotle (27th Ave)", FoodSpotCategory.off_campus, "Just off campus — bowl run classic."),
    ("Raising Cane's (Camelback)", FoodSpotCategory.off_campus, "Box combos + Cane's sauce."),
    ("Dutch Bros (Camelback)", FoodSpotCategory.off_campus, "Coffee runs before 8am class."),
    ("In-N-Out (Northern Ave)", FoodSpotCategory.off_campus, "Worth the drive. Animal style."),
]


async def _seed(session: AsyncSession) -> None:
    existing = (await session.execute(select(func.count()).select_from(User))).scalar_one()
    if existing:
        log.info("seed.skipped", users=existing)
        return

    now = datetime.now(UTC)

    # Feature flags (spec §2.4, §13) — all dark by default.
    for key, enabled in _FLAGS:
        session.add(Flag(key=key, enabled=enabled))

    # ~50 courses.
    courses: list[Course] = []
    for dept, dept_name in _DEPARTMENTS.items():
        for i, tpl in enumerate(_COURSE_TITLES):
            course = Course(
                code=f"{dept}{100 + i * 100 + rng.randint(0, 50)}",
                title=tpl.format(dept_name),
                department=dept_name,
            )
            courses.append(course)
            session.add(course)

    # 20 verified demo users. Same demo password for all.
    password_hash = hash_password("Password123!")
    users: list[User] = []
    for i, first in enumerate(_FIRST):
        user = User(
            email=f"{first.lower()}{i}@campus.edu",
            password_hash=password_hash,
            email_verified_at=now,
            display_name=f"{first} {chr(65 + i)}.",
            year=rng.choice(["freshman", "sophomore", "junior", "senior"]),
            major=rng.choice(list(_DEPARTMENTS.values())),
            bio=f"Hi, I'm {first}! Always up for a study session.",
            last_active_at=now - timedelta(hours=rng.randint(0, 72)),
        )
        users.append(user)
        session.add(user)

    await session.flush()

    # ~40 listings with placeholder images.
    listings: list[Listing] = []
    for i in range(40):
        title, desc, category, price = _LISTING_SEEDS[i % len(_LISTING_SEEDS)]
        listing = Listing(
            seller_id=rng.choice(users).id,
            title=title if i < len(_LISTING_SEEDS) else f"{title} #{i}",
            description=desc,
            price_cents=price + rng.randint(-500, 500),
            category=category,
            condition=rng.choice(list(ListingCondition)),
            expires_at=now + timedelta(days=90),
        )
        listings.append(listing)
        session.add(listing)
    await session.flush()
    for listing in listings:
        session.add(
            ListingImage(
                listing_id=listing.id,
                s3_key=f"seed/listings/{listing.id}/0.jpg",
                order=0,
                moderation_status=ModerationStatus.approved,
            )
        )

    # Tutor offerings: 8 tutors across seeded courses.
    for tutor in users[:8]:
        for course in rng.sample(courses, k=2):
            session.add(
                TutorOffering(
                    tutor_id=tutor.id,
                    course_id=course.id,
                    term_taken=rng.choice(["2025-fall", "2025-spring", "2024-fall"]),
                    grade_received=rng.choice(["A+", "A", "A-"]),
                    blurb="Took this recently — happy to help with problem sets.",
                )
            )

    # 5 open chats with members + messages.
    for name, slug, desc in _CHATS:
        owner = rng.choice(users)
        chat = Chat(name=name, slug=slug, description=desc, created_by_id=owner.id)
        session.add(chat)
        await session.flush()
        session.add(ChatMembership(chat_id=chat.id, user_id=owner.id, role=ChatRole.owner))
        members = [u for u in rng.sample(users, k=6) if u.id != owner.id]
        for member in members:
            session.add(ChatMembership(chat_id=chat.id, user_id=member.id))
        for j in range(5):
            sender = rng.choice([owner, *members])
            session.add(
                ChatMessage(
                    chat_id=chat.id,
                    sender_id=sender.id,
                    body=f"Welcome to {name}! Message {j + 1}.",
                )
            )

    # Food spots + demo runs (food-runs spec).
    spots: list[FoodSpot] = []
    for spot_name, spot_category, spot_desc in _FOOD_SPOTS:
        spot = FoodSpot(name=spot_name, category=spot_category, description=spot_desc, active=True)
        spots.append(spot)
        session.add(spot)
    # Runners need at least one payment method to charge a fee.
    for user in users[:6]:
        handle = f"@{user.display_name.split()[0]}-GCU"
        user.venmo_handle = handle
        user.payment_methods = [{"type": "venmo", "handle": handle}]
    await session.flush()

    # 1) An open run leaving soon — the feed's hero card.
    open_run = Run(
        runner_id=users[0].id,
        food_spot_id=spots[0].id,
        delivery_spot="Juniper Hall lobby",
        note="Leaving right after class, drop your order!",
        leaving_at=now + timedelta(minutes=25),
        fee_cents=200,
        spots_max=4,
        prepay_required=False,
        status=RunStatus.open,
    )
    session.add(open_run)
    await session.flush()
    session.add(
        RunOrder(
            run_id=open_run.id,
            requester_id=users[3].id,
            order_text="Spicy deluxe meal, lemonade, Polynesian sauce",
            status=RunOrderStatus.requested,
        )
    )

    # 2) A run mid-delivery.
    delivering_run = Run(
        runner_id=users[1].id,
        food_spot_id=spots[7].id,
        delivery_spot="Encanto Apartments courtyard",
        leaving_at=now - timedelta(minutes=20),
        fee_cents=300,
        spots_max=3,
        prepay_required=True,
        status=RunStatus.delivering,
    )
    session.add(delivering_run)
    await session.flush()
    session.add(
        RunOrder(
            run_id=delivering_run.id,
            requester_id=users[4].id,
            order_text="Chicken bowl, white rice, double chicken, mild salsa",
            status=RunOrderStatus.accepted,
        )
    )

    # 3) A completed run with a received order — powers demo run ratings.
    done_run = Run(
        runner_id=users[2].id,
        food_spot_id=spots[9].id,
        delivery_spot="Library front steps",
        leaving_at=now - timedelta(hours=3),
        fee_cents=150,
        spots_max=2,
        prepay_required=False,
        status=RunStatus.done,
        completed_at=now - timedelta(hours=2),
    )
    session.add(done_run)
    await session.flush()
    done_order = RunOrder(
        run_id=done_run.id,
        requester_id=users[5].id,
        order_text="Golden eagle, medium, soft top",
        status=RunOrderStatus.received,
    )
    session.add(done_order)
    await session.flush()
    session.add(
        Rating(
            rater_id=users[5].id,
            rated_user_id=users[2].id,
            context_type=RatingContext.run,
            context_id=done_order.id,
            stars=5,
            comment="Super fast, drink still cold. Legend.",
        )
    )
    session.add(
        Rating(
            rater_id=users[2].id,
            rated_user_id=users[5].id,
            context_type=RatingContext.run,
            context_id=done_order.id,
            stars=5,
            comment="Paid instantly, easy handoff.",
        )
    )

    # Sample ratings (context ids reference seeded listings).
    for _ in range(30):
        rater, rated = rng.sample(users, k=2)
        listing = rng.choice(listings)
        stars = rng.randint(3, 5)
        session.add(
            Rating(
                rater_id=rater.id,
                rated_user_id=rated.id,
                context_type=RatingContext.listing,
                context_id=listing.id if rng.random() > 0.5 else uuid.uuid4(),
                stars=stars,
                comment="Smooth transaction!" if stars >= 4 else "It was okay.",
            )
        )

    # Recompute cached reputation (Bayesian §5.2: (C*m + sum) / (C + n), C=8, m=4.0).
    await session.flush()
    result = await session.execute(
        select(Rating.rated_user_id, func.count(), func.sum(Rating.stars)).group_by(
            Rating.rated_user_id
        )
    )
    prior_c, global_m = 8, 4.0
    for rated_user_id, n, total in result.all():
        user = next(u for u in users if u.id == rated_user_id)
        user.reputation_score = (prior_c * global_m + float(total)) / (prior_c + int(n))
        user.rating_count = int(n)

    await session.commit()
    log.info(
        "seed.done",
        courses=len(courses),
        users=len(users),
        listings=len(listings),
        chats=len(_CHATS),
        food_spots=len(spots),
        runs=3,
    )


async def main() -> None:
    async with async_session_factory() as session:
        await _seed(session)


if __name__ == "__main__":
    asyncio.run(main())
