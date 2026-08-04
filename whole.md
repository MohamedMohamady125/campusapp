# CampusConnect — Final UI Build Instruction

> **You are implementing the CampusConnect UI. This file is the single source of truth for visual design.**
>
> Read the whole file before writing code. Everything here is directive, not advisory. Where you have a choice, choose the option this file names. Where this file is silent, choose the quieter option.
>
> **Stack:** Flutter 3.44+ · Material 3 · iOS + Android + web
> **Design language:** Atlas Dark — hairline borders, no shadows, one accent, compact Inter, true-neutral surfaces.
> **Companion docs (read if present):** `CAMPUSCONNECT_UI_UX_SPEC.md` (product logic, flows, copy, a11y depth), `CAMPUSCONNECT_VISUAL_REFINEMENT.md` (diagnosis of the previous build).

---

## 0. What you are building

A trust-first mobile app for one university campus. Every user is a verified student (.edu email + 6-digit code). Three features share one identity and one portable Bayesian reputation score:

| Tab | Job |
|---|---|
| **Market** | Buy/sell textbooks, furniture, electronics, tickets between students |
| **Tutors** | Search a course code → ranked list of students who took it and did well |
| **Chats** | Direct messages + community group rooms |

The UI's primary job is to **make trust legible at a glance**. Every screen answers, without a tap: who is this person, should I trust them, and what happens if this goes wrong.

---

## 1. The ten laws

These override taste, convention, and your own instinct. Do not violate them.

1. **Hairline borders, never shadows.** Every card, sheet, input, and elevated container gets `1px outlineVariant`. `elevation: 0` everywhere. There is exactly one `BoxShadow` in this app: none. Shadows are invisible on near-black and cheap-looking on white.
2. **True-neutral surfaces.** Never call `ColorScheme.fromSeed`. It generates hue-tinted neutrals — a blue seed makes every surface blue-grey and muddy. Use the explicit `ColorScheme`s in §3.1 verbatim.
3. **One accent, held back.** Indigo appears on exactly five things: the FAB, filled buttons, the selected nav destination, links/focus rings, and your own chat bubble. **Nothing on a listing card or tutor card is ever indigo.**
4. **Price is the strongest neutral, never a color.** `$146` in `onSurface` at `w700`. Green means "sale completed," nothing else.
5. **12px radius on box shells.** Cards, sheets, dialogs, image containers. Functionally-round things — avatars, toggles, radios, status dots, filter chips — stay fully round. Inputs and buttons get 10px. Nothing else.
6. **Compute grid cell heights. Never guess `childAspectRatio`.** Reserve title space whether the title fills it or not. Clipped text is a build failure, not a style opinion.
7. **Three weights only: w400 body, w600 headers, w700 price.** Hierarchy comes from size, weight, and opacity — not color.
8. **No hardcoded values in feature code.** No `Color(0xFF...)`, no `EdgeInsets.all(16)`, no `BorderRadius.circular(12)` outside `lib/design_system/`. Use `context.colors` and `context.tokens`. Reject your own code if it violates this.
9. **Never show a bare rating average.** `4.8` alone is misinformation. Always `★ 4.8 · 212`. Zero ratings renders `New member`, never `0.0` and never a fake `5.0`.
10. **48dp minimum touch target, everywhere.** Never set `VisualDensity.compact` — it shrinks targets to 40dp and breaks the accessibility floor.

---

## 2. Build order

Work in this sequence. Each step is visible immediately; do not skip ahead.

| # | Task | Section |
|---|---|---|
| 1 | Barrel file for Material imports | §3.0 |
| 2 | `AppColors` — explicit ColorSchemes | §3.1 |
| 3 | `AppTokens` — ThemeExtension | §3.2 |
| 4 | `AppTheme` — component theming | §3.3 |
| 5 | App root with text-scale clamp | §3.4 |
| 6 | `VerifiedAvatar`, `ReputationChip` | §4.1, §4.2 |
| 7 | `ListingCard` + computed grid | §4.3 |
| 8 | Market screen (header, chips, grid, FAB) | §5.1 |
| 9 | `TutorCard` + Tutors screens | §4.4, §5.2 |
| 10 | Chat components + screens | §4.5, §5.3 |
| 11 | Empty / loading / error / offline states | §6 |
| 12 | Accessibility pass + QA checklist | §7, §8 |

---

## 3. Foundation

### 3.0 Barrel file — do this first

Flutter's `material` and `cupertino` libraries were frozen in April 2026 and are moving to independently versioned `material_ui` / `cupertino_ui` packages on pub.dev. They will be deprecated in the framework in a coming stable release.

Create `lib/design_system/material.dart`:

```dart
export 'package:flutter/material.dart';
```

**Every other file in the project imports this, never `package:flutter/material.dart` directly.** When the migration lands it's a one-line change instead of thousands.

Also note: **Material 3 Expressive is not implemented in Flutter** and is not currently planned in the framework. Build against standard M3. `DynamicSchemeVariant.expressive` is an unrelated color algorithm — do not conflate them.

### 3.1 `lib/design_system/theme/app_colors.dart`

Paste verbatim. These hexes are the design.

```dart
import '../material.dart';

abstract final class AppColors {
  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF818CF8),
    onPrimary: Color(0xFF1A1150),
    primaryContainer: Color(0xFF2E2A6B),
    onPrimaryContainer: Color(0xFFDDE0FF),
    secondary: Color(0xFFA5A8B8),
    onSecondary: Color(0xFF12131A),
    secondaryContainer: Color(0xFF212228),
    onSecondaryContainer: Color(0xFFE6E7EC),
    tertiary: Color(0xFF3DD9A0),
    onTertiary: Color(0xFF00382A),
    tertiaryContainer: Color(0xFF00513C),
    onTertiaryContainer: Color(0xFFB7F2D8),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF3A0A0A),
    errorContainer: Color(0xFF6E1F1F),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF0A0A0C),
    onSurface: Color(0xFFF4F4F5),
    onSurfaceVariant: Color(0xFFA1A1AA),
    surfaceContainerLowest: Color(0xFF060608),
    surfaceContainerLow: Color(0xFF131316),
    surfaceContainer: Color(0xFF18181C),
    surfaceContainerHigh: Color(0xFF1F1F24),
    surfaceContainerHighest: Color(0xFF26262C),
    surfaceDim: Color(0xFF0A0A0C),
    surfaceBright: Color(0xFF2E2E35),
    outline: Color(0xFF3F3F49),
    outlineVariant: Color(0xFF2A2A31),
    inverseSurface: Color(0xFFF4F4F5),
    onInverseSurface: Color(0xFF18181C),
    inversePrimary: Color(0xFF4F46E5),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Colors.transparent,
  );

  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF4F46E5),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE0E1FF),
    onPrimaryContainer: Color(0xFF14116B),
    secondary: Color(0xFF52525B),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFEFF0F3),
    onSecondaryContainer: Color(0xFF1A1C20),
    tertiary: Color(0xFF12805C),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFB7F2D8),
    onTertiaryContainer: Color(0xFF00281C),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0E0E11),
    onSurfaceVariant: Color(0xFF63636E),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFAFAFB),
    surfaceContainer: Color(0xFFF4F4F6),
    surfaceContainerHigh: Color(0xFFEDEDF0),
    surfaceContainerHighest: Color(0xFFE4E4E8),
    surfaceDim: Color(0xFFE8E8EC),
    surfaceBright: Color(0xFFFFFFFF),
    outline: Color(0xFFC9C9D1),
    outlineVariant: Color(0xFFE6E6EA),
    inverseSurface: Color(0xFF18181C),
    onInverseSurface: Color(0xFFF4F4F5),
    inversePrimary: Color(0xFFB4B8FF),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Colors.transparent,
  );
}
```

**Surface role usage — memorize:**

| Use | Role |
|---|---|
| Page background | `surface` |
| **Cards** | `surfaceContainerLow` |
| Nav bar, bottom sheets | `surfaceContainer` |
| Search field, dialogs, menus | `surfaceContainerHigh` |
| Image placeholders, pressed states | `surfaceContainerHighest` |
| Primary text, prices | `onSurface` |
| Meta, timestamps, rating counts | `onSurfaceVariant` |
| **Card borders, dividers** | `outlineVariant` |
| Input borders, unselected chips | `outline` |

**Deprecated, never use:** `background`, `onBackground`, `surfaceVariant`. (`surfaceVariant` → `surfaceContainerHighest`. Note `onSurfaceVariant` is *not* deprecated and is correct for secondary text.)

### 3.2 `lib/design_system/theme/app_tokens.dart`

```dart
import 'dart:ui' show lerpDouble;
import '../material.dart';

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

  final double space1, space2, space3, space4, space5, space6, space8, space12;
  final double radiusXs, radiusSm, radiusMd, radiusLg;

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
  }) =>
      AppTokens(
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
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
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

extension AppContextX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}
```

Note: `lerp`'s parameter must be `covariant` or you get an override error.

### 3.3 `lib/design_system/theme/app_theme.dart`

```dart
import 'package:google_fonts/google_fonts.dart';
import '../material.dart';
import 'app_colors.dart';
import 'app_tokens.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light, AppTokens.lightTokens);
  static ThemeData dark() => _build(AppColors.dark, AppTokens.darkTokens);

  static ThemeData _build(ColorScheme scheme, AppTokens tokens) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      extensions: [tokens],
    );

    final t = GoogleFonts.interTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: t,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: t.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 22),
      ),

      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.brMd,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: scheme.secondaryContainer,
        indicatorShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return t.labelSmall?.copyWith(
            fontSize: 11,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
            color: sel ? scheme.onSurface : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: sel ? scheme.onSurface : scheme.onSurfaceVariant,
          );
        }),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          elevation: 0,
          textStyle: t.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: tokens.brSm),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(borderRadius: tokens.brSm),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.space3,
          vertical: tokens.space3,
        ),
        hintStyle: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: tokens.brSm,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: tokens.brSm,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: tokens.brSm,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: tokens.brLg),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle:
            t.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: tokens.brSm),
      ),
    );
  }
}
```

**Bundle Inter as an asset** rather than letting `google_fonts` fetch over HTTP at runtime. Download from fonts.google.com, drop the files into an asset folder, list the *folder* under `assets:` in pubspec (not under `fonts:`, and do not rename the files). Then register the license in `main()`:

```dart
LicenseRegistry.addLicense(() async* {
  final license = await rootBundle.loadString('google_fonts/OFL.txt');
  yield LicenseEntryWithLineBreaks(['google_fonts'], license);
});
```

### 3.4 App root

```dart
MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: ThemeMode.system,
  builder: (context, child) => MediaQuery.withClampedTextScaling(
    minScaleFactor: 1.0,
    maxScaleFactor: 2.0,
    child: child!,
  ),
);
```

`withClampedTextScaling` is a static method returning a Widget and asserts an ancestor `MediaQuery` — it must sit **inside** `MaterialApp.builder`, never above `MaterialApp`. `maxScaleFactor: 2.0` keeps WCAG 1.4.4 (200% resize) satisfied.

### 3.5 Type scale

Sizes are on top of the M3 scale from `GoogleFonts.interTextTheme`.

| Element | Size | Weight | Color |
|---|---|---|---|
| Screen title | 20 | w600 | `onSurface` |
| Section header | 13 | w600 | `onSurfaceVariant`, letterSpacing 0.4 |
| Card price | 16 | **w700** | `onSurface`, tabular figures |
| Detail price | 24 | w700 | `onSurface`, tabular figures |
| Card title | 13 | w400 | `onSurface` @ 85% |
| Tutor / profile name | 15 | w500 | `onSurface` |
| Seller name (card) | 11 | w500 | `onSurfaceVariant` |
| Rating value | 11 | w600 | `onSurfaceVariant` |
| Card meta | 11 | w400 | `onSurfaceVariant` @ 80% |
| Chip label | 12 | w500 / w600 selected | — |
| Chat message | 15 | w400 | — |
| Nav label | 11 | w500 / w600 selected | — |

De-emphasis ladder, four steps and no more: `onSurface` → `onSurface @85%` → `onSurfaceVariant` → `onSurfaceVariant @80%`.

**Never go below 80% alpha on `onSurfaceVariant`**, and never apply alpha to `onSurface` below 85% — both break the 4.5:1 contrast floor.

**Every number gets tabular figures:** `fontFeatures: const [FontFeature.tabularFigures()]` on prices, ratings, counts, member counts.

### 3.6 Motion

`Easing` and `Durations` live in **`material`**, not `animation`.

| Interaction | Duration | Curve |
|---|---|---|
| Enter / expand / sheet up | `Durations.medium4` | `Easing.emphasizedDecelerate` |
| Exit / collapse / sheet down | `Durations.short4` | `Easing.emphasizedAccelerate` |
| Chip select, toggle, in-place | `Durations.short4` | `Easing.standard` |
| Page transition | `Durations.medium2` | `Easing.emphasizedDecelerate` |
| Skeleton shimmer (repeating) | `Durations.long2` | `Easing.linear` |

**`Easing.emphasized` does not exist** — only `emphasizedAccelerate` and `emphasizedDecelerate`. Writing `Easing.emphasized` will not compile. The extra-long duration member is `extralong1`, all lowercase.

Exits are always faster than entrances. Gate decorative motion behind `MediaQuery.disableAnimationsOf(context)`.

---

## 4. Components

Build these in `lib/design_system/components/`. Feature folders must never define their own version — add a variant to the shared component instead.

### 4.1 `VerifiedAvatar`

- Sizes: `xs` 18, `sm` 24, `md` 40, `lg` 56, `xl` 96.
- Circular. Verification check emblem at bottom-right with a 2px `surface` ring — **only at `md` and above.** Below `md` it's noise; omit it.
- Fallback when no photo: **initials** on `secondaryContainer` in `onSecondaryContainer`. Never a generic grey person icon — that reads as "no real person here," the exact opposite of the product thesis.
- Optional `online` dot (8dp, `tokens.online`) replaces the emblem position — chat list only.
- Semantics: `label: '<Name>, verified student'`.

### 4.2 `ReputationChip`

The most-reused trust component. Enforce the rules **inside the component** so call sites cannot violate them.

```dart
enum ReputationVariant { compact, standard, detailed }

class ReputationChip extends StatelessWidget {
  const ReputationChip({
    super.key,
    required this.rating,        // null when the user has no ratings
    required this.ratingCount,
    this.marketplaceCount,
    this.tutoringCount,
    this.variant = ReputationVariant.standard,
    this.onTap,
  });

  final double? rating;
  final int ratingCount;
  final int? marketplaceCount;
  final int? tutoringCount;
  final ReputationVariant variant;
  final VoidCallback? onTap;
}
```

**Rendering:**

| Variant | Output |
|---|---|
| `compact` (cards) | `★ 4.8 · 212` — star 10dp `ratingStar`, value 11/w600 `onSurfaceVariant`, count 11 `onSurfaceVariant @80%` |
| `standard` (list rows) | `★ 4.8 · 212 ratings` — star 14dp, value 13/w600 `onSurface` |
| `detailed` (profiles, tappable) | `★ 4.8 · 212 ratings` + second line `41 from marketplace · 6 from tutoring` |

**Enforced internally:**

- `rating == null || ratingCount == 0` → render `New member`. No exceptions, no fallback to `0.0`, no fake `5.0`.
- On **cards**, `New member` is plain 11sp `onSurfaceVariant` text — **no pill, no background.** The pill treatment appears only on profiles and tutor cards.
- Rating formatted to exactly one decimal, **truncated, never rounded up.** `4.749` → `4.7`.
- The count is never hidden. It is half the signal.
- Separator is always the interpunct `·`.
- Semantics label: `'Rated 4.8 out of 5, from 212 ratings'` — not `'star 4.8 dot 212'`.

**Portable reputation disclosure.** When reputation is shown outside the context where it was earned (a mostly-marketplace rating appearing on a tutor card), the breakdown must be reachable **within one tap** — either as the `detailed` second line or behind a tap on the chip that opens the explainer sheet:

> **How reputation works**
> Your rating follows you across CampusConnect. Ratings from selling and from tutoring are shown separately so you can see where someone's reputation comes from. Ratings are weighted by how many you have — a 4.8 from 200 people means more than a 5.0 from two.

### 4.3 `ListingCard` + computed grid

**The clipping bug in the previous build came from guessing `childAspectRatio`. Compute it.**

```
cell height = (column width × 0.75)   // 4:3 image
            + 118                      // fixed content block
```

Content block anatomy — 118dp exactly:

```
 12  padding top
 20  price       16 / w700 / onSurface
  4  gap
 34  title       13 / w400 / height 1.3 / EXACTLY 2 lines reserved
  8  gap
 20  seller row  18dp avatar + name + compact reputation
  4  gap
 16  meta        11 / onSurfaceVariant @80%
 12  padding bottom
```

The 2-line title box is reserved **whether the title is one line or two.** That is what prevents clipping and keeps the grid regular.

```dart
LayoutBuilder(
  builder: (context, constraints) {
    const gutter = 12.0;
    const target = 200.0;
    final columns = (constraints.maxWidth / target).floor().clamp(2, 5);
    final colWidth = (constraints.maxWidth - gutter * (columns - 1)) / columns;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: gutter,
        mainAxisSpacing: gutter,
        mainAxisExtent: colWidth * 0.75 + 118,
      ),
      itemCount: listings.length,
      itemBuilder: (context, i) => ListingCard(listing: listings[i]),
    );
  },
)
```

```dart
class ListingCard extends StatelessWidget {
  const ListingCard({super.key, required this.listing, this.onTap});

  final Listing listing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final t = context.text;

    return Material(
      color: cs.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: context.tokens.brMd,
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                color: cs.surfaceContainerHighest,
                alignment: Alignment.center,
                child: listing.imageUrl == null
                    ? Icon(
                        listing.categoryIcon,
                        size: 26,
                        color: cs.onSurfaceVariant.withValues(alpha: .4),
                      )
                    : Image.network(listing.imageUrl!, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    listing.priceLabel,
                    style: t.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      height: 1.2,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 34,
                    child: Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall?.copyWith(
                        fontSize: 13,
                        height: 1.3,
                        color: cs.onSurface.withValues(alpha: .85),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 20,
                    child: Row(
                      children: [
                        VerifiedAvatar(user: listing.seller, size: 18),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            listing.seller.shortName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.labelSmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        ReputationChip(
                          rating: listing.seller.rating,
                          ratingCount: listing.seller.ratingCount,
                          variant: ReputationVariant.compact,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${listing.age} · ${listing.condition}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.labelSmall?.copyWith(
                      fontSize: 11,
                      color: cs.onSurfaceVariant.withValues(alpha: .8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Rules:**
- Whole card is one tap target. **No nested buttons in the grid** — nested targets at this size are a mis-tap factory.
- Long-press → save / share / report sheet.
- Image placeholder uses a **category-specific** icon (book, headphones, desk, ticket, lamp…), not one generic photo glyph. A grid without photos still reads as content.
- Seed data must include real image URLs. A demo grid of grey boxes looks broken regardless of layout quality.

### 4.4 `TutorCard`

Single-column list row, min 88dp, same hairline card treatment.

```
┌──────────────────────────────────────────────┐
│  ⬤   Jordan Reyes                     ★ 4.9  │
│  56  CS250 · A · Last fall            47     │
│      ⚡ Usually replies within an hour        │
│                               [ Message ]    │
└──────────────────────────────────────────────┘
```

- Avatar `lg` (56). Name 15/w500.
- **Course signal row** — course code w600 + grade + term. This is the domain-specific trust signal; it gets more weight than anything on a listing card.
- **Rank reason** in plain language, 11sp `onSurfaceVariant`, with a small leading icon: `Took CS250 last semester · A` / `Replies within an hour, usually` / `Top-rated for CS250`. **Never print the raw ranking percentages on the card.**
- `Message` is a tonal filled button, 40dp, right-aligned, tappable independently of the row.

### 4.5 Chat components

**`ChatListRow`** — 72dp, avatar `lg`, name 14/w500, preview 13 `onSurfaceVariant` 1-line clamp, timestamp 11 top-right, unread as a `Badge` on `primary`. Threads originating from a listing or tutor request carry a context sub-label: `About: Calculus Early Trans…` in 11sp.

**`MessageBubble`** — mine: `primaryContainer` / `onPrimaryContainer`, right-aligned, radius 16 with 4dp on the bottom-right. Theirs: `surfaceContainerHigh` / `onSurface`, left-aligned, 4dp bottom-left. Max width 78%. Text 15sp. Timestamps appear on tap or on the last message in a group, not on every bubble.
States: `sending` (timestamp at 60% opacity), `sent`, `failed` (2dp `error` left edge + tappable "Tap to retry").

**`Composer`** — bottom-anchored, `surfaceContainer`, expands to 5 lines then scrolls. Circular 40dp `primary` send button, enabled only with content. **Never blocks on the network, never loses typed text.** Messages send optimistically and reconcile.

**`SafetyCard`** — non-blocking info card injected once per listing thread:

> 🛡️ **Meeting up?** Campus spots like the library lobby or student center are good places to trade. Meet during the day and bring a friend if you're carrying cash.

`secondaryContainer` surface, 12dp radius, dismissible, **never error/warning colors, never a modal, never repeated.** A safety message that appears every time becomes wallpaper.

### 4.6 `FilterChipRow`

One horizontal `ListView`, **never a `Wrap`.** Height 32. First chip is `All`, selected by default.

| State | Fill | Border | Label |
|---|---|---|---|
| Unselected | transparent | 1px `outline` | `onSurfaceVariant` 12/w500 |
| Selected | `secondaryContainer` | none | `onSecondaryContainer` 12/w600 |

Animate with `Durations.short4` + `Easing.standard`. Value filters (price range, condition) do **not** belong in this row — put a single trailing `Filters (2)` chip that opens a sheet.

### 4.7 `ContentWidth`

Every scroll body wraps in this. Without it, web/desktop renders six columns spanning 1980px.

```dart
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.max = 1120});
  final Widget child;
  final double max;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: max),
          child: child,
        ),
      );
}
```

Market, Tutors, Groups, Profile → 1120. Chat threads → 720.

---

## 5. Screens

### 5.1 Market

```
┌────────────────────────────────────────┐
│ Market                          🔔  ⋮  │  56dp, 20/w600
│ ┌────────────────────────────────────┐ │
│ │ 🔍 Search listings                 │ │  40dp, surfaceContainerHigh, r10
│ └────────────────────────────────────┘ │
│  ⛨ Everyone here is a verified student │  11sp + 12dp shield icon
│                                        │
│ ⟨ All · Textbooks · Furniture · … ⟩    │  32dp single scroll row
│ ┌─────────┐ ┌─────────┐                │
│ │ listing │ │ listing │                │  computed grid, 12dp gutter
│ └─────────┘ └─────────┘                │
│                              ( 📷 )    │  FAB, r16, solid primary
└────────────────────────────────────────┘
```

- Search field is **40dp**, not the 64dp M3 default.
- The verified line is the ambient trust signal. It appears **once per surface**, not once per card.
- Default sort: **most recent.** On a small campus, freshness signals the marketplace is alive; "relevance" doesn't.
- Pull-to-refresh. Infinite scroll. Show cached results instantly on open and reconcile in the background.
- Grid needs 96dp bottom padding so the FAB never covers a card.

### 5.2 Listing creation — camera-first, ≤5 taps

The tap budget, literally: FAB → shutter → use photo → (title and price pre-filled) → post.

1. **Camera.** Opens directly to a live camera view, not a picker. Gallery in the bottom-left. 72dp shutter, bottom-center. First photo is the cover.
2. **Details.** Title pre-filled from image recognition and **pre-selected** so typing replaces it. Price pre-filled with a comparison anchor (`Similar textbooks sold for $30–50`). Category auto-detected as a tappable chip. Everything else collapsed under `Add details ▾`. **Never require a description.**
3. **Review.** Renders the actual `ListingCard` plus a detail preview. One `Post listing` button. Below it: `Listings expire after 90 days. You can renew anytime.`

3-step progress indicator across all steps. **Autosave the draft on every field change**; restore silently with a `Draft restored` toast. Success → hero into the grid + snackbar `Posted. Share it?`

### 5.3 Listing detail

Scan order — build so visual weight matches:

1. Photo carousel (1:1, page dots, tap → fullscreen)
2. Price — 24/w700
3. Title — 16/w500
4. Condition · posted time
5. **Seller row** — avatar `lg`, name, verified, `ReputationChip.standard`, major + class year, typical reply time, chevron to profile
6. Description
7. Category · condition · `Expires in 88 days`
8. More from this seller → · Similar listings →
9. `⋮ Report this listing` — quiet, always present

Sticky bottom bar: `[ ♡ ]  [ Message seller ]`. The message button takes the width.

### 5.4 Tutors

**Search:** course code field with autofocus on first visit. Typeahead against the real catalog, showing `CS250 — Data Structures` so the student confirms the right course. Accept `cs250`, `CS 250`, `CS-250`. Below: `Your courses` chips from the profile, then `Popular this week`.

**Results:**
```
CS250 · Data Structures
12 tutors on campus        How are tutors ranked? ›
─────────────────────────────────────────────
[ TutorCard ] × 10
[ Show more ]
```

The `How are tutors ranked?` link is **persistent and not dismissible.** It opens:

> **How we rank tutors**
> We rank by three things: their overall reputation on CampusConnect (the biggest factor), how recently they took the course, and how quickly they usually reply. New tutors start with a neutral score, so they aren't buried — they just haven't proven anything yet.

**Tutor profile:** same profile shell as a seller profile, plus courses taken with grades and terms, availability, and reviews **filtered to tutoring by default** with a toggle for all. Sticky `Message`.

### 5.5 Chats

**Thread list** — unified inbox. Segmented filter: `All · Buying · Selling · Tutoring · Groups`, default `All`.

**Thread** — context header pinned below the app bar for listing/tutoring threads (compact thumbnail + title + price, tappable back to the listing, collapses on scroll). Consecutive messages from the same sender within 5 minutes share one avatar and timestamp. Long-press → copy, report, delete own. `SafetyCard` once per listing thread.

**Group directory** — join in ≤3 taps total from app open, which means the `Join` button lives on the directory row, not behind a detail screen. Show `24 active today` alongside member count — activity is the signal that a room is worth joining. Open groups join instantly with an undo snackbar.

**Group room** — member count in the app bar. Moderator actions behind `⋮` for mods only, every action logged to an audit trail. Removed content leaves a tombstone: `Message removed by a moderator`. **Silent deletion is worse than visible moderation.**

### 5.6 Navigation

Four destinations, fixed. Not five, and no "Home" feed — a campus of a few thousand students can't fill a feed, and an empty feed on launch is the worst possible first impression.

| Destination | Icon (outlined / filled) | Badge |
|---|---|---|
| Market | `storefront_outlined` / `storefront` | — |
| Tutors | `school_outlined` / `school` | — |
| Chats | `forum_outlined` / `forum` | unread count |
| Profile | `person_outline` / `person` | action-required dot |

Always supply `selectedIcon`. Add a 1px `outlineVariant` top border to the nav bar via a wrapping `DecoratedBox`.

**Accessibility caveat:** `NavigationBar` does not scale with `MediaQuery.textScaler` and ignores `visualDensity`. Its labels stay fixed — keep them to one short word, and rely on the long-press tooltip as the accessible fallback.

Create is a **FAB on Market**, never a nav destination. On Tutors and Chats, creation is contextual (search field, `New group` in the app bar).

**Breakpoints — branch on `MediaQuery` width, never on platform or device type:**
`< 600` → `NavigationBar`, 2-col grid · `600–839` → `NavigationRail`, 3-col · `≥ 840` → rail + two-pane list/detail.

---

## 6. States

Every list surface implements all five. No exceptions.

**Loading.** Have cached data? Show it immediately and refresh silently — **cached data always beats a skeleton.** No cache? Skeleton matching the exact final card geometry, shimmer at `Durations.long2` / `Easing.linear`. Under ~300ms? Show nothing; a spinner flash is worse than the wait.

**Empty — exact copy:**

| Surface | Title | Body | Action |
|---|---|---|---|
| Market, nothing listed | `Nothing listed yet` | `Be the first. Sell that textbook you're never opening again.` | `Post a listing` |
| Market, filtered to zero | `No matches` | `Try a wider price range or a different category.` | `Clear filters` |
| Search, no results | `No results for "chem book"` | `Try fewer words, or search by course code.` | `Clear search` |
| Tutors, none for course | `No tutors for CS250 yet` | `You'll be the first to know when someone signs up. Took this course? You could tutor it.` | `Notify me` + `Offer to tutor` |
| Chats, empty | `No messages yet` | `Message a seller or a tutor and it'll show up here.` | `Browse the market` |
| My listings, empty | `You haven't listed anything` | `Snap a photo and you're posted in under a minute.` | `Post a listing` |
| Saved, empty | `Nothing saved` | `Tap the heart on any listing to keep it here.` | `Browse the market` |

Name the specific cause, never blame the user, offer **exactly one** primary action. The tutor empty state is the highest-value one in the app — it converts a dead end into a supply signal.

**Error.** Inline over modal. Plain language, no codes: `Couldn't load listings. Check your connection and try again.` Always recoverable. **Never lose user input** — a failed listing post returns to review with everything intact.

**Offline.** Slim persistent banner on `warningContainer`: `You're offline. We'll retry automatically.` Cached content stays browsable and fully legible, not greyed out. Composed messages queue and send on reconnect — show queued, not error.

**Restricted.** Removed listing → `This listing was removed.` (owner also sees why). Blocked user's content → hidden entirely, no tombstone. Suspended account → full-screen explanation with an appeal path, never a silent lockout.

---

## 7. Copy and accessibility

### Voice

A competent classmate. Direct, warm, unfussy.

- **Sentence case everywhere.** Never Title Case, never ALL CAPS.
- **No exclamation marks** outside the verification success moment.
- **No emoji in system copy.** Two exceptions: the shield on `SafetyCard`, the lightning on responsiveness.
- **Numbers are specific.** `212 ratings`, not `hundreds of ratings`. Specificity is a trust signal.
- **Errors state cause then fix**, in one sentence.
- Second person for the user, first-person-plural for the app: `Your listings` / `We'll review this within 24 hours.`
- Prices drop cents when they're noise: `$146`, not `$145.69`. Exact cents only on detail and checkout. Never `$43.00`.
- Relative time on cards is `4w`, not `4w ago` — `ago` is redundant when every card has it.
- Names: `Hugo H.` If it doesn't fit, drop the last initial before truncating the first name. Never render `D…`.

### Accessibility — WCAG 2.2 AA, non-negotiable

| Requirement | Threshold |
|---|---|
| Body text contrast | **4.5:1** |
| Large text (≥24px regular / ≥18.5px bold) | 3:1 |
| UI boundaries, icons, focus indicators | **3:1** |
| Touch targets | **48×48dp** |
| Text scaling support | **200%** |

11sp and 13sp text all require the full 4.5:1 — that covers timestamps, rating counts, and card meta, which is exactly where the temptation to cheat lives. Do not cheat there.

- `outlineVariant` frequently fails 3:1 — decorative dividers and card borders only, never input borders that identify a control.
- **Never compute `size * textScaleFactor`.** It's deprecated and Android 14+ scaling is non-linear. Use `MediaQuery.textScalerOf(context).scale(baseSize)`.
- Never use fixed-height containers around text. Test every screen at 200%.
- `MergeSemantics` on composite cards so a screen reader announces one unit, not eight fragments.
- Every `IconButton` needs a `tooltip`. Listing photos get `Semantics(label: '<title>, photo 1 of 4')`. Decorative images get `ExcludeSemantics`.
- New incoming message → `Semantics(liveRegion: true)` on the message list.
- **Color is never the only signal.** Unread = badge + weight. Failed message = icon + text. Verified = glyph + label.

---

## 8. Never build these

| Anti-pattern | Why |
|---|---|
| Bare star average without count | `5.0` from two ratings is misinformation |
| `0.0★` or a default 5.0 for new users | Punishes or lies — use `New member` |
| Verified badge on every card, row, and message | Badge inflation. The badge stops meaning anything |
| Fake urgency (`3 people viewing`, countdowns on others' listings) | Students detect it instantly; destroys the trust thesis for a marginal conversion bump |
| Opaque tutor ranking | A trust app with a black-box ranking is a contradiction |
| Promoted content in the #1 organic slot unlabeled | Effectively fraud |
| Review-begging modals | Interrupts the peak moment with a request |
| Onboarding carousel | This audience skips them. Teach in context |
| Infinite home feed | A small campus can't fill it |
| Modal safety warnings at signup | Alarming, decontextualized, dismissed. Contextual and calm instead |
| Silent moderation | Erodes trust more than the original violation |
| Single master notification switch | Guarantees total opt-out |
| Blocking the composer on network | Campus wifi is bad. Optimistic or nothing |
| Grey generic person icon as avatar fallback | Reads as "no real person here" |
| `VisualDensity.compact` | Breaks the 48dp floor |
| Nested tap targets inside grid cards | Mis-tap factory at that size |
| Any `BoxShadow` | Law 1 |
| Any `Color(0xFF…)` outside `design_system/` | Law 8 |

---

## 9. Definition of done

**Foundation**
- [ ] `design_system/material.dart` barrel exists; no file imports `package:flutter/material.dart` directly
- [ ] Zero calls to `ColorScheme.fromSeed` in the codebase
- [ ] `AppTokens` registered in both light and dark `ThemeData`
- [ ] `surfaceTintColor: Colors.transparent` and `elevation: 0` on every component theme
- [ ] `MediaQuery.withClampedTextScaling(min: 1.0, max: 2.0)` inside `MaterialApp.builder`
- [ ] `materialTapTargetSize: padded`, `visualDensity: standard`
- [ ] Inter bundled as an asset, license registered

**Components**
- [ ] `VerifiedAvatar` — 5 sizes, emblem only at `md`+, initials fallback
- [ ] `ReputationChip` — 3 variants, `New member` enforced internally, count never hidden, truncated not rounded
- [ ] `ListingCard` — 4:3 image, 118dp content block, 2-line title reserved
- [ ] Grid uses computed `mainAxisExtent`; zero `childAspectRatio` guesses
- [ ] `TutorCard` with plain-language rank reason
- [ ] `ChatListRow`, `MessageBubble`, `Composer`, `SafetyCard`, `EmptyState`, `FilterChipRow`, `ContentWidth`
- [ ] Skeletons match each card's exact geometry
- [ ] Widget tests per component: default / empty / dark / 200% text

**Flows**
- [ ] Listing creation ≤5 taps, counted on a real device
- [ ] Group join ≤3 taps from app open
- [ ] Draft autosave and restore
- [ ] Optimistic message send with retry
- [ ] Report reachable in 1 tap from listing, profile, thread, and message
- [ ] Reputation breakdown reachable in 1 tap wherever shown cross-context
- [ ] `How are tutors ranked?` present and persistent

**Visual acceptance** — screenshot Market and verify:
- [ ] No clipped text at any window width
- [ ] Card borders visible as crisp 1px hairlines
- [ ] Background reads near-black; cards are clearly a step above it
- [ ] Nothing on a listing card is indigo or green
- [ ] Price is the highest-contrast text on the card
- [ ] Max 5 columns; content centered with margins on a wide window
- [ ] Filter chips are one row with `All` selected
- [ ] Nothing looks blue-tinted grey
- [ ] FAB overlaps no card
- [ ] Light theme looks intentional, not inverted

**Accessibility**
- [ ] Contrast audit passes 4.5:1 text and 3:1 non-text, including all 11sp text
- [ ] All targets ≥48dp
- [ ] Every screen tested at 200% text scale
- [ ] TalkBack and VoiceOver pass on the four primary flows
- [ ] Reduce-motion respected
- [ ] No state communicated by color alone

**Trust thesis**
- [ ] Every user-generated surface carries attributed identity
- [ ] No bare rating average anywhere in the codebase
- [ ] Verified badge appears only on avatars and profile rows
- [ ] Ambient verification line on Market and Tutors
- [ ] No fake urgency, no review-begging, no unlabeled promoted content

---

**The final test:** put a screenshot of your Market screen next to Reddit or Robinhood. If yours has more colors, larger text, or softer edges, keep cutting.

*When in doubt: make the trust signal more visible, make the flow shorter, and make the copy plainer.*