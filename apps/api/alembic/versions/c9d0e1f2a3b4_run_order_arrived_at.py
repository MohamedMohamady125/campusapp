"""food runs: no-show counter — run_orders.arrived_at

The runner taps "I'm here" at a drop-off, stamping arrived_at and notifying
the requester. No-show is only legal NO_SHOW_WAIT (5 min) after this stamp.

Revision ID: c9d0e1f2a3b4
Revises: d7e8f9a0b1c2
Create Date: 2026-10-07

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'c9d0e1f2a3b4'
down_revision: Union[str, None] = 'd7e8f9a0b1c2'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        'run_orders',
        sa.Column('arrived_at', sa.DateTime(timezone=True), nullable=True),
    )


def downgrade() -> None:
    op.drop_column('run_orders', 'arrived_at')
