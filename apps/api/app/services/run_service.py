"""Food run business logic (food-runs spec).

State machine:
    run:   open → locked → at_store → delivering → done   (+ expired, cancelled)
    order: requested → accepted | declined | cancelled
           accepted → delivered → received | no_show

Trust model: the app never touches money. Coordination happens in a
Conversation(context_type='run'); payment is a displayed Venmo handle;
two-way ratings (context 'run', context_id = RunOrder.id) feed the shared
Bayesian reputation.
"""

import uuid
from datetime import UTC, datetime, timedelta

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import (
    BusinessRuleError,
    ConflictError,
    ForbiddenError,
    NotFoundError,
)
from app.models import Conversation, ConversationParticipant, Run, RunOrder, User
from app.models.enums import ConversationContext, RunOrderStatus, RunStatus
from app.repositories.chat_repo import NotificationRepository
from app.repositories.run_repo import RunRepository
from app.schemas.run import (
    FoodSpotResponse,
    RunCreateRequest,
    RunOrderResponse,
    RunResponse,
    RunUserSummary,
)
from app.schemas.user import PaymentMethod
from app.services.notification_dispatch import upsert_deduped_notification

NOTIFICATION_TYPE_RUN_REQUEST = "run_request"
NOTIFICATION_TYPE_RUN_ACCEPTED = "run_request_accepted"
NOTIFICATION_TYPE_RUN_DECLINED = "run_request_declined"
NOTIFICATION_TYPE_RUN_STATUS = "run_status"
NOTIFICATION_TYPE_RUN_COMPLETED = "run_completed"

# Runner ghost protection: any active run hard-expires this long after leaving.
RUN_HARD_EXPIRY = timedelta(minutes=90)

_LEGAL_TRANSITIONS: dict[RunStatus, set[RunStatus]] = {
    RunStatus.open: {RunStatus.locked, RunStatus.at_store},
    RunStatus.locked: {RunStatus.at_store},
    RunStatus.at_store: {RunStatus.delivering},
    RunStatus.delivering: {RunStatus.done},
}

_ACTIVE_ORDER_STATUSES = (RunOrderStatus.accepted, RunOrderStatus.delivered)


def _user_summary(user: User, *, include_payment: bool = False) -> RunUserSummary:
    return RunUserSummary(
        id=user.id,
        display_name=user.display_name,
        reputation_score=float(user.reputation_score),
        rating_count=user.rating_count,
        # Reveal payment rails only when the caller is entitled (see gate below).
        payment_methods=[PaymentMethod.model_validate(m) for m in user.payment_methods]
        if include_payment
        else [],
    )


def _order_response(order: RunOrder) -> RunOrderResponse:
    return RunOrderResponse(
        id=order.id,
        run_id=order.run_id,
        requester=_user_summary(order.requester),
        order_text=order.order_text,
        status=order.status,
        created_at=order.created_at,
    )


def run_response(run: Run, *, viewer_id: uuid.UUID) -> RunResponse:
    """Serialize a run for a specific viewer (authz-in-serialization):

    - runner sees every order;
    - a requester sees only their own order (as my_order);
    - everyone else sees counts only.
    The runner's payment methods are exposed to accepted requesters + the
    runner (they are the payment instructions), hidden from passers-by.
    """
    is_runner = run.runner_id == viewer_id
    my_order = next((o for o in run.orders if o.requester_id == viewer_id), None)
    accepted = [o for o in run.orders if o.status in _ACTIVE_ORDER_STATUSES]
    received = [o for o in run.orders if o.status == RunOrderStatus.received]
    pending = [o for o in run.orders if o.status == RunOrderStatus.requested]
    show_payment = is_runner or (
        my_order is not None
        and my_order.status
        in (RunOrderStatus.accepted, RunOrderStatus.delivered, RunOrderStatus.received)
    )
    return RunResponse(
        id=run.id,
        runner=_user_summary(run.runner, include_payment=show_payment),
        food_spot=FoodSpotResponse.model_validate(run.food_spot),
        delivery_spot=run.delivery_spot,
        note=run.note,
        leaving_at=run.leaving_at,
        fee_cents=run.fee_cents,
        spots_max=run.spots_max,
        prepay_required=run.prepay_required,
        pays_with_dining_dollars=run.pays_with_dining_dollars,
        status=run.status,
        conversation_id=run.conversation_id if (is_runner or my_order is not None) else None,
        accepted_count=len(accepted) + len(received),
        pending_count=len(pending),
        created_at=run.created_at,
        orders=[_order_response(o) for o in run.orders] if is_runner else [],
        my_order=_order_response(my_order) if my_order is not None else None,
    )


class RunService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session
        self._repo = RunRepository(session)
        self._notifications = NotificationRepository(session)

    # -- lifecycle ---------------------------------------------------------

    async def create_run(self, *, runner: User, body: RunCreateRequest) -> Run:
        spot = await self._repo.get_spot(body.food_spot_id)
        if spot is None or not spot.active:
            raise NotFoundError("Food spot not found.", code="FOOD_SPOT_NOT_FOUND")
        if body.leaving_at <= datetime.now(UTC):
            raise BusinessRuleError("Leaving time must be in the future.", code="LEAVING_AT_PAST")
        if (body.fee_cents > 0 or body.prepay_required) and not runner.payment_methods:
            raise BusinessRuleError(
                "Add a payment method before charging a fee.",
                code="PAYMENT_METHOD_REQUIRED",
            )
        run = Run(
            runner_id=runner.id,
            food_spot_id=spot.id,
            delivery_spot=body.delivery_spot,
            note=body.note,
            leaving_at=body.leaving_at,
            fee_cents=body.fee_cents,
            spots_max=body.spots_max,
            prepay_required=body.prepay_required,
            pays_with_dining_dollars=body.pays_with_dining_dollars,
        )
        self._repo.add(run)
        await self._session.commit()
        return await self._get_or_404(run.id)

    async def _get_or_404(self, run_id: uuid.UUID, *, for_update: bool = False) -> Run:
        run = await self._repo.get(run_id, for_update=for_update)
        if run is None:
            raise NotFoundError("Run not found.", code="RUN_NOT_FOUND")
        return run

    async def get_run(self, run_id: uuid.UUID) -> Run:
        return await self._get_or_404(run_id)

    # -- orders ------------------------------------------------------------

    async def request_spot(self, *, run_id: uuid.UUID, user: User, order_text: str) -> Run:
        run = await self._get_or_404(run_id, for_update=True)
        if run.runner_id == user.id:
            raise BusinessRuleError("You cannot join your own run.", code="SELF_ORDER")
        if run.status != RunStatus.open:
            raise ConflictError("This run is no longer taking orders.", code="RUN_NOT_OPEN")
        if await self._repo.find_order(run_id, user.id) is not None:
            raise ConflictError("You already have an order on this run.", code="DUPLICATE_ORDER")
        if self._accepted_count(run) >= run.spots_max:
            raise ConflictError("All spots on this run are taken.", code="RUN_FULL")
        order = RunOrder(run_id=run.id, requester_id=user.id, order_text=order_text)
        self._repo.add(order)
        await self._session.flush()
        await self._notify(
            run.runner_id,
            NOTIFICATION_TYPE_RUN_REQUEST,
            run=run,
            dedup_key="run_id",
            extra={"requester_name": user.display_name},
        )
        await self._session.commit()
        return await self._get_or_404(run_id)

    async def withdraw_order(self, *, run_id: uuid.UUID, order_id: uuid.UUID, user: User) -> None:
        run = await self._get_or_404(run_id)
        order = self._order_in(run, order_id)
        if order.requester_id != user.id:
            raise ForbiddenError("Not your order.", code="NOT_REQUESTER")
        if order.status != RunOrderStatus.requested:
            raise ConflictError("Only pending requests can be withdrawn.", code="ORDER_NOT_PENDING")
        order.status = RunOrderStatus.cancelled
        await self._session.commit()

    async def accept_order(self, *, run_id: uuid.UUID, order_id: uuid.UUID, actor: User) -> Run:
        run = await self._get_or_404(run_id, for_update=True)
        self._assert_runner(run, actor)
        order = self._order_in(run, order_id)
        if run.status not in (RunStatus.open, RunStatus.locked):
            raise ConflictError("This run can no longer accept orders.", code="RUN_NOT_OPEN")
        if order.status != RunOrderStatus.requested:
            raise ConflictError("Order is not pending.", code="ORDER_NOT_PENDING")
        if self._accepted_count(run) >= run.spots_max:
            raise ConflictError("All spots on this run are taken.", code="RUN_FULL")
        order.status = RunOrderStatus.accepted
        await self._join_run_conversation(run, order.requester_id, actor)
        await self._notify(
            order.requester_id,
            NOTIFICATION_TYPE_RUN_ACCEPTED,
            run=run,
            dedup_key="order_id",
            dedup_value=str(order.id),
            extra={"order_id": str(order.id)},
        )
        await self._session.commit()
        return await self._get_or_404(run_id)

    async def decline_order(self, *, run_id: uuid.UUID, order_id: uuid.UUID, actor: User) -> Run:
        run = await self._get_or_404(run_id)
        self._assert_runner(run, actor)
        order = self._order_in(run, order_id)
        if order.status != RunOrderStatus.requested:
            raise ConflictError("Order is not pending.", code="ORDER_NOT_PENDING")
        order.status = RunOrderStatus.declined
        await self._notify(
            order.requester_id,
            NOTIFICATION_TYPE_RUN_DECLINED,
            run=run,
            dedup_key="order_id",
            dedup_value=str(order.id),
            extra={"order_id": str(order.id)},
        )
        await self._session.commit()
        return await self._get_or_404(run_id)

    # -- status ------------------------------------------------------------

    async def update_status(self, *, run_id: uuid.UUID, actor: User, status: RunStatus) -> Run:
        run = await self._get_or_404(run_id)
        self._assert_runner(run, actor)
        allowed = _LEGAL_TRANSITIONS.get(run.status, set())
        if status not in allowed:
            raise ConflictError(
                f"Cannot go from {run.status} to {status}.", code="INVALID_TRANSITION"
            )
        if status == RunStatus.done:
            # `delivered` counts as resolved — a requester who never taps
            # "received" must not block the runner from finishing.
            if any(o.status == RunOrderStatus.accepted for o in run.orders):
                raise ConflictError(
                    "Mark every accepted order delivered or no-show before finishing.",
                    code="ORDERS_UNRESOLVED",
                )
            run.completed_at = datetime.now(UTC)
        if status == RunStatus.at_store:
            # Heading into the store closes the request window.
            for order in run.orders:
                if order.status == RunOrderStatus.requested:
                    order.status = RunOrderStatus.declined
        run.status = status
        notify_type = (
            NOTIFICATION_TYPE_RUN_COMPLETED
            if status == RunStatus.done
            else NOTIFICATION_TYPE_RUN_STATUS
        )
        for order in run.orders:
            if order.status in (*_ACTIVE_ORDER_STATUSES, RunOrderStatus.received):
                await self._notify(
                    order.requester_id,
                    notify_type,
                    run=run,
                    dedup_key="run_id",
                    extra={"run_status": str(status), "order_id": str(order.id)},
                )
        await self._session.commit()
        return await self._get_or_404(run_id)

    async def cancel_run(self, *, run_id: uuid.UUID, actor: User) -> Run:
        run = await self._get_or_404(run_id)
        self._assert_runner(run, actor)
        if run.status not in (RunStatus.open, RunStatus.locked):
            raise ConflictError(
                "Only open or locked runs can be cancelled.", code="INVALID_TRANSITION"
            )
        run.status = RunStatus.cancelled
        for order in run.orders:
            if order.status == RunOrderStatus.accepted:
                order.status = RunOrderStatus.cancelled
                await self._notify(
                    order.requester_id,
                    NOTIFICATION_TYPE_RUN_STATUS,
                    run=run,
                    dedup_key="run_id",
                    extra={"run_status": "cancelled"},
                )
            elif order.status == RunOrderStatus.requested:
                order.status = RunOrderStatus.declined
        await self._session.commit()
        return await self._get_or_404(run_id)

    # -- per-order fulfilment ---------------------------------------------

    async def mark_delivered(self, *, run_id: uuid.UUID, order_id: uuid.UUID, actor: User) -> Run:
        run = await self._get_or_404(run_id)
        self._assert_runner(run, actor)
        order = self._order_in(run, order_id)
        if run.status not in (RunStatus.at_store, RunStatus.delivering):
            raise ConflictError("Run is not out for delivery.", code="INVALID_TRANSITION")
        if order.status != RunOrderStatus.accepted:
            raise ConflictError("Order is not accepted.", code="ORDER_NOT_ACCEPTED")
        order.status = RunOrderStatus.delivered
        await self._session.commit()
        return await self._get_or_404(run_id)

    async def confirm_received(self, *, run_id: uuid.UUID, order_id: uuid.UUID, user: User) -> Run:
        run = await self._get_or_404(run_id)
        order = self._order_in(run, order_id)
        if order.requester_id != user.id:
            raise ForbiddenError("Not your order.", code="NOT_REQUESTER")
        if order.status != RunOrderStatus.delivered:
            raise ConflictError("Order has not been delivered yet.", code="ORDER_NOT_DELIVERED")
        order.status = RunOrderStatus.received
        await self._session.commit()
        return await self._get_or_404(run_id)

    async def mark_no_show(self, *, run_id: uuid.UUID, order_id: uuid.UUID, actor: User) -> Run:
        run = await self._get_or_404(run_id)
        self._assert_runner(run, actor)
        order = self._order_in(run, order_id)
        if run.status not in (RunStatus.at_store, RunStatus.delivering):
            raise ConflictError("Run is not out for delivery.", code="INVALID_TRANSITION")
        if order.status not in (RunOrderStatus.accepted, RunOrderStatus.delivered):
            raise ConflictError("Order is not accepted.", code="ORDER_NOT_ACCEPTED")
        order.status = RunOrderStatus.no_show
        await self._session.commit()
        return await self._get_or_404(run_id)

    # -- helpers -----------------------------------------------------------

    @staticmethod
    def _accepted_count(run: Run) -> int:
        return sum(
            1 for o in run.orders if o.status in (*_ACTIVE_ORDER_STATUSES, RunOrderStatus.received)
        )

    @staticmethod
    def _assert_runner(run: Run, actor: User) -> None:
        if run.runner_id != actor.id:
            raise ForbiddenError("Only the runner can do this.", code="NOT_RUNNER")

    @staticmethod
    def _order_in(run: Run, order_id: uuid.UUID) -> RunOrder:
        order = next((o for o in run.orders if o.id == order_id), None)
        if order is None:
            raise NotFoundError("Order not found.", code="ORDER_NOT_FOUND")
        return order

    async def _join_run_conversation(self, run: Run, requester_id: uuid.UUID, runner: User) -> None:
        """Create the run group chat on first accept; append participants after.

        Bypasses MessagingService.get_or_create_conversation (2-party helper);
        Conversation itself is N-participant safe.
        """
        if run.conversation_id is None:
            conversation = Conversation(context_type=ConversationContext.run, context_id=run.id)
            self._session.add(conversation)
            await self._session.flush()
            run.conversation_id = conversation.id
            self._session.add(
                ConversationParticipant(conversation_id=conversation.id, user_id=runner.id)
            )
        self._session.add(
            ConversationParticipant(conversation_id=run.conversation_id, user_id=requester_id)
        )

    async def _notify(
        self,
        user_id: uuid.UUID,
        type_: str,
        *,
        run: Run,
        dedup_key: str,
        dedup_value: str | None = None,
        extra: dict[str, str] | None = None,
    ) -> None:
        opted_out = await self._notifications.disabled_types_for([user_id], type_)
        if user_id in opted_out:
            return
        payload: dict[str, str] = {
            "run_id": str(run.id),
            "spot_name": run.food_spot.name,
            "runner_name": run.runner.display_name,
            **(extra or {}),
        }
        await upsert_deduped_notification(
            self._notifications,
            user_id=user_id,
            type_=type_,
            dedup_key=dedup_key,
            dedup_value=dedup_value if dedup_value is not None else str(run.id),
            payload=payload,
            now=datetime.now(UTC),
        )
