"""food runs: runs.payment_pref — pay-on-handoff method for non-prepay runs

The runner picks how requesters pay at the handoff: "cash" (always offered)
or one of their saved payment rails ("venmo", "zelle", …). Null on prepay
runs — the prepay proof flow already carries method details.

Revision ID: d0e1f2a3b4c5
Revises: c9d0e1f2a3b4
Create Date: 2026-10-08

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'd0e1f2a3b4c5'
down_revision: Union[str, None] = 'c9d0e1f2a3b4'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        'runs',
        sa.Column('payment_pref', sa.String(length=20), nullable=True),
    )


def downgrade() -> None:
    op.drop_column('runs', 'payment_pref')
