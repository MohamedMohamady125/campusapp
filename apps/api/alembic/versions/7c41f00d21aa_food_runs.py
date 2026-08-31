"""food runs: food_spots, runs, run_orders, venmo_handle, enum additions

Revision ID: 7c41f00d21aa
Revises: 2a0a036535f9
Create Date: 2026-08-31

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '7c41f00d21aa'
down_revision: Union[str, None] = '2a0a036535f9'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # New enum values must be committed before use — run outside the migration txn.
    with op.get_context().autocommit_block():
        op.execute("ALTER TYPE rating_context ADD VALUE IF NOT EXISTS 'run'")
        op.execute("ALTER TYPE conversation_context ADD VALUE IF NOT EXISTS 'run'")

    op.add_column('users', sa.Column('venmo_handle', sa.String(length=30), nullable=True))

    op.create_table(
        'food_spots',
        sa.Column('name', sa.String(length=120), nullable=False),
        sa.Column(
            'category',
            sa.Enum('campus', 'off_campus', name='food_spot_category'),
            nullable=False,
        ),
        sa.Column('description', sa.String(length=200), nullable=True),
        sa.Column('active', sa.Boolean(), nullable=False),
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column(
            'created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False
        ),
        sa.Column(
            'updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False
        ),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index(op.f('ix_food_spots_name'), 'food_spots', ['name'], unique=True)

    op.create_table(
        'runs',
        sa.Column('runner_id', sa.UUID(), nullable=False),
        sa.Column('food_spot_id', sa.UUID(), nullable=False),
        sa.Column('delivery_spot', sa.String(length=120), nullable=False),
        sa.Column('note', sa.Text(), nullable=True),
        sa.Column('leaving_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('fee_cents', sa.Integer(), nullable=False),
        sa.Column('spots_max', sa.Integer(), nullable=False),
        sa.Column('prepay_required', sa.Boolean(), nullable=False),
        sa.Column(
            'status',
            sa.Enum(
                'open',
                'locked',
                'at_store',
                'delivering',
                'done',
                'expired',
                'cancelled',
                name='run_status',
            ),
            nullable=False,
        ),
        sa.Column('conversation_id', sa.UUID(), nullable=True),
        sa.Column('completed_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column(
            'created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False
        ),
        sa.Column(
            'updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False
        ),
        sa.ForeignKeyConstraint(['runner_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['food_spot_id'], ['food_spots.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['conversation_id'], ['conversations.id'], ondelete='SET NULL'),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index(op.f('ix_runs_runner_id'), 'runs', ['runner_id'], unique=False)
    op.create_index(op.f('ix_runs_food_spot_id'), 'runs', ['food_spot_id'], unique=False)
    op.create_index('ix_runs_status_leaving', 'runs', ['status', 'leaving_at'], unique=False)

    op.create_table(
        'run_orders',
        sa.Column('run_id', sa.UUID(), nullable=False),
        sa.Column('requester_id', sa.UUID(), nullable=False),
        sa.Column('order_text', sa.Text(), nullable=False),
        sa.Column(
            'status',
            sa.Enum(
                'requested',
                'accepted',
                'declined',
                'cancelled',
                'delivered',
                'received',
                'no_show',
                name='run_order_status',
            ),
            nullable=False,
        ),
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column(
            'created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False
        ),
        sa.Column(
            'updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False
        ),
        sa.ForeignKeyConstraint(['run_id'], ['runs.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['requester_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('run_id', 'requester_id', name='uq_run_order_run_requester'),
    )
    op.create_index(op.f('ix_run_orders_run_id'), 'run_orders', ['run_id'], unique=False)
    op.create_index(op.f('ix_run_orders_requester_id'), 'run_orders', ['requester_id'], unique=False)


def downgrade() -> None:
    op.drop_table('run_orders')
    op.drop_table('runs')
    op.drop_table('food_spots')
    op.execute('DROP TYPE IF EXISTS run_order_status')
    op.execute('DROP TYPE IF EXISTS run_status')
    op.execute('DROP TYPE IF EXISTS food_spot_category')
    op.drop_column('users', 'venmo_handle')
    # Added enum values ('run' on rating_context/conversation_context) are not
    # removable in Postgres; left in place intentionally.
