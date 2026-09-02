"""run_orders: drop pickup_code (Mobile Order QR pickup feature removed)

The requester-attaches-QR pickup flow was removed: campus Mobile Order QRs are
non-transferable (the dining vendor blocks screenshots to enforce it), so the
column no longer backs any product path. Runs settle on the reimbursement
payment rails instead.

Revision ID: b2c3d4e5f6a7
Revises: a1b2c3d4e5f6
Create Date: 2026-09-02

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'b2c3d4e5f6a7'
down_revision: Union[str, None] = 'a1b2c3d4e5f6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.drop_column('run_orders', 'pickup_code')


def downgrade() -> None:
    op.add_column('run_orders', sa.Column('pickup_code', sa.Text(), nullable=True))
