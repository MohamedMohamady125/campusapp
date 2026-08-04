/// Legacy token constants — being migrated to `design_system/theme/`.
///
/// The app theme now lives in `design_system/theme/app_theme.dart` and
/// semantic tokens in `design_system/theme/app_tokens.dart` (use
/// `context.tokens`). These constants remain only for feature files that
/// have not yet been migrated; do not add new usages.
library;

import 'package:campusconnect/design_system/material.dart';

/// 4dp base spacing grid (spec §7.3).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Radius scale (spec §7.1 — cards are 12, everywhere).
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 16;
  static const double pill = 28;
}

/// Motion tokens (spec §8) — exits faster than entrances.
abstract final class AppMotion {
  static const Duration press = Durations.short2; // 100ms
  static const Duration release = Durations.short4; // 200ms
  static const Duration entrance = Durations.medium2; // 300ms
  static const Duration stagger = Duration(milliseconds: 35);
  static const Curve decelerate = Easing.emphasizedDecelerate;
  static const Curve emphasized = Easing.standard;
}
