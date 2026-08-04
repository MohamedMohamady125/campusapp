import 'package:campusconnect/design_system/components/reputation_chip.dart';
import 'package:campusconnect/design_system/components/verified_avatar.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Tutor list row, min 88dp (spec §10.4).
///
/// The course signal row is the domain-specific trust signal — it carries
/// more weight here than on a listing card. Each card carries a
/// plain-language rank reason (P5 — explain the algorithm).
class TutorCard extends StatelessWidget {
  const TutorCard({
    required this.name,
    required this.courseSignal,
    required this.onTap,
    required this.onMessage,
    super.key,
    this.avatarUrl,
    this.rating,
    this.ratingCount = 0,
    this.rankReason,
    this.promoted = false,
  });

  final String name;

  /// e.g. `CS250 · A · Last fall`
  final String courseSignal;

  /// Plain-language reason for the rank, e.g.
  /// `Usually replies within an hour` (spec §4.4).
  final String? rankReason;
  final String? avatarUrl;
  final double? rating;
  final int ratingCount;
  final bool promoted;
  final VoidCallback onTap;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;

    return Card(
      color: promoted ? colors.surfaceContainer : null,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 88),
          child: Padding(
            padding: EdgeInsets.all(tokens.space3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (promoted) ...[
                  Text(
                    'Promoted',
                    style: context.text.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: tokens.space1),
                ],
                // No MergeSemantics: letting the texts merge up into the
                // InkWell's semantics node gives the tap target its label.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VerifiedAvatar(
                      name: name,
                      imageUrl: avatarUrl,
                      size: AvatarSize.lg,
                    ),
                    SizedBox(width: tokens.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: context.text.titleMedium),
                          SizedBox(height: tokens.space1),
                          Text(
                            courseSignal,
                            style: context.text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (rankReason != null) ...[
                            SizedBox(height: tokens.space1),
                            Row(
                              children: [
                                Icon(
                                  Icons.bolt,
                                  size: 14,
                                  color: colors.onSurfaceVariant,
                                ),
                                SizedBox(width: tokens.space1),
                                Flexible(
                                  child: Text(
                                    rankReason!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.text.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
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
                SizedBox(height: tokens.space2),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    onPressed: onMessage,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(64, 40),
                    ),
                    child: const Text('Message'),
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
