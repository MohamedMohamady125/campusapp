# Trot push notifications — what's built & the 3 keys a human must plug in

## What already works (no keys needed)

- **Server**: `device_tokens` table + `POST /api/v1/notifications/devices` /
  `/devices/remove`; push fires from the same dedup pipeline as the in-app
  feed (`app/services/push_dispatch.py`), so **a notification that folds into
  an existing unread one never re-pushes** — at most one interruption per
  context per hour. Per-type opt-outs (`notification_preferences`) apply to
  push automatically. Stub provider in dev/test; `FcmPushProvider` activates
  the moment `FCM_SERVICE_ACCOUNT_JSON` is set.
- **App**: `PushService` (lib/core/push/push_service.dart) registers the FCM
  token after login, re-registers on rotation, unregisters on logout, and
  deep-links a tapped banner to the run/thread. It silently no-ops until
  Firebase config files exist — every build stays green.
- **Live Activity**: Dart side done (`run_live_activity.dart`, synced from the
  run-detail controller); Swift widget ready in
  `apps/mobile/ios/TrotRunActivity/TrotRunActivity.swift`.

## Push policy (who gets interrupted, and when)

| Event | Pushed to | Notes |
|---|---|---|
| `run_request` | runner | collapses per run; 2nd requester in <60min folds, no re-push |
| `run_request_accepted` / `declined` | requester | per order |
| `run_status` at_store / delivering / cancelled | accepted requesters | collapse key `run:<id>` — newer replaces older banner |
| `run_runner_arrived` | that requester | **time-sensitive** (breaks Focus) — 5-min window |
| `run_completed` | requesters | rate prompt |
| `run_payment_submitted` | runner | money copy stays loud |
| `run_payment_confirmed` | requester | |
| `dm_message` | recipient | collapses per conversation |
| `chat_mention` | mentioned user | |
| `chat_message` | **nobody** | room chatter is feed-only (anti-spam) |

## Step 1 — Firebase project (~15 min, covers iOS + Android)

1. console.firebase.google.com → create project **Trot** (Analytics off).
2. Add an **iOS app** with bundle id `edu.campus.campusconnect` → download
   `GoogleService-Info.plist` → drop into `apps/mobile/ios/Runner/` (add to
   the Runner target in Xcode, "Copy if needed").
3. Add an **Android app** (`edu.campus.campusconnect`) → download
   `google-services.json` → `apps/mobile/android/app/`; then in
   `android/settings.gradle` plugins add
   `id "com.google.gms.google-services" version "4.4.2" apply false` and in
   `android/app/build.gradle` plugins add `id "com.google.gms.google-services"`.
4. Project settings → Cloud Messaging → **APNs auth key**: create a key in
   developer.apple.com (Keys → + → Apple Push Notifications service), upload
   the `.p8` with Key ID + Team ID.
5. In Xcode, Runner target → Signing & Capabilities → **+ Push
   Notifications** and **+ Background Modes → Remote notifications**.

## Step 2 — API env (Railway)

Project settings → Service Accounts → **Generate new private key** → minify
the JSON to one line and set on the API service:

```
railway variables --service campusconnect-api --set 'FCM_SERVICE_ACCOUNT_JSON={...one-line json...}'
```

That alone flips the backend from stub to real FCM. Nothing to redeploy
beyond the variable restart.

## Step 3 — Live Activity widget target (~10 min, Xcode)

1. Xcode → File → New → Target → **Widget Extension**, name it exactly
   `TrotRunActivity`, uncheck "Include Configuration App Intent",
   check **Include Live Activity**.
2. Delete the template .swift files; add
   `ios/TrotRunActivity/TrotRunActivity.swift` to the new target.
3. Add the **App Groups** capability to BOTH Runner and TrotRunActivity with
   id `group.edu.campus.campusconnect.liveactivities` (must match
   `kRunLiveActivityAppGroup` in run_live_activity.dart).
4. In `ios/Runner/Info.plist` add `NSSupportsLiveActivities` = YES.
5. Widget target deployment: iOS 16.1+.

After this, a requester whose order is accepted sees the Trot tracker on the
lock screen / Dynamic Island: progress rail (heading → at store → on the way
→ arrived) and the live 5-minute pickup countdown once the runner arrives.

## Phase 2 (later, optional)

- **Push-to-update Live Activity** when the app is killed: store each
  activity's ActivityKit push token server-side and send APNs
  `liveactivity` events (needs a raw APNs adapter with the same `.p8` key).
- **Push-to-start** (iOS 17.2+): start the tracker from the accept event even
  if the requester never opened the run.
