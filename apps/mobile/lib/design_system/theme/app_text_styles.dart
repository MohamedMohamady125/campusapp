import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fifty Free type scale.
///
/// Manrope w800 with tight negative letter-spacing for display/headings and
/// buttons; Inter 400–500 for body copy; Inter tabular figures for numbers.
abstract final class AppTextStyles {
  static TextStyle _manrope(
    double size,
    FontWeight weight, {
    double? ls,
    double? height,
    Color color = AppColors.textHeading,
  }) => GoogleFonts.manrope(
    fontSize: size,
    fontWeight: weight,
    letterSpacing: ls,
    height: height,
    color: color,
  );

  static TextStyle _inter(
    double size,
    FontWeight weight, {
    double? ls,
    double? height,
    Color color = AppColors.textPrimary,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    letterSpacing: ls,
    height: height,
    color: color,
  );

  // Display / headings — Manrope w800, tight tracking.
  static final TextStyle displayLarge = _manrope(
    34,
    FontWeight.w800,
    ls: -1.2,
    height: 1.05,
  );
  static final TextStyle displayMedium = _manrope(
    28,
    FontWeight.w800,
    ls: -0.8,
  );
  static final TextStyle heading = _manrope(
    24,
    FontWeight.w800,
    ls: -0.6,
    height: 1.1,
  );
  static final TextStyle subheading = _manrope(20, FontWeight.w800, ls: -0.4);
  static final TextStyle titleLarge = _manrope(
    18,
    FontWeight.w700,
    ls: -0.3,
    height: 1.15,
  );
  static final TextStyle titleMedium = _manrope(16, FontWeight.w700, ls: -0.2);
  static final TextStyle titleSmall = _manrope(14, FontWeight.w700, ls: -0.1);

  // Body — Inter.
  static final TextStyle body = _inter(14, FontWeight.w500, height: 1.5);
  static final TextStyle bodyMedium = _inter(14, FontWeight.w400, height: 1.55);
  static final TextStyle bodySmall = _inter(12, FontWeight.w500, height: 1.45);

  // Micro labels — UPPERCASE eyebrows.
  static final TextStyle label = _inter(
    11,
    FontWeight.w700,
    ls: 1,
    color: AppColors.textSecondary,
  );
  static final TextStyle labelWide = _inter(
    11,
    FontWeight.w700,
    ls: 1.4,
    color: AppColors.textSecondary,
  );
  static final TextStyle labelSmall = _inter(10, FontWeight.w700);
  static final TextStyle labelTiny = _inter(9, FontWeight.w600);

  // Buttons — Manrope w800.
  static final TextStyle button = _manrope(
    15,
    FontWeight.w800,
    ls: 0.2,
    color: Colors.white,
  );
  static final TextStyle buttonSmall = _manrope(
    13,
    FontWeight.w800,
    color: AppColors.primaryDark,
  );

  // Numbers — Inter, tabular figures.
  static final TextStyle stat = _inter(28, FontWeight.w700, ls: -0.5).copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  static final TextStyle statSmall = _inter(16, FontWeight.w700).copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static final TextStyle profileName = _manrope(26, FontWeight.w800, ls: -0.8);

  // Inputs / toasts / avatars.
  static final TextStyle input = _inter(15, FontWeight.w500);
  static final TextStyle inputHint = _inter(
    15,
    FontWeight.w400,
    color: AppColors.textHint,
  );
  static final TextStyle toast = _inter(
    13,
    FontWeight.w600,
    ls: 0.2,
    color: Colors.white,
  );
  static final TextStyle avatarLetter = _manrope(
    20,
    FontWeight.w800,
    color: AppColors.primaryDark,
  );
  static final TextStyle avatarLetterLarge = _manrope(
    34,
    FontWeight.w800,
    color: AppColors.primaryDark,
  );
}
