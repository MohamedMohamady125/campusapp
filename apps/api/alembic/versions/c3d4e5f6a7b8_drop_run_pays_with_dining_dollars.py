"""runs: drop pays_with_dining_dollars (dining-dollars option removed)

The "paying with dining dollars" option was removed from the product: it was
descriptive metadata only (it never moved money or changed the state machine),
and runs settle purely on the off-app reimbursement rails. Dropping the column.

Revision ID: c3d4e5f6a7b8
Revises: b2c3d4e5f6a7
Create Date: 2026-09-02

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'c3d4e5f6a7b8'
down_revision: Union[str, None] = 'b2c3d4e5f6a7'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.drop_column('runs', 'pays_with_dining_dollars')


def downgrade() -> None:
    op.add_column(
        'runs',
        sa.Column(
            'pays_with_dining_dollars',
            sa.Boolean(),
            nullable=False,
            server_default=sa.text('false'),
        ),
    )
