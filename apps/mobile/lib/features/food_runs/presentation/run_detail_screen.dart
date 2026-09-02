import 'dart:async' show unawaited;

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/reputation_chip.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/components/verified_avatar.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/food_runs/presentation/rate_run_sheet.dart';
import 'package:campusconnect/features/food_runs/presentation/run_detail_controller.dart';
import 'package:campusconnect/features/food_runs/presentation/run_format.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Run detail — one screen, three viewers (visitor / requester / runner),
/// driven purely by the response shape. Kept live by the 5s poll.
class RunDetailScreen extends ConsumerWidget {
  const RunDetailScreen({required this.runId, super.key});

  final String runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(runDetailControllerProvider(runId));
    final myId = ref.watch(authControllerProvider).user?.id;
    final run = state.run;

    return Scaffold(
      appBar: AppBar(
        title: Text(run == null ? 'Run' : '${run.foodSpot.name} run'),
      ),
      body: SafeArea(
        child: switch ((state.loading, run)) {
          (true, null) => const _DetailSkeleton(),
          (false, null) => EmptyState(
            icon: Icons.cloud_off,
            title: "Couldn't load this run",
            body: 'Check your connection and try again.',
            actionLabel: 'Retry',
            onAction: () => ref
                .read(runDetailControllerProvider(runId).notifier)
                .refresh()
                .ignore(),
          ),
          (_, final RunResponse run) => _RunDetailBody(
            run: run,
            isRunner: run.runner.id == myId,
          ),
        },
      ),
    );
  }
}

class _RunDetailBody extends ConsumerWidget {
  const _RunDetailBody({required this.run, required this.isRunner});

  final RunResponse run;
  final bool isRunner;

  /// Runs every action through one error surface (spec §6.3 — never a
  /// silent failure).
  Future<void> _act(
    BuildContext context,
    Future<void> Function() action, {
    String? success,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      if (success != null) {
        messenger.showSnackBar(SnackBar(content: Text(success)));
      }
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
  }

  void _openGroupChat(BuildContext context) {
    final conversationId = run.conversationId;
    if (conversationId == null) return;
    unawaited(
      context.push(
        '/runs/run/${run.id}/chat',
        extra: (conversationId, '${run.foodSpot.name} run'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final controller = ref.read(runDetailControllerProvider(run.id).notifier);
    final myOrder = run.myOrder;

    return ListView(
      padding: EdgeInsets.all(tokens.space4),
      children: [
        _RunHeaderCard(run: run),
        SizedBox(height: tokens.space4),
        if (isRunner)
          ..._runnerSection(context, controller)
        else if (myOrder != null)
          ..._requesterSection(context, controller, myOrder)
        else
          ..._visitorSection(context, controller),
        SizedBox(height: tokens.space8),
      ],
    );
  }

  // ── Visitor ────────────────────────────────────────────────────────────
  List<Widget> _visitorSection(
    BuildContext context,
    RunDetailController controller,
  ) {
    final tokens = context.tokens;
    final open = run.status == RunStatus.open;
    final full = run.acceptedCount >= run.spotsMax;
    return [
      if (open && !full)
        FilledButton.icon(
          icon: const Icon(Icons.add_shopping_cart_outlined),
          label: const Text('Request a spot'),
          onPressed: () => _showRequestSheet(context, controller),
        )
      else
        Container(
          padding: EdgeInsets.all(tokens.space4),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLow,
            borderRadius: tokens.brSm,
            border: Border.all(color: context.colors.outlineVariant),
          ),
          child: Text(
            full
                ? 'This run is full — keep an eye out for the next one.'
                : 'This run is no longer taking orders.',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
    ];
  }

  Future<void> _showRequestSheet(
    BuildContext context,
    RunDetailController controller,
  ) {
    final text = TextEditingController();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final tokens = sheetContext.tokens;
        return Padding(
          padding: EdgeInsets.only(
            left: tokens.space4,
            right: tokens.space4,
            top: tokens.space4,
            bottom:
                MediaQuery.viewInsetsOf(sheetContext).bottom + tokens.space6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("What's your order?", style: AppTextStyles.subheading),
              SizedBox(height: tokens.space3),
              TextField(
                controller: text,
                autofocus: true,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'e.g. Medium iced latte, oat milk, no sugar',
                ),
              ),
              SizedBox(height: tokens.space2),
              Text(
                run.prepayRequired
                    ? '${runFeeLabel(run.feeCents)} · Venmo before '
                          'pickup (runner requires prepay).'
                    : '${runFeeLabel(run.feeCents)} · pay the runner '
                          'on delivery, off-app.',
                style: sheetContext.text.bodySmall?.copyWith(
                  color: sheetContext.colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: tokens.space4),
              FilledButton(
                onPressed: () {
                  final order = text.text.trim();
                  if (order.isEmpty) return;
                  Navigator.of(sheetContext).pop();
                  _act(
                    context,
                    () => controller.requestSpot(order),
                    success: "Request sent — you'll hear back soon.",
                  ).ignore();
                },
                child: const Text('Send request'),
              ),
            ],
          ),
        );
      },
    ).whenComplete(text.dispose);
  }

  // ── Requester ──────────────────────────────────────────────────────────
  List<Widget> _requesterSection(
    BuildContext context,
    RunDetailController controller,
    RunOrderResponse order,
  ) {
    final tokens = context.tokens;
    final accepted = const {
      RunOrderStatus.accepted,
      RunOrderStatus.delivered,
      RunOrderStatus.received,
    }.contains(order.status);
    final canRate =
        run.status == RunStatus.done &&
        (order.status == RunOrderStatus.delivered ||
            order.status == RunOrderStatus.received);
    return [
      _MyOrderCard(order: order),
      if (accepted && (run.feeCents > 0 || run.prepayRequired)) ...[
        SizedBox(height: tokens.space3),
        _PaymentCard(run: run),
      ],
      if (accepted && run.conversationId != null) ...[
        SizedBox(height: tokens.space3),
        OutlinedButton.icon(
          icon: const Icon(Icons.forum_outlined),
          label: const Text('Open run group chat'),
          onPressed: () => _openGroupChat(context),
        ),
      ],
      if (order.status == RunOrderStatus.delivered) ...[
        SizedBox(height: tokens.space3),
        FilledButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Confirm received'),
          onPressed: () => _act(
            context,
            () => controller.confirmReceived(order.id),
            success: 'Enjoy! Order confirmed.',
          ),
        ),
      ],
      if (order.status == RunOrderStatus.requested) ...[
        SizedBox(height: tokens.space3),
        TextButton(
          onPressed: () => _act(
            context,
            () => controller.withdraw(order.id),
            success: 'Request withdrawn.',
          ),
          child: const Text('Withdraw request'),
        ),
      ],
      if (canRate) ...[
        SizedBox(height: tokens.space3),
        FilledButton.tonalIcon(
          icon: const Icon(Icons.star_outline),
          label: Text('Rate ${run.runner.displayName}'),
          onPressed: () => showRateRunSheet(
            context,
            ratedUserId: run.runner.id,
            ratedName: run.runner.displayName,
            orderId: order.id,
          ),
        ),
      ],
    ];
  }

  // ── Runner ─────────────────────────────────────────────────────────────
  List<Widget> _runnerSection(
    BuildContext context,
    RunDetailController controller,
  ) {
    final tokens = context.tokens;
    final orders = run.orders?.toList() ?? [];
    final unresolved = orders.any(
      (o) => o.status == RunOrderStatus.accepted,
    );
    final active = const {
      RunStatus.open,
      RunStatus.locked,
      RunStatus.atStore,
      RunStatus.delivering,
    }.contains(run.status);

    return [
      if (active) ...[
        _RunnerStatusStepper(
          run: run,
          unresolved: unresolved,
          onAdvance: (next) => _act(
            context,
            () => controller.updateStatus(next),
          ),
        ),
        SizedBox(height: tokens.space3),
      ],
      if (run.conversationId != null) ...[
        OutlinedButton.icon(
          icon: const Icon(Icons.forum_outlined),
          label: const Text('Open run group chat'),
          onPressed: () => _openGroupChat(context),
        ),
        SizedBox(height: tokens.space3),
      ],
      Padding(
        padding: EdgeInsets.only(top: tokens.space2, bottom: tokens.space2),
        child: Text('ORDERS', style: AppTextStyles.label),
      ),
      if (orders.isEmpty)
        Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.space4),
          child: Text(
            'No requests yet — they show up here the moment '
            'someone wants in.',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        )
      else
        for (final order in orders) ...[
          _OrderCard(
            order: order,
            runDone: run.status == RunStatus.done,
            onAccept: () => _act(
              context,
              () => controller.accept(order.id),
              success: '${order.requester.displayName} is in.',
            ),
            onDecline: () => _act(
              context,
              () => controller.decline(order.id),
            ),
            onDelivered: () => _act(
              context,
              () => controller.markDelivered(order.id),
            ),
            onNoShow: () => _act(
              context,
              () => controller.markNoShow(order.id),
            ),
            onRate: () => showRateRunSheet(
              context,
              ratedUserId: order.requester.id,
              ratedName: order.requester.displayName,
              orderId: order.id,
            ),
          ),
          SizedBox(height: tokens.space3),
        ],
      if (run.status == RunStatus.open || run.status == RunStatus.locked) ...[
        SizedBox(height: tokens.space2),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: context.colors.error,
          ),
          onPressed: () => _confirmCancel(context, controller),
          child: const Text('Cancel run'),
        ),
      ],
    ];
  }

  Future<void> _confirmCancel(
    BuildContext context,
    RunDetailController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this run?'),
        content: const Text(
          'Everyone who requested a spot will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel run'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      if (!context.mounted) return;
      await _act(
        context,
        controller.cancelRun,
        success: 'Run cancelled.',
      );
    }
  }
}

// ── Shared cards ─────────────────────────────────────────────────────────

/// Trust + logistics header: destination, runner card, run facts.
class _RunHeaderCard extends StatelessWidget {
  const _RunHeaderCard({required this.run});

  final RunResponse run;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final runner = run.runner;
    return Container(
      padding: EdgeInsets.all(tokens.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: tokens.brMd,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(run.foodSpot.name, style: AppTextStyles.heading),
              ),
              _DetailStatusChip(run: run),
            ],
          ),
          SizedBox(height: tokens.space4),
          Row(
            children: [
              VerifiedAvatar(name: runner.displayName),
              SizedBox(width: tokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      runner.displayName,
                      style: context.text.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: tokens.space1),
                    ReputationChip(
                      rating: runner.ratingCount > 0
                          ? runner.reputationScore.toDouble()
                          : null,
                      ratingCount: runner.ratingCount,
                      variant: ReputationVariant.compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space4),
          _InfoRow(
            icon: Icons.schedule,
            label: run.status == RunStatus.open
                ? leavingLabel(run.leavingAt)
                : runStatusLabel(run.status),
          ),
          SizedBox(height: tokens.space2),
          _InfoRow(
            icon: Icons.place_outlined,
            label: 'Drops at ${run.deliverySpot}',
          ),
          SizedBox(height: tokens.space2),
          _InfoRow(
            icon: Icons.payments_outlined,
            label: run.prepayRequired
                ? '${runFeeLabel(run.feeCents)} · prepay required'
                : runFeeLabel(run.feeCents),
          ),
          if (run.paysWithDiningDollars) ...[
            SizedBox(height: tokens.space2),
            const _InfoRow(
              icon: Icons.credit_card_outlined,
              label: 'Runner pays with dining dollars — Venmo them back',
            ),
          ],
          SizedBox(height: tokens.space2),
          _InfoRow(
            icon: Icons.group_outlined,
            label: '${run.acceptedCount}/${run.spotsMax} spots taken',
          ),
          if (run.note != null && run.note!.isNotEmpty) ...[
            SizedBox(height: tokens.space3),
            Container(
              padding: EdgeInsets.all(tokens.space3),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: tokens.brXs,
              ),
              child: Text(
                run.note!,
                style: context.text.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailStatusChip extends StatelessWidget {
  const _DetailStatusChip({required this.run});

  final RunResponse run;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = runStatusColor(context, run.status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space2,
        vertical: tokens.space1,
      ),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: .12),
        shape: const StadiumBorder(),
      ),
      child: Text(
        runStatusLabel(run.status),
        style: context.text.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.onSurfaceVariant),
        SizedBox(width: tokens.space2),
        Expanded(
          child: Text(label, style: context.text.bodyMedium),
        ),
      ],
    );
  }
}

/// The requester's own order: text + status chip.
class _MyOrderCard extends StatelessWidget {
  const _MyOrderCard({required this.order});

  final RunOrderResponse order;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final statusColor = switch (order.status) {
      RunOrderStatus.accepted ||
      RunOrderStatus.delivered ||
      RunOrderStatus.received => tokens.success,
      RunOrderStatus.requested => tokens.warning,
      _ => colors.onSurfaceVariant,
    };
    final copy = switch (order.status) {
      RunOrderStatus.requested => 'Waiting on the runner to accept.',
      RunOrderStatus.accepted => "You're in! Watch the group chat.",
      RunOrderStatus.delivered => 'Dropped off — confirm below.',
      RunOrderStatus.received => 'All done. Enjoy!',
      RunOrderStatus.declined => "The runner couldn't take this one.",
      RunOrderStatus.noShow => 'Marked as a no-show.',
      _ => 'Request withdrawn.',
    };
    return Container(
      padding: EdgeInsets.all(tokens.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: tokens.brMd,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('YOUR ORDER', style: AppTextStyles.label),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.space2,
                  vertical: tokens.space1,
                ),
                decoration: ShapeDecoration(
                  color: statusColor.withValues(alpha: .12),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  runOrderStatusLabel(order.status),
                  style: context.text.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space2),
          Text(order.orderText, style: context.text.bodyMedium),
          SizedBox(height: tokens.space2),
          Text(
            copy,
            style: context.text.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Venmo @handle · $X" — payment happens off-app, stated plainly.
class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.run});

  final RunResponse run;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final handle = run.runner.venmoHandle;
    return Container(
      padding: EdgeInsets.all(tokens.space4),
      decoration: BoxDecoration(
        color: run.prepayRequired
            ? tokens.warningContainer
            : colors.surfaceContainerLow,
        borderRadius: tokens.brSm,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: run.prepayRequired
                    ? tokens.warning
                    : colors.onSurfaceVariant,
              ),
              SizedBox(width: tokens.space2),
              Expanded(
                child: Text(
                  handle == null || handle.isEmpty
                      ? '${runFeeAmount(run.feeCents)} to the runner'
                      : 'Venmo @$handle · ${runFeeAmount(run.feeCents)}',
                  style: context.text.titleSmall,
                ),
              ),
            ],
          ),
          if (run.prepayRequired) ...[
            SizedBox(height: tokens.space2),
            Text(
              'This runner requires prepay — send it before pickup.',
              style: context.text.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Runner's walk: open → at the store → delivering → done.
class _RunnerStatusStepper extends StatelessWidget {
  const _RunnerStatusStepper({
    required this.run,
    required this.unresolved,
    required this.onAdvance,
  });

  final RunResponse run;
  final bool unresolved;
  final ValueChanged<RunStatus> onAdvance;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final (next, label, icon) = switch (run.status) {
      RunStatus.open || RunStatus.locked => (
        RunStatus.atStore,
        "I'm at the store",
        Icons.storefront_outlined,
      ),
      RunStatus.atStore => (
        RunStatus.delivering,
        'Heading back — delivering',
        Icons.directions_run,
      ),
      _ => (RunStatus.done, 'Wrap up run', Icons.flag_outlined),
    };
    final blocked = next == RunStatus.done && unresolved;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          icon: Icon(icon),
          label: Text(label),
          onPressed: blocked ? null : () => onAdvance(next),
        ),
        if (blocked) ...[
          SizedBox(height: tokens.space2),
          Text(
            'Mark every accepted order delivered or no-show before '
            'wrapping up.',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// One incoming order on the runner's screen: trust row + order text +
/// the actions legal for its status.
class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.runDone,
    required this.onAccept,
    required this.onDecline,
    required this.onDelivered,
    required this.onNoShow,
    required this.onRate,
  });

  final RunOrderResponse order;
  final bool runDone;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onDelivered;
  final VoidCallback onNoShow;
  final VoidCallback onRate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final requester = order.requester;
    final canRate =
        runDone &&
        (order.status == RunOrderStatus.delivered ||
            order.status == RunOrderStatus.received);
    return Container(
      padding: EdgeInsets.all(tokens.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: tokens.brMd,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VerifiedAvatar(
                name: requester.displayName,
                size: AvatarSize.sm,
              ),
              SizedBox(width: tokens.space2),
              Expanded(
                child: Text(
                  requester.displayName,
                  style: context.text.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ReputationChip(
                rating: requester.ratingCount > 0
                    ? requester.reputationScore.toDouble()
                    : null,
                ratingCount: requester.ratingCount,
                variant: ReputationVariant.compact,
              ),
            ],
          ),
          SizedBox(height: tokens.space2),
          Text(order.orderText, style: context.text.bodyMedium),
          SizedBox(height: tokens.space3),
          switch (order.status) {
            RunOrderStatus.requested => Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ),
                SizedBox(width: tokens.space2),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    child: const Text('Decline'),
                  ),
                ),
              ],
            ),
            RunOrderStatus.accepted => Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onDelivered,
                    child: const Text('Delivered'),
                  ),
                ),
                SizedBox(width: tokens.space2),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onNoShow,
                    child: const Text('No-show'),
                  ),
                ),
              ],
            ),
            _ => Row(
              children: [
                Expanded(
                  child: Text(
                    runOrderStatusLabel(order.status),
                    style: context.text.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (canRate)
                  TextButton.icon(
                    onPressed: onRate,
                    icon: const Icon(Icons.star_outline, size: 18),
                    label: const Text('Rate'),
                  ),
              ],
            ),
          },
        ],
      ),
    );
  }
}

/// Skeleton matching the header-card geometry (spec §13.1).
class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return ListView(
      padding: EdgeInsets.all(tokens.space4),
      children: [
        Container(
          padding: EdgeInsets.all(tokens.space4),
          decoration: BoxDecoration(
            borderRadius: tokens.brMd,
            border: Border.all(color: colors.outlineVariant),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 200, height: 26),
              SizedBox(height: 16),
              Row(
                children: [
                  SkeletonBox(width: 40, height: 40, shape: BoxShape.circle),
                  SizedBox(width: 12),
                  SkeletonBox(width: 140, height: 16),
                ],
              ),
              SizedBox(height: 16),
              SkeletonBox(width: 180, height: 14),
              SizedBox(height: 8),
              SkeletonBox(width: 220, height: 14),
              SizedBox(height: 8),
              SkeletonBox(width: 120, height: 14),
            ],
          ),
        ),
      ],
    );
  }
}
