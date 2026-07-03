import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens (spec §6.1): 4px spacing grid, radius scale, seeded M3 color.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Radius scale: inputs/chips 12, cards 16, sheets 20, pills/composer 28.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 28;
}

/// Motion durations — everything under 500ms, honoring reduce-motion upstream.
abstract final class AppMotion {
  static const Duration press = Duration(milliseconds: 100);
  static const Duration release = Duration(milliseconds: 200);
  static const Duration entrance = Duration(milliseconds: 280);
  static const Duration stagger = Duration(milliseconds: 35);
  static const Curve decelerate = Cubic(0.05, 0.7, 0.1, 1);
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);
}

/// Brand seed — indigo-violet; semantic roles derive from it (spec §6.1).
const _brandSeed = Color(0xFF5B5BF0);

/// Dark palette anchors (bordered-card look, near-black background).
const _darkBg = Color(0xFF0E0F13);
const _darkCard = Color(0xFF1A1B21);
const _darkBorder = Color(0xFF2A2B33);
const _darkPrimary = Color(0xFF8C8CFF);

TextTheme _typography(TextTheme base, ColorScheme scheme) {
  final display = GoogleFonts.plusJakartaSansTextTheme(base);
  final body = GoogleFonts.interTextTheme(base);
  return base
      .copyWith(
        displayLarge: display.displayLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        displayMedium: display.displayMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        displaySmall: display.displaySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.75,
        ),
        headlineLarge: display.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.75,
        ),
        headlineMedium: display.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineSmall: display.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: display.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
        titleMedium: display.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        titleSmall: display.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: body.bodyLarge?.copyWith(height: 1.5),
        bodyMedium: body.bodyMedium?.copyWith(height: 1.5),
        bodySmall: body.bodySmall?.copyWith(height: 1.4),
        labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        labelMedium: body.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        labelSmall: body.labelSmall?.copyWith(fontWeight: FontWeight.w500),
      )
      .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
}

ThemeData _base(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  var scheme = ColorScheme.fromSeed(
    seedColor: _brandSeed,
    brightness: brightness,
  );
  if (dark) {
    scheme = scheme.copyWith(
      primary: _darkPrimary,
      surface: _darkBg,
      surfaceContainerLowest: _darkBg,
      surfaceContainerLow: _darkCard,
      surfaceContainer: _darkCard,
      surfaceContainerHigh: const Color(0xFF20212A),
      surfaceContainerHighest: const Color(0xFF262733),
      outlineVariant: _darkBorder,
    );
  }
  final textTheme = _typography(
    ThemeData(brightness: brightness).textTheme,
    scheme,
  );
  final border = scheme.outlineVariant;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: scheme.surface,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? _darkCard : scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    ),
    // Bordered, near-flat cards — borders over shadows (design brief).
    cardTheme: CardThemeData(
      elevation: 0,
      color: dark ? _darkCard : scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48), // a11y: min tap target (spec §6.2)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: border),
      ),
      backgroundColor: dark ? _darkCard : scheme.surface,
      selectedColor: scheme.primaryContainer,
      labelStyle: textTheme.labelMedium,
      side: BorderSide(color: border),
      showCheckmark: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? _darkCard : scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 68,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      backgroundColor: dark ? const Color(0xFF262733) : const Color(0xFF1F2028),
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      titleTextStyle: textTheme.titleMedium,
      subtitleTextStyle: textTheme.bodySmall?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: dark ? _darkCard : scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
    tabBarTheme: TabBarThemeData(
      labelStyle: textTheme.titleSmall,
      unselectedLabelStyle: textTheme.titleSmall,
      dividerColor: border,
    ),
  );
}

final ThemeData lightTheme = _base(Brightness.light);
final ThemeData darkTheme = _base(Brightness.dark);
