"""food runs: item price estimate + actual price — run_orders

item_price_cents: the requester's own estimate (incl. tax) entered when
placing the order — makes prepay an exact number (estimate + fee) and tells
the runner what they're fronting. actual_price_cents: the runner's final
receipt price; the delta drives the settle-up copy on both sides.

Revision ID: b1c2d3e4f5a6
Revises: a8b9c0d1e2f3
Create Date: 2026-10-11

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'b1c2d3e4f5a6'
down_revision: Union[str, None] = 'a8b9c0d1e2f3'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        'run_orders',
        sa.Column('item_price_cents', sa.Integer(), nullable=False, server_default='0'),
    )
    op.add_column(
        'run_orders',
        sa.Column('actual_price_cents', sa.Integer(), nullable=True),
    )


def downgrade() -> None:
    op.drop_column('run_orders', 'actual_price_cents')
    op.drop_column('run_orders', 'item_price_cents')
