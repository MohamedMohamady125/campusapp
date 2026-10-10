"""push notifications: device_tokens table (FCM/APNs registrations)

One row per (user, token). `token` is globally unique so a device that
switches accounts is reassigned, never duplicated.

Revision ID: a8b9c0d1e2f3
Revises: f2a3b4c5d6e7
Create Date: 2026-10-10

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = 'a8b9c0d1e2f3'
down_revision: Union[str, None] = 'f2a3b4c5d6e7'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'device_tokens',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('platform', sa.String(length=10), nullable=False),
        sa.Column('token', sa.String(length=512), nullable=False),
        sa.Column('last_seen_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('token', name='uq_device_token'),
    )
    op.create_index(
        op.f('ix_device_tokens_user_id'), 'device_tokens', ['user_id'], unique=False
    )


def downgrade() -> None:
    op.drop_index(op.f('ix_device_tokens_user_id'), table_name='device_tokens')
    op.drop_table('device_tokens')
