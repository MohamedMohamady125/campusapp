"""dropoff_locations: admin-curated catalog of valid drop-off points

Requesters pick a drop-off from this catalog (dropdown) instead of typing a
free-text address, so every drop-off is a known place.

Revision ID: e8f9a0b1c2d3
Revises: c3d4e5f6a7b8
Create Date: 2026-09-02

"""

from collections.abc import Sequence
from typing import Union

import sqlalchemy as sa

from alembic import op

revision: str = 'e8f9a0b1c2d3'
down_revision: Union[str, None] = 'c3d4e5f6a7b8'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'dropoff_locations',
        sa.Column('name', sa.String(length=120), nullable=False),
        sa.Column('description', sa.String(length=200), nullable=True),
        sa.Column('active', sa.Boolean(), nullable=False),
        sa.Column('lat', sa.Float(), nullable=True),
        sa.Column('lng', sa.Float(), nullable=True),
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column(
            'created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False
        ),
        sa.Column(
            'updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False
        ),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index(
        op.f('ix_dropoff_locations_name'), 'dropoff_locations', ['name'], unique=True
    )
    # Denormalized drop-off coordinates on each order feed runner navigation.
    op.add_column('run_orders', sa.Column('dropoff_lat', sa.Float(), nullable=True))
    op.add_column('run_orders', sa.Column('dropoff_lng', sa.Float(), nullable=True))


def downgrade() -> None:
    op.drop_column('run_orders', 'dropoff_lng')
    op.drop_column('run_orders', 'dropoff_lat')
    op.drop_index(op.f('ix_dropoff_locations_name'), table_name='dropoff_locations')
    op.drop_table('dropoff_locations')
