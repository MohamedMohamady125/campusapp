"""GCU campus catalog with accurate coordinates (OpenStreetMap-sourced).

Upserts the full real-world catalog:
- food_spots: every on-campus dining venue (Lopes Way / Student Union /
  Thunder Alley) + walkable off-campus staples, with OSM building centroids.
- dropoff_locations: every residence hall, apartment complex, academic
  building, landmark and parking garage a requester could meet a runner at.

Idempotent: matches rows by exact name, updates coordinates / category /
description in place, inserts what is missing, never deletes (orders
denormalize the drop-off name, so rows only ever get more accurate).
Runs on every boot via start.sh; also runnable ad-hoc:

    python -m app.seed_gcu_catalog
"""

import asyncio

import structlog
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import async_session_factory
from app.models import DropoffLocation, FoodSpot
from app.models.enums import FoodSpotCategory

log = structlog.get_logger()

# 2:1 banner crop with entropy framing — Unsplash pre-crops to the exact
# aspect the feed-card banner renders at, so BoxFit.cover never has to zoom
# into a macro close-up (the raw portrait/square originals looked terrible
# squeezed into a wide strip).
_UNSPLASH = (
    "https://images.unsplash.com/photo-{pid}?auto=format&fit=crop&crop=entropy&w=1000&h=500&q=70"
)


def _img(pid: str) -> str:
    """Curated per-venue photo (every ID verified live + visually reviewed
    against the cuisine before landing here — don't swap without re-checking
    the actual image content)."""
    return _UNSPLASH.format(pid=pid)


# (canonical name, category, description, lat, lng, image)
# Coordinates are OSM building centroids inside the GCU campus (Oct 2026).
# Venue list matches gcu.edu/admissions/visit-gcu-campus/campus-dining
# (Oct 2026): Lopes Way, Student Union, Thunderground, Arena/Quad, the
# residential GCBC/market satellites, The Rivers retail and Cañón 49.
_FOOD_SPOTS: list[tuple[str, FoodSpotCategory, str, float, float, str]] = [
    # --- on campus: Lopes Way ---------------------------------------------
    (
        "Chick-fil-A (Lopes Way)",
        FoodSpotCategory.campus,
        "Closed Sundays. Lines get long at noon.",
        33.512883,
        -112.122559,
        _img("1606755962773-d324e0a13086"),  # fried-chicken sandwich
    ),
    (
        "Panda Express (Lopes Way)",
        FoodSpotCategory.campus,
        "Orange chicken never misses.",
        33.512596,
        -112.127117,
        _img("1525755662778-989d0524087e"),  # orange chicken plate
    ),
    (
        "Subway (Lopes Way)",
        FoodSpotCategory.campus,
        "Footlongs on Lopes Way.",
        33.512585,
        -112.127650,
        _img("1528735602780-2552fd46c7af"),  # toasted sub
    ),
    (
        "Taco Thunder (Lopes Way)",
        FoodSpotCategory.campus,
        "Street tacos on Lopes Way.",
        33.512700,
        -112.125500,
        _img("1551504734-5ee1c4a1479b"),  # street tacos + salsa
    ),
    (
        "Pita Jungle (GCU)",
        FoodSpotCategory.campus,
        "Fresh Mediterranean on campus.",
        33.512577,
        -112.128563,
        _img("1540914124281-342587941389"),  # mezze spread
    ),
    (
        "Kaminari (Lopes Way)",
        FoodSpotCategory.campus,
        "Korean street food + poke on Lopes Way.",
        33.512599,
        -112.127240,
        _img("1590301157890-4810ed352733"),  # bibimbap bowl
    ),
    # --- on campus: Student Union ------------------------------------------
    (
        "Qdoba (Student Union)",
        FoodSpotCategory.campus,
        "Burritos, bowls, queso.",
        33.513231,
        -112.130269,
        _img("1562059390-a761a084768e"),  # burrito wraps
    ),
    (
        "Canyon Pizza Company",
        FoodSpotCategory.campus,
        "Late-night slices.",
        33.513085,
        -112.129835,
        _img("1513104890138-7c749659a591"),  # pepperoni pizza
    ),
    (
        "Einstein Bros. Bagels",
        FoodSpotCategory.campus,
        "Bagels + coffee by the Student Union.",
        33.513353,
        -112.130217,
        _img("1585445490387-f47934b73b54"),  # fresh bagel tray
    ),
    (
        "Jamba (Student Union)",
        FoodSpotCategory.campus,
        "Smoothies between classes.",
        33.513294,
        -112.130264,
        _img("1505252585461-04db1eb84625"),  # layered smoothies
    ),
    (
        "The Habit Burger Grill",
        FoodSpotCategory.campus,
        "Charburgers by the Union.",
        33.513386,
        -112.129806,
        _img("1568901346375-23c9450c58cd"),  # charburger
    ),
    (
        "Lopes Training Table",
        FoodSpotCategory.campus,
        "Protein plates by the Union.",
        33.513267,
        -112.129983,
        _img("1532550907401-a500c9a57435"),  # grilled chicken plate
    ),
    (
        "Lopacelli's Pasta (Student Union)",
        FoodSpotCategory.campus,
        "Pasta + breadsticks in the Union.",
        33.513310,
        -112.130120,
        _img("1551183053-bf91a1d81141"),  # fresh pasta
    ),
    (
        "GCBC (Grand Canyon Beverage Co.)",
        FoodSpotCategory.campus,
        "Campus coffee — pre-8am lifesaver.",
        33.511778,
        -112.128841,
        _img("1509042239860-f550ce710b93"),  # latte art
    ),
    # --- on campus: Thunderground ------------------------------------------
    (
        "Taco Bell (Thunder Alley)",
        FoodSpotCategory.campus,
        "Crunchwrap HQ in the Thunderground.",
        33.513613,
        -112.130710,
        _img("1582234372722-50d7ccc30ebd"),  # tacos plate
    ),
    (
        "Fresh Fusion (Thunderground)",
        FoodSpotCategory.campus,
        "Sushi + poke in the Thunderground.",
        33.513540,
        -112.130640,
        _img("1579584425555-c3ce17fd4351"),  # sushi rolls
    ),
    (
        "Sweet Disciple",
        FoodSpotCategory.campus,
        "Candy + desserts in Thunder Alley.",
        33.513499,
        -112.130712,
        _img("1621939514649-280e2ee25f60"),  # candy wall
    ),
    # --- on campus: Arena & Quad -------------------------------------------
    (
        "Havoc House",
        FoodSpotCategory.campus,
        "Wings + games by the Arena.",
        33.510487,
        -112.129247,
        _img("1555939594-58d7cb561ad1"),  # grilled wings
    ),
    (
        "Arena Café",
        FoodSpotCategory.campus,
        "Coffee + breakfast by the Arena.",
        33.510149,
        -112.128922,
        _img("1553163147-622ab57be1c7"),  # breakfast skillet
    ),
    (
        "The Quad Kitchen",
        FoodSpotCategory.campus,
        "Dining hall on the Quad.",
        33.511283,
        -112.128870,
        _img("1546069901-ba9599a7e63c"),  # dining spread
    ),
    (
        "Purple Greens (The Quad)",
        FoodSpotCategory.campus,
        "Salads on the Quad.",
        33.511300,
        -112.128800,
        _img("1512621776951-a57141f2eefd"),  # salad bowl
    ),
    # --- on campus: residential + The Rivers -------------------------------
    (
        "Purple Greens & More (Turquoise)",
        FoodSpotCategory.campus,
        "Salads + wraps at Turquoise.",
        33.512662,
        -112.121824,
        _img("1540420773420-3366772f4999"),  # garden salad
    ),
    (
        "Herd Stop (Antelope)",
        FoodSpotCategory.campus,
        "Groceries + grab-and-go at Antelope.",
        33.511773,
        -112.122794,
        _img("1578916171728-46686eac8d58"),  # grocery aisle
    ),
    (
        "Jimmy John's (Agua Fria)",
        FoodSpotCategory.campus,
        "Freaky fast subs at Agua Fria.",
        33.515433,
        -112.120701,
        _img("1619096252214-ef06c45683e3"),  # stacked sub
    ),
    (
        "GCBC (The Rivers)",
        FoodSpotCategory.campus,
        "Coffee at The Rivers.",
        33.515453,
        -112.118700,
        _img("1495474472287-4d71bcdd2085"),  # coffee + pastry
    ),
    (
        "Panera Bread (The Rivers)",
        FoodSpotCategory.campus,
        "Soup, salads + bakery at The Rivers.",
        33.515450,
        -112.119100,
        _img("1555507036-ab1f4038808a"),  # bakery croissants
    ),
    (
        "Nekter Juice Bar (The Rivers)",
        FoodSpotCategory.campus,
        "Juice + açaí bowls at The Rivers.",
        33.515450,
        -112.118900,
        _img("1622597467836-f3285f2131b8"),  # fresh juices
    ),
    (
        "Cañón 49 (GCU Hotel)",
        FoodSpotCategory.campus,
        "Sit-down grill at the GCU Hotel.",
        33.511177,
        -112.114136,
        _img("1544025162-d76694265947"),  # grill platter
    ),
    # --- on campus: markets --------------------------------------------------
    (
        "Lope Shop (campus store)",
        FoodSpotCategory.campus,
        "Snacks, drinks, GCU gear.",
        33.511271,
        -112.129427,
        _img("1582058091505-f87a2e55a40f"),  # snack sweets
    ),
    (
        "Lopes Mart (Lopes Way)",
        FoodSpotCategory.campus,
        "Snacks, drinks, essentials.",
        33.512745,
        -112.123618,
        _img("1604719312566-8912e9227c6a"),  # market shelves
    ),
    (
        "Lopes Mart (The Grove)",
        FoodSpotCategory.campus,
        "Snacks, drinks, essentials.",
        33.515670,
        -112.130533,
        _img("1604719312566-8912e9227c6a"),  # market shelves
    ),
    (
        "Lopes Mart (Chaparral)",
        FoodSpotCategory.campus,
        "Snacks, drinks, essentials.",
        33.514779,
        -112.126305,
        _img("1604719312566-8912e9227c6a"),  # market shelves
    ),
    (
        "Lopes Mart (Canyon Activities Center)",
        FoodSpotCategory.campus,
        "Snacks, drinks, essentials.",
        33.516088,
        -112.123450,
        _img("1604719312566-8912e9227c6a"),  # market shelves
    ),
]

# Legacy seed names -> canonical names above, so the upsert renames the old
# approximate rows in place instead of leaving duplicates behind.
# NOTE: never map FROM a name that is also in _FOOD_SPOTS — the rename pass
# pops it from the lookup dict and the canonical pass would re-insert a dupe.
_SPOT_RENAMES: dict[str, str] = {
    "Qdoba (Lopes Way)": "Qdoba (Student Union)",
    "Kamnari (Lopes Way)": "Kaminari (Lopes Way)",
    "Canyon Pizza Co.": "Canyon Pizza Company",
    "Training Table": "Lopes Training Table",
    "The Grid (POD Market)": "Lopes Mart (Lopes Way)",
}

# (name, description, lat, lng) — OSM building centroids. Names double as the
# denormalized order.dropoff string, so they are short and unambiguous.
_DROPOFFS: list[tuple[str, str, float, float]] = [
    # --- residence halls -------------------------------------------------
    ("Acacia Hall", "Front entrance.", 33.516246, -112.132258),
    ("Camelback Hall", "Front entrance.", 33.512420, -112.127437),
    ("Canyon Hall", "Front entrance.", 33.514130, -112.127939),
    ("Chaparral Hall", "Ground-floor elevator bank.", 33.514779, -112.126305),
    ("Cypress Hall", "Front entrance.", 33.514111, -112.129839),
    ("Ironwood Hall", "By the front desk / mail cubbies.", 33.516253, -112.130539),
    ("Juniper Hall", "Main lobby, ground floor.", 33.515670, -112.130533),
    ("Ocotillo Hall", "Front entrance.", 33.516115, -112.126375),
    ("Prescott Hall", "First-floor common lounge.", 33.512417, -112.128451),
    ("Saguaro Hall", "Front entrance.", 33.515477, -112.126382),
    ("Sedona Hall", "Front entrance.", 33.514074, -112.126374),
    ("Willow Hall", "Front entrance.", 33.515666, -112.132248),
    # --- apartments ------------------------------------------------------
    ("Agave Apartments", "Main entrance.", 33.515064, -112.125053),
    ("Agua Fria Apartments", "Main entrance.", 33.515433, -112.120701),
    ("Antelope Apartments", "Main entrance.", 33.511773, -112.122794),
    ("Cactus Apartments", "Main entrance.", 33.511744, -112.123882),
    ("Copper Apartments", "Main entrance.", 33.512658, -112.120761),
    ("Diamondback Apartments", "Main entrance.", 33.512651, -112.122790),
    ("Encanto Apartments", "Central courtyard seating.", 33.511688, -112.126360),
    ("Jerome Apartments", "Main entrance.", 33.511027, -112.123877),
    ("North Rim Apartments", "Central walkway.", 33.513200, -112.128300),
    ("Oak Creek Apartments", "Main entrance.", 33.510777, -112.120615),
    ("Palo Verde Apartments", "Main entrance.", 33.510719, -112.121822),
    ("Papago Apartments North", "Ground-floor mailroom.", 33.513237, -112.126368),
    ("Papago Apartments South", "Ground-floor mailroom.", 33.512361, -112.126382),
    ("Ponderosa Apartments", "Main entrance.", 33.510006, -112.120631),
    ("Roadrunner Apartments", "Main entrance.", 33.511790, -112.128444),
    ("Gila Apartments", "Main entrance.", 33.514560, -112.118579),
    ("Salt River Apartments", "Main entrance.", 33.515441, -112.119568),
    ("Santa Cruz Apartments", "Main entrance.", 33.514146, -112.120717),
    ("Verde River Apartments", "Main entrance.", 33.515453, -112.118597),
    ("Sonora Apartments", "Main entrance.", 33.511056, -112.122794),
    ("Turquoise Apartments", "Main entrance.", 33.512662, -112.121824),
    # --- landmarks & campus life ----------------------------------------
    ("Student Union entrance", "Front doors of the Union.", 33.513295, -112.129967),
    ("Library front steps", "Main entrance steps.", 33.513555, -112.129903),
    ("Lopes Way fountain", "By the fountain on Lopes Way.", 33.512900, -112.128100),
    ("GCU Arena", "Main entrance plaza.", 33.510149, -112.128922),
    ("GCU Stadium", "Main gate.", 33.512086, -112.131318),
    ("Antelope Fitness Center", "Front entrance.", 33.512016, -112.122851),
    ("Papago Fitness Center", "Front entrance.", 33.512206, -112.126676),
    ("Canyon Activities Center", "Front entrance.", 33.516088, -112.123450),
    ("Lopes Performance Center", "Front entrance.", 33.513473, -112.131365),
    ("Thunder Alley", "Outside the bowling entrance.", 33.513471, -112.130655),
    ("Little Canyon Park", "Park entrance.", 33.515713, -112.128451),
    ("Colter Commons", "Central seating.", 33.512745, -112.123618),
    # --- academic buildings ---------------------------------------------
    ("Colangelo College of Business", "Main lobby.", 33.514055, -112.125268),
    ("Engineering building (CSET)", "Engineering building lobby.", 33.510972, -112.130757),
    ("Natural Sciences building", "Main lobby.", 33.511193, -112.130544),
    ("Technology building", "Main lobby.", 33.510183, -112.127250),
    ("College of Arts & Media", "Main lobby.", 33.511559, -112.127290),
    ("College of Education", "Main lobby.", 33.511036, -112.129397),
    ("College of Theology", "Main lobby.", 33.511043, -112.128002),
    ("Humanities building", "Main lobby.", 33.511599, -112.130370),
    ("Ethington Theatre", "Front entrance.", 33.510358, -112.128132),
    ("Student Advising Center", "Main lobby.", 33.512025, -112.130377),
    # --- parking garages (commuters) ------------------------------------
    ("29th Ave Garage", "Ground-level entrance.", 33.510164, -112.123512),
    ("31st Ave Garage", "Ground-level entrance.", 33.510477, -112.125004),
    ("33rd Ave Garage", "Ground-level entrance.", 33.510072, -112.130802),
    ("Grove Parking Garage", "Ground-level entrance.", 33.515744, -112.133402),
    ("Halo Parking Garage", "Ground-level entrance.", 33.513994, -112.133593),
    ("Missouri Garage", "Ground-level entrance.", 33.515856, -112.121934),
    ("Rivers Parking Garage", "Ground-level entrance.", 33.516214, -112.119850),
]

# Legacy seed names → canonical names above (renamed in place, orders keep
# their denormalized strings).
_DROPOFF_RENAMES: dict[str, str] = {
    "Juniper Hall lobby": "Juniper Hall",
    "Ironwood Hall front desk": "Ironwood Hall",
    "Acacia Hall study room": "Acacia Hall",
    "Encanto Apartments courtyard": "Encanto Apartments",
    "Papago Apartments mailroom": "Papago Apartments South",
    "CSET building lobby": "Engineering building (CSET)",
    "Chaparral Hall elevators": "Chaparral Hall",
    "Prescott Hall lounge": "Prescott Hall",
    "The Grove picnic tables": "Jerome Apartments",
}


async def _seed(session: AsyncSession) -> None:
    spots = {s.name: s for s in (await session.execute(select(FoodSpot))).scalars()}
    # Rename legacy rows first so the canonical pass updates them in place.
    for old, new in _SPOT_RENAMES.items():
        row = spots.pop(old, None)
        if row is not None and new not in spots:
            row.name = new
            spots[new] = row
    created = updated = 0
    for name, category, description, lat, lng, image in _FOOD_SPOTS:
        row = spots.get(name)
        if row is None:
            session.add(
                FoodSpot(
                    name=name,
                    category=category,
                    description=description,
                    active=True,
                    lat=lat,
                    lng=lng,
                    image_url=image,
                )
            )
            created += 1
        else:
            row.category = category
            row.description = description
            row.lat = lat
            row.lng = lng
            # Catalog images are curated here — always sync so crop/quality
            # fixes to the URL template reach existing rows on redeploy.
            row.image_url = image
            updated += 1
    log.info("seed_gcu_catalog.spots", created=created, updated=updated)

    # Deactivate any off-campus spots that exist in the DB — on-campus only.
    deactivated = 0
    for row in spots.values():
        if row.category == FoodSpotCategory.off_campus and row.active:
            row.active = False
            deactivated += 1
    if deactivated:
        log.info("seed_gcu_catalog.deactivated_off_campus", count=deactivated)

    dropoffs = {d.name: d for d in (await session.execute(select(DropoffLocation))).scalars()}
    for old, new in _DROPOFF_RENAMES.items():
        drow = dropoffs.pop(old, None)
        if drow is not None and new not in dropoffs:
            drow.name = new
            dropoffs[new] = drow
    created = updated = 0
    for name, description, lat, lng in _DROPOFFS:
        drow = dropoffs.get(name)
        if drow is None:
            session.add(
                DropoffLocation(name=name, description=description, active=True, lat=lat, lng=lng)
            )
            created += 1
        else:
            drow.description = description
            drow.lat = lat
            drow.lng = lng
            updated += 1
    log.info("seed_gcu_catalog.dropoffs", created=created, updated=updated)

    await session.commit()


async def main() -> None:
    async with async_session_factory() as session:
        await _seed(session)


if __name__ == "__main__":
    asyncio.run(main())
