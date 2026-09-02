"""food runs: live runner GPS location + food-spot destination coords

Adds runner_lat/runner_lng/location_updated_at to runs (Uber/Lyft-style live
tracking, pushed by the runner's device while active) and lat/lng to
food_spots (the destination pin on the live map). All nullable.

Revision ID: f5a6b7c8d9e0
Revises: d3f4a5b6c7e8
Create Date: 2026-09-01

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'f5a6b7c8d9e0'
down_revision: Union[str, None] = 'd3f4a5b6c7e8'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('runs', sa.Column('runner_lat', sa.Float(), nullable=True))
    op.add_column('runs', sa.Column('runner_lng', sa.Float(), nullable=True))
    op.add_column(
        'runs',
        sa.Column('location_updated_at', sa.DateTime(timezone=True), nullable=True),
    )
    op.add_column('food_spots', sa.Column('lat', sa.Float(), nullable=True))
    op.add_column('food_spots', sa.Column('lng', sa.Float(), nullable=True))


def downgrade() -> None:
    op.drop_column('food_spots', 'lng')
    op.drop_column('food_spots', 'lat')
    op.drop_column('runs', 'location_updated_at')
    op.drop_column('runs', 'runner_lng')
    op.drop_column('runs', 'runner_lat')
