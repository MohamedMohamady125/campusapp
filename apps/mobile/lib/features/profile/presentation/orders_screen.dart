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

/// Orders — the profile's complete run history: every run posted and every
/// order joined, active first, then the full past. Each row opens the run
/// detail with the complete record (order text, drop-off, payment proof,
/// totals) — the paper trail both sides can point at.
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
    if (state.myRuns.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No orders yet',
            body: 'Runs you post and orders you join will show up here.',
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
    final active = state.myRuns
        .where((r) => activeStatuses.contains(r.status))
        .toList();
    final past = state.myRuns
        .where((r) => !activeStatuses.contains(r.status))
        .toList();
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
