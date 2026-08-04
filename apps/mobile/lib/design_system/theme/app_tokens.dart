import 'dart:ui' show lerpDouble;

import 'package:campusconnect/design_system/material.dart';

/// Design tokens (spec §5.4, §7): semantic colors ColorScheme has no slot
/// for, plus the spacing and radius scales. Registered as a [ThemeExtension]
/// on both themes; access via `context.tokens`.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    // Semantic colors
    required this.verified,
    required this.onVerified,
    required this.verifiedContainer,
    required this.success,
    required this.warning,
    required this.warningContainer,
    required this.price,
    required this.ratingStar,
    required this.online,
    // Spacing (4dp base grid, spec §7.3)
    this.space1 = 4,
    this.space2 = 8,
    this.space3 = 12,
    this.space4 = 16,
    this.space5 = 20,
    this.space6 = 24,
    this.space8 = 32,
    this.space12 = 48,
    // Radii (spec §7.1 — cards are radiusMd, everywhere)
    this.radiusXs = 4,
    this.radiusSm = 8,
    this.radiusMd = 12,
    this.radiusLg = 16,
    this.radiusXl = 28,
  });

  final Color verified;
  final Color onVerified;
  final Color verifiedContainer;
  final Color success;
  final Color warning;
  final Color warningContainer;
  final Color price;
  final Color ratingStar;
  final Color online;

  final double space1;
  final double space2;
  final double space3;
  final double space4;
  final double space5;
  final double space6;
  final double space8;
  final double space12;

  final double radiusXs;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;

  // Convenience shapes
  BorderRadius get brSm => BorderRadius.circular(radiusSm);
  BorderRadius get brMd => BorderRadius.circular(radiusMd);
  BorderRadius get brLg => BorderRadius.circular(radiusLg);

  static const light = AppTokens(
    verified: Color(0xFF0E6B4F),
    onVerified: Color(0xFFFFFFFF),
    verifiedContainer: Color(0xFFB7F2D8),
    success: Color(0xFF1B6C3A),
    warning: Color(0xFF8A5A00),
    warningContainer: Color(0xFFFFEDCB),
    price: Color(0xFF0F3D2E),
    ratingStar: Color(0xFFB8860B),
    online: Color(0xFF2E7D32),
  );

  static const dark = AppTokens(
    verified: Color(0xFF6FD9AE),
    onVerified: Color(0xFF00382A),
    verifiedContainer: Color(0xFF00513C),
    success: Color(0xFF7ADB9C),
    warning: Color(0xFFF5BF54),
    warningContainer: Color(0xFF5C3D00),
    price: Color(0xFFB8EFD4),
    ratingStar: Color(0xFFF2C94C),
    online: Color(0xFF81C995),
  );

  @override
  AppTokens copyWith({
    Color? verified,
    Color? onVerified,
    Color? verifiedContainer,
    Color? success,
    Color? warning,
    Color? warningContainer,
    Color? price,
    Color? ratingStar,
    Color? online,
  }) {
    return AppTokens(
      verified: verified ?? this.verified,
      onVerified: onVerified ?? this.onVerified,
      verifiedContainer: verifiedContainer ?? this.verifiedContainer,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      price: price ?? this.price,
      ratingStar: ratingStar ?? this.ratingStar,
      online: online ?? this.online,
      space1: space1,
      space2: space2,
      space3: space3,
      space4: space4,
      space5: space5,
      space6: space6,
      space8: space8,
      space12: space12,
      radiusXs: radiusXs,
      radiusSm: radiusSm,
      radiusMd: radiusMd,
      radiusLg: radiusLg,
      radiusXl: radiusXl,
    );
  }

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      verified: Color.lerp(verified, other.verified, t)!,
      onVerified: Color.lerp(onVerified, other.onVerified, t)!,
      verifiedContainer: Color.lerp(
        verifiedContainer,
        other.verifiedContainer,
        t,
      )!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      price: Color.lerp(price, other.price, t)!,
      ratingStar: Color.lerp(ratingStar, other.ratingStar, t)!,
      online: Color.lerp(online, other.online, t)!,
      space1: lerpDouble(space1, other.space1, t)!,
      space2: lerpDouble(space2, other.space2, t)!,
      space3: lerpDouble(space3, other.space3, t)!,
      space4: lerpDouble(space4, other.space4, t)!,
      space5: lerpDouble(space5, other.space5, t)!,
      space6: lerpDouble(space6, other.space6, t)!,
      space8: lerpDouble(space8, other.space8, t)!,
      space12: lerpDouble(space12, other.space12, t)!,
      radiusXs: lerpDouble(radiusXs, other.radiusXs, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusXl: lerpDouble(radiusXl, other.radiusXl, t)!,
    );
  }
}

/// Ergonomic access. Use `context.tokens.space4`, never the raw generic.
extension AppTokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}
