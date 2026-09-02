"""food runs: move drop-off from run to per-order (each requester's hall)

Drops runs.delivery_spot and adds run_orders.dropoff. Each requester now
supplies their own drop location when they request a spot, so the runner
delivers per order instead of everyone meeting at one shared spot.

Revision ID: d3f4a5b6c7e8
Revises: c2e3d4f5a6b7
Create Date: 2026-09-01

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'd3f4a5b6c7e8'
down_revision: Union[str, None] = 'c2e3d4f5a6b7'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add nullable first so existing rows survive, backfill, then enforce.
    op.add_column('run_orders', sa.Column('dropoff', sa.String(length=120), nullable=True))
    op.execute("UPDATE run_orders SET dropoff = 'Campus drop-off' WHERE dropoff IS NULL")
    op.alter_column('run_orders', 'dropoff', nullable=False)

    op.drop_column('runs', 'delivery_spot')


def downgrade() -> None:
    op.add_column(
        'runs',
        sa.Column('delivery_spot', sa.String(length=120), nullable=True),
    )
    op.execute("UPDATE runs SET delivery_spot = 'Campus drop-off' WHERE delivery_spot IS NULL")
    op.alter_column('runs', 'delivery_spot', nullable=False)

    op.drop_column('run_orders', 'dropoff')
