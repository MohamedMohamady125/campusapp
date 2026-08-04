import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusconnect/design_system/components/reputation_chip.dart';
import 'package:campusconnect/design_system/components/verified_avatar.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Optional status pill on the photo (spec §10.3).
enum ListingCardStatus { none, isNew, reserved, expiring, sold }

/// Marketplace grid card, 2-up (spec §10.3).
///
/// The whole card is one tap target — no nested buttons; nested targets in a
/// 2-up grid are a mis-tap factory. Long-press opens save/share/report.
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
  });

  final String title;
  final String priceLabel;
  final String sellerName;
  final String? imageUrl;
  final double? rating;
  final int ratingCount;

  /// e.g. `2h ago · Like new`
  final String? metaLabel;
  final ListingCardStatus status;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Object? heroTag;

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
      aspectRatio: 1,
      child: imageUrl == null || imageUrl!.isEmpty
          ? ColoredBox(
              color: colors.surfaceContainerHighest,
              child: Icon(
                Icons.image_outlined,
                color: colors.onSurfaceVariant,
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
      child: Card(
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
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
              // Flexible so a 2-line title compresses inside a fixed grid
              // cell instead of overflowing it.
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(tokens.space3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        priceLabel,
                        style: context.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: tokens.price,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      SizedBox(height: tokens.space1),
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleMedium,
                        ),
                      ),
                      SizedBox(height: tokens.space2),
                      Row(
                        children: [
                          VerifiedAvatar(
                            name: sellerName,
                            size: AvatarSize.xs,
                          ),
                          SizedBox(width: tokens.space1),
                          Flexible(
                            child: Text(
                              sellerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: tokens.space2),
                          ReputationChip(
                            rating: rating,
                            ratingCount: ratingCount,
                            variant: ReputationVariant.compact,
                          ),
                        ],
                      ),
                      if (metaLabel != null) ...[
                        SizedBox(height: tokens.space1),
                        Text(
                          metaLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
