import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/material.dart';

/// Deep-link target for a notification: `(location, extra title)`.
typedef NotificationRoute = (String location, String? title);

String? _str(NotificationResponse n, String key) {
  final value = n.payload[key];
  return value != null && value.isString ? value.asString : null;
}

int _count(NotificationResponse n) {
  final value = n.payload['count'];
  return value != null && value.isNum ? value.asNum.toInt() : 1;
}

/// Human title per Sprint 6 render rules. Unknown/legacy payloads (missing
/// names, unrecognised types) fall back to a generic line — never crash.
String notificationTitle(NotificationResponse n) {
  final sender = _str(n, 'sender_name');
  final chatName = _str(n, 'chat_name');
  final count = _count(n);
  final more = count - 1 == 1 ? '1 more message' : '${count - 1} more messages';
  switch (n.type) {
    case 'chat_message':
      if (sender == null || chatName == null) break;
      return count > 1
          ? '$sender and $more in $chatName'
          : '$sender in $chatName';
    case 'chat_mention':
      if (sender == null || chatName == null) break;
      return '$sender mentioned you in $chatName';
    case 'dm_message':
      if (sender == null) break;
      return count > 1 ? '$sender and $more' : '$sender sent you a message';
  }
  return 'You have a new notification';
}

/// Where tapping the notification should navigate, or null for legacy types.
NotificationRoute? notificationRoute(NotificationResponse n) {
  switch (n.type) {
    case 'chat_message' || 'chat_mention':
      final chatId = _str(n, 'chat_id');
      if (chatId == null) return null;
      return ('/chats/room/$chatId', _str(n, 'chat_name'));
    case 'dm_message':
      final conversationId = _str(n, 'conversation_id');
      if (conversationId == null) return null;
      return ('/chats/conversation/$conversationId', _str(n, 'sender_name'));
  }
  return null;
}

/// Leading icon per type; mentions are visually distinct (brand blue @).
IconData notificationIcon(NotificationResponse n) => switch (n.type) {
  'chat_message' => Icons.chat_bubble_outline,
  'chat_mention' => Icons.alternate_email,
  'dm_message' => Icons.mail_outline,
  _ => Icons.notifications_none,
};

/// Whether the leading icon gets the brand-blue mention treatment.
bool notificationIsMention(NotificationResponse n) => n.type == 'chat_mention';

/// Short relative timestamp, matching the marketplace card style.
String notificationRelativeTime(DateTime time, {DateTime? now}) {
  final delta = (now ?? DateTime.now().toUtc()).difference(time.toUtc());
  if (delta.inMinutes < 1) return 'Just now';
  if (delta.inMinutes < 60) return '${delta.inMinutes}m';
  if (delta.inHours < 24) return '${delta.inHours}h';
  if (delta.inDays < 7) return '${delta.inDays}d';
  return '${delta.inDays ~/ 7}w';
}
