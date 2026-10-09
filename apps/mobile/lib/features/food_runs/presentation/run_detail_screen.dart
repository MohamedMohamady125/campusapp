import 'dart:async' show unawaited;

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/components/confetti_burst.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/reputation_chip.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/components/slide_to_confirm.dart';
import 'package:campusconnect/design_system/components/swipe_action.dart';
import 'package:campusconnect/design_system/components/verified_avatar.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_colors.dart';
import 'package:campusconnect/design_system/theme/app_motion.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/food_runs/presentation/live_map_card.dart';
import 'package:campusconnect/features/food_runs/presentation/no_show_countdown.dart';
import 'package:campusconnect/features/food_runs/presentation/payment_method_display.dart';
import 'package:campusconnect/features/food_runs/presentation/rate_run_sheet.dart';
import 'package:campusconnect/features/food_runs/presentation/run_detail_controller.dart';
import 'package:campusconnect/features/food_runs/presentation/run_format.dart';
import 'package:campusconnect/features/food_runs/presentation/runner_location_broadcaster.dart';
import 'package:campusconnect/features/food_runs/presentation/runner_route_card.dart';
import 'package:campusconnect/features/food_runs/presentation/spot_image.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Run detail — one screen, three viewers (visitor / requester / runner),
/// driven purely by the response shape. Kept live by the 5s poll.
class RunDetailScreen extends ConsumerWidget {
  const RunDetailScreen({required this.runId, super.key});

  final String runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(runDetailControllerProvider(runId));
    final run = state.run;

    return Scaffold(
      appBar: AppBar(
        title: Text(run == null ? 'Run' : run.foodSpot.name),
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
            // Server-authoritative: never derived from a client id compare —
            // a not-yet-loaded profile used to demote the runner to visitor
            // and show them "Request a spot" on their own run.
            isRunner: run.isMine ?? false,
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
  /// silent failure). Returns true on success so callers can chain
  /// celebration moments.
  Future<bool> _act(
    BuildContext context,
    Future<void> Function() action, {
    String? success,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      // A crisp confirmation tick on every committed run action — the
      // "satisfying button" feel (honours the OS haptic setting).
      unawaited(HapticFeedback.selectionClick());
      if (success != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(success)),
              ],
            ),
          ),
        );
      }
      return true;
    } on Object catch (e) {
      unawaited(HapticFeedback.heavyImpact());
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
      return false;
    }
  }

  /// Opens (or resumes) the 1:1 run chat for [orderId] — strictly between
  /// the runner and that order's requester (DoorDash-style order chat).
  Future<void> _openRunChat(
    BuildContext context,
    WidgetRef ref, {
    required String recipientId,
    required String recipientName,
    required String orderId,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final convo = await ref
          .read(conversationsRepositoryProvider)
          .openConversation(
            recipientId: recipientId,
            contextType: ConversationContext.run,
            contextId: orderId,
          );
      if (context.mounted) {
        // push (not go): back returns to this run, and /messages sits outside
        // the flag-hidden /chats branch so the redirect guard can't bounce it.
        await context.push('/messages/${convo.id}', extra: recipientName);
      }
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
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
        // Live "where's my runner" map — requester/visitor only. The runner
        // gets their own RunnerRouteCard map below; rendering both stacked
        // two maps on the dasher's screen.
        if (!isRunner && run.runnerLocation != null) ...[
          LiveMapCard(run: run),
          SizedBox(height: tokens.space4),
        ],
        if (isRunner)
          ..._runnerSection(context, ref, controller)
        else if (myOrder != null)
          ..._requesterSection(context, ref, controller, myOrder)
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
            full ? 'This run is full.' : 'No longer taking orders.',
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
    RunDetailController controller, {
    String success = 'Request sent.',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _RequestSheet(
        run: run,
        onSubmit: (order, dropoffId) => _act(
          context,
          () => controller.requestSpot(order, dropoffId),
          success: success,
        ),
      ),
    );
  }

  // ── Requester ──────────────────────────────────────────────────────────
  List<Widget> _requesterSection(
    BuildContext context,
    WidgetRef ref,
    RunDetailController controller,
    RunOrderResponse order,
  ) {
    final tokens = context.tokens;
    final accepted = const {
      RunOrderStatus.accepted,
      RunOrderStatus.delivered,
      RunOrderStatus.received,
    }.contains(order.status);
    final rateable =
        run.status == RunStatus.done &&
        (order.status == RunOrderStatus.delivered ||
            order.status == RunOrderStatus.received);
    // Server-authoritative (QA M-05): a submitted rating disables the CTA.
    final alreadyRated = order.ratedByMe ?? false;
    final canRate = rateable && !alreadyRated;
    return [
      _MyOrderCard(order: order),
      SizedBox(height: tokens.space3),
      OutlinedButton.icon(
        icon: const Icon(Icons.chat_bubble_outline, size: 18),
        label: Text('Message ${run.runner.displayName}'),
        onPressed: () => _openRunChat(
          context,
          ref,
          recipientId: run.runner.id,
          recipientName: run.runner.displayName,
          orderId: order.id,
        ),
      ),
      if (accepted && (run.feeCents > 0 || run.prepayRequired)) ...[
        SizedBox(height: tokens.space3),
        _PaymentCard(run: run),
        SizedBox(height: tokens.space3),
        _PaymentProofCard(order: order, controller: controller),
      ],
      if (order.status == RunOrderStatus.delivered) ...[
        SizedBox(height: tokens.space3),
        // Committed, irreversible confirmation — slide, don't tap (Uber-style
        // slide-to-confirm; a mis-tap here releases the runner).
        SlideToConfirm(
          label: 'Slide to confirm received',
          icon: Icons.check_rounded,
          onConfirmed: () async {
            final ok = await _act(
              context,
              () => controller.confirmReceived(order.id),
              success: 'Enjoy! Order confirmed.',
            );
            // Gamified payoff — the transaction is complete (success-feedback).
            if (ok && context.mounted) showConfettiBurst(context);
          },
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
          onPressed: () async {
            await showRateRunSheet(
              context,
              ratedUserId: run.runner.id,
              ratedName: run.runner.displayName,
              orderId: order.id,
              dropoff: order.dropoff,
              currentRating: run.runner.reputationScore,
              ratingCount: run.runner.ratingCount,
            );
            // Done runs no longer poll — re-sync so ratedByMe flips the
            // CTA to "Rated" immediately (QA M-05).
            await controller.refresh();
          },
        ),
      ] else if (rateable && alreadyRated) ...[
        SizedBox(height: tokens.space3),
        FilledButton.tonalIcon(
          icon: const Icon(Icons.star),
          label: Text('You rated ${run.runner.displayName}'),
          onPressed: null,
        ),
      ],
    ];
  }

  // ── Runner ─────────────────────────────────────────────────────────────
  List<Widget> _runnerSection(
    BuildContext context,
    WidgetRef ref,
    RunDetailController controller,
  ) {
    final tokens = context.tokens;
    // The runner's own order rides along but isn't a "request" — it is
    // auto-accepted server-side and never consumes a requester spot.
    final myOrder = run.myOrder;
    final orders = (run.orders?.toList() ?? [])
        .where((o) => o.requester.id != run.runner.id)
        .toList();
    // Grouped by what the runner has to do next, so the screen reads as a
    // worklist instead of one long undifferentiated pile of cards.
    final pending = orders
        .where((o) => o.status == RunOrderStatus.requested)
        .toList();
    final deliveries = orders
        .where((o) => o.status == RunOrderStatus.accepted)
        .toList();
    final wrapped = orders
        .where(
          (o) =>
              o.status != RunOrderStatus.requested &&
              o.status != RunOrderStatus.accepted,
        )
        .toList();
    final unresolved = deliveries.isNotEmpty;
    final active = const {
      RunStatus.open,
      RunStatus.locked,
      RunStatus.atStore,
      RunStatus.delivering,
    }.contains(run.status);
    // Runner auto-shares GPS once en route (locked → delivering), matching the
    // server's location-share window.
    final enRoute = const {
      RunStatus.locked,
      RunStatus.atStore,
      RunStatus.delivering,
    }.contains(run.status);

    return [
      // Glanceable dashboard: how many need an answer, how many are riding,
      // what the fee is — replaces three scattered plain-text lines.
      _RunnerDashboard(
        run: run,
        pendingCount: pending.length,
        deliveryCount: deliveries.length,
      ),
      SizedBox(height: tokens.space3),
      if (active) ...[
        _RunnerStatusStepper(
          run: run,
          unresolved: unresolved,
          onAdvance: (next) async {
            // Prepay gate: heading to the store with unpaid accepted orders
            // is the dasher's money on the line — surface it as an explicit
            // choice (drop them / front the money), never an auto-drop,
            // because payment happens off-app and only a human can judge it.
            if (next == RunStatus.atStore && run.prepayRequired) {
              final unpaid = deliveries
                  .where((o) => o.paymentSubmittedAt == null)
                  .toList();
              if (unpaid.isNotEmpty) {
                final choice = await _confirmUnpaid(context, unpaid);
                if (choice == null) return; // backed out
                if (choice == _UnpaidChoice.dropUnpaid) {
                  for (final o in unpaid) {
                    if (!context.mounted) return;
                    await _act(context, () => controller.decline(o.id));
                  }
                }
              }
            }
            if (!context.mounted) return;
            final ok = await _act(
              context,
              () => controller.updateStatus(next),
            );
            // Wrapping up the run is the runner's win — celebrate it.
            if (ok && next == RunStatus.done && context.mounted) {
              showConfettiBurst(context);
            }
          },
        ),
        SizedBox(height: tokens.space3),
      ],
      if (enRoute) ...[
        RunnerLocationBroadcaster(runId: run.id),
        SizedBox(height: tokens.space3),
        // The runner's single map: their position + numbered drop-offs.
        RunnerRouteCard(run: run),
        SizedBox(height: tokens.space3),
      ],
      // The runner never "requests a spot" on their own run — their food is
      // implicit. Only legacy self-orders still render as a card.
      if (myOrder != null) ...[
        _RunnerOwnOrderCard(order: myOrder),
        SizedBox(height: tokens.space3),
      ],
      if (orders.isEmpty) ...[
        Padding(
          padding: EdgeInsets.only(top: tokens.space2, bottom: tokens.space2),
          child: Text('ORDERS', style: AppTextStyles.label),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.space4),
          child: Text(
            // QA S-07: a wrapped-up run must not promise future requests.
            active ? 'No requests yet.' : 'This run ended without orders.',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ] else ...[
        ..._orderGroup(context, ref, controller, 'NEW REQUESTS', pending),
        ..._orderGroup(context, ref, controller, 'DELIVERIES', deliveries),
        ..._orderGroup(context, ref, controller, 'WRAPPED UP', wrapped),
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

  /// The prepay decision gate: lists everyone who hasn't paid and lets the
  /// dasher drop them, knowingly front the money, or back out.
  Future<_UnpaidChoice?> _confirmUnpaid(
    BuildContext context,
    List<RunOrderResponse> unpaid,
  ) {
    final names = unpaid.map((o) => o.requester.displayName).join(', ');
    return showDialog<_UnpaidChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          unpaid.length == 1
              ? "1 person hasn't paid yet"
              : "${unpaid.length} people haven't paid yet",
        ),
        content: Text(
          // Payment terms stay explicit — this gate exists to prevent
          // disputes, so name the choice plainly.
          '$names. Prepay is required — drop them, or continue and '
          'collect at drop-off.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_UnpaidChoice.continueAnyway),
            child: const Text('Continue anyway'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_UnpaidChoice.dropUnpaid),
            child: const Text('Drop unpaid'),
          ),
        ],
      ),
    );
  }

  /// One labelled group of order cards ("NEW REQUESTS · 2"); renders nothing
  /// when the group is empty so the screen only shows sections that matter.
  List<Widget> _orderGroup(
    BuildContext context,
    WidgetRef ref,
    RunDetailController controller,
    String label,
    List<RunOrderResponse> group,
  ) {
    if (group.isEmpty) return const [];
    final tokens = context.tokens;
    return [
      Padding(
        padding: EdgeInsets.only(top: tokens.space2, bottom: tokens.space2),
        child: Text('$label · ${group.length}', style: AppTextStyles.label),
      ),
      for (final order in group) ...[
        _OrderCard(
          order: order,
          collectFeeCents: run.prepayRequired ? null : run.feeCents,
          runDone: run.status == RunStatus.done,
          // Delivered/No-show only make sense once the dasher is actually
          // out (server rejects them earlier anyway).
          canResolve: const {
            RunStatus.atStore,
            RunStatus.delivering,
          }.contains(run.status),
          awaitingPrepay:
              run.prepayRequired &&
              order.status == RunOrderStatus.accepted &&
              order.paymentSubmittedAt == null,
          onRemoveUnpaid:
              run.prepayRequired &&
                  order.status == RunOrderStatus.accepted &&
                  order.paymentSubmittedAt == null &&
                  const {
                    RunStatus.open,
                    RunStatus.locked,
                  }.contains(run.status)
              ? () => _act(
                  context,
                  () => controller.decline(order.id),
                  success: '${order.requester.displayName} removed — unpaid.',
                )
              : null,
          onMessage: () => _openRunChat(
            context,
            ref,
            recipientId: order.requester.id,
            recipientName: order.requester.displayName,
            orderId: order.id,
          ),
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
          onImHere: () => _act(
            context,
            () => controller.markArrived(order.id),
            success:
                '${order.requester.displayName} pinged — '
                '5-minute window started.',
          ),
          onNoShow: () => _act(
            context,
            () => controller.markNoShow(order.id),
          ),
          onRate: () async {
            await showRateRunSheet(
              context,
              ratedUserId: order.requester.id,
              ratedName: order.requester.displayName,
              orderId: order.id,
              // Runner rating a customer — customer tags, not delivery.
              ratingRunner: false,
              dropoff: order.dropoff,
              currentRating: order.requester.reputationScore,
              ratingCount: order.requester.ratingCount,
            );
            // Done runs no longer poll — re-sync to flip Rate → Rated.
            await controller.refresh();
          },
        ),
        SizedBox(height: tokens.space3),
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

/// What the dasher chose at the prepay gate (heading to the store with
/// unpaid accepted orders).
enum _UnpaidChoice { dropUnpaid, continueAnyway }

// ── Shared cards ─────────────────────────────────────────────────────────

/// Trust + logistics header: destination, runner card, run facts.
class _RunHeaderCard extends StatelessWidget {
  const _RunHeaderCard({required this.run});

  final RunResponse run;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final terminal =
        run.status == RunStatus.cancelled || run.status == RunStatus.expired;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: tokens.brMd,
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spot photo header — the detail screen opens on the food, not a
          // wall of text. Hidden entirely when the spot has no imagery.
          if (run.foodSpot.imageUrl != null)
            SizedBox(
              height: 168,
              width: double.infinity,
              child: SpotImage(
                name: run.foodSpot.name,
                imageUrl: run.foodSpot.imageUrl,
              ),
            ),
          Padding(
            padding: EdgeInsets.all(tokens.space4),
            child: _headerBody(context, terminal: terminal),
          ),
        ],
      ),
    );
  }

  Widget _headerBody(BuildContext context, {required bool terminal}) {
    final tokens = context.tokens;
    final colors = context.colors;
    final runner = run.runner;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(run.foodSpot.name, style: AppTextStyles.heading),
            ),
            if (terminal) _DetailStatusChip(run: run),
          ],
        ),
        if (!terminal) ...[
          SizedBox(height: tokens.space5),
          _LifecycleRail(status: run.status),
        ],
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
          icon: Icons.payments_outlined,
          label: run.prepayRequired
              ? switch (paymentPrefsLabel(run.paymentPrefs ?? const [])) {
                  // Prepay runs carry rails only — show them so the
                  // requester knows exactly how to send money up front.
                  final String prefs =>
                    '${runFeeLabel(run.feeCents)} · prepay via $prefs',
                  null => '${runFeeLabel(run.feeCents)} · prepay required',
                }
              : switch (run.feeCents > 0
                    ? paymentPrefsLabel(run.paymentPrefs ?? const [])
                    : null) {
                  // Pay-on-handoff methods the runner picked, so requesters
                  // know what to have ready at the drop-off.
                  final String prefs when prefs == 'Cash' =>
                    '${runFeeLabel(run.feeCents)} · cash on handoff',
                  final String prefs =>
                    '${runFeeLabel(run.feeCents)} · pay with $prefs',
                  null => runFeeLabel(run.feeCents),
                },
        ),
        SizedBox(height: tokens.space2),
        _InfoRow(
          icon: Icons.group_outlined,
          label: spotsLabel(run),
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
    return AnimatedContainer(
      duration: AppMotion.resolve(context, AppMotion.micro),
      curve: AppMotion.standard,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space2,
        vertical: tokens.space1,
      ),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: .12),
        shape: const StadiumBorder(),
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.resolve(context, AppMotion.micro),
        child: Text(
          runStatusLabel(run.status),
          key: ValueKey(run.status),
          style: context.text.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Horizontal run-lifecycle rail: OPEN → LOCKED → AT STORE → DELIVERING → DONE.
/// Reached steps fill brand blue, the current step glows, future steps are
/// muted hairline dots — the run's story at a glance (design brief §8).
class _LifecycleRail extends StatelessWidget {
  const _LifecycleRail({required this.status});

  final RunStatus status;

  static const _steps = <(RunStatus, String)>[
    (RunStatus.open, 'OPEN'),
    (RunStatus.locked, 'LOCKED'),
    (RunStatus.atStore, 'AT STORE'),
    (RunStatus.delivering, 'DELIVERING'),
    (RunStatus.done, 'DONE'),
  ];

  @override
  Widget build(BuildContext context) {
    final matched = _steps.indexWhere((s) => s.$1 == status);
    final current = matched < 0 ? _steps.length - 1 : matched;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _steps.length; i++)
          Expanded(
            child: _LifecycleNode(
              label: _steps[i].$2,
              reached: i <= current,
              active: i == current,
              leftLineActive: i <= current,
              rightLineActive: i < current,
              first: i == 0,
              last: i == _steps.length - 1,
            ),
          ),
      ],
    );
  }
}

class _LifecycleNode extends StatelessWidget {
  const _LifecycleNode({
    required this.label,
    required this.reached,
    required this.active,
    required this.leftLineActive,
    required this.rightLineActive,
    required this.first,
    required this.last,
  });

  final String label;
  final bool reached;
  final bool active;
  final bool leftLineActive;
  final bool rightLineActive;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final muted = colors.outlineVariant;
    return Column(
      children: [
        SizedBox(
          height: 18,
          child: Row(
            children: [
              Expanded(
                child: first
                    ? const SizedBox.shrink()
                    : AnimatedContainer(
                        duration: AppMotion.resolve(context, AppMotion.enter),
                        curve: AppMotion.standard,
                        height: 2,
                        color: leftLineActive ? AppColors.primary : muted,
                      ),
              ),
              _Dot(reached: reached, active: active),
              Expanded(
                child: last
                    ? const SizedBox.shrink()
                    : AnimatedContainer(
                        duration: AppMotion.resolve(context, AppMotion.enter),
                        curve: AppMotion.standard,
                        height: 2,
                        color: rightLineActive ? AppColors.primary : muted,
                      ),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.space1),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              fontSize: 9,
              letterSpacing: 0.4,
              color: reached ? AppColors.primary : colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.reached, required this.active});

  final bool reached;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = active ? 16.0 : 12.0;
    return AnimatedContainer(
      duration: AppMotion.resolve(context, AppMotion.enter),
      curve: AppMotion.emphasized,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: reached ? AppColors.primary : colors.surface,
        border: Border.all(
          color: reached ? AppColors.primary : colors.outlineVariant,
          width: 2,
        ),
        boxShadow: active ? AppShadows.primaryGlow : null,
      ),
      child: reached && !active
          ? const Icon(Icons.check, size: 8, color: Colors.white)
          : null,
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
      RunOrderStatus.accepted => "You're in! Send payment below.",
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
          // Runner announced arrival: urgent animated banner with the live
          // 5-minute window (same clock the runner's No-show unlock uses).
          if (order.status == RunOrderStatus.accepted &&
              order.arrivedAt != null) ...[
            SizedBox(height: tokens.space3),
            RunnerHereBanner(
              arrivedAt: order.arrivedAt!,
              dropoff: order.dropoff,
            ),
          ],
          SizedBox(height: tokens.space2),
          Text(order.orderText, style: context.text.bodyMedium),
          SizedBox(height: tokens.space2),
          _InfoRow(
            icon: Icons.place_outlined,
            label: 'Drop at ${order.dropoff}',
          ),
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

/// Revealed only after the runner accepts you (spec: PII stays hidden until
/// then). Lists every rail the runner saved with a tap-to-copy handle —
/// payment always happens off-app, stated plainly.
class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.run});

  final RunResponse run;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final methods = run.runner.paymentMethods ?? const <PaymentMethod>[];
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
          Text('PAY THE RUNNER', style: AppTextStyles.label),
          SizedBox(height: tokens.space2),
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
                  '${runFeeAmount(run.feeCents)} to the runner',
                  style: context.text.titleSmall,
                ),
              ),
            ],
          ),
          if (methods.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: tokens.space2),
              child: Text(
                'Pay the runner off-app — they will share their handle here.',
                style: context.text.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final m in methods) ...[
              SizedBox(height: tokens.space3),
              _PaymentMethodRow(method: m),
            ],
          if (run.prepayRequired) ...[
            SizedBox(height: tokens.space3),
            Text(
              'Prepay required — send it before pickup.',
              style: context.text.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          SizedBox(height: tokens.space3),
          Row(
            children: [
              Icon(Icons.lock_outline, size: 14, color: tokens.verified),
              SizedBox(width: tokens.space2),
              Expanded(
                child: Text(
                  // One-line trust note; the proof card below carries the
                  // "attach a screenshot" nudge so it isn't said twice.
                  'Paid directly to the runner — never through CampusConnect.',
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One revealed rail: icon + app label + handle (phone/email/username), with
/// tap-to-copy and — if the runner attached one — a scannable QR code.
class _PaymentMethodRow extends StatelessWidget {
  const _PaymentMethodRow({required this.method});

  final PaymentMethod method;

  void _showQr(BuildContext context, String url) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Scan to pay with ${method.type.label}',
                  style: context.text.titleSmall,
                ),
                const SizedBox(height: 12),
                InteractiveViewer(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('QR image unavailable.'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final qrUrl = method.qrUrl;
    final hasQr = qrUrl != null && qrUrl.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(method.type.icon, size: 20, color: colors.onSurfaceVariant),
            SizedBox(width: tokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.type.label, style: context.text.labelSmall),
                  Text(method.handle, style: context.text.bodyMedium),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Copy',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy_outlined, size: 18),
              onPressed: () {
                unawaited(
                  Clipboard.setData(ClipboardData(text: method.handle)),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${method.type.label} handle copied'),
                  ),
                );
              },
            ),
          ],
        ),
        // QR shows automatically when the runner attached one — the payer
        // just scans; tap to enlarge.
        if (hasQr)
          Padding(
            padding: EdgeInsets.only(
              left: tokens.space3 + 20,
              top: tokens.space2,
            ),
            child: GestureDetector(
              onTap: () => _showQr(context, qrUrl),
              child: ClipRRect(
                borderRadius: tokens.brSm,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(6),
                  child: Image.network(
                    qrUrl,
                    width: 132,
                    height: 132,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_2,
                          size: 18,
                          color: colors.onSurfaceVariant,
                        ),
                        SizedBox(width: tokens.space2),
                        Text(
                          'QR unavailable',
                          style: context.text.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The dasher's at-a-glance strip: pending requests, live deliveries, and
/// fee per order — three tiles instead of scattered plain-text lines.
class _RunnerDashboard extends StatelessWidget {
  const _RunnerDashboard({
    required this.run,
    required this.pendingCount,
    required this.deliveryCount,
  });

  final RunResponse run;
  final int pendingCount;
  final int deliveryCount;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: tokens.brMd,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _DashboardStat(
              value: '$pendingCount',
              label: 'NEW',
              icon: Icons.mark_email_unread_outlined,
              // Pending requests are the runner's to-do — highlight them.
              color: pendingCount > 0 ? tokens.warning : null,
            ),
            VerticalDivider(width: 1, color: colors.outlineVariant),
            _DashboardStat(
              value: '$deliveryCount/${run.spotsMax}',
              label: 'GOING',
              icon: Icons.group_outlined,
            ),
            VerticalDivider(width: 1, color: colors.outlineVariant),
            _DashboardStat(
              value: runFeeLabel(run.feeCents),
              label: 'PER ORDER',
              icon: Icons.payments_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardStat extends StatelessWidget {
  const _DashboardStat({
    required this.value,
    required this.label,
    required this.icon,
    this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final accent = color ?? colors.onSurfaceVariant;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space2,
          vertical: tokens.space3,
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: accent),
            SizedBox(height: tokens.space1),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color ?? colors.onSurface,
                ),
              ),
            ),
            SizedBox(height: tokens.space1 / 2),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontSize: 10,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
  final Future<void> Function(RunStatus) onAdvance;

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
        // Status advances are one-way — slide to commit (Uber-style).
        SlideToConfirm(
          label: label,
          icon: icon,
          enabled: !blocked,
          onConfirmed: () => onAdvance(next),
        ),
        if (blocked) ...[
          SizedBox(height: tokens.space2),
          Text(
            'Mark each order delivered or no-show first.',
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
/// The runner's own attached order — informational, no accept/decline
/// controls (it is auto-accepted and resolves itself when the run is done).
class _RunnerOwnOrderCard extends StatelessWidget {
  const _RunnerOwnOrderCard({required this.order});

  final RunOrderResponse order;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(tokens.space4),
      decoration: BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: tokens.brMd,
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lunch_dining_outlined,
                size: 18,
                color: AppColors.primaryDark,
              ),
              SizedBox(width: tokens.space2),
              Text(
                'Your order',
                style: context.text.titleSmall?.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space2),
          Text(order.orderText, style: context.text.bodyMedium),
          SizedBox(height: tokens.space2),
          Text(
            'Drop at ${order.dropoff}',
            style: context.text.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.runDone,
    required this.canResolve,
    required this.awaitingPrepay,
    required this.onMessage,
    required this.onAccept,
    required this.onDecline,
    required this.onDelivered,
    required this.onImHere,
    required this.onNoShow,
    required this.onRate,
    this.onRemoveUnpaid,
    this.collectFeeCents,
  });

  final RunOrderResponse order;
  final bool runDone;

  /// Fee to collect from this requester at handoff (non-prepay runs only;
  /// null on prepay — the proof panel covers money there).
  final int? collectFeeCents;

  /// Run is at the store / delivering — Delivered and No-show are legal.
  final bool canResolve;

  /// Prepay run, accepted, no proof yet — the dasher's money is at risk.
  final bool awaitingPrepay;
  final VoidCallback onMessage;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onDelivered;

  /// "I'm here" — stamps the no-show counter for this drop-off.
  final VoidCallback onImHere;
  final VoidCallback onNoShow;
  final VoidCallback onRate;

  /// Drop an accepted-but-unpaid order on a prepay run (open/locked only).
  final VoidCallback? onRemoveUnpaid;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final requester = order.requester;
    final rateable =
        runDone &&
        (order.status == RunOrderStatus.delivered ||
            order.status == RunOrderStatus.received);
    // Server-authoritative (QA M-05): once rated, the CTA flips to a
    // disabled "Rated" so it can't be tapped into a guaranteed 409.
    final alreadyRated = order.ratedByMe ?? false;
    final canRate = rateable && !alreadyRated;
    final card = Container(
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
              SizedBox(width: tokens.space1),
              IconButton(
                onPressed: onMessage,
                tooltip: 'Message ${requester.displayName}',
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                color: colors.primary,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          SizedBox(height: tokens.space3),
          // What + where + what to collect, labelled and boxed so the dasher
          // reads the job in one glance — "vague order card" feedback: the
          // order text and drop-off were easy to miss as loose plain lines.
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(tokens.space3),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: tokens.brXs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('THEIR ORDER', style: AppTextStyles.label),
                SizedBox(height: tokens.space1),
                Text(
                  order.orderText,
                  style: context.text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: tokens.space3),
                Text('DELIVER TO', style: AppTextStyles.label),
                SizedBox(height: tokens.space1),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: colors.primary,
                    ),
                    SizedBox(width: tokens.space2),
                    Expanded(
                      child: Text(
                        order.dropoff,
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (collectFeeCents != null && collectFeeCents! > 0) ...[
                  SizedBox(height: tokens.space3),
                  Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: 18,
                        color: tokens.success,
                      ),
                      SizedBox(width: tokens.space2),
                      Expanded(
                        child: Text(
                          'Collect ${runFeeAmount(collectFeeCents!)} '
                          'at handoff',
                          style: context.text.bodySmall?.copyWith(
                            color: tokens.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Payment state — one glance: green receipt panel when paid,
          // loud amber strip while the dasher is still owed.
          if (order.paymentSubmittedAt != null) ...[
            SizedBox(height: tokens.space3),
            _PaymentProofReview(order: order),
          ] else if (awaitingPrepay) ...[
            SizedBox(height: tokens.space3),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(tokens.space3),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: tokens.brXs,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_top_rounded,
                    size: 16,
                    color: tokens.warning,
                  ),
                  SizedBox(width: tokens.space2),
                  Expanded(
                    child: Text(
                      "Awaiting prepayment — hasn't sent proof yet.",
                      style: context.text.bodySmall?.copyWith(
                        color: tokens.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            // Arrived: the 5-minute no-show counter is running — countdown
            // strip + Delivered, with No-show locked until the window elapses
            // (mirrors the server's NO_SHOW_TOO_EARLY guard).
            RunOrderStatus.accepted
                when canResolve && order.arrivedAt != null =>
              ArrivedActions(
                arrivedAt: order.arrivedAt!,
                onDelivered: onDelivered,
                onNoShow: onNoShow,
              ),
            // Out with the food but not yet announced at this drop-off:
            // "I'm here" starts the counter and pings the requester.
            RunOrderStatus.accepted when canResolve => Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onDelivered,
                    child: const Text('Delivered'),
                  ),
                ),
                SizedBox(width: tokens.space2),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onImHere,
                    icon: const Icon(Icons.hail_rounded, size: 18),
                    label: const Text("I'm here"),
                  ),
                ),
              ],
            ),
            // Accepted but not out yet: no Delivered/No-show (the server
            // rejects them before at_store) — just the state, plus the
            // drop-unpaid escape hatch on prepay runs.
            RunOrderStatus.accepted => Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _OrderStatusPill(status: order.status),
                  ),
                ),
                if (onRemoveUnpaid != null)
                  TextButton.icon(
                    onPressed: onRemoveUnpaid,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.error,
                    ),
                    icon: const Icon(Icons.person_remove_outlined, size: 18),
                    label: const Text('Remove — unpaid'),
                  ),
              ],
            ),
            _ => Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _OrderStatusPill(status: order.status),
                  ),
                ),
                if (canRate)
                  TextButton.icon(
                    onPressed: onRate,
                    icon: const Icon(Icons.star_outline, size: 18),
                    label: const Text('Rate'),
                  )
                else if (rateable && alreadyRated)
                  TextButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.star, size: 18),
                    label: const Text('Rated'),
                  ),
              ],
            ),
          },
        ],
      ),
    );

    // Swipe accelerator on pending requests: swipe right to accept, left to
    // decline. The Accept/Decline buttons above remain the primary,
    // discoverable path (this gesture is a power-user shortcut, not the only
    // way — Fitts's & Hick's laws + accessibility).
    if (order.status == RunOrderStatus.requested) {
      return SwipeAction(
        borderRadius: tokens.brMd,
        onSwipeRight: onAccept,
        onSwipeLeft: onDecline,
        rightIcon: Icons.check_rounded,
        rightLabel: 'Accept',
        leftIcon: Icons.close_rounded,
        leftLabel: 'Decline',
        child: card,
      );
    }
    return card;
  }
}

/// Small stadium status pill for resolved orders (delivered / received /
/// declined / no-show) — colour-coded instead of a bare text label.
class _OrderStatusPill extends StatelessWidget {
  const _OrderStatusPill({required this.status});

  final RunOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final color = switch (status) {
      RunOrderStatus.accepted ||
      RunOrderStatus.delivered ||
      RunOrderStatus.received => tokens.success,
      RunOrderStatus.requested => tokens.warning,
      RunOrderStatus.declined || RunOrderStatus.noShow => colors.error,
      _ => colors.onSurfaceVariant,
    };
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
        runOrderStatusLabel(status),
        style: context.text.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Runner-side view of a submitted payment proof: the screenshot (tap to
/// enlarge) + any note the requester attached.
class _PaymentProofReview extends StatelessWidget {
  const _PaymentProofReview({required this.order});

  final RunOrderResponse order;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final url = order.paymentProofUrl;
    final note = order.paymentNote;
    // Neutral container matching the order box above it — the card stays one
    // calm surface; "paid" reads from the green icon accent alone.
    return Container(
      padding: EdgeInsets.all(tokens.space3),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: tokens.brXs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 16,
                color: tokens.success,
              ),
              SizedBox(width: tokens.space2),
              Text('PAYMENT PROOF', style: AppTextStyles.label),
            ],
          ),
          if (url != null && url.isNotEmpty) ...[
            SizedBox(height: tokens.space2),
            GestureDetector(
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => Dialog(
                  child: InteractiveViewer(
                    child: Image.network(url, fit: BoxFit.contain),
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: tokens.brXs,
                child: Image.network(
                  url,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Padding(
                    padding: EdgeInsets.symmetric(vertical: tokens.space2),
                    child: Text(
                      'Screenshot attached (image pending).',
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (note != null && note.isNotEmpty) ...[
            SizedBox(height: tokens.space2),
            Text('“$note”', style: context.text.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Request sheet: order text + a drop-off *picker* (admin-curated catalog,
/// no free-text addresses). Consumer so it can read the dropoff catalog and
/// keep its own selection state.
class _RequestSheet extends ConsumerStatefulWidget {
  const _RequestSheet({required this.run, required this.onSubmit});

  final RunResponse run;
  final Future<void> Function(String orderText, String dropoffId) onSubmit;

  @override
  ConsumerState<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends ConsumerState<_RequestSheet> {
  final _text = TextEditingController();
  String? _dropoffId;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final run = widget.run;
    final catalog = ref.watch(dropoffCatalogProvider);
    return Padding(
      padding: EdgeInsets.only(
        left: tokens.space4,
        right: tokens.space4,
        top: tokens.space4,
        bottom: MediaQuery.viewInsetsOf(context).bottom + tokens.space6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo-led header — the spot imagery carries through the whole
          // request flow, matching the feed/detail aesthetic.
          ClipRRect(
            borderRadius: tokens.brMd,
            child: SizedBox(
              height: 96,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SpotImage(
                    name: run.foodSpot.name,
                    imageUrl: run.foodSpot.imageUrl,
                    monogramFontSize: 22,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0x99000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: tokens.space3,
                    right: tokens.space3,
                    bottom: tokens.space2,
                    child: Text(
                      run.foodSpot.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.space4),
          Text("What's your order?", style: AppTextStyles.subheading),
          SizedBox(height: tokens.space3),
          TextField(
            controller: _text,
            autofocus: true,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'e.g. Medium iced latte, oat milk, no sugar',
            ),
          ),
          SizedBox(height: tokens.space4),
          Text('Where should they drop it?', style: AppTextStyles.label),
          SizedBox(height: tokens.space2),
          catalog.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => Text(
              "Couldn't load drop-off spots — try again.",
              style: context.text.bodySmall?.copyWith(
                color: context.colors.error,
              ),
            ),
            data: (spots) => DropdownButtonFormField<String>(
              initialValue: _dropoffId,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.place_outlined),
                hintText: 'Pick a drop-off spot',
              ),
              items: [
                for (final s in spots)
                  DropdownMenuItem(value: s.id, child: Text(s.name)),
              ],
              onChanged: (v) => setState(() => _dropoffId = v),
            ),
          ),
          SizedBox(height: tokens.space4),
          Text(
            // Payment terms at the point of commitment — keep explicit.
            run.prepayRequired
                ? '${runFeeLabel(run.feeCents)} · prepay before pickup'
                : '${runFeeLabel(run.feeCents)} · pay at handoff',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.space4),
          FilledButton(
            onPressed: () {
              final order = _text.text.trim();
              if (order.isEmpty) {
                _snack('Add your order first.');
                return;
              }
              if (_dropoffId == null) {
                _snack('Pick a drop-off spot.');
                return;
              }
              Navigator.of(context).pop();
              unawaited(HapticFeedback.selectionClick());
              widget.onSubmit(order, _dropoffId!).ignore();
            },
            child: const Text('Send request'),
          ),
        ],
      ),
    );
  }
}

/// Requester's payment-proof card: send a transaction screenshot + note so
/// the runner can confirm off-app payment. Least-friction — one tap picks
/// the screenshot, an optional note, one tap submits. Once submitted it
/// flips to a confirmation and the runner sees it on their order card.
class _PaymentProofCard extends ConsumerStatefulWidget {
  const _PaymentProofCard({required this.order, required this.controller});

  final RunOrderResponse order;
  final RunDetailController controller;

  @override
  ConsumerState<_PaymentProofCard> createState() => _PaymentProofCardState();
}

class _PaymentProofCardState extends ConsumerState<_PaymentProofCard> {
  final _note = TextEditingController();
  final _picker = ImagePicker();
  XFile? _picked;
  Uint8List? _bytes;
  bool _submitting = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String _contentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _pick() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _picked = file;
      _bytes = bytes;
    });
  }

  Future<void> _submit() async {
    final bytes = _bytes;
    final file = _picked;
    if (bytes == null || file == null) return;
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.controller.submitPaymentProof(
        widget.order.id,
        bytes: bytes,
        contentType: _contentType(file.path),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      unawaited(HapticFeedback.mediumImpact());
      messenger.showSnackBar(
        const SnackBar(content: Text('Payment proof sent to the runner.')),
      );
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final submitted = widget.order.paymentSubmittedAt != null;

    if (submitted) {
      return Container(
        padding: EdgeInsets.all(tokens.space4),
        decoration: BoxDecoration(
          color: tokens.success.withValues(alpha: .12),
          borderRadius: tokens.brSm,
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.verified_outlined, size: 20, color: tokens.success),
            SizedBox(width: tokens.space3),
            Expanded(
              child: Text(
                'Payment proof sent — the runner can confirm it.',
                style: context.text.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(tokens.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: tokens.brSm,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SEND PAYMENT PROOF', style: AppTextStyles.label),
          SizedBox(height: tokens.space2),
          Text(
            'Paid off-app? Attach a screenshot so the runner can confirm.',
            style: context.text.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.space3),
          if (_bytes != null)
            ClipRRect(
              borderRadius: tokens.brXs,
              child: Image.memory(
                _bytes!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          if (_bytes != null) SizedBox(height: tokens.space2),
          OutlinedButton.icon(
            onPressed: _submitting ? null : _pick,
            icon: const Icon(Icons.image_outlined),
            label: Text(
              _bytes == null ? 'Add screenshot' : 'Change screenshot',
            ),
          ),
          SizedBox(height: tokens.space3),
          TextField(
            controller: _note,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Add a note (optional)',
            ),
          ),
          SizedBox(height: tokens.space3),
          FilledButton.icon(
            onPressed: (_bytes == null || _submitting) ? null : _submit,
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
            label: const Text('Send to runner'),
          ),
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
