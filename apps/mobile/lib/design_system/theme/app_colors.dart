import 'package:campusconnect/design_system/material.dart';

/// Trot palette — warm cream, charcoal ink, ONE coral accent.
///
/// From docs/TROT_LOGO_BRIEF.md: warm off-white cream canvas (#F7F3EC),
/// near-black charcoal ink (#1C1B19), a single bold coral-orange accent
/// (#F0532E), and soft warm grays. One accent only — no rainbow. All
/// neutrals are WARM (brown-leaning), never cool blue-grays.
///
/// WCAG notes (measured): white-on-coral is 3.10 (FAILS AA) so coral CTAs
/// use INK text (5.56 PASS). Coral itself is too light for link text on
/// cream, so links/pressed use [primaryDark] #C8371D (4.7–5.2 PASS).
/// Destructive is a distinct true red #D92D20 so errors never read as brand.
abstract final class AppColors {
  // Primary — Trot coral.
  static const primary = Color(0xFFF0532E);
  static const primaryDark = Color(0xFFC8371D); // pressed states, link text
  static const primaryLight = Color(0xFFFF7A5F);
  static const primaryBg = Color(0xFFFFEDE8); // tinted chip/selected fills
  static const primaryBorder = Color(0xFFFFD7CC);
  static const primaryMuted = Color(0xFFFFE1D9);
  static const primaryDisabled = Color(0xFFFFB4A4); // disabled CTA fill
  static const primaryAccent = Color(0xFFFF8268);

  // Ink — charcoal for hero text, snackbars, emphasis, CTA labels.
  static const ink = Color(0xFF1C1B19);
  static const inkSoft = Color(0xFF2A2825);

  // Backgrounds / surfaces.
  /// App canvas — pure white (user decision, overrides the brief's cream
  /// base). Cream survives as subtle warm panels/input fills; depth comes
  /// from hairline borders, never a tinted background.
  static const canvas = Color(0xFFFFFFFF);
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFF6F2EA); // input fills, subtle panels
  static const surfaceAlt = Color(0xFFF0EBE2); // skeletons, avatar circles

  // Text — warm charcoal ramp.
  static const textPrimary = Color(0xFF1F1D1A);
  static const textDark = Color(0xFF1C1B19);
  static const textHeading = Color(0xFF211F1B);
  static const textSecondary = Color(0xFF6F6A62);
  static const textTertiary = Color(0xFF9A948A);
  static const textQuaternary = Color(0xFFA8A297);
  static const textMuted = Color(0xFFC7C1B5);
  static const textHint = Color(0xFFD6D0C4);

  // Borders — hairline, warm, barely-there.
  static const border = Color(0xFFEFEAE1); // default card border
  static const borderLight = Color(0xFFF4F0E7);
  static const borderMedium = Color(0xFFE5DFD4); // outlined buttons

  // Status.
  static const error = Color(0xFFD92D20); // destructive — true red, not coral
  static const errorDark = Color(0xFFB42318);
  static const errorBg = Color(0xFFFDEBE9);
  static const errorBorder = Color(0xFFF6C8C2);
  static const success = Color(0xFF10B981);
  static const successDark = Color(0xFF059669);
  static const warning = Color(0xFFFFB700);
  static const warningDark = Color(0xFFB45309); // text-grade amber (AA on tint)
  static const rose = Color(0xFFF43F5E);

  // Accents — category/role color-coding ONLY, never general UI.
  static const purple = Color(0xFF8B5CF6);
  static const cyan = Color(0xFF06B6D4);
  static const cyanDark = Color(0xFF0891B2);
  static const teal = Color(0xFF0EA5E9);
  static const amber = Color(0xFFF5A623);
  static const whatsapp = Color(0xFF25D366);

  /// Trot mapped onto Material roles. Cream canvas, white cards, hairline
  /// warm borders; ink on inverse slots (snackbars/toasts). Coral CTAs carry
  /// INK labels via [ColorScheme.onPrimary] (white fails AA on coral).
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: ink,
    primaryContainer: primaryBg,
    onPrimaryContainer: primaryDark,
    secondary: textSecondary,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: surfaceAlt,
    onSecondaryContainer: textHeading,
    tertiary: success,
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD7F5EA),
    onTertiaryContainer: successDark,
    error: error,
    onError: Color(0xFFFFFFFF),
    errorContainer: errorBg,
    onErrorContainer: errorDark,
    surface: surface,
    onSurface: textPrimary,
    onSurfaceVariant: textSecondary,
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: surfaceLight,
    surfaceContainer: surfaceAlt,
    surfaceContainerHigh: surfaceAlt,
    surfaceContainerHighest: Color(0xFFEAE4D9),
    surfaceDim: surfaceAlt,
    surfaceBright: Color(0xFFFFFFFF),
    outline: borderMedium,
    outlineVariant: border,
    inverseSurface: ink,
    onInverseSurface: Color(0xFFFFFFFF),
    inversePrimary: primaryMuted,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Colors.transparent,
  );

  /// Dark scheme — warm charcoal neutrals, lighter coral accent
  /// (selected via the Appearance picker or the OS setting).
  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryAccent,
    onPrimary: Color(0xFF1C1B19),
    primaryContainer: primaryDark,
    onPrimaryContainer: primaryBg,
    secondary: Color(0xFFB3ADA3),
    onSecondary: Color(0xFF1A1813),
    secondaryContainer: Color(0xFF2A2823),
    onSecondaryContainer: Color(0xFFECE7DE),
    tertiary: success,
    onTertiary: Color(0xFF00382A),
    tertiaryContainer: Color(0xFF00513C),
    onTertiaryContainer: Color(0xFFB7F2D8),
    error: Color(0xFFFF8A7A),
    onError: Color(0xFF3A0A0A),
    errorContainer: Color(0xFF6E1F1F),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: ink,
    onSurface: Color(0xFFF5F3EF),
    onSurfaceVariant: Color(0xFFA8A297),
    surfaceContainerLowest: Color(0xFF121110),
    surfaceContainerLow: Color(0xFF242220),
    surfaceContainer: Color(0xFF2A2825),
    surfaceContainerHigh: Color(0xFF32302C),
    surfaceContainerHighest: Color(0xFF3A3733),
    surfaceDim: ink,
    surfaceBright: Color(0xFF444039),
    outline: Color(0xFF4E4A43),
    outlineVariant: Color(0xFF363330),
    inverseSurface: Color(0xFFF5F3EF),
    onInverseSurface: Color(0xFF242220),
    inversePrimary: primary,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Colors.transparent,
  );
}

/// Subtle shadows — reserved for floating elements only (sheets, thumbs).
abstract final class AppShadows {
  static const sm = [
    BoxShadow(
      color: Color(0x0A000000), // black 4%
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
  static const md = [
    BoxShadow(
      color: Color(0x0D000000), // black 5%
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];
  static const lg = [
    BoxShadow(
      color: Color(0x0F000000), // black 6%
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
  static const xl = [
    BoxShadow(
      color: Color(0x1F000000), // black 12%
      blurRadius: 30,
      offset: Offset(0, 12),
    ),
  ];

  /// Under hero coral CTAs only.
  static const primaryGlow = [
    BoxShadow(
      color: Color(0x47F0532E), // primary @ 28%
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
