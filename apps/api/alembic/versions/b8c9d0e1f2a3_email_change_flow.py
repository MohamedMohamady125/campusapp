"""Email-change flow: users.pending_email + verification_purpose value.

Revision ID: b8c9d0e1f2a3
Revises: a7b8c9d0e1f2
Create Date: 2026-10-11
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "b8c9d0e1f2a3"
down_revision: str | None = "a7b8c9d0e1f2"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column("users", sa.Column("pending_email", sa.String(length=255), nullable=True))
    # pg enum ADD VALUE cannot run inside the migration transaction here.
    with op.get_context().autocommit_block():
        op.execute("ALTER TYPE verification_purpose ADD VALUE IF NOT EXISTS 'email_change'")


def downgrade() -> None:
    # Postgres cannot drop an enum value; leave it in place.
    op.drop_column("users", "pending_email")
