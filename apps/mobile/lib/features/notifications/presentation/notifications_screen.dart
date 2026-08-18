import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/fade_slide_in.dart';
import 'package:campusconnect/design_system/components/pressable.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/notifications/presentation/notification_presenter.dart';
import 'package:campusconnect/features/notifications/presentation/notifications_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Notifications inbox (Sprint 6): paginated list, per-type rows,
/// optimistic mark-read, and deep links into chats/DMs.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) {
        ref.read(notificationsControllerProvider.notifier).loadMore().ignore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _open(NotificationResponse notification) {
    // Optimistic: the row and badge flip before the API call resolves.
    ref
        .read(notificationsControllerProvider.notifier)
        .markRead(notification)
        .ignore();
    final route = notificationRoute(notification);
    if (route == null) return;
    context.go(route.$1, extra: route.$2);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => controller.markAllRead().ignore(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: state.loading
          ? ListView(
              children: const [
                ListRowSkeleton(),
                ListRowSkeleton(),
                ListRowSkeleton(),
                ListRowSkeleton(),
              ],
            )
          : state.items.isEmpty
          ? (state.error != null
                ? EmptyState(
                    icon: Icons.cloud_off,
                    title: "Couldn't load notifications",
                    body: 'Check your connection and try again.',
                    actionLabel: 'Retry',
                    onAction: () => controller.refresh().ignore(),
                  )
                : const EmptyState(
                    icon: Icons.notifications_none,
                    title: "You're all caught up",
                    body: 'New messages and mentions will land here.',
                  ))
          : RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView.separated(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(tokens.space4),
                itemCount: state.items.length + (state.loadingMore ? 1 : 0),
                separatorBuilder: (_, _) => SizedBox(height: tokens.space2),
                itemBuilder: (context, i) {
                  if (i >= state.items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }
                  final notification = state.items[i];
                  return FadeSlideIn(
                    index: i,
                    child: _NotificationRow(
                      notification: notification,
                      onTap: () => _open(notification),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification, required this.onTap});

  final NotificationResponse notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final unread = notification.readAt == null;
    final mention = notificationIsMention(notification);

    return MergeSemantics(
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(tokens.space3),
          decoration: BoxDecoration(
            // Unread rows get the primaryBg tint (Fifty Free §5).
            color: unread ? colors.primaryContainer : colors.surface,
            borderRadius: tokens.brSm,
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: mention
                      ? colors.primaryContainer
                      : colors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notificationIcon(notification),
                  size: 20,
                  color: mention ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
              SizedBox(width: tokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notificationTitle(notification),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w400,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: tokens.space1),
                    Text(
                      notificationRelativeTime(notification.createdAt),
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (unread) ...[
                SizedBox(width: tokens.space2),
                Container(
                  key: ValueKey('unread-dot-${notification.id}'),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
