"""food_spots.image_url + backfill seeded spots with hero photos

The prod seed is skip-if-exists, so new seed-data fields never reach a
database that was already seeded — this migration carries the photo URLs
itself, keyed by the (unique) spot name.

Revision ID: d7e8f9a0b1c2
Revises: e13e8b267a8e
Create Date: 2026-10-05

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'd7e8f9a0b1c2'
down_revision: Union[str, None] = 'e13e8b267a8e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

_UNSPLASH = "https://images.unsplash.com/photo-{pid}?auto=format&fit=crop&w=800&q=60"
_SPOT_IMAGES: dict[str, str] = {
    "Chick-fil-A (Lopes Way)": _UNSPLASH.format(pid="1606755962773-d324e0a13086"),
    "Panda Express (Lopes Way)": _UNSPLASH.format(pid="1512058564366-18510be2db19"),
    "Qdoba (Lopes Way)": _UNSPLASH.format(pid="1546069901-ba9599a7e63c"),
    "Subway (Lopes Way)": _UNSPLASH.format(pid="1509722747041-616f39b57569"),
    "Pita Jungle (GCU)": _UNSPLASH.format(pid="1540914124281-342587941389"),
    "Canyon Pizza Co.": _UNSPLASH.format(pid="1513104890138-7c749659a591"),
    "The Grid (POD Market)": _UNSPLASH.format(pid="1621939514649-280e2ee25f60"),
    "Chipotle (27th Ave)": _UNSPLASH.format(pid="1582234372722-50d7ccc30ebd"),
    "Raising Cane's (Camelback)": _UNSPLASH.format(pid="1562967914-608f82629710"),
    "Dutch Bros (Camelback)": _UNSPLASH.format(pid="1509042239860-f550ce710b93"),
    "In-N-Out (Northern Ave)": _UNSPLASH.format(pid="1568901346375-23c9450c58cd"),
}


def upgrade() -> None:
    op.add_column(
        'food_spots',
        sa.Column('image_url', sa.String(length=500), nullable=True),
    )
    spots = sa.table(
        'food_spots',
        sa.column('name', sa.String),
        sa.column('image_url', sa.String),
    )
    for name, url in _SPOT_IMAGES.items():
        op.execute(
            spots.update().where(spots.c.name == name).values(image_url=url)
        )


def downgrade() -> None:
    op.drop_column('food_spots', 'image_url')
