# Motion & micro-interaction system

CampusConnect treats motion as **feedback, not decoration**. Every animated
surface draws its timing and curves from a single module —
`apps/mobile/lib/design_system/theme/app_motion.dart` (`AppMotion`) — so the
whole product moves with one deliberate physical language, and so the timing is
auditable against research rather than hand-tuned per screen.

## Why (the research)

- **Nielsen's response-time limits (NN/g).** ~0.1s (100ms) reads as
  *instantaneous* — the outcome feels caused by the user, which is what makes
  direct manipulation feel direct. ~1s keeps the user's flow of thought
  unbroken. So press feedback lives at/under 100ms and no routine transition
  approaches 1s.
  <https://www.nngroup.com/articles/response-times-3-important-limits/>
- **Doherty Threshold (Doherty & Thadani, IBM, 1982).** Keep the interaction
  round-trip under ~400ms and users stay in flow and perceive the product more
  positively. Our interactive motion sits well under this; only large-surface
  entrances reach 500ms. <https://lawsofux.com/doherty-threshold/>
- **Material 3 motion tokens.** We alias Flutter's built-in `Durations` and
  `Easing` classes (the M3 spec values Google tuned) instead of inventing our
  own curves. <https://m3.material.io/styles/motion/easing-and-duration/tokens-specs>
- **Fitts's & Hick's laws.** Swipe accelerators are *additive* — the tap
  targets they sit on remain the primary, discoverable path. A swipe is faster
  for the power user; a labelled button is discoverable for everyone.

## Accessibility — WCAG 2.3.3 (Animation from Interactions)

Every consumer of these tokens collapses motion when the OS "reduce motion"
setting is on. Use `AppMotion.resolve(context, duration)` (or check
`MediaQuery.disableAnimationsOf(context)`) so animations fall back to
`AppMotion.instant` (`Duration.zero`). `Pressable`, `FadeSlideIn`,
`SwipeAction`, and the skeleton shimmer all honour this.

## Tokens

| Token | Value | Role | Source |
|---|---|---|---|
| `AppMotion.instant` | 0ms | reduce-motion fallback | — |
| `AppMotion.feedback` | 100ms (`Durations.short2`) | press / release | Nielsen 0.1s |
| `AppMotion.micro` | 200ms (`Durations.short4`) | chips, counters, icon swaps | M3 |
| `AppMotion.enter` | 300ms (`Durations.medium2`) | element / list-item entrance | M3 |
| `AppMotion.screen` | 500ms (`Durations.long2`) | full-screen / large surface | M3, Doherty ceiling |
| `AppMotion.stagger` | 40ms | per-item list-entrance delay (index clamped to 10) | Doherty 400ms tail |
| `AppMotion.standard` | `Easing.standard` | default transitions | M3 |
| `AppMotion.emphasized` | `Curves.easeInOutCubicEmphasized` | expressive hero moments | M3 |
| `AppMotion.decelerate` | `Easing.emphasizedDecelerate` | elements arriving | M3 |
| `AppMotion.accelerate` | `Easing.emphasizedAccelerate` | elements leaving | M3 |

## Where it's applied

- **`Pressable`** (tappable cards/rows across every feature) — 100ms scale +
  opacity press feedback, `HapticFeedback.lightImpact` on tap.
- **`FadeSlideIn`** (list entrances across marketplace, tutoring, chats,
  messaging, notifications, food runs) — fade + 16px slide-up on the emphasized
  decelerate curve, staggered by `AppMotion.stagger`.
- **`SwipeAction`** (runner order cards) — swipe **right to accept**, **left to
  decline** a food-run request. Right = affirmative by convention. Haptics mark
  the two moments that matter: *arming* (crossing the commit threshold,
  `mediumImpact`) and *committing* (release past it, `selectionClick`). The
  Accept/Decline buttons remain, so this is a shortcut, never the only path.
- **Skeleton shimmer** — reduce-motion-aware loading placeholders that match the
  final layout shape (perceived-performance over bare spinners).
