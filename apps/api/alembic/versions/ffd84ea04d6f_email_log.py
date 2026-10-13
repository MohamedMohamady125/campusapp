"""email_log table for the email program

Revision ID: ffd84ea04d6f
Revises: 6117fccd01d6
Create Date: 2026-10-13
"""

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects.postgresql import UUID

revision = "ffd84ea04d6f"
down_revision = "6117fccd01d6"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "email_log",
        sa.Column("id", UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "user_id",
            UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("kind", sa.String(40), nullable=False),
        sa.Column(
            "created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False
        ),
        sa.Column(
            "updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False
        ),
    )
    op.create_index("ix_email_log_user_id", "email_log", ["user_id"])
    op.create_index(
        "ix_email_log_user_kind_created", "email_log", ["user_id", "kind", "created_at"]
    )


def downgrade() -> None:
    op.drop_table("email_log")
