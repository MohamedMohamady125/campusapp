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

/// Countdown copy for the leaving chip. Recomputed on every poll so it
/// stays live-ish without a per-second ticker.
String leavingLabel(DateTime leavingAt, {DateTime? now}) {
  final delta = leavingAt.toUtc().difference((now ?? DateTime.now()).toUtc());
  if (delta.inMinutes < 1) return 'Leaving now';
  if (delta.inMinutes < 60) return 'Leaving in ${delta.inMinutes}m';
  final hours = delta.inHours;
  final minutes = delta.inMinutes % 60;
  return minutes == 0
      ? 'Leaving in ${hours}h'
      : 'Leaving in ${hours}h ${minutes}m';
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
