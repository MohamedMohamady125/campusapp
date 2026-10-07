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
    case 'run_request':
      final requester = _str(n, 'requester_name');
      final spot = _str(n, 'spot_name');
      if (requester == null || spot == null) return 'New order request';
      return '$requester wants in on your $spot run';
    case 'run_request_accepted':
      final spot = _str(n, 'spot_name');
      return spot == null
          ? "You're in! Your order was accepted"
          : "You're in! Your $spot order was accepted";
    case 'run_request_declined':
      final spot = _str(n, 'spot_name');
      return spot == null
          ? "The runner couldn't take your order"
          : "The runner couldn't take your $spot order";
    case 'run_status':
      return _runStatusTitle(n);
    case 'run_completed':
      return 'Run complete — rate your runner';
  }
  return 'You have a new notification';
}

/// Friendly copy per run-status update payload.
String _runStatusTitle(NotificationResponse n) {
  final spot = _str(n, 'spot_name');
  switch (_str(n, 'run_status')) {
    case 'at_store':
      return spot == null
          ? 'Your runner is at the store'
          : 'Your runner is at $spot';
    case 'delivering':
      return 'Your order is on its way';
    case 'cancelled':
      return spot == null
          ? 'That run was cancelled'
          : 'The $spot run was cancelled';
  }
  return 'Your run has an update';
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
      // /messages sits outside the flag-hidden /chats branch, so DM deep
      // links (run chats included) work while the Chats tab is off.
      return ('/messages/$conversationId', _str(n, 'sender_name'));
    case 'run_request' ||
        'run_request_accepted' ||
        'run_request_declined' ||
        'run_status' ||
        'run_completed':
      final runId = _str(n, 'run_id');
      if (runId == null) return null;
      return ('/runs/run/$runId', _str(n, 'spot_name'));
  }
  return null;
}

/// Leading icon per type; mentions are visually distinct (brand blue @).
IconData notificationIcon(NotificationResponse n) => switch (n.type) {
  'chat_message' => Icons.chat_bubble_outline,
  'chat_mention' => Icons.alternate_email,
  'dm_message' => Icons.mail_outline,
  'run_request' => Icons.fastfood_outlined,
  'run_request_accepted' || 'run_completed' => Icons.check_circle_outline,
  'run_request_declined' => Icons.remove_circle_outline,
  'run_status' => Icons.directions_run,
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
