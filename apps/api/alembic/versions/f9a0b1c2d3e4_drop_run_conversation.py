"""drop runs.conversation_id: remove the run group chat

The run-level group conversation is removed; coordination now happens through
per-order tracking + payment-proof, not a shared chat.

Revision ID: f9a0b1c2d3e4
Revises: e8f9a0b1c2d3
Create Date: 2026-09-02

"""

from collections.abc import Sequence
from typing import Union

import sqlalchemy as sa

from alembic import op

revision: str = 'f9a0b1c2d3e4'
down_revision: Union[str, None] = 'e8f9a0b1c2d3'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Dropping the column also drops its dependent FK constraint in Postgres.
    op.drop_column('runs', 'conversation_id')


def downgrade() -> None:
    op.add_column('runs', sa.Column('conversation_id', sa.UUID(), nullable=True))
    op.create_foreign_key(
        'runs_conversation_id_fkey',
        'runs',
        'conversations',
        ['conversation_id'],
        ['id'],
        ondelete='SET NULL',
    )
