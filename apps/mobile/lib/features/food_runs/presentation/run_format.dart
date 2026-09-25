import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Fee cents as a chip label: `Free`, `$2 fee`, `$2.50 fee`.
String runFeeLabel(int cents) {
  if (cents == 0) return 'Free';
  final dollars = cents % 100 == 0
      ? '\$${cents ~/ 100}'
      : '\$${(cents / 100).toStringAsFixed(2)}';
  return '$dollars fee';
}

/// Fee cents as a plain amount: `$2`, `$2.50`.
String runFeeAmount(int cents) => cents % 100 == 0
    ? '\$${cents ~/ 100}'
    : '\$${(cents / 100).toStringAsFixed(2)}';

/// The exact departure time for the leaving chip, e.g. `Leaving 3:45 PM`.
/// A day prefix is added when the run isn't today (`Leaving tomorrow 8:00 AM`,
/// `Leaving Fri 9:15 AM`) so the time is never ambiguous.
String leavingLabel(DateTime leavingAt, {DateTime? now}) {
  final local = leavingAt.toLocal();
  final current = (now ?? DateTime.now()).toLocal();
  final prefix = _dayPrefix(local, current);
  final time = clockTime(local);
  return prefix == null ? 'Leaving $time' : 'Leaving $prefix $time';
}

/// 12-hour clock label with an AM/PM suffix, e.g. `3:45 PM`, `12:00 AM`.
String clockTime(DateTime dt) {
  final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour < 12 ? 'AM' : 'PM';
  return '$hour12:$minute $period';
}

String? _dayPrefix(DateTime dt, DateTime now) {
  final target = DateTime(dt.year, dt.month, dt.day);
  final today = DateTime(now.year, now.month, now.day);
  final days = target.difference(today).inDays;
  if (days == 0) return null;
  if (days == 1) return 'tomorrow';
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return weekdays[dt.weekday - 1];
}

/// Human label per run status.
String runStatusLabel(RunStatus status) => switch (status) {
  RunStatus.open => 'Open',
  RunStatus.locked => 'Locked',
  RunStatus.atStore => 'At the store',
  RunStatus.delivering => 'Delivering',
  RunStatus.done => 'Done',
  RunStatus.expired => 'Expired',
  RunStatus.cancelled => 'Cancelled',
  _ => 'Run',
};

/// Status accent color from tokens (§6.1 semantic colors, never hardcoded).
Color runStatusColor(BuildContext context, RunStatus status) {
  final tokens = context.tokens;
  final colors = context.colors;
  return switch (status) {
    RunStatus.open => tokens.success,
    RunStatus.atStore || RunStatus.delivering => tokens.warning,
    RunStatus.done => tokens.success,
    RunStatus.locked => colors.onSurfaceVariant,
    _ => colors.onSurfaceVariant,
  };
}

/// Human label per order status (requester timeline chip).
String runOrderStatusLabel(RunOrderStatus status) => switch (status) {
  RunOrderStatus.requested => 'Requested',
  RunOrderStatus.accepted => 'Accepted',
  RunOrderStatus.declined => 'Declined',
  RunOrderStatus.cancelled => 'Withdrawn',
  RunOrderStatus.delivered => 'Delivered',
  RunOrderStatus.received => 'Received',
  RunOrderStatus.noShow => 'No-show',
  _ => 'Order',
};
