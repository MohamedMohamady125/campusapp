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
import 'package:campusconnect/features/notifications/presentation/notification_bell.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// My Runs — the dedicated bottom tab for everything you're involved in:
/// runs you posted and runs you joined. Live commitments first, finished
/// runs below — a dashboard of what needs attention, not a history dump.
class MyRunsScreen extends ConsumerStatefulWidget {
  const MyRunsScreen({super.key});

  @override
  ConsumerState<MyRunsScreen> createState() => _MyRunsScreenState();
}

class _MyRunsScreenState extends ConsumerState<MyRunsScreen> {
  @override
  void initState() {
    super.initState();
    // Re-sync on every visit — the tab is only useful if it's current.
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
    final tokens = context.tokens;

    return Scaffold(
      body: ContentWidth(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      tokens.space4,
                      tokens.space4,
                      tokens.space4,
                      tokens.space3,
                    ),
                    child: Row(
                      children: [
                        Text('My Runs', style: AppTextStyles.displayMedium),
                        const Spacer(),
                        const NotificationBell(),
                      ],
                    ),
                  ),
                ),
              ),
              ..._slivers(state),
            ],
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
          padding: EdgeInsets.fromLTRB(
            tokens.space4,
            tokens.space2,
            tokens.space4,
            96,
          ),
          sliver: SliverList.list(
            children: [
              // Match the image-led RunRow silhouette: photo banner + footer.
              for (var i = 0; i < 3; i++) ...[
                const SkeletonBox(width: double.infinity, height: 132),
                SizedBox(height: tokens.space2),
                const SkeletonBox(width: 200, height: 18),
                SizedBox(height: tokens.space2),
                const SkeletonBox(width: 140, height: 14),
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
            icon: Icons.directions_run,
            title: 'No runs yet',
            body: 'Runs you post and orders you join will show up here.',
            actionLabel: 'Post a run',
            onAction: () => context.go('/runs/create'),
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
    Widget section(String label) => Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.space4,
        tokens.space2,
        tokens.space4,
        tokens.space2,
      ),
      child: Text(label, style: AppTextStyles.label),
    );
    return [
      if (active.isNotEmpty) ...[
        SliverToBoxAdapter(child: section('ACTIVE')),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: tokens.space4),
          sliver: SliverList.separated(
            itemCount: active.length,
            separatorBuilder: (_, _) => SizedBox(height: tokens.space3),
            itemBuilder: (context, i) => FadeSlideIn(
              index: i,
              child: RunRow(run: active[i], showStatus: true),
            ),
          ),
        ),
      ],
      if (past.isNotEmpty) ...[
        SliverToBoxAdapter(child: section('HISTORY')),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(tokens.space4, 0, tokens.space4, 96),
          sliver: SliverList.separated(
            itemCount: past.length,
            separatorBuilder: (_, _) => SizedBox(height: tokens.space3),
            itemBuilder: (context, i) => FadeSlideIn(
              index: i,
              child: RunRow(run: past[i], showStatus: true),
            ),
          ),
        ),
      ] else
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
    ];
  }
}
