# Trot — Google Play Launch Guide

Everything needed to publish the Android app under the **Trot** name. The signed
release artifact is already built and verified; the rest is account setup and
copy-paste forms that only you can complete in a browser with your Google account.

> **Launch scope:** Trot ships **runs-first** — the Food Runs feed is the home
> tab and the only live feature set (plus Profile, in-run messaging, ratings).
> Marketplace, Tutoring, and Chats exist in the code but are **flag-gated OFF**
> for launch. The store listing below describes **only food runs** on purpose —
> stores can reject a listing that advertises features a reviewer can't see.

---

## 0. Status — what's done vs. what you do

**Done (in this repo):**
- App display name is **Trot** (`android:label="Trot"` in `AndroidManifest.xml`).
- Launcher icons regenerated from `docs/brand/logo/icon-master.svg` (coral square,
  cream `t` + charcoal drop-off dot) across all 5 densities.
- Upload keystore generated: `apps/mobile/android/upload-keystore.jks` (gitignored).
- Signing wired: `apps/mobile/android/app/build.gradle.kts` signs release builds
  with the upload key via `key.properties` (gitignored).
- `INTERNET` + foreground-only location permissions in the manifest.
- Privacy policy page rebranded to Trot: `apps/mobile/web/privacy.html`
  → hosted at `https://campusconnect-lake.vercel.app/privacy.html` after the next web deploy.

**You must do (browser, ~1–2 hrs first time):**
1. Create a Google Play Developer account (one-time **$25**, needs a Google account + payment card).
2. Create the app in Play Console and upload a fresh **AAB** (start with **Internal testing**).
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
| App name | **Trot** |
| Package name (applicationId) | `edu.campus.campusconnect` |
| Version | `1.0.0` (versionCode `10`) |
| Category | Food & Drink (alt: Maps & Navigation) |
| Default language | English (United States) |

> The **public name** ("Trot") is independent of the `applicationId`. The package
> id `edu.campus.campusconnect` is an internal identifier users never see — it is
> **permanent** for the life of the listing, so leaving it as-is is fine. The
> signing key is also permanent. (If you ever want a `trot`-branded package id,
> it must change **before** the first upload — tell me and I'll update it.)

---

## 2. Store listing (copy-paste)

**App name (max 30):**
```
Trot
```

**Short description (max 80):**
```
Get food trotted over by a fellow student — or earn by running one yourself.
```

**Full description (max 4000):**
```
Trot is peer-to-peer food delivery for your campus. Someone's already heading
to the dining hall or the coffee spot — Trot lets them bring your order along
for a small tip. No fleet of strangers, no delivery-giant fees. Just students
helping students, between classes.

HOW IT WORKS
• Post a request — tell Trot what you want and where you are.
• Or join a run — heading out anyway? Pick up a few orders on the way and earn.
• Follow along live — watch your runner approach in real time.
• Settle up simply — tips are arranged directly between you and the runner.

WHY STUDENTS USE TROT
• VERIFIED PEERS ONLY — every account is a verified student with a campus email.
  You're always dealing with a real classmate, never an anonymous stranger.
• REPUTATION YOU CAN TRUST — runners and requesters build a star rating over
  time, so good actors are easy to spot.
• FAST AND LIGHT — a clean, native app built for life between classes. Post or
  join a run in seconds.
• BUILT-IN MESSAGING — coordinate the hand-off without sharing your number.

Trot is launching at Grand Canyon University. Keep the core free, keep it
student-to-student, and never sell your data.

Food, trotted over by a fellow student.
```

**Contact email:** a real address you monitor. Replace the placeholder
`support@campusconnect.app` in `privacy.html` with the same address before deploy.

**Privacy policy URL:**
```
https://campusconnect-lake.vercel.app/privacy.html
```

### Graphics you must upload (Play requirements)
| Asset | Spec | Notes |
|---|---|---|
| App icon | 512×512 PNG, 32-bit | Reuse the Trot launcher art (`docs/brand/logo/icon-master.svg` → export at 512). |
| Feature graphic | 1024×500 PNG/JPG | Banner at top of listing. Required. Coral field + `trot` wordmark works well. |
| Phone screenshots | 2–8 images, PNG/JPG, 9:16, min 320px | Runs feed, Run detail (live track), Create run, Rating, Profile. |

> I can generate the feature graphic from the brand kit and help capture
> screenshots from an emulator if you want — just ask.

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
- **Content rating questionnaire** → complete honestly. With user-to-user
  messaging present, declare "Users can interact / communicate" — expect a Teen
  (or higher) rating.
- **Target audience & content** → 18+ or 13+ (students); not directed to children.
- **Ads** → No (the app shows no ads).
- **Government app** → No.
- **Financial features** → No in-app payments (food-run tips are settled directly
  between users off-app; no Play Billing). Declare no payments.
- **Permissions** → foreground location is explained by the live food-run tracking
  feature; be ready to justify it in the review notes if asked.

---

## 5. Play Console walkthrough

1. **Create the developer account** — https://play.google.com/console/signup →
   sign in → pay the one-time $25 → verify identity (Google approval can take time).
2. **Create app** — Play Console → *Create app* → name **Trot**, default language
   English (US), type **App**, **Free**. Accept the declarations.
3. **Set up → App content** — work through each required section: Privacy policy
   URL, Data safety (§3), Content rating, Target audience, Ads, etc.
4. **Store listing** — paste the copy from §2, upload icon + feature graphic +
   screenshots.
5. **Upload the build** — Start with **Testing → Internal testing** (fastest, no
   full review): *Create new release* → upload the AAB (build it per §6) →
   accept **Play App Signing** → add release notes → **Save → Review → Roll out**.
6. **Add testers** — add your email + a few students to the internal track, share
   the opt-in link, install from Play, verify login against the live API works.
7. **Promote to Production** — once internal testing looks good: *Production →
   Create release* → reuse the same AAB → submit for review. First review can
   take a few days; plan for that inside your window.

**First-release release notes (copy-paste):**
```
Trot is live at GCU. Get food trotted over by a fellow student, or earn by
running one yourself. Verified students only.
```

---

## 6. Building the AAB (do this before upload)

The checked-in artifact may be stale (old name/version). Build a fresh signed AAB:

```bash
cd apps/mobile
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://campusconnect-api-production.up.railway.app
```

Output: `build/app/outputs/bundle/release/app-release.aab`.

Verify it's signed with your upload key (not debug):
```bash
jarsigner -verify -certs build/app/outputs/bundle/release/app-release.aab
```

For every future update, bump `version:` in `apps/mobile/pubspec.yaml`
(e.g. `1.0.1+11` — the `+NN` versionCode must increase on every upload) and rebuild.

> The build prints "failed to strip debug symbols from native libraries" — a
> harmless Flutter tooling warning; the AAB is still produced and correctly signed.
