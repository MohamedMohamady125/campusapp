"""Bulk food-runs demo data for realistic load testing (food-runs spec).

Layers a large, realistic dataset on top of the base seed:
- 40 extra verified users (total 60) with Venmo handles
- ~45 open runs spread over the next few hours (feed scroll testing)
- ~18 in-progress runs (locked / at_store / delivering) with group chats
- ~60 completed runs over the past 2 weeks with two-way ratings
- a handful of expired / cancelled runs
- run notifications for the first few demo users
- reputation recomputed for everyone (Bayesian §5.2)

Run with: python -m app.seed_runs_bulk
Idempotent: skips if more than 10 runs already exist.
"""

import asyncio
import random
from datetime import UTC, datetime, timedelta

import structlog
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import hash_password
from app.db.session import async_session_factory
from app.models import (
    Conversation,
    ConversationParticipant,
    FoodSpot,
    Message,
    Notification,
    Rating,
    Run,
    RunOrder,
    User,
)
from app.models.enums import (
    ConversationContext,
    RatingContext,
    RunOrderStatus,
    RunStatus,
)

log = structlog.get_logger()

rng = random.Random(7)

_EXTRA_FIRST = [
    "Aiden",
    "Bella",
    "Carlos",
    "Diana",
    "Eli",
    "Fatima",
    "Gabe",
    "Hana",
    "Ivan",
    "Jade",
    "Kobe",
    "Luna",
    "Marco",
    "Nina",
    "Omar",
    "Paige",
    "Rico",
    "Sofia",
    "Tyler",
    "Uma",
    "Vince",
    "Wren",
    "Ximena",
    "Yusuf",
    "Zara",
    "Andre",
    "Brooke",
    "Caleb",
    "Demi",
    "Ethan",
    "Faye",
    "Gio",
    "Holly",
    "Isaac",
    "Jenna",
    "Kai",
    "Lena",
    "Miles",
    "Nora",
    "Owen",
]

_DELIVERY_SPOTS = [
    "Juniper Hall lobby",
    "Ironwood Hall front desk",
    "Acacia Hall study room",
    "Encanto Apartments courtyard",
    "Papago Apartments mailroom",
    "Library front steps",
    "Student Union entrance",
    "Lopes Way fountain",
    "CSET building lobby",
    "Chaparral Hall elevators",
    "Prescott Hall lounge",
    "The Grove picnic tables",
]

_NOTES = [
    "Leaving right after class, drop your order!",
    "Walking over in a bit, happy to grab extras.",
    "Gym first, then food. Order up.",
    "Anyone else craving this? Tag along.",
    "Quick run between classes, be fast!",
    "Roommate bailed so I have room for more orders.",
    None,
    None,
]

# Per-spot realistic order text (keyed by substring of spot name).
_ORDERS: dict[str, list[str]] = {
    "Chick-fil-A": [
        "Spicy deluxe meal, lemonade, Polynesian sauce",
        "12-count nuggets, fries, Chick-fil-A sauce x3",
        "Cobb salad with avocado ranch",
        "Grilled club, no tomato, sweet tea",
    ],
    "Panda": [
        "Orange chicken + chow mein plate",
        "Bigger plate: beijing beef, honey walnut shrimp, fried rice",
        "Bowl with super greens and teriyaki chicken",
    ],
    "Qdoba": [
        "Chicken burrito, queso inside, no beans",
        "Impossible bowl, brown rice, extra pico",
        "3 tacos al pastor + chips and queso",
    ],
    "Subway": [
        "Footlong turkey on italian herb, everything, toasted",
        "6in tuna, provolone, spinach, chipotle sauce",
        "Steak & cheese footlong, double meat",
    ],
    "Pita": [
        "Chicken shawarma pita + hummus side",
        "Falafel bowl, extra tahini",
        "Greek salad with gyro meat",
    ],
    "Pizza": [
        "2 pepperoni slices + ranch",
        "Personal margherita, extra basil",
        "BBQ chicken slice + garlic knots",
    ],
    "Grid": [
        "Celsius (arctic vibe), sour patch kids, cup noodles",
        "Red bull, protein bar, hot cheetos",
        "Two Gatorades (blue) and a muffin",
    ],
    "Chipotle": [
        "Chicken bowl, white rice, double chicken, mild salsa",
        "Steak burrito, brown rice, black beans, guac (I know it's extra)",
        "Veggie bowl, fajita veggies, corn, cheese, lettuce",
        "Carnitas quesadilla + chips",
    ],
    "Cane's": [
        "Box combo, extra toast, lemonade",
        "3 finger combo, extra Cane's sauce x2",
        "Caniac combo — starving, don't judge",
    ],
    "Dutch": [
        "Golden eagle, medium, soft top",
        "Iced caramelizer, large",
        "Rebel energy, strawberry, medium",
        "White chocolate mocha, oat milk, hot",
    ],
    "In-N-Out": [
        "Double-double animal style, fries well done, neapolitan shake",
        "Cheeseburger, animal fries, pink lemonade",
        "2 double-doubles plain (one's for my roommate)",
    ],
}
_DEFAULT_ORDERS = ["The usual, text me if they're out", "Whatever combo #1 is + a drink"]

_RATING_GOOD = [
    "Super fast, food still hot. Legend.",
    "Dropped it right at my door, 10/10.",
    "Got my order perfect, even the sauces.",
    "Quick and friendly, would order again.",
    "Clutch before my 2pm. Thank you!!",
]
_RATING_OK = [
    "Took a bit longer than posted but all good.",
    "Fries were cold but everything else fine.",
]
_RATING_RUNNER = [
    "Paid instantly, easy handoff.",
    "Was at the spot on time, smooth.",
    "Venmo'd before I even got back. Great.",
    "Easy pickup, clear instructions.",
]


def _order_text(spot_name: str) -> str:
    for key, options in _ORDERS.items():
        if key in spot_name:
            return rng.choice(options)
    return rng.choice(_DEFAULT_ORDERS)


async def _seed(session: AsyncSession) -> None:
    run_count = (await session.execute(select(func.count()).select_from(Run))).scalar_one()
    if run_count > 10:
        log.info("seed_runs_bulk.skipped", runs=run_count)
        return

    now = datetime.now(UTC)

    users = list((await session.execute(select(User).order_by(User.created_at))).scalars())
    spots = list(
        (await session.execute(select(FoodSpot).where(FoodSpot.active.is_(True)))).scalars()
    )
    if not users or not spots:
        log.error("seed_runs_bulk.missing_base_seed")
        return

    # 40 extra verified users so the campus feels alive.
    password_hash = hash_password("Password123!")
    for i, first in enumerate(_EXTRA_FIRST):
        user = User(
            email=f"{first.lower()}{i + 100}@campus.edu",
            password_hash=password_hash,
            email_verified_at=now,
            display_name=f"{first} {chr(65 + i % 26)}.",
            year=rng.choice(["freshman", "sophomore", "junior", "senior"]),
            major=rng.choice(
                ["Computer Science", "Nursing", "Business", "Biology", "Psychology", "Engineering"]
            ),
            bio=rng.choice(
                [
                    f"{first} here — always down for a food run.",
                    "Chronic snacker. Will run for tips.",
                    "Between classes most of the day, hmu.",
                    "",
                ]
            ),
            last_active_at=now - timedelta(minutes=rng.randint(1, 4000)),
        )
        users.append(user)
        session.add(user)
    await session.flush()

    # Everyone gets a Venmo handle — every user can post fee runs.
    for user in users:
        if not user.venmo_handle:
            user.venmo_handle = f"@{user.display_name.split()[0]}-GCU{rng.randint(1, 99)}"

    def _new_run(
        runner: User,
        *,
        status: RunStatus,
        leaving_at: datetime,
        completed_at: datetime | None = None,
    ) -> Run:
        run = Run(
            runner_id=runner.id,
            food_spot_id=rng.choice(spots).id,
            delivery_spot=rng.choice(_DELIVERY_SPOTS),
            note=rng.choice(_NOTES),
            leaving_at=leaving_at,
            fee_cents=rng.choice([0, 100, 100, 150, 200, 200, 250, 300, 500]),
            spots_max=rng.randint(1, 6),
            prepay_required=rng.random() < 0.3,
            status=status,
            completed_at=completed_at,
        )
        session.add(run)
        return run

    def _spot_name(run: Run) -> str:
        return next(s.name for s in spots if s.id == run.food_spot_id)

    async def _add_orders(run: Run, runner: User, statuses: list[RunOrderStatus]) -> list[RunOrder]:
        requesters = rng.sample([u for u in users if u.id != runner.id], k=len(statuses))
        orders = []
        for requester, order_status in zip(requesters, statuses, strict=True):
            order = RunOrder(
                run_id=run.id,
                requester_id=requester.id,
                order_text=_order_text(_spot_name(run)),
                status=order_status,
            )
            session.add(order)
            orders.append(order)
        return orders

    async def _add_chat(run: Run, runner: User, orders: list[RunOrder]) -> None:
        """Group chat exactly as the service creates it on first accept."""
        active = [
            o
            for o in orders
            if o.status
            in (RunOrderStatus.accepted, RunOrderStatus.delivered, RunOrderStatus.received)
        ]
        if not active:
            return
        convo = Conversation(context_type=ConversationContext.run, context_id=run.id)
        session.add(convo)
        await session.flush()
        run.conversation_id = convo.id
        session.add(ConversationParticipant(conversation_id=convo.id, user_id=runner.id))
        for order in active:
            session.add(
                ConversationParticipant(conversation_id=convo.id, user_id=order.requester_id)
            )
        openers = [
            f"Heading to {_spot_name(run)} soon, got everyone's orders!",
            "On my way, anything else before I leave?",
            f"Meet at {run.delivery_spot} in ~15.",
        ]
        session.add(
            Message(conversation_id=convo.id, sender_id=runner.id, body=rng.choice(openers))
        )
        for order in active[:2]:
            session.add(
                Message(
                    conversation_id=convo.id,
                    sender_id=order.requester_id,
                    body=rng.choice(["Thank you!!", "You're the best", "Venmo sent 🙏", "omw"]),
                )
            )

    n_open = n_active = n_done = 0
    all_runs: list[tuple[Run, User]] = []  # (run, runner) for notification payloads

    # ~45 open runs over the next 6 hours — plenty to scroll.
    for _ in range(45):
        runner = rng.choice(users)
        run = _new_run(
            runner,
            status=RunStatus.open,
            leaving_at=now + timedelta(minutes=rng.randint(5, 360)),
        )
        await session.flush()
        n_pending = rng.choices([0, 1, 2, 3], weights=[3, 4, 2, 1])[0]
        n_accepted = rng.choices([0, 1, 2], weights=[5, 3, 1])[0]
        n_accepted = min(n_accepted, run.spots_max)
        n_pending = min(n_pending, run.spots_max - n_accepted)
        orders = await _add_orders(
            run,
            runner,
            [RunOrderStatus.requested] * n_pending + [RunOrderStatus.accepted] * n_accepted,
        )
        await session.flush()
        await _add_chat(run, runner, orders)
        all_runs.append((run, runner))
        n_open += 1

    # ~18 in-progress runs: locked / at_store / delivering with accepted orders.
    for status in [RunStatus.locked] * 5 + [RunStatus.at_store] * 6 + [RunStatus.delivering] * 7:
        runner = rng.choice(users)
        run = _new_run(
            runner,
            status=status,
            leaving_at=now - timedelta(minutes=rng.randint(5, 45)),
        )
        await session.flush()
        statuses = [RunOrderStatus.accepted] * rng.randint(1, min(3, run.spots_max))
        if status == RunStatus.delivering and rng.random() < 0.5:
            statuses[0] = RunOrderStatus.delivered
        orders = await _add_orders(run, runner, statuses)
        await session.flush()
        await _add_chat(run, runner, orders)
        all_runs.append((run, runner))
        n_active += 1

    # ~60 completed runs across the past 2 weeks with two-way ratings.
    for _ in range(60):
        runner = rng.choice(users)
        finished = now - timedelta(minutes=rng.randint(60, 14 * 24 * 60))
        run = _new_run(
            runner,
            status=RunStatus.done,
            leaving_at=finished - timedelta(minutes=rng.randint(20, 50)),
            completed_at=finished,
        )
        await session.flush()
        k = rng.randint(1, min(3, run.spots_max))
        statuses = [
            rng.choices(
                [RunOrderStatus.received, RunOrderStatus.delivered, RunOrderStatus.no_show],
                weights=[8, 2, 1],
            )[0]
            for _ in range(k)
        ]
        orders = await _add_orders(run, runner, statuses)
        await session.flush()
        await _add_chat(run, runner, orders)
        all_runs.append((run, runner))
        for order in orders:
            if order.status != RunOrderStatus.received:
                continue
            if rng.random() < 0.85:  # requester rates runner
                stars = rng.choices([5, 4, 3], weights=[7, 2, 1])[0]
                session.add(
                    Rating(
                        rater_id=order.requester_id,
                        rated_user_id=runner.id,
                        context_type=RatingContext.run,
                        context_id=order.id,
                        stars=stars,
                        comment=rng.choice(_RATING_GOOD if stars == 5 else _RATING_OK),
                    )
                )
            if rng.random() < 0.6:  # runner rates requester
                session.add(
                    Rating(
                        rater_id=runner.id,
                        rated_user_id=order.requester_id,
                        context_type=RatingContext.run,
                        context_id=order.id,
                        stars=rng.choices([5, 4], weights=[8, 2])[0],
                        comment=rng.choice(_RATING_RUNNER),
                    )
                )
        n_done += 1

    # A few expired / cancelled runs for the "my runs" history.
    for status in [RunStatus.expired] * 4 + [RunStatus.cancelled] * 3:
        runner = rng.choice(users)
        run = _new_run(
            runner,
            status=status,
            leaving_at=now - timedelta(hours=rng.randint(2, 72)),
        )
        await session.flush()
        if rng.random() < 0.5:
            await _add_orders(run, runner, [RunOrderStatus.declined])
        await session.flush()

    # Run notifications for the first 6 demo users so the bell has content.
    # Payload matches RunService._notify: run_id / spot_name / runner_name.
    for user in users[:6]:
        for ntype in ("run_request", "run_request_accepted", "run_status", "run_completed"):
            if rng.random() < 0.7:
                run, runner = rng.choice(all_runs)
                session.add(
                    Notification(
                        user_id=user.id,
                        type=ntype,
                        payload={
                            "run_id": str(run.id),
                            "spot_name": _spot_name(run),
                            "runner_name": runner.display_name,
                        },
                        read_at=now if rng.random() < 0.4 else None,
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
    by_id = {u.id: u for u in users}
    for rated_user_id, n, total in result.all():
        rated = by_id.get(rated_user_id)
        if rated is not None:
            rated.reputation_score = (prior_c * global_m + float(total)) / (prior_c + int(n))
            rated.rating_count = int(n)

    await session.commit()
    log.info(
        "seed_runs_bulk.done",
        users=len(users),
        open_runs=n_open,
        active_runs=n_active,
        done_runs=n_done,
        expired_cancelled=7,
    )


async def main() -> None:
    async with async_session_factory() as session:
        await _seed(session)


if __name__ == "__main__":
    asyncio.run(main())
