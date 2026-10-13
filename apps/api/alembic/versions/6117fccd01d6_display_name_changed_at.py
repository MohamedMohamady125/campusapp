"""users.display_name_changed_at — one-time lifetime rename stamp

Display name can be changed exactly once per account; the stamp records
when the rename was used and locks the field afterwards.

Revision ID: 6117fccd01d6
Revises: d4e5f6a7b8c9
Create Date: 2026-10-13

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '6117fccd01d6'
down_revision: Union[str, None] = 'd4e5f6a7b8c9'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        'users',
        sa.Column('display_name_changed_at', sa.DateTime(timezone=True), nullable=True),
    )


def downgrade() -> None:
    op.drop_column('users', 'display_name_changed_at')
