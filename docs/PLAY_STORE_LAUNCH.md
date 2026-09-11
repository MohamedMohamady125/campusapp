# CampusConnect — Google Play Launch Guide

Everything needed to publish the Android app. The signed release artifact is
already built and verified; the rest is account setup and copy-paste forms that
only you can complete in a browser with your Google account.

---

## 0. Status — what's done vs. what you do

**Done (in this repo):**
- Upload keystore generated: `apps/mobile/android/upload-keystore.jks` (gitignored).
- Signing wired: `apps/mobile/android/app/build.gradle.kts` signs release builds
  with the upload key via `key.properties` (gitignored).
- `INTERNET` permission added (release builds need it explicitly).
- Signed release **AAB** built and verified (signed with `CN=CampusConnect`, not debug):
  - `apps/mobile/build/app/outputs/bundle/release/app-release.aab`
- Privacy policy page published with the web build: `apps/mobile/web/privacy.html`
  → hosted at `https://campusconnect-lake.vercel.app/privacy.html` after the next web deploy.

**You must do (browser, ~1–2 hrs first time):**
1. Create a Google Play Developer account (one-time **$25**, needs a Google account + payment card).
2. Create the app in Play Console and upload `app-release.aab` (start with **Internal testing**).
3. Fill the store listing, Data Safety, content rating, and required declarations (copy-paste below).

> ⚠️ **BACK UP THE KEYSTORE.** If `upload-keystore.jks` or its password is lost you can
> never ship an update under the same app again. Store both in a password manager.
> - Keystore: `apps/mobile/android/upload-keystore.jks`
> - Store/key password: `kQKNQ5e8skoIaljt8ZKw`
> - Key alias: `upload`

---

## 1. App identity (permanent once published)

| Field | Value |
|---|---|
| App name | CampusConnect |
| Package name (applicationId) | `edu.campus.campusconnect` |
| Version | `1.0.0` (versionCode `3`) |
| Category | Social (or Education) |
| Default language | English (United States) |

> `applicationId` and the signing key are **permanent** for the life of the listing.
> If you'd prefer a different package id (e.g. `app.campusconnect.mobile`), change it
> **before** the first upload — tell me and I'll update it.

---

## 2. Store listing (copy-paste)

**App name (max 30):**
```
CampusConnect
```

**Short description (max 80):**
```
Buy, sell, tutor, chat, and run food — with verified students on your campus.
```

**Full description (max 4000):**
```
CampusConnect is the trust-first app for your campus. Every account is a
verified student, so you're always dealing with a real peer — never an
anonymous stranger.

One identity. One reputation. Everything you do on campus, in one place:

• MARKETPLACE — Buy and sell textbooks, furniture, electronics, and tickets
  with students down the hall. Snap a photo, set a price, post in seconds.

• PEER TUTORING — Find students who aced the course you're taking. Search by
  course code, see ranked matches by reputation, and message the best fit.

• COMMUNITY CHATS — Join topic, major, and interest group chats. Moderated,
  on-campus, and spam-free.

• FOOD RUNS — Heading to the dining hall or a coffee spot? Post a run and take
  orders, or join someone else's and get your order delivered. Follow the
  runner live and settle up off-app.

• REPUTATION THAT TRAVELS — Ratings you earn selling carry into tutoring and
  chats, so good actors are easy to trust.

Built for speed and safety: verified .edu identity, reporting and moderation
tools, and a clean, fast, native experience designed for life between classes.

CampusConnect keeps the core free and never sells your data.
```

**Contact email:** a real address you monitor (replace the placeholder
`support@campusconnect.app` in `privacy.html` with the same one).

**Privacy policy URL:**
```
https://campusconnect-lake.vercel.app/privacy.html
```

### Graphics you must upload (Play requirements)
| Asset | Spec | Notes |
|---|---|---|
| App icon | 512×512 PNG, 32-bit | Reuse the launcher icon art. |
| Feature graphic | 1024×500 PNG/JPG | Banner shown at top of listing. Required. |
| Phone screenshots | 2–8 images, PNG/JPG, 16:9 or 9:16, min 320px | Use the renovated Feed, Run detail, Create run, Rating, Profile screens. |

> You can capture phone screenshots from the running app or an emulator.
> I can help generate a feature graphic and grab screenshots if you want.

---

## 3. Data Safety form (answers)

In Play Console → **App content → Data safety**. Declare accurately:

**Does your app collect or share user data?** → **Yes**

| Data type | Collected | Shared | Purpose | Optional? |
|---|---|---|---|---|
| Email address | Yes | No | Account management | Required |
| Name (display name) | Yes | No | Account management, App functionality | Required |
| User content: photos | Yes | No | App functionality | Optional |
| User content: messages/other | Yes | No | App functionality | Required for the feature |
| Location: approximate | Yes | No | App functionality (live food-run tracking) | Optional |
| Location: precise | Yes | No | App functionality (live food-run tracking) | Optional |
| App activity / other user-generated content | Yes | No | App functionality | Required for the feature |
| Crash logs / diagnostics | Yes | No | Analytics, App functionality | Optional |

**Security practices:**
- Data is encrypted in transit → **Yes**.
- Users can request data deletion → **Yes** (via the contact email; see privacy policy).

> Location is **foreground-only** and used solely to show live runner progress
> during an active food run. Do **not** declare background location — the app
> does not request it (manifest has only `ACCESS_FINE_LOCATION` /
> `ACCESS_COARSE_LOCATION`, no `ACCESS_BACKGROUND_LOCATION`).

---

## 4. Other required declarations
- **Content rating questionnaire** → complete honestly. With user-to-user chat/
  messaging present, expect a Teen (or higher) rating; declare "Users can
  interact / share user-generated content."
- **Target audience & content** → 18+ or 13+ (students); not directed to children.
- **Ads** → No (the app shows no ads).
- **Government app** → No.
- **Financial features** → No in-app payments (food-run settle-up is off-app; no
  Play Billing). Declare no payments.
- **Permissions** → location usage is explained by the food-run feature; be ready
  to justify it in the review notes if asked.

---

## 5. Play Console walkthrough

1. **Create the developer account** — https://play.google.com/console/signup →
   sign in with your Google account → pay the one-time $25 → verify identity
   (Google may take a little while to approve).
2. **Create app** — Play Console → *Create app* → name `CampusConnect`, default
   language English (US), type **App**, **Free**. Accept the declarations.
3. **Set up → App content** — work through each required section: Privacy policy
   URL, Data safety (§3), Content rating, Target audience, Ads, News app, etc.
4. **Store listing** — paste the copy from §2, upload icon + feature graphic +
   screenshots.
5. **Upload the build** — Start with **Testing → Internal testing** (fastest, no
   full review): *Create new release* → upload
   `apps/mobile/build/app/outputs/bundle/release/app-release.aab` →
   accept **Play App Signing** (Google manages the app signing key; your upload
   key just signs uploads) → add release notes → **Save → Review → Roll out**.
6. **Add testers** — add your own email + a few students to the internal test
   track, share the opt-in link, install from Play, verify login against the
   live API works.
7. **Promote to Production** — once internal testing looks good: *Production →
   Create release* → reuse the same AAB → submit for review. First review can
   take a few days; plan for that inside your 2-week window.

---

## 6. Rebuilding the AAB (for future updates)

Bump the version in `apps/mobile/pubspec.yaml` (e.g. `1.0.1+4` — versionCode must
increase every upload), then:

```bash
cd apps/mobile
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://campusconnect-api-production.up.railway.app
```

Output: `build/app/outputs/bundle/release/app-release.aab`.

> Note: the build prints "failed to strip debug symbols from native libraries" —
> this is a harmless Flutter tooling warning; the AAB is still produced and
> correctly signed with the upload key. Verify with:
> `jarsigner -verify -certs build/app/outputs/bundle/release/app-release.aab`
