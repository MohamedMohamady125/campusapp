import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/components/content_width.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/fade_slide_in.dart';
import 'package:campusconnect/design_system/components/pressable.dart';
import 'package:campusconnect/design_system/components/reputation_chip.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/components/verified_avatar.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/food_runs/presentation/run_format.dart';
import 'package:campusconnect/features/food_runs/presentation/runs_feed_controller.dart';
import 'package:campusconnect/features/notifications/presentation/notification_bell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Food runs — the hero home screen. Live feed of runs heading out now,
/// plus a "My runs" segment for runs you're on (either side of the bag).
class RunsFeedScreen extends ConsumerStatefulWidget {
  const RunsFeedScreen({super.key});

  @override
  ConsumerState<RunsFeedScreen> createState() => _RunsFeedScreenState();
}

class _RunsFeedScreenState extends ConsumerState<RunsFeedScreen> {
  final _scroll = ScrollController();
  bool _showMine = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_showMine) return;
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) {
        ref.read(runsFeedControllerProvider.notifier).loadMore().ignore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    final controller = ref.read(runsFeedControllerProvider.notifier);
    return _showMine ? controller.refreshMyRuns() : controller.refresh();
  }

  void _setSegment({required bool mine}) {
    setState(() => _showMine = mine);
    if (mine) {
      ref.read(runsFeedControllerProvider.notifier).refreshMyRuns().ignore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(runsFeedControllerProvider);
    final tokens = context.tokens;
    final colors = context.colors;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/runs/create'),
        tooltip: 'Start a run',
        icon: const Icon(Icons.directions_run),
        label: const Text('Start a run'),
      ),
      body: ContentWidth(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: _scroll,
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
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Food runs',
                                style: AppTextStyles.heading,
                              ),
                            ),
                            const NotificationBell(),
                          ],
                        ),
                        SizedBox(height: tokens.space1),
                        // Ambient trust line (whole.md §5.1) — once per
                        // surface, not once per card.
                        Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 12,
                              color: colors.onSurfaceVariant,
                            ),
                            SizedBox(width: tokens.space1),
                            Text(
                              'Every runner is a verified student',
                              style: context.text.bodySmall?.copyWith(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: tokens.space3),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: false,
                              label: Text('Live runs'),
                              icon: Icon(Icons.bolt_outlined),
                            ),
                            ButtonSegment(
                              value: true,
                              label: Text('My runs'),
                              icon: Icon(Icons.receipt_long_outlined),
                            ),
                          ],
                          selected: {_showMine},
                          showSelectedIcon: false,
                          onSelectionChanged: (selection) =>
                              _setSegment(mine: selection.first),
                        ),
                        if (!_showMine) ...[
                          SizedBox(height: tokens.space3),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilterChip(
                              avatar: const Icon(
                                Icons.credit_card_outlined,
                                size: 18,
                              ),
                              label: const Text('Dining dollars'),
                              selected: state.diningDollarsOnly,
                              onSelected: (value) => ref
                                  .read(runsFeedControllerProvider.notifier)
                                  .setDiningDollarsOnly(value: value)
                                  .ignore(),
                            ),
                          ),
                        ],
                        SizedBox(height: tokens.space3),
                      ],
                    ),
                  ),
                ),
              ),
              if (_showMine)
                ..._myRunsSlivers(state)
              else
                ..._liveSlivers(state),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _liveSlivers(RunsFeedState state) {
    final tokens = context.tokens;
    if (state.loading) return const [_SkeletonList()];
    if (state.error != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.cloud_off,
            title: "Couldn't load runs",
            body: 'Check your connection and try again.',
            actionLabel: 'Retry',
            onAction: () => ref
                .read(runsFeedControllerProvider.notifier)
                .refresh()
                .ignore(),
          ),
        ),
      ];
    }
    if (state.items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.fastfood_outlined,
            title: 'No runs right now',
            body:
                'Heading somewhere? Grab orders on your way '
                'and make a few bucks.',
            actionLabel: 'Post one',
            onAction: () => context.go('/runs/create'),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        // 96dp bottom padding so the FAB never covers a card.
        padding: EdgeInsets.fromLTRB(tokens.space4, 0, tokens.space4, 96),
        sliver: SliverList.separated(
          itemCount: state.items.length,
          separatorBuilder: (_, _) => SizedBox(height: tokens.space3),
          itemBuilder: (context, i) => FadeSlideIn(
            index: i,
            child: RunCard(run: state.items[i]),
          ),
        ),
      ),
      if (state.loadingMore)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(tokens.space3),
            child: const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
    ];
  }

  List<Widget> _myRunsSlivers(RunsFeedState state) {
    final tokens = context.tokens;
    if (state.myRunsLoading) return const [_SkeletonList()];
    if (state.myRuns.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.directions_run,
            title: 'No runs yet',
            body: 'Runs you post and orders you join will show up here.',
            actionLabel: 'Start a run',
            onAction: () => context.go('/runs/create'),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(tokens.space4, 0, tokens.space4, 96),
        sliver: SliverList.separated(
          itemCount: state.myRuns.length,
          separatorBuilder: (_, _) => SizedBox(height: tokens.space3),
          itemBuilder: (context, i) => FadeSlideIn(
            index: i,
            child: RunCard(run: state.myRuns[i], showStatus: true),
          ),
        ),
      ),
    ];
  }
}

/// One run in the feed: destination big, runner trust row, countdown +
/// fee + spots chips, delivery line. Hairline border, no elevation.
class RunCard extends StatelessWidget {
  const RunCard({required this.run, this.showStatus = false, super.key});

  final RunResponse run;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final runner = run.runner;
    final statusVisible = showStatus && run.status != RunStatus.open;

    return Pressable(
      onTap: () => context.go('/runs/run/${run.id}'),
      child: Container(
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
                  child: Text(
                    run.foodSpot.name,
                    style: AppTextStyles.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: tokens.space2),
                if (statusVisible)
                  _StatusChip(status: run.status)
                else
                  _LeavingChip(leavingAt: run.leavingAt),
              ],
            ),
            SizedBox(height: tokens.space3),
            Row(
              children: [
                VerifiedAvatar(name: runner.displayName, size: AvatarSize.sm),
                SizedBox(width: tokens.space2),
                Flexible(
                  child: Text(
                    runner.displayName,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: tokens.space2),
                ReputationChip(
                  rating: runner.ratingCount > 0
                      ? runner.reputationScore.toDouble()
                      : null,
                  ratingCount: runner.ratingCount,
                  variant: ReputationVariant.compact,
                  showCount: false,
                ),
              ],
            ),
            SizedBox(height: tokens.space3),
            Wrap(
              spacing: tokens.space2,
              runSpacing: tokens.space1,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _MetaChip(
                  icon: Icons.payments_outlined,
                  label: runFeeLabel(run.feeCents),
                  emphasized: run.feeCents == 0,
                ),
                _MetaChip(
                  icon: Icons.group_outlined,
                  label: '${run.acceptedCount}/${run.spotsMax} spots',
                ),
                if (run.prepayRequired)
                  const _MetaChip(
                    icon: Icons.lock_clock_outlined,
                    label: 'Prepay',
                  ),
                if (run.paysWithDiningDollars)
                  const _MetaChip(
                    icon: Icons.credit_card_outlined,
                    label: 'Dining dollars',
                  ),
              ],
            ),
            SizedBox(height: tokens.space2),
            Row(
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 14,
                  color: colors.onSurfaceVariant,
                ),
                SizedBox(width: tokens.space1),
                Expanded(
                  child: Text(
                    'Drops at ${run.deliverySpot}',
                    style: context.text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LeavingChip extends StatelessWidget {
  const _LeavingChip({required this.leavingAt});

  final DateTime leavingAt;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final urgent =
        leavingAt.toUtc().difference(DateTime.now().toUtc()) <
        const Duration(minutes: 10);
    final color = urgent ? tokens.warning : tokens.success;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space2,
        vertical: tokens.space1,
      ),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: .12),
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 12, color: color),
          SizedBox(width: tokens.space1),
          Text(
            leavingLabel(leavingAt),
            style: context.text.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final RunStatus status;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = runStatusColor(context, status);
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
        runStatusLabel(status),
        style: context.text.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final color = emphasized ? tokens.success : colors.onSurfaceVariant;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space2,
        vertical: tokens.space1,
      ),
      decoration: ShapeDecoration(
        color: colors.surfaceContainerHighest,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: tokens.space1),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton list matching the run card geometry (spec §13.1).
class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(tokens.space4, 0, tokens.space4, 96),
      sliver: SliverList.separated(
        itemCount: 4,
        separatorBuilder: (_, _) => SizedBox(height: tokens.space3),
        itemBuilder: (_, _) => Container(
          padding: EdgeInsets.all(tokens.space4),
          decoration: BoxDecoration(
            borderRadius: tokens.brMd,
            border: Border.all(color: colors.outlineVariant),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 180, height: 22),
              SizedBox(height: 12),
              Row(
                children: [
                  SkeletonBox(width: 32, height: 32, shape: BoxShape.circle),
                  SizedBox(width: 8),
                  SkeletonBox(width: 120, height: 14),
                ],
              ),
              SizedBox(height: 12),
              SkeletonBox(width: 220, height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
