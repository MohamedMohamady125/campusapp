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

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import (
    BusinessRuleError,
    ConflictError,
    ForbiddenError,
    NotFoundError,
    ValidationAppError,
)
from app.integrations.storage.base import (
    ALLOWED_CONTENT_TYPES,
    SignedUpload,
    StorageProvider,
)
from app.integrations.storage.provider import get_storage_provider
from app.integrations.storage.resolve import image_public_url
from app.models import (
    DropoffLocation,
    FoodSpot,
    Rating,
    Run,
    RunOrder,
    User,
)
from app.models.enums import RatingContext, RunOrderStatus, RunStatus
from app.repositories.chat_repo import NotificationRepository
from app.repositories.run_repo import RunRepository
from app.schemas.run import (
    DropoffLocationCreateRequest,
    FoodSpotCreateRequest,
    FoodSpotResponse,
    RunCreateRequest,
    RunLocation,
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
NOTIFICATION_TYPE_RUN_PAYMENT = "run_payment_submitted"
NOTIFICATION_TYPE_RUN_ARRIVED = "run_runner_arrived"

# Runner ghost protection: any active run hard-expires this long after leaving.
RUN_HARD_EXPIRY = timedelta(minutes=90)

# No-show counter (DoorDash-style): once the runner taps "I'm here" the
# requester has this long to show before no-show becomes legal. Research:
# DoorDash uses 5 min after contact, Uber Eats 7-8 min, UberX 2 min — 5 min
# fits a dorm walk-down without stalling a multi-stop student runner.
NO_SHOW_WAIT = timedelta(minutes=5)

# The create form defaults the leaving time to "now"; a few seconds of clock
# skew / submit latency shouldn't be rejected. Anything older than this is a
# genuine past time and refused.
LEAVING_AT_GRACE = timedelta(minutes=2)

_LEGAL_TRANSITIONS: dict[RunStatus, set[RunStatus]] = {
    RunStatus.open: {RunStatus.locked, RunStatus.at_store},
    RunStatus.locked: {RunStatus.at_store},
    RunStatus.at_store: {RunStatus.delivering},
    RunStatus.delivering: {RunStatus.done},
}

_ACTIVE_ORDER_STATUSES = (RunOrderStatus.accepted, RunOrderStatus.delivered)

# Live location is only shared while the runner is actually en route — from the
# moment the run locks through delivery. Never before leaving, never after done.
_LOCATION_SHARE_STATUSES = frozenset({RunStatus.locked, RunStatus.at_store, RunStatus.delivering})


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


def _order_response(order: RunOrder, *, rated_by_me: bool = False) -> RunOrderResponse:
    proof_url = image_public_url(order.payment_proof_key) if order.payment_proof_key else None
    return RunOrderResponse(
        rated_by_me=rated_by_me,
        id=order.id,
        run_id=order.run_id,
        requester=_user_summary(order.requester),
        order_text=order.order_text,
        dropoff=order.dropoff,
        dropoff_lat=order.dropoff_lat,
        dropoff_lng=order.dropoff_lng,
        status=order.status,
        created_at=order.created_at,
        payment_proof_url=proof_url,
        payment_note=order.payment_note,
        payment_submitted_at=order.payment_submitted_at,
        arrived_at=order.arrived_at,
    )


def run_response(
    run: Run,
    *,
    viewer_id: uuid.UUID,
    rated_order_ids: frozenset[uuid.UUID] | set[uuid.UUID] = frozenset(),
) -> RunResponse:
    """Serialize a run for a specific viewer (authz-in-serialization):

    - runner sees every order;
    - a requester sees only their own order (as my_order);
    - everyone else sees counts only.
    The runner's payment methods are exposed to accepted requesters + the
    runner (they are the payment instructions), hidden from passers-by.
    """
    is_runner = run.runner_id == viewer_id
    my_order = next((o for o in run.orders if o.requester_id == viewer_id), None)
    # The runner's own order (self-order) never counts toward spots.
    others = [o for o in run.orders if o.requester_id != run.runner_id]
    accepted = [o for o in others if o.status in _ACTIVE_ORDER_STATUSES]
    received = [o for o in others if o.status == RunOrderStatus.received]
    pending = [o for o in others if o.status == RunOrderStatus.requested]
    entitled = is_runner or (
        my_order is not None
        and my_order.status
        in (RunOrderStatus.accepted, RunOrderStatus.delivered, RunOrderStatus.received)
    )
    # Payment info is revealed on accept — pending requesters don't need the
    # runner's handle/QR yet (accept comes first, payment after, even on prepay).
    show_payment = entitled
    # Live location: entitled viewer, run en route, and the runner has pinged.
    runner_location: RunLocation | None = None
    if (
        entitled
        and run.status in _LOCATION_SHARE_STATUSES
        and run.runner_lat is not None
        and run.runner_lng is not None
        and run.location_updated_at is not None
    ):
        runner_location = RunLocation(
            lat=run.runner_lat,
            lng=run.runner_lng,
            updated_at=run.location_updated_at,
        )
    return RunResponse(
        id=run.id,
        runner=_user_summary(run.runner, include_payment=show_payment),
        is_mine=is_runner,
        food_spot=FoodSpotResponse.model_validate(run.food_spot),
        note=run.note,
        leaving_at=run.leaving_at,
        fee_cents=run.fee_cents,
        spots_max=run.spots_max,
        prepay_required=run.prepay_required,
        payment_prefs=run.payment_prefs,
        status=run.status,
        accepted_count=len(accepted) + len(received),
        pending_count=len(pending),
        created_at=run.created_at,
        # Runner sees every order; requesters/visitors get [] here.
        orders=[_order_response(o, rated_by_me=o.id in rated_order_ids) for o in run.orders]
        if is_runner
        else [],
        my_order=_order_response(my_order, rated_by_me=my_order.id in rated_order_ids)
        if my_order is not None
        else None,
        runner_location=runner_location,
    )


class RunService:
    def __init__(self, session: AsyncSession, storage: StorageProvider | None = None) -> None:
        self._session = session
        self._repo = RunRepository(session)
        self._notifications = NotificationRepository(session)
        self._storage = storage or get_storage_provider()

    # -- lifecycle ---------------------------------------------------------

    async def create_run(self, *, runner: User, body: RunCreateRequest) -> Run:
        spot = await self._repo.get_spot(body.food_spot_id)
        if spot is None or not spot.active:
            raise NotFoundError("Food spot not found.", code="FOOD_SPOT_NOT_FOUND")
        if body.leaving_at <= datetime.now(UTC) - LEAVING_AT_GRACE:
            raise BusinessRuleError("Leaving time must be in the future.", code="LEAVING_AT_PAST")
        if (body.fee_cents > 0 or body.prepay_required) and not runner.payment_methods:
            raise BusinessRuleError(
                "Add a payment method before charging a fee.",
                code="PAYMENT_METHOD_REQUIRED",
            )
        # Pay-on-handoff methods only apply to non-prepay runs (prepay has its
        # own proof flow). "cash" is always allowed; anything else must be one
        # of the runner's saved payment-method types. Order-preserving dedupe.
        payment_prefs: list[str] = []
        if not body.prepay_required:
            saved = {m.get("type") for m in (runner.payment_methods or [])}
            for pref in body.payment_prefs:
                if pref != "cash" and pref not in saved:
                    raise BusinessRuleError(
                        "Pick cash or one of your saved payment methods.",
                        code="PAYMENT_PREF_INVALID",
                    )
                if pref not in payment_prefs:
                    payment_prefs.append(pref)
        run = Run(
            runner_id=runner.id,
            food_spot_id=spot.id,
            note=body.note,
            leaving_at=body.leaving_at,
            fee_cents=body.fee_cents,
            spots_max=body.spots_max,
            prepay_required=body.prepay_required,
            payment_prefs=payment_prefs,
        )
        self._repo.add(run)
        await self._session.commit()
        return await self._get_or_404(run.id)

    async def create_spot(self, *, body: FoodSpotCreateRequest) -> FoodSpot:
        """Admin-only: register a new food-spot destination in the catalog."""
        if await self._repo.spot_name_exists(body.name):
            raise ConflictError("A spot with that name already exists.", code="FOOD_SPOT_EXISTS")
        spot = FoodSpot(
            name=body.name,
            category=body.category,
            description=body.description,
            lat=body.lat,
            lng=body.lng,
            image_url=body.image_url,
        )
        self._repo.add_spot(spot)
        await self._session.commit()
        await self._session.refresh(spot)
        return spot

    async def list_dropoffs(self) -> list[DropoffLocation]:
        return await self._repo.list_dropoffs()

    async def create_dropoff(self, *, body: DropoffLocationCreateRequest) -> DropoffLocation:
        """Admin-only: register a valid drop-off point requesters can pick from."""
        if await self._repo.dropoff_name_exists(body.name):
            raise ConflictError("A drop-off with that name already exists.", code="DROPOFF_EXISTS")
        dropoff = DropoffLocation(
            name=body.name, description=body.description, lat=body.lat, lng=body.lng
        )
        self._repo.add_dropoff(dropoff)
        await self._session.commit()
        await self._session.refresh(dropoff)
        return dropoff

    async def _get_or_404(self, run_id: uuid.UUID, *, for_update: bool = False) -> Run:
        run = await self._repo.get(run_id, for_update=for_update)
        if run is None:
            raise NotFoundError("Run not found.", code="RUN_NOT_FOUND")
        return run

    async def get_run(self, run_id: uuid.UUID) -> Run:
        return await self._get_or_404(run_id)

    async def rated_order_ids(self, *, run: Run, rater_id: uuid.UUID) -> set[uuid.UUID]:
        """Order ids on [run] the viewer has already rated (QA M-05: the Rate
        CTA must grey out server-authoritatively, not from client memory)."""
        order_ids = [o.id for o in run.orders]
        if not order_ids:
            return set()
        rows = await self._session.execute(
            select(Rating.context_id).where(
                Rating.rater_id == rater_id,
                Rating.context_type == RatingContext.run,
                Rating.context_id.in_(order_ids),
                Rating.deleted_at.is_(None),
            )
        )
        return {cid for cid in rows.scalars() if cid is not None}

    # -- orders ------------------------------------------------------------

    async def request_spot(
        self,
        *,
        run_id: uuid.UUID,
        user: User,
        order_text: str,
        dropoff_location_id: uuid.UUID,
    ) -> Run:
        run = await self._get_or_404(run_id, for_update=True)
        # A runner may attach their OWN order to their run (they're obviously
        # picking up food for themselves too). It is auto-accepted, never
        # notifies, and doesn't consume a requester spot (see _accepted_count).
        is_self_order = run.runner_id == user.id
        if run.status != RunStatus.open:
            raise ConflictError("This run is no longer taking orders.", code="RUN_NOT_OPEN")
        if await self._repo.find_order(run_id, user.id) is not None:
            raise ConflictError("You already have an order on this run.", code="DUPLICATE_ORDER")
        if not is_self_order and self._accepted_count(run) >= run.spots_max:
            raise ConflictError("All spots on this run are taken.", code="RUN_FULL")
        # Resolve the picked catalog location → denormalize its name onto the
        # order so every read path stays a plain string (no free-text addresses).
        location = await self._repo.get_dropoff(dropoff_location_id)
        if location is None or not location.active:
            raise NotFoundError("Drop-off location not found.", code="DROPOFF_NOT_FOUND")
        order = RunOrder(
            run_id=run.id,
            requester_id=user.id,
            order_text=order_text,
            dropoff=location.name,
            dropoff_lat=location.lat,
            dropoff_lng=location.lng,
            status=RunOrderStatus.accepted if is_self_order else RunOrderStatus.requested,
        )
        self._repo.add(order)
        await self._session.flush()
        if not is_self_order:
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
        # Prepay runs: accept FIRST, pay after. The accept notification is what
        # prompts the requester to pay (proof upload requires accepted status),
        # so gating accept on proof would deadlock the flow.
        order.status = RunOrderStatus.accepted
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
        if order.requester_id == run.runner_id:
            raise ConflictError("You cannot decline your own order.", code="CANNOT_DECLINE_SELF")
        # Prepay enforcement is the runner's call, never automatic (off-app
        # payment means the server can't verify money moved — only the human
        # can). So on a prepay run the runner may drop an accepted order that
        # still has no proof, but only before heading to the store.
        droppable_unpaid = (
            order.status == RunOrderStatus.accepted
            and run.prepay_required
            and order.payment_submitted_at is None
            and run.status in (RunStatus.open, RunStatus.locked)
        )
        if order.status != RunOrderStatus.requested and not droppable_unpaid:
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

    # -- payment proof -----------------------------------------------------

    _PAYABLE_STATUSES = (
        RunOrderStatus.accepted,
        RunOrderStatus.delivered,
        RunOrderStatus.received,
    )

    async def create_payment_proof_upload(
        self, *, run_id: uuid.UUID, order_id: uuid.UUID, user: User, content_type: str
    ) -> SignedUpload:
        """Signed-URL direct upload for the requester's transaction screenshot.

        Off-app payment (spec: the app never moves money) — the requester pays
        via the runner's revealed handle, then attaches proof here. Only the
        requester on an accepted order may upload.
        """
        if content_type not in ALLOWED_CONTENT_TYPES:
            raise ValidationAppError(
                "Unsupported image type.",
                code="UNSUPPORTED_CONTENT_TYPE",
                details={"allowed": sorted(ALLOWED_CONTENT_TYPES)},
            )
        run = await self._get_or_404(run_id)
        order = self._order_in(run, order_id)
        if order.requester_id != user.id:
            raise ForbiddenError("Not your order.", code="NOT_REQUESTER")
        if order.status not in self._PAYABLE_STATUSES:
            raise ConflictError(
                "You can only submit payment after the runner accepts.",
                code="ORDER_NOT_ACCEPTED",
            )
        ext = content_type.split("/")[-1]
        key = f"run-payments/{order.id}/{uuid.uuid4()}.{ext}"
        return await self._storage.create_signed_upload(key=key, content_type=content_type)

    async def submit_payment_proof(
        self,
        *,
        run_id: uuid.UUID,
        order_id: uuid.UUID,
        user: User,
        proof_key: str,
        note: str | None,
    ) -> Run:
        """Requester confirms payment: store the screenshot key + note and ping
        the runner so it surfaces on their order card (least-friction proof)."""
        run = await self._get_or_404(run_id)
        order = self._order_in(run, order_id)
        if order.requester_id != user.id:
            raise ForbiddenError("Not your order.", code="NOT_REQUESTER")
        if order.status not in self._PAYABLE_STATUSES:
            raise ConflictError(
                "You can only submit payment after the runner accepts.",
                code="ORDER_NOT_ACCEPTED",
            )
        order.payment_proof_key = proof_key
        order.payment_note = note
        order.payment_submitted_at = datetime.now(UTC)
        await self._notify(
            run.runner_id,
            NOTIFICATION_TYPE_RUN_PAYMENT,
            run=run,
            dedup_key="order_id",
            dedup_value=str(order.id),
            extra={"order_id": str(order.id), "requester_name": user.display_name},
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
            # The runner's own order auto-resolves — they delivered to
            # themselves, no confirmation needed.
            for order in run.orders:
                if order.requester_id == run.runner_id and order.status in (
                    RunOrderStatus.accepted,
                    RunOrderStatus.delivered,
                ):
                    order.status = RunOrderStatus.received
            # `delivered` counts as resolved — a requester who never taps
            # "received" must not block the runner from finishing.
            if any(o.status == RunOrderStatus.accepted for o in run.orders):
                raise ConflictError(
                    "Mark every accepted order delivered or no-show before finishing.",
                    code="ORDERS_UNRESOLVED",
                )
            run.completed_at = datetime.now(UTC)
        if status == RunStatus.at_store:
            # Heading into the store closes the request window — notify
            # auto-declined requesters so they know they didn't make it.
            for order in run.orders:
                if order.status == RunOrderStatus.requested:
                    order.status = RunOrderStatus.declined
                    await self._notify(
                        order.requester_id,
                        NOTIFICATION_TYPE_RUN_DECLINED,
                        run=run,
                        dedup_key="order_id",
                        dedup_value=str(order.id),
                        extra={"order_id": str(order.id)},
                    )
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

    async def update_location(
        self, *, run_id: uuid.UUID, actor: User, lat: float, lng: float
    ) -> Run:
        """Runner pings their live GPS position (Uber/Lyft-style tracking).

        Only the runner may report, and only while the run is en route
        (locked → delivering). The point is exposed to accepted requesters in
        run_response; before locking / after done we drop the ping.
        """
        run = await self._get_or_404(run_id)
        self._assert_runner(run, actor)
        if run.status not in _LOCATION_SHARE_STATUSES:
            raise ConflictError(
                "Location sharing is only active while the run is en route.",
                code="RUN_NOT_EN_ROUTE",
            )
        run.runner_lat = lat
        run.runner_lng = lng
        run.location_updated_at = datetime.now(UTC)
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
                await self._notify(
                    order.requester_id,
                    NOTIFICATION_TYPE_RUN_STATUS,
                    run=run,
                    dedup_key="run_id",
                    extra={"run_status": "cancelled"},
                )
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
        if run.status in (RunStatus.cancelled, RunStatus.expired):
            raise ConflictError("Run is no longer active.", code="RUN_NOT_ACTIVE")
        order = self._order_in(run, order_id)
        if order.requester_id != user.id:
            raise ForbiddenError("Not your order.", code="NOT_REQUESTER")
        if order.status != RunOrderStatus.delivered:
            raise ConflictError("Order has not been delivered yet.", code="ORDER_NOT_DELIVERED")
        order.status = RunOrderStatus.received
        await self._session.commit()
        return await self._get_or_404(run_id)

    async def mark_arrived(self, *, run_id: uuid.UUID, order_id: uuid.UUID, actor: User) -> Run:
        """Runner taps "I'm here" at a drop-off: stamp the no-show counter and
        notify the requester. Idempotent — a re-tap never resets the clock
        (that would let a runner shorten the requester's window)."""
        run = await self._get_or_404(run_id)
        self._assert_runner(run, actor)
        order = self._order_in(run, order_id)
        if run.status not in (RunStatus.at_store, RunStatus.delivering):
            raise ConflictError("Run is not out for delivery.", code="INVALID_TRANSITION")
        if order.status != RunOrderStatus.accepted:
            raise ConflictError("Order is not accepted.", code="ORDER_NOT_ACCEPTED")
        if order.arrived_at is None:
            order.arrived_at = datetime.now(UTC)
            await self._notify(
                order.requester_id,
                NOTIFICATION_TYPE_RUN_ARRIVED,
                run=run,
                dedup_key="order_id",
                dedup_value=str(order.id),
                extra={"dropoff": order.dropoff},
            )
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
        # No-show is never a surprise: the runner must announce arrival first
        # ("I'm here"), then wait out NO_SHOW_WAIT before it becomes legal.
        if order.arrived_at is None:
            raise ConflictError(
                'Tap "I\'m here" first — the requester gets a 5-minute window.',
                code="ARRIVAL_REQUIRED",
            )
        arrived = order.arrived_at
        if arrived.tzinfo is None:
            arrived = arrived.replace(tzinfo=UTC)
        if datetime.now(UTC) < arrived + NO_SHOW_WAIT:
            raise ConflictError(
                "The requester's 5-minute window hasn't elapsed yet.",
                code="NO_SHOW_TOO_EARLY",
            )
        order.status = RunOrderStatus.no_show
        await self._session.commit()
        return await self._get_or_404(run_id)

    # -- helpers -----------------------------------------------------------

    @staticmethod
    def _accepted_count(run: Run) -> int:
        # The runner's own order never consumes a requester spot.
        return sum(
            1
            for o in run.orders
            if o.requester_id != run.runner_id
            and o.status in (*_ACTIVE_ORDER_STATUSES, RunOrderStatus.received)
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
