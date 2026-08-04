import 'dart:ui' show lerpDouble;

import 'package:campusconnect/design_system/material.dart';

/// Design tokens (whole.md §3.2): semantic colors ColorScheme has no slot
/// for, plus the spacing and radius scales. Registered as a [ThemeExtension]
/// on both themes; access via `context.tokens`.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.verified,
    required this.onVerified,
    required this.success,
    required this.warning,
    required this.warningContainer,
    required this.ratingStar,
    required this.online,
    this.space1 = 4,
    this.space2 = 8,
    this.space3 = 12,
    this.space4 = 16,
    this.space5 = 20,
    this.space6 = 24,
    this.space8 = 32,
    this.space12 = 48,
    this.radiusXs = 4,
    this.radiusSm = 10,
    this.radiusMd = 12,
    this.radiusLg = 16,
  });

  final Color verified;
  final Color onVerified;
  final Color success;
  final Color warning;
  final Color warningContainer;
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

  BorderRadius get brSm => BorderRadius.circular(radiusSm);
  BorderRadius get brMd => BorderRadius.circular(radiusMd);
  BorderRadius get brLg => BorderRadius.circular(radiusLg);

  static const darkTokens = AppTokens(
    verified: Color(0xFF3DD9A0),
    onVerified: Color(0xFF00382A),
    success: Color(0xFF3DD9A0),
    warning: Color(0xFFF5BF54),
    warningContainer: Color(0xFF5C3D00),
    ratingStar: Color(0xFFF5C451),
    online: Color(0xFF3DD9A0),
  );

  static const lightTokens = AppTokens(
    verified: Color(0xFF12805C),
    onVerified: Color(0xFFFFFFFF),
    success: Color(0xFF12805C),
    warning: Color(0xFF8A5A00),
    warningContainer: Color(0xFFFFEDCB),
    ratingStar: Color(0xFFC9930A),
    online: Color(0xFF12805C),
  );

  @override
  AppTokens copyWith({
    Color? verified,
    Color? onVerified,
    Color? success,
    Color? warning,
    Color? warningContainer,
    Color? ratingStar,
    Color? online,
  }) => AppTokens(
    verified: verified ?? this.verified,
    onVerified: onVerified ?? this.onVerified,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    warningContainer: warningContainer ?? this.warningContainer,
    ratingStar: ratingStar ?? this.ratingStar,
    online: online ?? this.online,
  );

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      verified: Color.lerp(verified, other.verified, t)!,
      onVerified: Color.lerp(onVerified, other.onVerified, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
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
    );
  }
}

/// Ergonomic access. Use `context.tokens.space4`, never the raw generic.
extension AppTokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}
