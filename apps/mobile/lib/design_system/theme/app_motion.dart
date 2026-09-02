import 'package:campusconnect/design_system/material.dart';

/// Central motion tokens for CampusConnect.
///
/// Motion here is feedback, not decoration. Every animated surface in the app
/// draws its timing and curve from this one module so the whole product moves
/// with a single, deliberate physical language. The values are grounded in
/// published interaction-design research:
///
/// * **Nielsen's response-time limits** (NN/g). 0.1s (100ms) reads as
///   *instantaneous* — the outcome feels caused by the user, which is what
///   makes direct manipulation feel direct. 1s keeps the user's flow of
///   thought unbroken. So press feedback lives at/under 100ms and no routine
///   transition approaches 1s.
///   https://www.nngroup.com/articles/response-times-3-important-limits/
/// * **Doherty Threshold** (Doherty & Thadani, IBM, 1982). Keep the
///   interaction round-trip under ~400ms and the user stays in flow and
///   perceives the product more positively. Our interactive motion is well
///   under this; only large-surface entrances reach 500ms.
///   https://lawsofux.com/doherty-threshold/
/// * **Material 3 motion** — easing + duration tokens. We alias Flutter's
///   built-in [Durations] and [Easing] (the M3 spec values Google tuned) so we
///   inherit those curves rather than inventing our own.
///   https://m3.material.io/styles/motion/easing-and-duration/tokens-specs
///
/// **WCAG 2.3.3 (Animation from Interactions).** Every consumer of these tokens
/// must collapse motion when the OS "reduce motion" setting is on. Use
/// [resolve] (or check `MediaQuery.disableAnimationsOf(context)`) so animations
/// fall back to [instant].
abstract final class AppMotion {
  // ---------------------------------------------------------------------------
  // Durations — aliased to Flutter's Material 3 `Durations` tokens.
  // ---------------------------------------------------------------------------

  /// No motion. The reduce-motion fallback for every token below.
  static const Duration instant = Duration.zero;

  /// Press / release feedback. ≤100ms reads as direct manipulation (Nielsen
  /// 0.1s "instantaneous" limit). M3 `Durations.short2`.
  static const Duration feedback = Durations.short2; // 100ms

  /// Small in-place state changes: status chips, counters, icon swaps,
  /// selection ticks. M3 `Durations.short4`.
  static const Duration micro = Durations.short4; // 200ms

  /// Standard element enter/exit and list-item entrance. M3 `Durations.medium2`.
  static const Duration enter = Durations.medium2; // 300ms

  /// Full-screen / large-surface transitions. M3 `Durations.long2` — still
  /// inside the 500ms comfort ceiling and far below Nielsen's 1s flow limit.
  static const Duration screen = Durations.long2; // 500ms

  /// Per-item delay for staggered list entrances. Small enough that a full
  /// screen settles well within the flow-of-thought window; clamp the index so
  /// long lists never crawl in. Ten steps × 40ms = 400ms tail (Doherty).
  static const Duration stagger = Duration(milliseconds: 40);

  // ---------------------------------------------------------------------------
  // Curves — aliased to Flutter's Material 3 `Easing` / emphasized curves.
  // ---------------------------------------------------------------------------

  /// Default curve for most transitions (M3 standard easing).
  static const Curve standard = Easing.standard;

  /// Expressive symmetric curve for elements that both grow and settle
  /// (M3 emphasized). Use for hero/large moments.
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;

  /// Elements entering the screen decelerate to rest (M3 emphasized
  /// decelerate) — the natural "arriving" feel.
  static const Curve decelerate = Easing.emphasizedDecelerate;

  /// Elements leaving the screen accelerate away (M3 emphasized accelerate).
  static const Curve accelerate = Easing.emphasizedAccelerate;

  // ---------------------------------------------------------------------------
  // Helpers.
  // ---------------------------------------------------------------------------

  /// Returns [d], or [instant] when the OS "reduce motion" accessibility
  /// setting is on (WCAG 2.3.3). Use for any duration handed to an implicit
  /// animation so motion honours the user's preference without extra branches.
  static Duration resolve(BuildContext context, Duration d) =>
      MediaQuery.disableAnimationsOf(context) ? instant : d;
}
