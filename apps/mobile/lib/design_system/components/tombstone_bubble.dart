import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Tombstone for a moderator-deleted chat message (Sprint 6).
///
/// Muted `surfaceContainer` fill, italic tertiary text, a shield icon, and
/// the moderation reason underneath. Deliberately not tappable — there is
/// nothing to do with a removed message.
class TombstoneBubble extends StatelessWidget {
  const TombstoneBubble({
    required this.isMine,
    super.key,
    this.deletedByName,
    this.reason,
  });

  final bool isMine;
  final String? deletedByName;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final byLine = deletedByName == null
        ? 'Removed by moderator'
        : 'Removed by $deletedByName';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space3,
          vertical: tokens.space2,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 14,
                  color: colors.onSurfaceVariant,
                ),
                SizedBox(width: tokens.space1),
                Flexible(
                  child: Text(
                    byLine,
                    style: context.text.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            if (reason != null && reason!.isNotEmpty) ...[
              SizedBox(height: tokens.space1),
              Text(
                'Reason: $reason',
                style: context.text.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
