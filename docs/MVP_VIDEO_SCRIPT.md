# MVP Demo Video Script — CampusConnect (TRUE version, matches the app as built)

**Target: 8–10 minutes.** Covers all five required sections, in order:
1. Demo of the MVP
2. How the problem was identified and solution conceived
3. Iterative process/approach
4. Design decisions revisited
5. 1–2 recommendations for STG-452

Every product claim in this script has been verified against the running
app and the code. The corrections vs. your draft are listed at the bottom
— read them once so you don't ad-lib something untrue.

---

## SETUP — Before you hit record

**Window 1 (main — desktop layout):**
- Tab A: https://campusconnect-lake.vercel.app — logged in as
  `ava0@campus.edu` / `Password123!` (Ava = buyer + chat owner/moderator,
  has the pending @mention)
- Tab B: MVP Final Report — title page
- Tab C: Jira board (backlog view, all 8 epics)
- Tab D: Confluence Project Home
- Tab E: Confluence Sprint 7 / MVP Delivery page
- Tab F: GitHub repo — file tree + commits

**Window 2 (small, incognito):**
- Same URL, logged in as `ben1@campus.edu` / `Password123!` (Ben =
  seller + CS250 tutor + chat member)

**Pre-flight (do ALL of these):**
- Hard-refresh both windows (Cmd+Shift+R) — the service worker caches
  old builds.
- Confirm the API is up: ping me to verify the tunnel, or check that
  browse loads listings.
- Ava's bell should show **3 unread** (the @mention + deduped chat
  messages). Do NOT open the notifications screen before recording or
  you'll consume the badge.
- Dry-run 60 seconds: marketplace search `CS250` → Ben's textbook →
  tutor search `CS250` → 4 ranked cards → CS250 Study Group chat.

---

## OPENING (15 sec)

**Open:** MVP Final Report title page.

> "Hi, I'm Mohamed Mohamady. This is my final MVP demonstration video for
> CampusConnect — my STG-451 capstone project. I'll cover five things: a
> demo of the working product, how I identified the problem and conceived
> the solution, the iterative process I followed, key design decisions I
> made along the way, and my recommendations for continued development in
> STG-452. Let's start with the demo."

---

## PART 1 — MVP DEMO (3 minutes) — THE CENTERPIECE

**Open:** the live app (Window 1, as Ava).

> "CampusConnect is live. Three integrated features for verified college
> students: a campus marketplace, peer tutoring, and community chats. All
> three sharing one identity, one messaging service, one reputation. Let
> me walk through each."

### 1a. Marketplace (45 sec)

**Do:** Navigate to the marketplace browse tab.

> "Marketplace browse — verified students only. Grid layout, full-text
> search, category and price filters."

**Do:** Type `CS250` in search → Ben's "CS250 Algorithms textbook" appears.
Click into it.

> "Listing detail — photo, price, and the seller card with the seller's
> reputation score. And Message Seller."

**Do:** Click Message Seller. Type `Hi, is this still available?` Send.

**Do:** Switch to Window 2 (Ben). Wait a beat; show the bell badge, click
it, show the "Ava A. sent you a message" notification, click through to
the conversation.

> "The message lands on the seller's side within a few seconds — the app
> polls on a five-second interval. And notice it arrived as a
> notification too. Same messaging infrastructure the tutoring feature
> uses."

### 1b. Tutoring (45 sec)

**Switch to Window 1.** Navigate to the tutor tab.

> "Tutoring. Pick a course, see ranked tutors."

**Do:** Type `CS250` (no space) in the course box. Select it. Four ranked
cards appear.

> "Notice the reason strings on each card — 'Top-rated for CS250', 'Took
> CS250 recently' with the term and grade. Ranking transparency. The
> ranking itself is reputation times point-six, plus recency times
> point-three, plus responsiveness times point-one — all three subscores
> normalized to zero-to-one, then weighted. And the reputation here is
> the exact same score you just saw on the marketplace seller card.
> That's the shared-services architecture paying off."

**Do:** Point at the top card's reputation chip, term, and grade — then
click Message on a tutor to show it opens the same messaging.

### 1c. Community Chats (45 sec)

**Do:** Navigate to the chats tab, show the directory briefly.

> "Community chats. A directory of discoverable groups — open chats join
> in one tap; restricted ones require moderator approval, enforced
> server-side."

**Do:** Open "CS250 Study Group" (you're the owner). Scroll the thread —
point at the tombstoned message.

> "Full messaging with @mentions. And real moderation: when a moderator
> deletes a message it leaves a visible tombstone with the moderator's
> name and a written reason — deletion and muting both require a reason,
> for accountability. Mute and ban are one long-press away."

**Do:** Click the notification bell (Ava has 3 unread).

> "Notifications tie it all together — chat mentions, chat activity, and
> direct messages in one place. Mentions always come through
> individually, and regular chat traffic is deduplicated on a 60-minute
> window — you can see it here: 'Ben and one more message in CS250 Study
> Group' — so a busy chat doesn't drown out a personal DM. Tapping any of
> these deep-links straight into the right conversation."

**Do:** Tap the @mention notification — it opens the chat.

### 1d. MVP Recap (15 sec)

**Do:** Return to browse/home.

> "Three features. One shared identity. One reputation. One messaging
> service. Deployed, verified-student-gated. That's the MVP."

---

## PART 2 — PROBLEM IDENTIFIED, SOLUTION CONCEIVED (90 sec)

**Open:** MVP Final Report → Section 2.

> "How did I get here? I identified this problem by direct observation of
> what college students actually do today.
>
> To buy a used textbook, students post on Facebook Marketplace. To find
> a sublease, they scroll subreddits. To find a tutor, they navigate
> expensive commercial services or the overloaded campus tutoring center.
> To build community, they scatter across Discord, GroupMe, and
> Instagram.
>
> Each of these platforms was designed for the general public — not for a
> verified, closed, trusted college community. That fragmentation has
> documented consequences: scams in unverified marketplaces, unaffordable
> tutoring, social isolation especially for new and international
> students, and no shared identity across services.
>
> I analyzed these as four separate sub-problems in the initial proposal.
> Solving each independently would need four separate platforms. But they
> share a common architectural need — a verified, closed, student-only
> environment with unified identity and reputation. That insight was the
> founding design decision: build one platform, share the trust
> infrastructure, and the three features reinforce each other."

**Do:** Point at the paragraph headers in Section 2.

> "As a solo developer, I aggressively narrowed scope from an initial
> eight-feature brainstorm down to the three features that maximize value
> while remaining buildable in one semester. Features requiring external
> partnerships or high liability got cut. That scope discipline is direct
> evidence of competency 6.3 — analyzing a complex problem and applying
> computing plus business plus social considerations to arrive at a
> defensible scope."

---

## PART 3 — ITERATIVE PROCESS (60 sec)

**Open:** Jira board (backlog view).

> "The iterative process was Agile Scrum, adapted for a solo developer.
> Seven biweekly sprints. Each sprint had a planning session, daily
> written check-ins, and a written retrospective at the end."

**Do:** Point at the 8 epics.

> "Sprint 1 was setup. Sprint 2 was authentication. Sprint 3 shipped the
> marketplace core. Sprint 4 built the shared messaging service and the
> reputation system. Sprint 5 delivered tutor matching and chat
> foundations. Sprint 6 finished chat messaging, moderation, and
> notifications. Sprint 7 — this sprint — is usability testing,
> accessibility audit, security review, and deployment."

**Do:** Click into one Epic (KAN-4) to show detailed tasks.

> "35 total issues on the board, all with acceptance criteria and
> story-point estimates. Velocity was tracked sprint over sprint to
> calibrate the next commitment."

**Open:** Confluence Project Home.

> "All documentation lives in Confluence — 15-plus pages including the
> proposal, high-level mock, Architecture Decision Records, per-sprint
> retrospectives, risk log, API documentation, and data model."

**Open:** GitHub repo.

> "Source code on GitHub with continuous integration running lint,
> type-check, and the full test suite on every push — separate lanes for
> the FastAPI backend and the Flutter app. The web frontend is deployed
> on Vercel; the backend is FastAPI on PostgreSQL with Redis and
> S3-compatible object storage. Industry-standard tooling end to end.
> That covers competency 6.2 — design concepts, principles, tools, and
> problem-solving strategies drawn from current practice."

---

## PART 4 — DESIGN DECISIONS REVISITED (2.5 minutes)

**Open:** MVP Final Report → Section 6.

> "Every project has design decisions that turned out well and some that
> had to be revisited. Let me walk through the four that mattered most."

### 4a. Shared Services Architecture (35 sec) — Section 6.2

> "First — building messaging as generic conversation infrastructure
> rather than three separate messaging features, and building reputation
> as one campus-wide score across all features.
>
> The alternative would have been three messaging systems and three
> reputation scores. Rejected because it duplicates work and stops the
> features from feeling integrated.
>
> Assessment: this was the single highest-leverage decision in the
> project. Sprint 5's tutor matching was almost entirely a query and a
> formula — no new plumbing — because the messaging and reputation it
> needed already existed. Sprint 6's chat notifications reused the same
> notification pipeline as direct messages. Feature velocity in Sprints 5
> and 6 was noticeably faster than earlier sprints. Correct decision, and
> the biggest one."

### 4b. Bayesian-Prior Reputation (35 sec) — Section 6.3

> "Second — reputation uses a Bayesian-prior weighted mean, not a simple
> average.
>
> Simple averaging produces a pathology: a new user with one 5-star
> rating outranks a well-established user with fifty 4.9-star ratings.
> That's obviously wrong.
>
> The formula is: prior strength times the global mean, plus the sum of
> the user's stars, divided by prior strength plus their rating count —
> with a prior strength of eight and the global mean seeded at 4.0 and
> recomputed from real platform data. So a single 5-star rating lands you
> at about 4.1, not 5.0. Fifty ratings averaging 4.9 gets you about 4.8.
> The prior fades as real data accumulates.
>
> Assessment: correct decision, a handful of lines of code, and direct
> evidence of competency 5.2 — applying mathematical modeling to a
> real-world problem. The same neutral-prior idea also solved tutor
> cold-start: new tutors get the pool median for responsiveness instead
> of being buried at zero."

### 4c. Content-Moderation Gate on Images (30 sec) — Section 6.4

> "Third — every uploaded image passes through a moderation gate before
> it's publicly visible. Images are created in a 'pending' state and only
> flip to approved after the moderation provider clears them — the
> listing flow never blocks on a rejected image reaching the public.
>
> The provider sits behind an interface: in the MVP it's a stub that
> clears images at upload time, and the design moves the real provider
> call to a background worker in production, so a three-photo listing
> never freezes the Publish button while a third-party API thinks.
>
> Assessment: the gate pattern was cheap to build now and is exactly
> what a real deployment needs — swapping in a real provider is a
> configuration change, not a redesign."

### 4d. Moderation UX: Tombstones + Mandatory Reasons (30 sec) — Section 6.6

> "Fourth — chat moderation. Deleted messages leave a visible tombstone —
> 'Removed by moderator', with the moderator's name and the written
> reason — rather than vanishing. Deleting and muting both require a
> written reason, and every action is written to an audit log.
>
> The alternative — silent moderation — is easier for moderators but
> leaves other participants confused and sanctioned members with no
> explanation.
>
> Assessment: validated by usability testing — testers preferred the
> tombstones — and aligned with how mature platforms like Discord, Slack,
> and GitHub handle moderation. Correct decision."

---

## PART 5 — RECOMMENDATIONS FOR STG-452 (60 sec)

**Open:** MVP Final Report → Section 7.

> "Two recommendations for continued development in STG-452."

### 5a. WebSockets (25 sec) — Section 7.1

> "First — replace the polling-based messaging with WebSockets. The
> current system polls on a five-second interval in open conversations
> and fifteen seconds for the notification bell. That feels
> near-real-time, but it has a bounded worst-case latency and it costs
> requests even when nothing is happening.
>
> A WebSocket implementation would deliver messages in under half a
> second and cut idle server load. The groundwork exists — the transport
> sits behind a provider so it can swap without UI changes. Self-contained
> project, two to three sprints. Success criteria: sub-500-millisecond
> delivery and live badge updates."

### 5b. Real Pilot (30 sec) — Section 7.2

> "Second — pilot deployment at a real institution. The MVP works
> technically, but it's only been tested with a handful of volunteers. A
> real pilot at one department or one dormitory — say 20 to 50 real users
> for two months — would surface issues artificial testing cannot: real
> moderation edge cases, real marketplace scam attempts, real chat
> dynamics with genuine social stakes.
>
> Import the real course catalog, instrument analytics for daily actives,
> listings per user, tutoring matches, chat activity, and reporting
> rates. Handle IRB and terms-of-service before starting. The findings
> directly inform the v2 roadmap."

---

## CLOSING (20 sec)

**Open:** MVP Final Report title page.

> "That's the MVP demo, the problem framing, the process, the design
> decisions, and the STG-452 recommendations. Every artifact — Jira
> board, Confluence workspace, GitHub repo, live production URL, and this
> video — is linked on the title page of the final report. Thanks for
> watching, and thanks to the instructor for the guidance over the
> semester."

---

## Tab-switching cheat sheet

| Part | Open |
|------|------|
| Opening | MVP Report title page |
| 1a Marketplace | Live app (Ava) → Window 2 (Ben) briefly |
| 1b Tutoring | Live app (Ava) |
| 1c Chats + bell | Live app (Ava) |
| 1d Recap | Live app home |
| 2 Problem | MVP Report Section 2 |
| 3 Process | Jira → Confluence Home → GitHub |
| 4a–4d | MVP Report Sections 6.2 / 6.3 / 6.4 / 6.6 |
| 5a–5b | MVP Report Sections 7.1 / 7.2 |
| Closing | MVP Report title page |

---

## What changed vs. your draft (so you don't say something untrue)

1. **Type `CS250`, not `CS 250`** — everywhere (tutor search AND the
   marketplace search demo).
2. **Reason strings** are "Top-rated for CS250" / "Took CS250 fall · A" —
   there is **no "Fast to respond" label**. Don't quote it.
3. **No tutor-profile click-through / reviews section** — the card itself
   carries reputation, term, grade. Narrate from the card, then click
   Message.
4. **Message latency is ~5 seconds** (5s polling), not "about 3 seconds".
   Say "within a few seconds — the app polls on a five-second interval."
5. **Bayesian numbers corrected**: prior strength **8**, global mean
   seeded **4.0** (recomputed from platform data) — not 3.5/5. One 5★ →
   **~4.1** (not 3.75); fifty 4.9★ → **~4.8**.
6. **Chat directory has no browse-by-type filters** — say "a directory of
   discoverable groups", not "browse by type — courses, majors, dorms".
7. **No member list UI in the chat room** — show the thread and the
   tombstone instead.
8. **Ban reason is optional** — say "deletion and muting require a
   written reason" (don't say all three are mandatory).
9. **Notification types are: chat mentions, chat messages, and DMs** — do
   NOT claim "listing interest" or "tutoring requests" notifications.
10. **Image moderation is not async in the MVP** — reframed 4c as a
    "moderation gate + provider interface" decision (pending→approved
    status, stub inline now, background worker as the documented
    production path). Don't claim "1–3 seconds per image" measurements or
    that the async pattern shipped for chat attachments.
11. **Polling is a fixed 5s/15s**, not "adaptive 3s active / 30s
    background" — 5a reworded accordingly.
12. **Infrastructure**: frontend on Vercel; backend is FastAPI +
    PostgreSQL + Redis + S3-compatible storage. Don't name Render or "managed
    database" — just don't specify hosting for the backend.
13. **Sprint 6 wording**: it shipped chat messaging, **moderation**, and
    notifications (moderation landed in 6, not 7).
14. The **60-min dedup line now points at a real on-screen artifact**
    ("Ben and 1 more message in CS250 Study Group") and the @mention
    deep-link is a live beat — strongest 15 seconds of the demo, don't
    cut it.
