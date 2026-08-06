import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusconnect/design_system/components/pressable.dart';
import 'package:campusconnect/design_system/components/reputation_chip.dart';
import 'package:campusconnect/design_system/components/verified_avatar.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Optional status pill on the photo (spec §10.3).
enum ListingCardStatus { none, isNew, reserved, expiring, sold }

/// Fixed content-block height below the 4:3 image (whole.md §4.3).
///
/// 12 pad + 20 price + 4 gap + 34 title (2 lines reserved) + 8 gap +
/// 20 seller row + 4 gap + 16 meta + 12 pad = 130. Grids must size cells as
/// `colWidth * 3/4 + kListingCardContentHeight` — never guess aspect ratios.
const double kListingCardContentHeight = 130;

/// Marketplace grid card (whole.md §4.3).
///
/// The whole card is one tap target — no nested buttons; nested targets in a
/// grid are a mis-tap factory. Long-press opens save/share/report. The
/// 2-line title box is reserved whether the title fills it or not: that is
/// what prevents clipping and keeps the grid regular.
class ListingCard extends StatelessWidget {
  const ListingCard({
    required this.title,
    required this.priceLabel,
    required this.sellerName,
    required this.onTap,
    super.key,
    this.imageUrl,
    this.rating,
    this.ratingCount = 0,
    this.metaLabel,
    this.status = ListingCardStatus.none,
    this.onLongPress,
    this.heroTag,
    this.placeholderIcon,
  });

  final String title;
  final String priceLabel;
  final String sellerName;
  final String? imageUrl;
  final double? rating;
  final int ratingCount;

  /// e.g. `2h · Like new`
  final String? metaLabel;
  final ListingCardStatus status;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Object? heroTag;

  /// Category-specific placeholder icon shown when there is no photo —
  /// never one generic photo glyph (whole.md §4.3).
  final IconData? placeholderIcon;

  String? get _statusLabel => switch (status) {
    ListingCardStatus.none => null,
    ListingCardStatus.isNew => 'New',
    ListingCardStatus.reserved => 'Reserved',
    ListingCardStatus.expiring => 'Expiring',
    ListingCardStatus.sold => 'Sold',
  };

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;

    Widget image = AspectRatio(
      aspectRatio: 4 / 3,
      child: imageUrl == null || imageUrl!.isEmpty
          ? ColoredBox(
              color: colors.surfaceContainerHighest,
              child: Icon(
                placeholderIcon ?? Icons.image_outlined,
                size: 26,
                color: colors.onSurfaceVariant.withValues(alpha: .4),
              ),
            )
          : CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  ColoredBox(color: colors.surfaceContainerHighest),
              errorWidget: (_, _, _) =>
                  ColoredBox(color: colors.surfaceContainerHighest),
            ),
    );
    if (heroTag != null) image = Hero(tag: heroTag!, child: image);

    return MergeSemantics(
      child: Pressable(
        onTap: onTap,
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    image,
                    if (_statusLabel != null)
                      Positioned(
                        left: tokens.space2,
                        top: tokens.space2,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: tokens.space2,
                            vertical: tokens.space1 / 2,
                          ),
                          decoration: ShapeDecoration(
                            color: status == ListingCardStatus.expiring
                                ? tokens.warningContainer
                                : colors.surfaceContainerHigh,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            _statusLabel!,
                            style: context.text.labelSmall?.copyWith(
                              color: status == ListingCardStatus.expiring
                                  ? tokens.warning
                                  : colors.onSurface,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // Fixed 118dp content block (whole.md §4.3) — the 2-line
                // title box is reserved whether the title fills it or not.
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        priceLabel,
                        // Inter w700 tabular figures — same 20dp line as before
                        // (16 * 1.2); geometry is load-bearing (see const doc).
                        style: AppTextStyles.statSmall.copyWith(
                          color: colors.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 34,
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(
                            fontSize: 13,
                            height: 1.3,
                            color: colors.onSurface.withValues(alpha: .85),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 20,
                        child: Row(
                          children: [
                            VerifiedAvatar(
                              name: sellerName,
                              size: AvatarSize.xs,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                sellerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.labelSmall?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ReputationChip(
                              rating: rating,
                              ratingCount: ratingCount,
                              variant: ReputationVariant.compact,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 16,
                        child: metaLabel == null
                            ? null
                            : Text(
                                metaLabel!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.labelSmall?.copyWith(
                                  fontSize: 11,
                                  color: colors.onSurfaceVariant.withValues(
                                    alpha: .8,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
