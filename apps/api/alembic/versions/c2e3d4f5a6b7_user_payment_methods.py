"""users: payment_methods jsonb + backfill from venmo_handle

Revision ID: c2e3d4f5a6b7
Revises: b1d2c3e4f5a6
Create Date: 2026-09-01

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = 'c2e3d4f5a6b7'
down_revision: Union[str, None] = 'b1d2c3e4f5a6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        'users',
        sa.Column(
            'payment_methods',
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'[]'::jsonb"),
        ),
    )
    # Backfill: seed a venmo entry for anyone who already saved a handle so the
    # multi-rail store starts from the legacy single-rail data (no data loss).
    op.execute(
        """
        UPDATE users
        SET payment_methods =
            jsonb_build_array(
                jsonb_build_object('type', 'venmo', 'handle', venmo_handle)
            )
        WHERE venmo_handle IS NOT NULL AND venmo_handle <> ''
        """
    )


def downgrade() -> None:
    op.drop_column('users', 'payment_methods')
