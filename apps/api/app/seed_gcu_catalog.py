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

_UNSPLASH = "https://images.unsplash.com/photo-{pid}?auto=format&fit=crop&w=800&q=60"
_IMG_CHICKEN = _UNSPLASH.format(pid="1606755962773-d324e0a13086")
_IMG_ASIAN = _UNSPLASH.format(pid="1512058564366-18510be2db19")
_IMG_BOWL = _UNSPLASH.format(pid="1546069901-ba9599a7e63c")
_IMG_SANDWICH = _UNSPLASH.format(pid="1509722747041-616f39b57569")
_IMG_MED = _UNSPLASH.format(pid="1540914124281-342587941389")
_IMG_PIZZA = _UNSPLASH.format(pid="1513104890138-7c749659a591")
_IMG_SNACKS = _UNSPLASH.format(pid="1621939514649-280e2ee25f60")
_IMG_MEX = _UNSPLASH.format(pid="1582234372722-50d7ccc30ebd")
_IMG_FRIED = _UNSPLASH.format(pid="1562967914-608f82629710")
_IMG_COFFEE = _UNSPLASH.format(pid="1509042239860-f550ce710b93")
_IMG_BURGER = _UNSPLASH.format(pid="1568901346375-23c9450c58cd")

# (canonical name, category, description, lat, lng, image-on-insert)
# Coordinates are OSM building centroids inside the GCU campus (Oct 2026).
_FOOD_SPOTS: list[tuple[str, FoodSpotCategory, str, float, float, str]] = [
    # --- on campus -------------------------------------------------------
    (
        "Chick-fil-A (Lopes Way)",
        FoodSpotCategory.campus,
        "Closed Sundays. Lines get long at noon.",
        33.512883,
        -112.122559,
        _IMG_CHICKEN,
    ),
    (
        "Panda Express (Lopes Way)",
        FoodSpotCategory.campus,
        "Orange chicken never misses.",
        33.512596,
        -112.127117,
        _IMG_ASIAN,
    ),
    (
        "Qdoba (Student Union)",
        FoodSpotCategory.campus,
        "Burritos, bowls, queso.",
        33.513231,
        -112.130269,
        _IMG_BOWL,
    ),
    (
        "Pita Jungle (GCU)",
        FoodSpotCategory.campus,
        "Fresh Mediterranean on campus.",
        33.512577,
        -112.128563,
        _IMG_MED,
    ),
    (
        "Canyon Pizza Co.",
        FoodSpotCategory.campus,
        "Late-night slices.",
        33.513085,
        -112.129835,
        _IMG_PIZZA,
    ),
    (
        "Einstein Bros. Bagels",
        FoodSpotCategory.campus,
        "Bagels + coffee by the Student Union.",
        33.513353,
        -112.130217,
        _IMG_SANDWICH,
    ),
    (
        "Jamba (Student Union)",
        FoodSpotCategory.campus,
        "Smoothies between classes.",
        33.513294,
        -112.130264,
        _IMG_BOWL,
    ),
    (
        "Taco Bell (Thunder Alley)",
        FoodSpotCategory.campus,
        "Crunchwrap HQ in Thunder Alley.",
        33.513613,
        -112.130710,
        _IMG_MEX,
    ),
    (
        "The Habit Burger Grill",
        FoodSpotCategory.campus,
        "Charburgers by the Union.",
        33.513386,
        -112.129806,
        _IMG_BURGER,
    ),
    (
        "Sweet Disciple",
        FoodSpotCategory.campus,
        "Ice cream + desserts in Thunder Alley.",
        33.513499,
        -112.130712,
        _IMG_SNACKS,
    ),
    (
        "GCBC (Grand Canyon Beverage Co.)",
        FoodSpotCategory.campus,
        "Campus coffee — pre-8am lifesaver.",
        33.511778,
        -112.128841,
        _IMG_COFFEE,
    ),
    (
        "Havoc House",
        FoodSpotCategory.campus,
        "Wings + games by the Arena.",
        33.510487,
        -112.129247,
        _IMG_FRIED,
    ),
    (
        "The Quad Kitchen",
        FoodSpotCategory.campus,
        "Dining hall on the Quad.",
        33.511283,
        -112.128870,
        _IMG_BOWL,
    ),
    (
        "Training Table",
        FoodSpotCategory.campus,
        "Protein plates by the Union.",
        33.513267,
        -112.129983,
        _IMG_CHICKEN,
    ),
    (
        "Kamnari (Lopes Way)",
        FoodSpotCategory.campus,
        "Korean street food on Lopes Way.",
        33.512599,
        -112.127240,
        _IMG_ASIAN,
    ),
    (
        "Lope Shop (campus store)",
        FoodSpotCategory.campus,
        "Snacks, drinks, GCU gear.",
        33.511271,
        -112.129427,
        _IMG_SNACKS,
    ),
    (
        "The Grid (POD Market)",
        FoodSpotCategory.campus,
        "Snacks, drinks, essentials.",
        33.512745,
        -112.123618,
        _IMG_SNACKS,
    ),
    # --- off campus (walkable / short drive) -----------------------------
    (
        "Subway (35th & Camelback)",
        FoodSpotCategory.off_campus,
        "Footlongs just west of campus.",
        33.510359,
        -112.134701,
        _IMG_SANDWICH,
    ),
    (
        "El Taco Tote (Camelback)",
        FoodSpotCategory.off_campus,
        "Build-your-own taco spot.",
        33.509733,
        -112.133849,
        _IMG_MEX,
    ),
    (
        "Federico's Mexican Food",
        FoodSpotCategory.off_campus,
        "Late-night burritos, open late.",
        33.509206,
        -112.133869,
        _IMG_MEX,
    ),
    (
        "Great Wall Cuisine",
        FoodSpotCategory.off_campus,
        "Dim sum + Chinese on 35th Ave.",
        33.510939,
        -112.133373,
        _IMG_ASIAN,
    ),
    (
        "Pho Vinh Long",
        FoodSpotCategory.off_campus,
        "Vietnamese pho south of Camelback.",
        33.508171,
        -112.134657,
        _IMG_ASIAN,
    ),
    (
        "Chipotle (27th Ave)",
        FoodSpotCategory.off_campus,
        "Just off campus — bowl run classic.",
        33.509300,
        -112.116800,
        _IMG_MEX,
    ),
    (
        "Raising Cane's (Camelback)",
        FoodSpotCategory.off_campus,
        "Box combos + Cane's sauce.",
        33.509500,
        -112.100300,
        _IMG_FRIED,
    ),
    (
        "Dutch Bros (Camelback)",
        FoodSpotCategory.off_campus,
        "Coffee runs before 8am class.",
        33.509600,
        -112.110200,
        _IMG_COFFEE,
    ),
    (
        "In-N-Out (Northern Ave)",
        FoodSpotCategory.off_campus,
        "Worth the drive. Animal style.",
        33.554100,
        -112.128900,
        _IMG_BURGER,
    ),
]

# Legacy seed names → canonical names above, so the upsert renames the old
# approximate rows in place instead of leaving duplicates behind.
_SPOT_RENAMES: dict[str, str] = {
    "Qdoba (Lopes Way)": "Qdoba (Student Union)",
    "Subway (Lopes Way)": "Subway (35th & Camelback)",
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
    ("Santa Cruz Apartments", "Main entrance.", 33.514146, -112.120717),
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
            if not row.image_url:
                row.image_url = image
            updated += 1
    log.info("seed_gcu_catalog.spots", created=created, updated=updated)

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
