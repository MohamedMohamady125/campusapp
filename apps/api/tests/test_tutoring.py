"""Tutoring tests (spec §14 M6): §5.1 ranking units + J2 E2E."""

import uuid
from datetime import UTC, datetime

import httpx
import pytest
from sqlalchemy import update

from app.core.scoring import WEIGHT_RECENCY, WEIGHT_REPUTATION, WEIGHT_RESPONSIVENESS
from app.db.session import async_session_factory
from app.models import Course, User
from app.services.tutor_ranking import TutorCandidate, rank_tutors, term_ordinal
from tests.helpers import make_user

NOW = datetime(2026, 7, 1, tzinfo=UTC)


def _cand(
    reputation: float = 4.0,
    term: str = "2025-fall",
    reply: float | None = None,
    rating_count: int = 0,
    last_active: datetime | None = None,
) -> TutorCandidate:
    return TutorCandidate(
        tutor_id=uuid.uuid4(),
        reputation=reputation,
        term=term,
        median_reply_seconds=reply,
        rating_count=rating_count,
        last_active_at=last_active,
    )


# --- §5.1 unit tests ---------------------------------------------------------


def test_weights_are_spec_values() -> None:
    assert (WEIGHT_REPUTATION, WEIGHT_RECENCY, WEIGHT_RESPONSIVENESS) == (0.60, 0.30, 0.10)


def test_score_composition_uses_weights() -> None:
    """Best-on-all-axes scores 1.0; worst-on-all scores per remaining weight."""
    best = _cand(reputation=5.0, term="2026-spring", reply=60)
    worst = _cand(reputation=3.0, term="2023-fall", reply=86400)
    ranked = rank_tutors([best, worst])
    scores = {r.tutor_id: r for r in ranked}
    assert scores[best.tutor_id].score == pytest.approx(1.0)
    assert scores[worst.tutor_id].score == pytest.approx(0.0)
    # Reputation dominates: better rep but older term still wins overall.
    high_rep_old = _cand(reputation=5.0, term="2023-fall", reply=600)
    low_rep_new = _cand(reputation=3.0, term="2026-spring", reply=600)
    ranked = rank_tutors([high_rep_old, low_rep_new])
    assert ranked[0].tutor_id == high_rep_old.tutor_id
    assert ranked[0].score == pytest.approx(WEIGHT_REPUTATION + WEIGHT_RESPONSIVENESS)


def test_new_tutor_not_floored_to_last() -> None:
    """Cold start (spec §5.1): no reply data → pool-median neutral prior."""
    fast = _cand(reputation=4.5, term="2025-fall", reply=60)
    slow = _cand(reputation=4.5, term="2025-fall", reply=86400)
    fresh = _cand(reputation=4.5, term="2025-fall", reply=None)
    ranked = rank_tutors([fast, slow, fresh])
    order = [r.tutor_id for r in ranked]
    assert order.index(fresh.tutor_id) < order.index(slow.tutor_id)  # not last
    by_id = {r.tutor_id: r for r in ranked}
    assert 0.0 < by_id[fresh.tutor_id].responsiveness_norm < 1.0  # neutral, not zero


def test_tie_breaks_rating_count_then_last_active() -> None:
    a = _cand(rating_count=10, last_active=datetime(2026, 6, 1, tzinfo=UTC))
    b = _cand(rating_count=50, last_active=datetime(2026, 1, 1, tzinfo=UTC))
    c = _cand(rating_count=10, last_active=datetime(2026, 6, 30, tzinfo=UTC))
    ranked = rank_tutors([a, b, c])
    assert [r.tutor_id for r in ranked] == [b.tutor_id, c.tutor_id, a.tutor_id]


def test_term_ordinal_orders_terms() -> None:
    assert term_ordinal("2025-fall") > term_ordinal("2025-spring") > term_ordinal("2024-fall")


def test_empty_pool() -> None:
    assert rank_tutors([]) == []


# --- API / E2E ---------------------------------------------------------------


async def _seed_course(code: str = "CS250", title: str = "Data Structures") -> str:
    async with async_session_factory() as session:
        course = Course(code=code, title=title, department="Computer Science")
        session.add(course)
        await session.commit()
        return str(course.id)


async def _user_id(client: httpx.AsyncClient, headers: dict[str, str]) -> str:
    return str((await client.get("/api/v1/users/me", headers=headers)).json()["id"])


async def test_course_autocomplete(client: httpx.AsyncClient) -> None:
    await _seed_course("CS250")
    await _seed_course("MATH101", title="Calculus I")
    user = await make_user(client, "student@campus.edu")
    resp = await client.get("/api/v1/courses", params={"q": "cs2"}, headers=user)
    assert [c["code"] for c in resp.json()] == ["CS250"]
    resp = await client.get("/api/v1/courses", params={"q": "Data Struct"}, headers=user)
    assert [c["code"] for c in resp.json()] == ["CS250"]


async def test_offering_crud_and_guards(client: httpx.AsyncClient) -> None:
    course_id = await _seed_course()
    tutor = await make_user(client, "tutor@campus.edu")
    other = await make_user(client, "other@campus.edu")

    body = {"course_id": course_id, "term_taken": "2025-fall", "grade_received": "A"}
    resp = await client.post("/api/v1/tutoring/offerings", json=body, headers=tutor)
    assert resp.status_code == 201, resp.text
    offering_id = resp.json()["id"]

    # Duplicate offering for the same course → 409.
    resp = await client.post("/api/v1/tutoring/offerings", json=body, headers=tutor)
    assert resp.status_code == 409
    assert resp.json()["error"]["code"] == "ALREADY_OFFERING"

    # Bad term format rejected at the boundary.
    bad = dict(body, term_taken="fall-2025")
    assert (
        await client.post("/api/v1/tutoring/offerings", json=bad, headers=tutor)
    ).status_code == 400

    # Only the owner can remove it.
    resp = await client.delete(f"/api/v1/tutoring/offerings/{offering_id}", headers=other)
    assert resp.status_code == 403
    resp = await client.delete(f"/api/v1/tutoring/offerings/{offering_id}", headers=tutor)
    assert resp.status_code == 204

    # Deactivated offering no longer appears in search.
    resp = await client.get("/api/v1/tutoring/tutors", params={"course": "CS250"}, headers=tutor)
    assert resp.json()["items"] == []


async def test_j2_course_to_ranked_list_to_message(client: httpx.AsyncClient) -> None:
    """E2E J2: course code → ranked tutor list → message top match (spec §1)."""
    course_id = await _seed_course()
    strong = await make_user(client, "strong@campus.edu")
    newbie = await make_user(client, "newbie@campus.edu")
    student = await make_user(client, "student@campus.edu")

    for headers, term in ((strong, "2026-spring"), (newbie, "2024-fall")):
        resp = await client.post(
            "/api/v1/tutoring/offerings",
            json={"course_id": course_id, "term_taken": term, "grade_received": "A"},
            headers=headers,
        )
        assert resp.status_code == 201

    # Give 'strong' a reputation edge (cached §5.2 score set directly).
    async with async_session_factory() as session:
        await session.execute(
            update(User)
            .where(User.email == "strong@campus.edu")
            .values(reputation_score=4.8, rating_count=25)
        )
        await session.commit()

    resp = await client.get("/api/v1/tutoring/tutors", params={"course": "cs250"}, headers=student)
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["course"]["code"] == "CS250"
    assert len(data["items"]) == 2
    top = data["items"][0]
    assert top["tutor"]["display_name"] == "strong"
    assert top["score"] >= data["items"][1]["score"]
    # New tutor gets neutral responsiveness, not zero (cold start §5.1).
    assert data["items"][1]["responsiveness_norm"] > 0.0

    # Message the top match — reuses M5 messaging with tutoring context.
    resp = await client.post(
        "/api/v1/conversations",
        json={
            "recipient_id": top["tutor"]["id"],
            "context_type": "tutoring",
            "context_id": top["offering"]["id"],
        },
        headers=student,
    )
    assert resp.status_code == 201
    conv_id = resp.json()["id"]
    resp = await client.post(
        f"/api/v1/conversations/{conv_id}/messages",
        json={"body": "Hi! Can you help me with CS250?"},
        headers=student,
    )
    assert resp.status_code == 201
