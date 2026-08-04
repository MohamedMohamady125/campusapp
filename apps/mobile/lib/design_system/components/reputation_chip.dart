import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Display variants for [ReputationChip] (spec §10.2).
enum ReputationVariant { compact, standard, detailed }

/// The single most-reused trust component (spec §4.2, §10.2).
///
/// Rules enforced here so they cannot be violated at call sites:
/// - `rating == null || ratingCount == 0` renders `New member`. No exceptions.
/// - Rating formatted to exactly one decimal, truncated, never rounded up.
/// - The count is never hidden — it is half the signal.
class ReputationChip extends StatelessWidget {
  const ReputationChip({
    required this.rating,
    required this.ratingCount,
    super.key,
    this.marketplaceCount,
    this.tutoringCount,
    this.variant = ReputationVariant.standard,
    this.onTap,
  });

  /// Bayesian-adjusted average; null when the user has no ratings.
  final double? rating;
  final int ratingCount;
  final int? marketplaceCount;
  final int? tutoringCount;
  final ReputationVariant variant;
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
    final countLabel = variant == ReputationVariant.compact
        ? '$ratingCount'
        : '$ratingCount ratings';

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 14, color: tokens.ratingStar),
        SizedBox(width: tokens.space1),
        Text(
          value,
          style: context.text.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        Text(
          ' · $countLabel',
          style: context.text.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
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
