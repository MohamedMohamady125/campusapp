"""runs: pays_with_dining_dollars flag

Revision ID: b1d2c3e4f5a6
Revises: 7c41f00d21aa
Create Date: 2026-09-01

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'b1d2c3e4f5a6'
down_revision: Union[str, None] = '7c41f00d21aa'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        'runs',
        sa.Column(
            'pays_with_dining_dollars',
            sa.Boolean(),
            nullable=False,
            server_default=sa.text('false'),
        ),
    )


def downgrade() -> None:
    op.drop_column('runs', 'pays_with_dining_dollars')
