"""run_orders: pickup_code for requester Mobile Order QR

Revision ID: a1b2c3d4e5f6
Revises: f5a6b7c8d9e0
Create Date: 2026-09-02

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'a1b2c3d4e5f6'
down_revision: Union[str, None] = 'f5a6b7c8d9e0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('run_orders', sa.Column('pickup_code', sa.Text(), nullable=True))


def downgrade() -> None:
    op.drop_column('run_orders', 'pickup_code')
