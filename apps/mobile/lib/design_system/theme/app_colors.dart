import 'package:campusconnect/design_system/material.dart';

/// Fifty Free palette — Robinhood-inspired fintech in brand blue.
///
/// Flat, white, airy: pure white surfaces, hairline borders, one accent
/// color (#144F86), near-black ink for contrast moments. Named tokens below
/// are the spec; the [light] ColorScheme maps them onto Material roles so
/// theme-driven widgets pick them up automatically.
abstract final class AppColors {
  // Primary — brand blue.
  static const primary = Color(0xFF144F86);
  static const primaryDark = Color(0xFF0F3D68); // pressed states, link text
  static const primaryLight = Color(0xFF2268A8);
  static const primaryBg = Color(0xFFEAF1F8); // tinted chip/selected fills
  static const primaryBorder = Color(0xFFD3E2EF);
  static const primaryMuted = Color(0xFFD9E7F2);
  static const primaryDisabled = Color(0xFF9EBCD8); // disabled CTA fill
  static const primaryAccent = Color(0xFF4A84B8);

  // Ink — near-black for hero CTAs, snackbars, emphasis.
  static const ink = Color(0xFF0B0D0E);
  static const inkSoft = Color(0xFF1C2124);

  // Backgrounds / surfaces.
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFF7F8F9); // input fills, subtle panels
  static const surfaceAlt = Color(0xFFF2F4F5); // skeletons, avatar circles

  // Text.
  static const textPrimary = Color(0xFF0F1112);
  static const textDark = Color(0xFF0B0D0E);
  static const textHeading = Color(0xFF14181B);
  static const textSecondary = Color(0xFF6F787D);
  static const textTertiary = Color(0xFF9AA3A8);
  static const textQuaternary = Color(0xFFA9B1B6);
  static const textMuted = Color(0xFFC6CDD1);
  static const textHint = Color(0xFFD3D8DB);

  // Borders — hairline, barely-there.
  static const border = Color(0xFFEEF1F2); // default card border
  static const borderLight = Color(0xFFF5F6F7);
  static const borderMedium = Color(0xFFE3E6E8); // outlined buttons

  // Status.
  static const error = Color(0xFFFF5000); // "down" orange-red / destructive
  static const errorDark = Color(0xFFE64800);
  static const errorBg = Color(0xFFFFF1EA);
  static const errorBorder = Color(0xFFFFD6C2);
  static const success = Color(0xFF10B981);
  static const successDark = Color(0xFF059669);
  static const warning = Color(0xFFFFB700);
  static const warningDark = Color(0xFFF59E0B);
  static const rose = Color(0xFFF43F5E);

  // Accents — category/role color-coding ONLY, never general UI.
  static const purple = Color(0xFF8B5CF6);
  static const cyan = Color(0xFF06B6D4);
  static const cyanDark = Color(0xFF0891B2);
  static const teal = Color(0xFF0EA5E9);
  static const amber = Color(0xFFF5A623);
  static const whatsapp = Color(0xFF25D366);

  /// Fifty Free mapped onto Material roles. White everywhere; hairline
  /// borders on outline slots; ink on inverse slots (snackbars/toasts).
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Color(0xFFFFFFFF),
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
    surfaceContainerHighest: Color(0xFFECEFF0),
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

  /// Dark scheme retained for completeness (app forces light mode).
  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryAccent,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: primaryDark,
    onPrimaryContainer: primaryBg,
    secondary: Color(0xFFA5A8B8),
    onSecondary: Color(0xFF12131A),
    secondaryContainer: Color(0xFF212228),
    onSecondaryContainer: Color(0xFFE6E7EC),
    tertiary: success,
    onTertiary: Color(0xFF00382A),
    tertiaryContainer: Color(0xFF00513C),
    onTertiaryContainer: Color(0xFFB7F2D8),
    error: Color(0xFFFF7A45),
    onError: Color(0xFF3A0A0A),
    errorContainer: Color(0xFF6E1F1F),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: ink,
    onSurface: Color(0xFFF4F4F5),
    onSurfaceVariant: Color(0xFFA1A1AA),
    surfaceContainerLowest: Color(0xFF060608),
    surfaceContainerLow: Color(0xFF131316),
    surfaceContainer: Color(0xFF18181C),
    surfaceContainerHigh: Color(0xFF1F1F24),
    surfaceContainerHighest: Color(0xFF26262C),
    surfaceDim: ink,
    surfaceBright: Color(0xFF2E2E35),
    outline: Color(0xFF3F3F49),
    outlineVariant: Color(0xFF2A2A31),
    inverseSurface: Color(0xFFF4F4F5),
    onInverseSurface: Color(0xFF18181C),
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

  /// Under hero blue CTAs only.
  static const primaryGlow = [
    BoxShadow(
      color: Color(0x47144F86), // primary @ 28%
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
