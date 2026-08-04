import 'package:campusconnect/design_system/components/verified_avatar.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Thread list row, 72dp (spec §10.5).
///
/// Unread is signalled by badge + weight, never colour alone (spec §15.5).
class ChatListRow extends StatelessWidget {
  const ChatListRow({
    required this.name,
    required this.preview,
    required this.onTap,
    super.key,
    this.avatarUrl,
    this.timestamp,
    this.unreadCount = 0,
    this.contextLabel,
    this.online = false,
  });

  final String name;
  final String preview;
  final String? avatarUrl;
  final String? timestamp;
  final int unreadCount;

  /// Origin label, e.g. `About: Calculus Early Trans…` or a course code.
  final String? contextLabel;
  final bool online;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final unread = unreadCount > 0;

    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space4,
            vertical: tokens.space3,
          ),
          child: Row(
            children: [
              VerifiedAvatar(
                name: name,
                imageUrl: avatarUrl,
                size: AvatarSize.lg,
                online: online,
              ),
              SizedBox(width: tokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall,
                    ),
                    if (contextLabel != null)
                      Text(
                        contextLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    SizedBox(height: tokens.space1),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: tokens.space2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (timestamp != null)
                    Text(
                      timestamp!,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  if (unread) ...[
                    SizedBox(height: tokens.space1),
                    Badge.count(
                      count: unreadCount,
                      backgroundColor: colors.primary,
                      textColor: colors.onPrimary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
