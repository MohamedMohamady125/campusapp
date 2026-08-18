# Sprint 5 — Loom Video Script (TRUE version, matches the app as built)

**Target: 6 minutes.** Read it in a normal talking voice.

Every claim in this script has been verified against the running app.
Changes from the old draft are the reason-label wording, the cold-start
detail (pool median, not 0.5), the tutor-profile click-through (cut — not
built), chat type filters (cut — not built), and the chat rate limit
(reframed as a logged risk, not a shipped fix).

---

## SETUP — Before you hit record

**Window 1 (main):**
- Tab A: Sprint 5 Report docx — scrolled to title page
- Tab B: Jira board, filtered to Sprint 5 (Epic KAN-5)
- Tab C: Confluence Sprint 5 page (Design Notes → Tutor Matching Formula)
- Tab D: Confluence Risk Log

**Window 2 (your running app):**
- Backend up (`make infra-up` + uvicorn) — check
  `http://localhost:8000/api/v1/health/ready` says ok
- Logged in as `ava0@campus.edu` / `Password123!`
- Demo course is **CS250** — it is seeded with **4 tutors** (Iris, Ben,
  Noah, Ella) with clearly different scores, so the ranking is visible
- At least one open chat exists in the directory (seeded)

**Dry run:** type `CS250` (no space) in tutor search and confirm 4 ranked
cards appear, each with a reason label. That's the visual centerpiece.

---

## PART 1 — Intro (20 sec)

**Open:** Sprint 5 Report title page

> "Hi, I'm Mohamed. This is my Sprint 5 review for CampusConnect. This
> sprint I finished the peer tutoring feature end to end, and laid the
> foundation for community chats. Two of the three main features are now
> fully working. Let me show you."

---

## PART 2 — The payoff of shared services (25 sec)

**Stay on:** Title page

> "The big story of this sprint — Sprint 4's investment in shared services
> paid off exactly as I hoped. The tutor matching algorithm just consumes
> reputation and message data that already existed. The chat foundation
> reuses the participant patterns from direct conversations. Feature
> velocity was noticeably faster than sprints where I had to build
> infrastructure. Build it once in Sprint 4, use it three times in
> Sprint 5 and beyond."

---

## PART 3 — Live demo: Tutor Matching (2 min) — THE IMPORTANT PART

**Open:** Window 2 — the running app. Navigate to the tutor search screen.

> "Here's the tutor search. As a student, I pick a course I need help
> with."

**Do:** Type `CS250` into the course autocomplete. Select it.

> "Same autocomplete over the seeded catalog from Sprint 4. And here are
> the ranked tutors — four of them, in ranked order."

**Do:** Point at the results list.

> "Notice each tutor card carries a reason label — things like 'Top-rated
> for CS250', or 'Took CS250 recently' with the term and grade. That's
> ranking transparency. Without it, a ranked list feels arbitrary — one of
> my Sprint 5 challenges. Adding the reason strings was a small change
> with a big impact on perceived fairness."

**Do:** Point at the top tutor's card — reputation chip, grade, term.

> "Each card shows the tutor's reputation — the same Bayesian score they
> earned across the whole platform, marketplace included — plus when they
> took the course and the grade they got. One identity, one reputation."

**Do:** Click Message on the top tutor.

> "Message Tutor opens a conversation with tutoring context. Uses the
> exact same messaging service from Sprint 4 that the marketplace uses.
> Just a different context tag on the conversation."

**Open:** Confluence Sprint 5 → Design Notes → Tutor Matching Formula

> "Here's the math. Match score equals point-six times reputation, plus
> point-three times recency, plus point-one times responsiveness. All
> three subscores normalized to zero-to-one, then weighted. The weights
> live as named constants in one scoring module."

**Do:** Point at the three bullets on the page.

> "Reputation is the Bayesian score from Sprint 4. Recency is how recently
> they took the course, normalized — someone who took it last semester
> scores near one. Responsiveness is median reply time on messages over
> the last thirty days. And for cold start: tutors with no message history
> get the pool median as a neutral prior — same intuition as the Bayesian
> reputation prior. New tutors aren't penalized for having no data, and
> the prior fades as real data accumulates."

---

## PART 4 — Live demo: Community Chats (45 sec)

**Do:** Switch to the chats section of the app.

> "Community chats — the foundation shipped this sprint. Messaging and
> moderation land in Sprint 6."

**Do:** Open the chat directory.

> "Directory of discoverable chats. Each card shows the member count and a
> join button."

**Do:** Click into an open chat to join.

> "Open chats join immediately. Chats with request visibility can't be
> joined directly — they require moderator approval, which is enforced
> server-side."

---

## PART 5 — Jira board (25 sec)

**Open:** Jira board, Sprint 5 filter.

> "The board. Two tasks under Epic KAN-5, twenty-one story points."

**Do:** Point at each task.

> "KAN-27 was the tutor matching algorithm and UI — thirteen points, the
> bigger one. KAN-28 was the chats foundation. [Describe your actual
> completion state.]"

---

## PART 6 — Challenges (50 sec)

**Open:** Sprint 5 Report → Section 5

> "Three challenges worth flagging.
>
> One — cold-start for the responsiveness metric. New tutors have no
> message data. Scoring them zero would systematically bury them. Fixed by
> giving them the pool median as a neutral prior — same pattern as the
> Bayesian reputation prior.
>
> Two — ranking felt arbitrary without explanation. Added the reason
> strings I just showed. Small change, big impact.
>
> Three — chat spam. During internal testing I realized bulk chat creation
> is an obvious spam vector. I've logged it as a risk with a per-user
> creation rate limit as the mitigation, scheduled alongside chat
> messaging in Sprint 6. Lesson: rate limiting belongs on the pre-merge
> checklist for any user-content endpoint."

**Open:** Confluence Risk Log.

> "Two new risk log entries. R-11 is chat spam — mitigation is the
> creation rate limit landing in Sprint 6. R-12 is that tutor recency
> can't be verified without gradebook access — a known limitation.
> Reputation stays the primary trust signal."

---

## PART 7 — Metrics + lessons (30 sec)

**Open:** Sprint 5 Report → Sections 6 + 7

> "Velocity: twenty-one committed, [X] completed. Five sprints of data
> now.
>
> Three lessons. Shared services keep paying dividends — Sprint 4's
> infrastructure meant Sprint 5's features were mostly a query and a
> formula. Explainability matters for ranked results — reason strings
> were minutes of work with disproportionate value. And rate limiting
> belongs on the pre-merge checklist for any user-content endpoint."

---

## PART 8 — Sprint 6 preview (20 sec)

**Open:** Jira backlog → Epic KAN-6

> "Sprint 6 finishes community chats with messaging, moderation, and the
> chat-creation rate limit, plus adds the unified notification system.
> KAN-29 is chat messaging with moderation — thirteen points. KAN-30 is
> notifications — eight points. Twenty-one committed, holding at
> baseline."

---

## PART 9 — Close (15 sec)

**Open:** Sprint 5 Report title page

> "That's Sprint 5. Tutoring is fully working, chats foundation is in
> place, ready for messaging in Sprint 6. All links on the title page.
> Thanks."

---

## Tab-switching cheat sheet

| Part | Open |
|------|------|
| 1, 2 | Sprint 5 Report title page |
| 3 | Running app (tutor search) → Confluence (formula) |
| 4 | Running app (chats section) |
| 5 | Jira board, Sprint 5 |
| 6 | Sprint 5 Report Section 5 → Risk Log |
| 7 | Sprint 5 Report Sections 6-7 |
| 8 | Jira backlog, KAN-6 Epic |
| 9 | Sprint 5 Report title page |

---

## What changed vs. the old draft (so you don't say something untrue)

1. **Type `CS250`, not `CS 250`** — the course exists and has 4 tutors.
2. **Reason labels** read like "Top-rated for CS250" / "Took CS250 fall ·
   A" — quote them loosely, don't promise "Fast to respond".
3. **No tutor-profile click-through** — the card itself carries
   reputation, term, grade; narrate from the card, then hit Message.
4. **Cold start = pool median**, not a fixed 0.5.
5. **No "filterable by type" claim** for the chat directory.
6. **Restricted chats reject with "requires approval"** — say "require
   moderator approval", not "return pending".
7. **The 3-per-week chat rate limit is NOT built** — it's now framed as
   risk R-11 with the mitigation scheduled for Sprint 6.
