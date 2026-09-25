"""run_orders payment proof: off-app transaction screenshot + note

After the runner accepts, the requester pays via the revealed handle and can
attach a transaction screenshot (S3 key) + optional note; the runner sees it on
the order card. The app never moves money.

Revision ID: a0b1c2d3e4f5
Revises: f9a0b1c2d3e4
Create Date: 2026-09-02

"""

from collections.abc import Sequence
from typing import Union

import sqlalchemy as sa

from alembic import op

revision: str = 'a0b1c2d3e4f5'
down_revision: Union[str, None] = 'f9a0b1c2d3e4'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        'run_orders', sa.Column('payment_proof_key', sa.String(length=300), nullable=True)
    )
    op.add_column(
        'run_orders', sa.Column('payment_note', sa.String(length=300), nullable=True)
    )
    op.add_column(
        'run_orders',
        sa.Column('payment_submitted_at', sa.DateTime(timezone=True), nullable=True),
    )


def downgrade() -> None:
    op.drop_column('run_orders', 'payment_submitted_at')
    op.drop_column('run_orders', 'payment_note')
    op.drop_column('run_orders', 'payment_proof_key')
