import 'dart:async' show unawaited;

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/components/content_width.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/fade_slide_in.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/food_runs/presentation/run_row.dart';
import 'package:campusconnect/features/food_runs/presentation/runs_feed_controller.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Orders — runs the user *joined as a requester*, active first, then the
/// full past. Runs they dashed live in My Runs (Past) instead — this screen
/// is strictly the customer-side paper trail. Each row opens the run detail
/// with the complete record (order text, drop-off, payment proof).
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Re-sync on every visit — history is only trustworthy if it's current.
    unawaited(
      Future.microtask(
        () => ref.read(runsFeedControllerProvider.notifier).refreshMyRuns(),
      ),
    );
  }

  Future<void> _refresh() async {
    await ref.read(runsFeedControllerProvider.notifier).refreshMyRuns();
    unawaited(HapticFeedback.selectionClick());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(runsFeedControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: ContentWidth(
        // Single-column phone-style flow: keep it readable on desktop (QA #16).
        max: 640,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: _slivers(state),
          ),
        ),
      ),
    );
  }

  List<Widget> _slivers(RunsFeedState state) {
    final tokens = context.tokens;
    if (state.myRunsLoading) {
      return [
        SliverPadding(
          padding: EdgeInsets.all(tokens.space4),
          sliver: SliverList.list(
            children: [
              for (var i = 0; i < 3; i++) ...[
                const SkeletonBox(width: double.infinity, height: 132),
                SizedBox(height: tokens.space2),
                const SkeletonBox(width: 200, height: 18),
                SizedBox(height: tokens.space4),
              ],
            ],
          ),
        ),
      ];
    }
    // Requester-side only: runs the user dashed belong in My Runs (Past),
    // not here — Orders is strictly what *they ordered* from someone else.
    final orders = state.myRuns.where((r) => !(r.isMine ?? false)).toList();
    if (orders.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No orders yet',
            body: 'Runs you join as a requester will show up here.',
            actionLabel: 'Browse runs',
            onAction: () => context.go('/runs'),
          ),
        ),
      ];
    }
    const activeStatuses = {
      RunStatus.open,
      RunStatus.locked,
      RunStatus.atStore,
      RunStatus.delivering,
    };
    // An order is only "in progress" while it's live — a withdrawn/declined
    // one on a still-open run is history, not an active order (QA #11).
    bool isActive(RunResponse r) {
      if (!activeStatuses.contains(r.status)) return false;
      final status = r.myOrder?.status;
      return status != RunOrderStatus.cancelled &&
          status != RunOrderStatus.declined;
    }

    final active = orders.where(isActive).toList();
    final past = orders.where((r) => !isActive(r)).toList();
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          tokens.space4,
          tokens.space2,
          tokens.space4,
          tokens.space6,
        ),
        sliver: SliverList.list(
          children: [
            if (active.isNotEmpty) ...[
              Text('IN PROGRESS', style: AppTextStyles.label),
              SizedBox(height: tokens.space2),
              for (final (i, run) in active.indexed) ...[
                FadeSlideIn(
                  index: i,
                  child: RunRow(run: run, showStatus: true),
                ),
                SizedBox(height: tokens.space3),
              ],
              SizedBox(height: tokens.space2),
            ],
            if (past.isNotEmpty) ...[
              Text('PAST', style: AppTextStyles.label),
              SizedBox(height: tokens.space2),
              for (final (i, run) in past.indexed) ...[
                FadeSlideIn(
                  index: active.length + i,
                  child: RunRow(run: run, showStatus: true),
                ),
                SizedBox(height: tokens.space3),
              ],
            ],
          ],
        ),
      ),
    ];
  }
}
