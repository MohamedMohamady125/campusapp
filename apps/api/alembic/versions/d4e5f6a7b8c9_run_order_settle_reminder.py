"""food runs: settle-up nudge stamp — run_orders.settle_reminder_sent_at

The maintenance loop sends one "settle up" reminder ~2h after a run is done
when payment is still unconfirmed. This stamp makes the nudge once-only.

Revision ID: d4e5f6a7b8c9
Revises: b8c9d0e1f2a3
Create Date: 2026-10-11

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'd4e5f6a7b8c9'
down_revision: Union[str, None] = 'b8c9d0e1f2a3'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        'run_orders',
        sa.Column('settle_reminder_sent_at', sa.DateTime(timezone=True), nullable=True),
    )


def downgrade() -> None:
    op.drop_column('run_orders', 'settle_reminder_sent_at')
