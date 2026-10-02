import 'dart:async' show Timer, unawaited;

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/components/content_width.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/fade_slide_in.dart';
import 'package:campusconnect/design_system/components/live_dot.dart';
import 'package:campusconnect/design_system/components/pressable.dart';
import 'package:campusconnect/design_system/components/reputation_chip.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/components/verified_avatar.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_colors.dart';
import 'package:campusconnect/design_system/theme/app_motion.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/food_runs/presentation/run_format.dart';
import 'package:campusconnect/features/food_runs/presentation/run_row.dart';
import 'package:campusconnect/features/food_runs/presentation/runs_feed_controller.dart';
import 'package:campusconnect/features/notifications/presentation/notification_bell.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Feed view filter. `all` keeps server order; `topRated`/`closingSoon` are
/// client-side sorts over already-loaded runs (real data, no new endpoint).
enum _RunFilter { all, topRated, closingSoon }

/// Food runs — the hero home screen. A blue hero card for the run you should
/// grab right now, then the rest as compact rows. The user's own runs live
/// in the dedicated My Runs tab.
class RunsFeedScreen extends ConsumerStatefulWidget {
  const RunsFeedScreen({super.key});

  @override
  ConsumerState<RunsFeedScreen> createState() => _RunsFeedScreenState();
}

class _RunsFeedScreenState extends ConsumerState<RunsFeedScreen> {
  final _scroll = ScrollController();
  _RunFilter _filter = _RunFilter.all;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
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

  Future<void> _refresh() async {
    await ref.read(runsFeedControllerProvider.notifier).refresh();
    unawaited(HapticFeedback.selectionClick());
  }

  void _setFilter(_RunFilter filter) => setState(() => _filter = filter);

  /// Live runs re-ordered for the active filter. Sorts are pure views over the
  /// loaded page — every key is a field the API already returns.
  List<RunResponse> _sorted(List<RunResponse> items) {
    switch (_filter) {
      case _RunFilter.topRated:
        final list = [...items]
          ..sort(
            (a, b) =>
                b.runner.reputationScore.compareTo(a.runner.reputationScore),
          );
        return list;
      case _RunFilter.closingSoon:
        final list = [...items]
          ..sort((a, b) => a.leavingAt.compareTo(b.leavingAt));
        return list;
      case _RunFilter.all:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(runsFeedControllerProvider);
    final liveCount = state.items.length;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/runs/create'),
        tooltip: 'Post a run',
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        icon: const Icon(Icons.add),
        label: Text('Post a run', style: AppTextStyles.button),
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
                  child: _Header(
                    liveCount: liveCount,
                    filter: _filter,
                    onFilter: _setFilter,
                  ),
                ),
              ),
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
            title: 'No runs open right now',
            body:
                'The lunch rush is quiet. Heading somewhere on campus? '
                'Post a run and orders come to you.',
            actionLabel: 'Post a run',
            onAction: () => context.go('/runs/create'),
          ),
        ),
      ];
    }

    final sorted = _sorted(state.items);
    final hero = sorted.first;
    final rest = sorted.skip(1).toList();
    final myId = ref.read(authControllerProvider).user?.id;

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space4,
            tokens.space2,
            tokens.space4,
            tokens.space4,
          ),
          child: FadeSlideIn(
            child: _HeroRunCard(run: hero, isMine: hero.runner.id == myId),
          ),
        ),
      ),
      if (rest.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space4,
              0,
              tokens.space4,
              tokens.space3,
            ),
            child: Text('OPEN NOW · ON CAMPUS', style: AppTextStyles.labelWide),
          ),
        ),
      SliverPadding(
        // 96dp bottom padding so the FAB never covers a row.
        padding: EdgeInsets.fromLTRB(tokens.space4, 0, tokens.space4, 96),
        sliver: SliverList.separated(
          itemCount: rest.length,
          separatorBuilder: (_, _) => SizedBox(height: tokens.space3),
          itemBuilder: (context, i) => FadeSlideIn(
            index: i + 1,
            child: RunRow(run: rest[i]),
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
}

/// Screen header: date eyebrow, title + live pill + bell, filter chips.
class _Header extends StatelessWidget {
  const _Header({
    required this.liveCount,
    required this.filter,
    required this.onFilter,
  });

  final int liveCount;
  final _RunFilter filter;
  final ValueChanged<_RunFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space4,
            tokens.space4,
            tokens.space4,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _dateEyebrow(),
                style: AppTextStyles.labelWide.copyWith(
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: tokens.space1),
              Row(
                children: [
                  Text('Food Runs', style: AppTextStyles.displayMedium),
                  SizedBox(width: tokens.space3),
                  if (liveCount > 0) _LivePill(count: liveCount),
                  const Spacer(),
                  const NotificationBell(),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.space3),
        _FeedFilters(selected: filter, onSelected: onFilter),
        SizedBox(height: tokens.space1),
      ],
    );
  }

  /// Persona: greet by time of day instead of a flat date stamp.
  static String _dateEyebrow() {
    const days = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];
    final now = DateTime.now();
    final greeting = switch (now.hour) {
      < 5 => 'LATE NIGHT CRAVINGS',
      < 12 => 'GOOD MORNING',
      < 17 => 'GOOD AFTERNOON',
      _ => 'GOOD EVENING',
    };
    return '$greeting · ${days[now.weekday - 1]} ${clockTime(now)}';
  }
}

/// Green "N live" pill with a pulsing dot — signals a live, breathing feed.
class _LivePill extends StatelessWidget {
  const _LivePill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space2,
        vertical: tokens.space1,
      ),
      decoration: ShapeDecoration(
        color: tokens.success.withValues(alpha: .12),
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiveDot(color: tokens.success),
          SizedBox(width: tokens.space1),
          Text(
            '$count live',
            style: context.text.labelSmall?.copyWith(
              color: tokens.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal filter row — doubles as the sort selector and the My-runs switch.
class _FeedFilters extends StatelessWidget {
  const _FeedFilters({required this.selected, required this.onSelected});

  final _RunFilter selected;
  final ValueChanged<_RunFilter> onSelected;

  static const _options = <(_RunFilter, String)>[
    (_RunFilter.all, 'All runs'),
    (_RunFilter.closingSoon, 'Closing soon'),
    (_RunFilter.topRated, 'Top rated'),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: tokens.space4),
        children: [
          for (final (value, label) in _options)
            Padding(
              padding: EdgeInsets.only(right: tokens.space2),
              child: FilterChip(
                label: Text(label),
                selected: selected == value,
                showCheckmark: false,
                shape: const StadiumBorder(),
                // Yamesh-kit chips: selected is a solid brand fill with white
                // text, unselected stays a quiet hairline pill.
                backgroundColor: colors.surface,
                selectedColor: colors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.space3,
                  vertical: tokens.space2,
                ),
                side: selected == value
                    ? BorderSide.none
                    : BorderSide(color: colors.outlineVariant),
                labelStyle: context.text.labelMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: selected == value
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: selected == value
                      ? Colors.white
                      : colors.onSurfaceVariant,
                ),
                onSelected: (_) => onSelected(value),
              ),
            ),
        ],
      ),
    );
  }
}

/// The one run to grab now — full-bleed brand blue, glow shadow, white ink.
/// The countdown ticks live every second (Uber-style urgency) and the spots
/// bar animates as seats fill.
class _HeroRunCard extends StatefulWidget {
  const _HeroRunCard({required this.run, required this.isMine});

  final RunResponse run;

  /// The viewer is this run's runner — never show them "Attach my order".
  final bool isMine;

  @override
  State<_HeroRunCard> createState() => _HeroRunCardState();
}

class _HeroRunCardState extends State<_HeroRunCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Tick the countdown once a second only while it's inside the final
    // hour — beyond that the label is a clock time and never changes.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final mins = widget.run.leavingAt
          .toLocal()
          .difference(DateTime.now())
          .inMinutes;
      if (mins < 60 && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final run = widget.run;
    final tokens = context.tokens;

    return Pressable(
      onTap: () => context.go('/runs/run/${run.id}'),
      child: Container(
        decoration: BoxDecoration(
          // Branded depth: deep→light blue sweep instead of a flat fill.
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              Color(0xFF2A72B4),
            ],
          ),
          borderRadius: BorderRadius.circular(tokens.radiusXl),
          boxShadow: AppShadows.primaryGlow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Soft decorative glow orb in the corner — persona, not clutter.
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: .14),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(tokens.space5),
              child: _heroBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroBody(BuildContext context) {
    final run = widget.run;
    final tokens = context.tokens;
    final runner = run.runner;
    final rated = runner.ratingCount > 0;
    final ratingText = ReputationChip.formatRating(
      runner.reputationScore.toDouble(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'CLOSING IN',
                style: AppTextStyles.labelWide.copyWith(
                  color: Colors.white.withValues(alpha: .7),
                ),
              ),
            ),
            Text(
              _liveClosingLabel(run.leavingAt),
              style: AppTextStyles.titleLarge.copyWith(
                color: Colors.white,
                // Tabular figures — the ticking clock never jitters
                // horizontally (number-tabular).
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.space3),
        Text(
          run.foodSpot.name,
          style: AppTextStyles.heading.copyWith(color: Colors.white),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: tokens.space4),
        Row(
          children: [
            VerifiedAvatar(
              name: runner.displayName,
              size: AvatarSize.sm,
              showEmblem: false,
            ),
            SizedBox(width: tokens.space2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    runner.displayName,
                    style: context.text.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    rated
                        ? '★ $ratingText · ${runner.ratingCount} ratings'
                        : 'New runner',
                    style: context.text.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: .75),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'FEE',
                  style: AppTextStyles.labelTiny.copyWith(
                    color: Colors.white.withValues(alpha: .6),
                  ),
                ),
                Text(
                  run.feeCents == 0 ? 'Free' : runFeeAmount(run.feeCents),
                  style: AppTextStyles.statSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: tokens.space4),
        _SpotsBar(taken: run.acceptedCount, max: run.spotsMax),
        SizedBox(height: tokens.space4),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () => context.go('/runs/run/${run.id}'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(52),
                  // Full-round pill CTA — the delivery-kit signature shape.
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  widget.isMine
                      ? 'Manage my run'
                      : run.myOrder != null
                      ? 'View my order'
                      : 'Attach my order',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: tokens.space2),
            _HeroIconButton(
              icon: Icons.chat_bubble_outline,
              onTap: () => context.go('/runs/run/${run.id}'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Animated seat-fill bar on the hero card — "3 of 5 spots taken" as a
/// gamified capacity meter that eases to its new width whenever the poll
/// brings fresh numbers.
class _SpotsBar extends StatelessWidget {
  const _SpotsBar({required this.taken, required this.max});

  final int taken;
  final int max;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final left = max - taken;
    final frac = max == 0 ? 0.0 : (taken / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                left <= 0 ? 'RUN IS FULL' : 'SPOTS',
                style: AppTextStyles.labelTiny.copyWith(
                  color: Colors.white.withValues(alpha: .6),
                ),
              ),
            ),
            Text(
              left <= 0 ? '$taken/$max' : '$left of $max left',
              style: context.text.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.space1),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 6,
            child: Stack(
              children: [
                Container(color: Colors.white.withValues(alpha: .22)),
                TweenAnimationBuilder<double>(
                  tween: Tween(end: frac),
                  duration: AppMotion.resolve(context, AppMotion.micro),
                  curve: AppMotion.emphasized,
                  builder: (context, value, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: const ColoredBox(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Countdown label for the hero: `mm:ss` ticking inside the final hour,
/// otherwise a clock time.
String _liveClosingLabel(DateTime leavingAt) {
  final diff = leavingAt.toLocal().difference(DateTime.now());
  if (diff.isNegative) return 'now';
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    final s = diff.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
  return clockTime(leavingAt.toLocal());
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'View run details',
      child: Tooltip(
        message: 'View run details',
        child: Material(
          color: Colors.white.withValues(alpha: .16),
          shape: const StadiumBorder(),
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withValues(alpha: .3),
            customBorder: const StadiumBorder(),
            child: SizedBox(
              width: 52,
              height: 52,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton list matching the new hero + row geometry.
class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        tokens.space4,
        tokens.space2,
        tokens.space4,
        96,
      ),
      sliver: SliverList.list(
        children: [
          // Hero placeholder.
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: tokens.brLg,
            ),
          ),
          SizedBox(height: tokens.space4),
          // Section eyebrow ("OPEN NOW · ON CAMPUS") placeholder.
          const SkeletonBox(width: 140, height: 12),
          SizedBox(height: tokens.space3),
          for (var i = 0; i < 4; i++) ...[
            Container(
              padding: EdgeInsets.all(tokens.space3),
              decoration: BoxDecoration(
                borderRadius: tokens.brLg,
                border: Border.all(color: colors.outlineVariant),
              ),
              child: const Row(
                children: [
                  SkeletonBox(width: 56, height: 56),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 140, height: 18),
                        SizedBox(height: 8),
                        SkeletonBox(width: 180, height: 12),
                      ],
                    ),
                  ),
                  SkeletonBox(width: 56, height: 28),
                ],
              ),
            ),
            SizedBox(height: tokens.space3),
          ],
        ],
      ),
    );
  }
}
