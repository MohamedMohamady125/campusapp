import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Display variants for [ReputationChip] (spec §10.2).
enum ReputationVariant { compact, standard, detailed }

/// The single most-reused trust component (spec §4.2, §10.2).
///
/// Rules enforced here so they cannot be violated at call sites:
/// - `rating == null || ratingCount == 0` renders `New member`. No exceptions.
/// - Rating formatted to exactly one decimal, truncated, never rounded up.
/// - The count is shown by default — it is half the signal. Dense surfaces
///   (e.g. the runs feed card) may opt out with `showCount: false`, but the
///   count still shows wherever a trust decision is made (profile, detail).
class ReputationChip extends StatelessWidget {
  const ReputationChip({
    required this.rating,
    required this.ratingCount,
    super.key,
    this.marketplaceCount,
    this.tutoringCount,
    this.variant = ReputationVariant.standard,
    this.showCount = true,
    this.onTap,
  });

  /// Bayesian-adjusted average; null when the user has no ratings.
  final double? rating;
  final int ratingCount;
  final int? marketplaceCount;
  final int? tutoringCount;
  final ReputationVariant variant;

  /// Whether to render the rating count (`· 12`). Off only on dense surfaces.
  final bool showCount;
  final VoidCallback? onTap;

  /// One decimal place, truncated: 4.749 displays as 4.7 (spec §4.2).
  static String formatRating(double value) =>
      ((value * 10).floor() / 10).toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;

    if (rating == null || ratingCount == 0) {
      // Honest neutral state — never 0.0 stars, never a fake 5.0.
      return Semantics(
        label: 'New member, no ratings yet',
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space3,
            vertical: tokens.space1,
          ),
          decoration: ShapeDecoration(
            color: colors.surfaceContainerHighest,
            shape: const StadiumBorder(),
          ),
          child: Text(
            'New member',
            style: context.text.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final value = formatRating(rating!);
    final compact = variant == ReputationVariant.compact;
    final countLabel = compact ? '$ratingCount' : '$ratingCount ratings';

    // Per-variant type (whole.md §4.2): compact = star 10, value 11/w600
    // onSurfaceVariant; standard/detailed = star 14, value 13/w600 onSurface.
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: compact ? 10 : 14,
          color: tokens.ratingStar,
        ),
        SizedBox(width: tokens.space1),
        Text(
          value,
          style: context.text.labelSmall?.copyWith(
            fontSize: compact ? 11 : 13,
            fontWeight: FontWeight.w600,
            color: compact ? colors.onSurfaceVariant : colors.onSurface,
          ),
        ),
        if (showCount)
          Text(
            ' · $countLabel',
            style: context.text.labelSmall?.copyWith(
              fontSize: compact ? 11 : 13,
              color: colors.onSurfaceVariant.withValues(
                alpha: compact ? .8 : 1,
              ),
            ),
          ),
      ],
    );

    Widget child = row;
    if (variant == ReputationVariant.detailed &&
        (marketplaceCount != null || tutoringCount != null)) {
      // Portable-reputation disclosure (spec §4.3).
      final parts = <String>[
        if (marketplaceCount != null) '$marketplaceCount from marketplace',
        if (tutoringCount != null) '$tutoringCount from tutoring',
      ];
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          row,
          SizedBox(height: tokens.space1),
          Text(
            parts.join(' · '),
            style: context.text.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Semantics(
      label: 'Rated $value out of 5, from $ratingCount ratings',
      button: onTap != null,
      child: ExcludeSemantics(
        child: onTap == null
            ? child
            : InkWell(
                onTap: onTap,
                borderRadius: tokens.brSm,
                child: child,
              ),
      ),
    );
  }
}
