import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/admin/data/behavior_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Behaviour insights (admin/moderator): which screens students live on,
/// how long they stay, and what they actually do — the data the product
/// gets shaped around. Reads GET /admin/behavior.
class BehaviorInsightsScreen extends ConsumerStatefulWidget {
  const BehaviorInsightsScreen({super.key});

  @override
  ConsumerState<BehaviorInsightsScreen> createState() =>
      _BehaviorInsightsScreenState();
}

class _BehaviorInsightsScreenState
    extends ConsumerState<BehaviorInsightsScreen> {
  int _days = 14;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final insights = ref.watch(behaviorInsightsProvider(_days));

    return Scaffold(
      appBar: AppBar(title: const Text('Behavior insights')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(behaviorInsightsProvider(_days).future),
        child: ListView(
          padding: EdgeInsets.all(tokens.space4),
          children: [
            Center(
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 7, label: Text('7 days')),
                  ButtonSegment(value: 14, label: Text('14 days')),
                  ButtonSegment(value: 30, label: Text('30 days')),
                ],
                selected: {_days},
                showSelectedIcon: false,
                onSelectionChanged: (sel) => setState(() => _days = sel.first),
              ),
            ),
            SizedBox(height: tokens.space4),
            ...insights.when(
              loading: _skeletons,
              error: (_, _) => [
                EmptyState(
                  icon: Icons.insights_outlined,
                  title: "Couldn't load insights",
                  body: 'Check your connection and try again.',
                  actionLabel: 'Retry',
                  onAction: () =>
                      ref.invalidate(behaviorInsightsProvider(_days)),
                ),
              ],
              data: (data) => data.daily.isEmpty
                  ? const [
                      EmptyState(
                        icon: Icons.insights_outlined,
                        title: 'No activity yet',
                        body:
                            'Data appears as soon as students start '
                            'using the app.',
                      ),
                    ]
                  : _sections(context, data),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _skeletons() {
    final tokens = context.tokens;
    return [
      for (var i = 0; i < 5; i++) ...[
        SkeletonBox(height: 92, borderRadius: tokens.brLg),
        SizedBox(height: tokens.space3),
      ],
    ];
  }

  List<Widget> _sections(BuildContext context, BehaviorResponse data) {
    final tokens = context.tokens;
    final today = data.daily.isNotEmpty ? data.daily.first : null;
    final totalEvents = data.daily.fold<int>(0, (sum, d) => sum + d.events);
    return [
      Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'ACTIVE TODAY',
              value: '${today?.activeUsers ?? 0}',
            ),
          ),
          SizedBox(width: tokens.space3),
          Expanded(
            child: _SummaryCard(
              label: 'SESSIONS TODAY',
              value: '${today?.sessions ?? 0}',
            ),
          ),
          SizedBox(width: tokens.space3),
          Expanded(
            child: _SummaryCard(label: 'EVENTS', value: '$totalEvents'),
          ),
        ],
      ),
      SizedBox(height: tokens.space5),
      const _SectionTitle('Daily pulse', 'Active students per day'),
      SizedBox(height: tokens.space3),
      _DailyPulseChart(days: data.daily.toList()),
      SizedBox(height: tokens.space5),
      const _SectionTitle(
        'Where students spend time',
        'By total minutes on screen',
      ),
      SizedBox(height: tokens.space3),
      _ScreenTimeCard(screens: data.screens.toList()),
      SizedBox(height: tokens.space5),
      const _SectionTitle('Top actions', 'What students actually do'),
      SizedBox(height: tokens.space3),
      _TopActionsCard(events: data.topEvents.toList()),
      SizedBox(height: tokens.space6),
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.titleMedium),
        Text(
          subtitle,
          style: context.text.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: tokens.space4,
        horizontal: tokens.space2,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: tokens.brLg,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Text(value, style: context.text.headlineSmall),
          SizedBox(height: tokens.space1),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 0.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Simple vertical bar chart: one bar per day, oldest → newest, the one
/// accent color on a neutral track. No chart dependency needed.
class _DailyPulseChart extends StatelessWidget {
  const _DailyPulseChart({required this.days});

  /// Newest first, as the API returns them.
  final List<BehaviorDay> days;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final ordered = days.reversed.toList();
    final peak = ordered.fold<int>(
      1,
      (m, d) => d.activeUsers > m ? d.activeUsers : m,
    );
    return Container(
      padding: EdgeInsets.all(tokens.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: tokens.brLg,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 96,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final day in ordered) ...[
                  Expanded(
                    child: Semantics(
                      label:
                          '${day.day}: ${day.activeUsers} active, '
                          '${day.sessions} sessions',
                      child: Tooltip(
                        message:
                            '${day.day} — ${day.activeUsers} active, '
                            '${day.sessions} sessions, ${day.events} events',
                        child: FractionallySizedBox(
                          alignment: Alignment.bottomCenter,
                          heightFactor: (day.activeUsers / peak).clamp(
                            0.04,
                            1.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: tokens.brSm,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (day != ordered.last) SizedBox(width: tokens.space1),
                ],
              ],
            ),
          ),
          SizedBox(height: tokens.space2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ordered.first.day}',
                style: context.text.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                'peak $peak',
                style: context.text.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                '${ordered.last.day}',
                style: context.text.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ranked screens: friendly name, views + avg dwell, and a horizontal bar
/// proportional to total minutes spent there.
class _ScreenTimeCard extends StatelessWidget {
  const _ScreenTimeCard({required this.screens});

  final List<ScreenStat> screens;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final shown = screens.take(10).toList();
    final peakMinutes = shown.fold<double>(
      1,
      (m, s) => s.totalMinutes > m ? s.totalMinutes.toDouble() : m,
    );
    return Container(
      padding: EdgeInsets.all(tokens.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: tokens.brLg,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: shown.isEmpty
          ? Text(
              'No screen data yet.',
              style: context.text.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            )
          : Column(
              children: [
                for (final s in shown) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              screenLabel(s.screen),
                              style: context.text.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _dwellLabel(s.avgSeconds),
                            style: context.text.labelMedium,
                          ),
                        ],
                      ),
                      SizedBox(height: tokens.space1),
                      ClipRRect(
                        borderRadius: tokens.brSm,
                        child: LinearProgressIndicator(
                          value: (s.totalMinutes / peakMinutes).clamp(
                            0.02,
                            1.0,
                          ),
                          minHeight: 6,
                          backgroundColor: colors.surfaceContainerHighest,
                          color: colors.primary,
                        ),
                      ),
                      SizedBox(height: tokens.space1),
                      Text(
                        '${s.views} views · ${s.uniqueUsers} students · '
                        '${s.totalMinutes.toStringAsFixed(0)} min total',
                        style: context.text.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (s != shown.last) SizedBox(height: tokens.space3),
                ],
              ],
            ),
    );
  }
}

class _TopActionsCard extends StatelessWidget {
  const _TopActionsCard({required this.events});

  final List<EventStat> events;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final shown = events.take(12).toList();
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: tokens.brLg,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: shown.isEmpty
          ? Padding(
              padding: EdgeInsets.all(tokens.space4),
              child: Text(
                'No actions recorded yet.',
                style: context.text.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            )
          : Column(
              children: [
                for (final e in shown) ...[
                  ListTile(
                    dense: true,
                    title: Text(eventLabel(e.name)),
                    subtitle: Text('${e.uniqueUsers} students'),
                    trailing: Text(
                      '${e.count}',
                      style: context.text.titleSmall,
                    ),
                  ),
                  if (e != shown.last)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
    );
  }
}

String _dwellLabel(num seconds) {
  if (seconds < 60) return '${seconds.toStringAsFixed(0)}s avg';
  return '${(seconds / 60).toStringAsFixed(1)}m avg';
}

/// Friendly names for the normalized route patterns the tracker emits.
const _screenNames = <String, String>{
  '/runs': 'Runs feed',
  '/runs/run/:id': 'Run details',
  '/runs/create': 'Post a run',
  '/my-runs': 'My runs',
  '/profile': 'Profile',
  '/profile/orders': 'Orders',
  '/profile/edit': 'Edit profile',
  '/profile/payment-methods': 'Payment methods',
  '/profile/my-listings': 'My listings',
  '/profile/insights': 'Behavior insights',
  '/notifications': 'Notifications',
  '/messages/:id': 'Direct messages',
  '/market': 'Marketplace',
  '/market/listing/:id': 'Listing details',
  '/market/sell': 'Sell',
  '/tutors': 'Tutor search',
  '/chats': 'Chats',
  '/chats/room/:id': 'Chat room',
  '/chats/conversation/:id': 'Conversation',
  '/login': 'Login',
  '/register': 'Register',
  '/verify': 'Verify email',
  '/forgot-password': 'Forgot password',
};

String screenLabel(String screen) => _screenNames[screen] ?? screen;

/// "app.run_order_placed" → "Run order placed".
String eventLabel(String name) {
  final bare = name.startsWith('app.') ? name.substring(4) : name;
  final words = bare.replaceAll('_', ' ').replaceAll('.', ' · ');
  return words.isEmpty ? name : words[0].toUpperCase() + words.substring(1);
}
