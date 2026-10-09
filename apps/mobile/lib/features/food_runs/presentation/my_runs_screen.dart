import 'dart:async' show unawaited;

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/components/content_width.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/fade_slide_in.dart';
import 'package:campusconnect/design_system/components/pressable.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_motion.dart';
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

/// Live commitments vs finished history — the tab defaults to what needs
/// attention right now.
enum MyRunsFilter { active, past }

class _MyRunsScreenState extends ConsumerState<MyRunsScreen> {
  MyRunsFilter _filter = MyRunsFilter.active;

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
    final shown = _filter == MyRunsFilter.active ? active : past;
    return [
      SliverToBoxAdapter(
        child: _MyRunsFilters(
          selected: _filter,
          activeCount: active.length,
          pastCount: past.length,
          onSelected: (f) {
            if (f == _filter) return;
            unawaited(HapticFeedback.selectionClick());
            setState(() => _filter = f);
          },
        ),
      ),
      if (shown.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: _filter == MyRunsFilter.active
              ? EmptyState(
                  icon: Icons.directions_run,
                  title: 'Nothing active right now',
                  body:
                      'Post a run or join one from the feed — live runs '
                      'land here.',
                  actionLabel: 'Post a run',
                  onAction: () => context.go('/runs/create'),
                )
              : const EmptyState(
                  icon: Icons.history,
                  title: 'No past runs yet',
                  body: 'Finished and cancelled runs will show up here.',
                ),
        )
      else
        SliverPadding(
          // 96dp bottom padding so the FAB never covers a row.
          padding: EdgeInsets.fromLTRB(tokens.space4, 0, tokens.space4, 96),
          sliver: SliverList.separated(
            // Keyed per filter so switching re-runs the entrance stagger.
            key: ValueKey(_filter),
            itemCount: shown.length,
            separatorBuilder: (_, _) => SizedBox(height: tokens.space3),
            itemBuilder: (context, i) => FadeSlideIn(
              index: i,
              child: RunRow(run: shown[i], showStatus: true),
            ),
          ),
        ),
    ];
  }
}

/// Active | Past stadium pills (same custom style as the feed had — stock
/// Material chips clip their labels at this size). Default is Active.
class _MyRunsFilters extends StatelessWidget {
  const _MyRunsFilters({
    required this.selected,
    required this.activeCount,
    required this.pastCount,
    required this.onSelected,
  });

  final MyRunsFilter selected;
  final int activeCount;
  final int pastCount;
  final ValueChanged<MyRunsFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final options = <(MyRunsFilter, String)>[
      (MyRunsFilter.active, 'Active · $activeCount'),
      (MyRunsFilter.past, 'Past · $pastCount'),
    ];
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: tokens.space4),
        children: [
          for (final (value, label) in options)
            Padding(
              padding: EdgeInsets.only(right: tokens.space2),
              child: Center(
                child: Semantics(
                  button: true,
                  selected: selected == value,
                  child: Pressable(
                    onTap: () => onSelected(value),
                    child: AnimatedContainer(
                      duration: AppMotion.resolve(context, AppMotion.micro),
                      curve: AppMotion.emphasized,
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.space4,
                        vertical: tokens.space2 + 2,
                      ),
                      decoration: ShapeDecoration(
                        color: selected == value
                            ? colors.primary
                            : colors.surface,
                        shape: StadiumBorder(
                          side: selected == value
                              ? BorderSide.none
                              : BorderSide(color: colors.outlineVariant),
                        ),
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        style: context.text.labelMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: selected == value
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected == value
                              ? Colors.white
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
