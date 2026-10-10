"""food runs: runner-side payment confirmation — run_orders.payment_confirmed_at

The runner marks an order as paid (requester sent money but forgot the
screenshot). Either stamp — requester proof or runner confirm — counts as
paid at the prepay gate, so honest payers never look unpaid.

Revision ID: f2a3b4c5d6e7
Revises: e1f2a3b4c5d6
Create Date: 2026-10-10

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'f2a3b4c5d6e7'
down_revision: Union[str, None] = 'e1f2a3b4c5d6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        'run_orders',
        sa.Column('payment_confirmed_at', sa.DateTime(timezone=True), nullable=True),
    )


def downgrade() -> None:
    op.drop_column('run_orders', 'payment_confirmed_at')
