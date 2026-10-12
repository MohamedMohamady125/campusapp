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
    case 'run_runner_arrived':
      final dropoff = _str(n, 'dropoff');
      return dropoff == null
          ? 'Your runner is here — you have 5 minutes!'
          : 'Your runner is at $dropoff — you have 5 minutes!';
    case 'run_no_show':
      final dropoff = _str(n, 'dropoff');
      return dropoff == null
          ? 'Your order was marked a no-show'
          : 'Your $dropoff order was marked a no-show';
    case 'run_payment_submitted':
      final requester = _str(n, 'requester_name');
      return requester == null
          ? 'Payment proof received'
          : '$requester sent payment proof';
    case 'run_payment_confirmed':
      return 'Runner confirmed your payment';
    case 'run_price_final':
      return _priceFinalTitle(n);
    case 'run_order_withdrawn':
      final requester = _str(n, 'requester_name');
      final spot = _str(n, 'spot_name');
      if (requester == null || spot == null) return 'An order was withdrawn';
      return '$requester withdrew their $spot order';
    case 'run_settle_reminder':
      return _settleReminderTitle(n);
    case 'rating_received':
      final rater = _str(n, 'rater_name');
      final stars = _str(n, 'stars');
      if (rater == null || stars == null) return 'You got a new rating';
      return '$rater rated you $stars★';
    case 'admin_message':
      // Staff announcement: render the admin's copy verbatim.
      return _str(n, 'title') ?? 'Announcement';
  }
  return 'You have a new notification';
}

/// Secondary line under the title, or null when the type has none.
/// Announcements carry free-form staff copy worth showing in the feed.
String? notificationBody(NotificationResponse n) {
  if (n.type != 'admin_message') return null;
  final body = _str(n, 'body');
  return body == null || body.isEmpty ? null : body;
}

/// Settle-up headline: exact dollars, loud (payment-terms rule — money
/// copy is exempt from the copy diet).
String _priceFinalTitle(NotificationResponse n) {
  final delta = int.tryParse(_str(n, 'delta_cents') ?? '');
  final actual = int.tryParse(_str(n, 'actual_price_cents') ?? '');
  if (delta == null || actual == null) return 'Final price for your order';
  String money(int cents) => cents % 100 == 0
      ? '\$${cents ~/ 100}'
      : '\$${(cents / 100).toStringAsFixed(2)}';
  // No estimate on file (post-prepay flow): delta == actual, so the
  // "more than your estimate" framing would mislead — just state the total.
  if (delta == actual) {
    return 'Items came to ${money(actual)} — pay at handoff';
  }
  if (delta > 0) {
    return 'Items came to ${money(actual)} — you owe ${money(delta)} more';
  }
  if (delta < 0) {
    return 'Items came to ${money(actual)} — '
        '${money(-delta)} back to you';
  }
  return 'Items came to ${money(actual)} — exactly your estimate';
}

/// Settle-up nudge: exact dollars, loud (payment-terms rule — money copy
/// is exempt from the copy diet).
String _settleReminderTitle(NotificationResponse n) {
  final runner = _str(n, 'runner_name') ?? 'your runner';
  final owed = int.tryParse(_str(n, 'owed_cents') ?? '');
  if (owed == null) return 'Settle up — you still owe $runner';
  final money = owed % 100 == 0
      ? '\$${owed ~/ 100}'
      : '\$${(owed / 100).toStringAsFixed(2)}';
  return 'Settle up — you still owe $runner $money';
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
        'run_completed' ||
        'run_runner_arrived' ||
        'run_no_show' ||
        'run_payment_submitted' ||
        'run_payment_confirmed' ||
        'run_price_final' ||
        'run_order_withdrawn' ||
        'run_settle_reminder':
      final runId = _str(n, 'run_id');
      if (runId == null) return null;
      return ('/runs/run/$runId', _str(n, 'spot_name'));
    case 'rating_received':
      // Your own profile is where the new star shows up.
      return ('/profile', null);
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
  'run_runner_arrived' => Icons.hail_rounded,
  'run_no_show' => Icons.timer_off_outlined,
  'run_payment_submitted' ||
  'run_payment_confirmed' ||
  'run_price_final' ||
  'run_settle_reminder' => Icons.account_balance_wallet_outlined,
  'run_order_withdrawn' => Icons.undo_rounded,
  'rating_received' => Icons.star_outline_rounded,
  'admin_message' => Icons.campaign_outlined,
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
