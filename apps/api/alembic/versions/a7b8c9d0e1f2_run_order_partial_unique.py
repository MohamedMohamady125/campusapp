"""Run order unique → partial (live orders only).

Withdrawn (cancelled) or declined orders must not block a fresh request on
the same run (QA issue #1): replace the hard UNIQUE(run_id, requester_id)
with a partial unique index excluding terminal non-fulfilled statuses.

Revision ID: a7b8c9d0e1f2
Revises: b1c2d3e4f5a6
Create Date: 2026-10-11
"""

from collections.abc import Sequence

from alembic import op

revision: str = "a7b8c9d0e1f2"
down_revision: str | None = "b1c2d3e4f5a6"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.drop_constraint("uq_run_order_run_requester", "run_orders", type_="unique")
    op.create_index(
        "uq_run_order_live",
        "run_orders",
        ["run_id", "requester_id"],
        unique=True,
        postgresql_where="status NOT IN ('cancelled', 'declined')",
    )


def downgrade() -> None:
    op.drop_index("uq_run_order_live", table_name="run_orders")
    op.create_unique_constraint(
        "uq_run_order_run_requester", "run_orders", ["run_id", "requester_id"]
    )
