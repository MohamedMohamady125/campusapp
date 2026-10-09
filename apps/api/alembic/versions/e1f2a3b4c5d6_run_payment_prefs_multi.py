"""food runs: runs.payment_pref (single) -> runs.payment_prefs (multi)

The runner can now offer any mix of pay-on-handoff methods at once —
"cash" plus saved rails ("venmo", "zelle", …) — so the single string
column becomes a JSONB list. Existing single prefs are carried over as
one-element lists.

Revision ID: e1f2a3b4c5d6
Revises: d0e1f2a3b4c5
Create Date: 2026-10-09

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB


revision: str = 'e1f2a3b4c5d6'
down_revision: Union[str, None] = 'd0e1f2a3b4c5'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        'runs',
        sa.Column('payment_prefs', JSONB(), nullable=False, server_default='[]'),
    )
    # Carry over yesterday's single pref as a one-element list.
    op.execute(
        "UPDATE runs SET payment_prefs = to_jsonb(ARRAY[payment_pref]) "
        "WHERE payment_pref IS NOT NULL"
    )
    op.drop_column('runs', 'payment_pref')


def downgrade() -> None:
    op.add_column(
        'runs',
        sa.Column('payment_pref', sa.String(length=20), nullable=True),
    )
    op.execute(
        "UPDATE runs SET payment_pref = payment_prefs->>0 "
        "WHERE jsonb_array_length(payment_prefs) > 0"
    )
    op.drop_column('runs', 'payment_prefs')
