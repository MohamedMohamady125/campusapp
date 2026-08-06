import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Delivery state of a message (spec §10.5).
enum MessageStatus { sending, sent, failed }

/// Chat bubble (spec §10.5, Fifty Free §4).
///
/// Mine: solid `primary` blue with white text, right-aligned, 4dp
/// bottom-right corner. Theirs: `surfaceContainerLow`, left-aligned,
/// 4dp bottom-left corner.
/// Max width 78% of the screen. Failed messages get a 2dp error left edge
/// and a tappable "Tap to retry" — an icon + text, never colour alone.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.body,
    required this.isMine,
    super.key,
    this.timestamp,
    this.status = MessageStatus.sent,
    this.showTimestamp = false,
    this.onRetry,
    this.onLongPress,
  });

  final String body;
  final bool isMine;
  final String? timestamp;
  final MessageStatus status;
  final bool showTimestamp;
  final VoidCallback? onRetry;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final failed = status == MessageStatus.failed;

    final round = Radius.circular(tokens.radiusLg);
    final radius = BorderRadius.only(
      topLeft: round,
      topRight: round,
      bottomLeft: isMine ? round : const Radius.circular(4),
      bottomRight: isMine ? const Radius.circular(4) : round,
    );

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.78,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space3,
        vertical: tokens.space2,
      ),
      decoration: BoxDecoration(
        color: isMine ? colors.primary : colors.surfaceContainerLow,
        borderRadius: radius,
        border: failed
            ? Border(left: BorderSide(color: colors.error, width: 2))
            : null,
      ),
      child: Text(
        body,
        style: context.text.bodyLarge?.copyWith(
          color: isMine ? colors.onPrimary : colors.onSurface,
        ),
      ),
    );

    return Semantics(
      label: failed ? 'Message failed to send. Tap to retry.' : null,
      child: Column(
        crossAxisAlignment: isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: failed ? onRetry : null,
            onLongPress: onLongPress,
            child: bubble,
          ),
          if (failed)
            Padding(
              padding: EdgeInsets.only(top: tokens.space1),
              child: GestureDetector(
                onTap: onRetry,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 14, color: colors.error),
                    SizedBox(width: tokens.space1),
                    Text(
                      'Tap to retry',
                      style: context.text.bodySmall?.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (showTimestamp && timestamp != null)
            Padding(
              padding: EdgeInsets.only(top: tokens.space1),
              child: Opacity(
                opacity: status == MessageStatus.sending ? 0.6 : 1,
                child: Text(
                  status == MessageStatus.sending ? 'Sending…' : timestamp!,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
