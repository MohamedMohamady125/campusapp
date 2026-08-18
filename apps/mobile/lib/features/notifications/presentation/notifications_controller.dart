import 'dart:async';

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/features/notifications/data/notifications_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Unread notification count for the bell badge (Sprint 6).
///
/// Polls every 15s while a bell is on screen — same pattern as the 5s chat
/// room poll, just slower because the badge is ambient, not a conversation.
class UnreadNotificationsController extends AutoDisposeNotifier<int> {
  static const _pollInterval = Duration(seconds: 15);

  NotificationsRepository get _repo =>
      ref.read(notificationsRepositoryProvider);

  @override
  int build() {
    final timer = Timer.periodic(_pollInterval, (_) => refresh().ignore());
    ref.onDispose(timer.cancel);
    unawaited(Future.microtask(refresh));
    return 0;
  }

  Future<void> refresh() async {
    try {
      final page = await _repo.fetchPage(limit: 1);
      state = page.unreadCount;
    } on Object {
      // Keep the last known count; the next poll will reconcile.
    }
  }

  /// Sets the count from a fresher server response (notifications screen).
  void set(int count) => state = count < 0 ? 0 : count;

  /// Optimistic decrement when a single notification is marked read.
  void decrement() => set(state - 1);
}

final AutoDisposeNotifierProvider<UnreadNotificationsController, int>
unreadNotificationsProvider =
    NotifierProvider.autoDispose<UnreadNotificationsController, int>(
      UnreadNotificationsController.new,
    );

/// State for the notifications screen; newest first, cursor-paginated.
class NotificationsState {
  const NotificationsState({
    this.items = const [],
    this.nextCursor,
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final List<NotificationResponse> items;
  final String? nextCursor;
  final bool loading;
  final bool loadingMore;
  final String? error;
}

/// Notifications list controller: initial load, infinite scroll, and
/// optimistic mark-read (spec §6.3) that keeps the bell badge in sync.
class NotificationsController extends AutoDisposeNotifier<NotificationsState> {
  NotificationsRepository get _repo =>
      ref.read(notificationsRepositoryProvider);

  @override
  NotificationsState build() {
    unawaited(Future.microtask(refresh));
    return const NotificationsState();
  }

  Future<void> refresh() async {
    try {
      final page = await _repo.fetchPage();
      ref.read(unreadNotificationsProvider.notifier).set(page.unreadCount);
      state = NotificationsState(
        items: page.items.toList(),
        nextCursor: page.nextCursor,
        loading: false,
      );
    } on Object catch (e) {
      state = NotificationsState(
        items: state.items,
        loading: false,
        error: apiErrorMessage(e),
      );
    }
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loading || state.loadingMore) return;
    state = NotificationsState(
      items: state.items,
      nextCursor: cursor,
      loading: false,
      loadingMore: true,
    );
    try {
      final page = await _repo.fetchPage(cursor: cursor);
      state = NotificationsState(
        items: [...state.items, ...page.items],
        nextCursor: page.nextCursor,
        loading: false,
      );
    } on Object {
      state = NotificationsState(
        items: state.items,
        nextCursor: cursor,
        loading: false,
      );
    }
  }

  /// Marks one notification read — optimistic: the row and the badge update
  /// immediately; the next poll reconciles if the call fails.
  Future<void> markRead(NotificationResponse notification) async {
    if (notification.readAt != null) return;
    _setRead({notification.id});
    ref.read(unreadNotificationsProvider.notifier).decrement();
    try {
      await _repo.markRead([notification.id]);
    } on Object {
      // Optimistic state stands; polling reconciles.
    }
  }

  Future<void> markAllRead() async {
    _setRead(state.items.map((n) => n.id).toSet());
    ref.read(unreadNotificationsProvider.notifier).set(0);
    try {
      await _repo.markAllRead();
    } on Object {
      // Optimistic state stands; polling reconciles.
    }
  }

  void _setRead(Set<String> ids) {
    final now = DateTime.now().toUtc();
    state = NotificationsState(
      items: [
        for (final n in state.items)
          if (ids.contains(n.id) && n.readAt == null)
            n.rebuild((b) => b.readAt = now)
          else
            n,
      ],
      nextCursor: state.nextCursor,
      loading: false,
    );
  }
}

final AutoDisposeNotifierProvider<NotificationsController, NotificationsState>
notificationsControllerProvider =
    NotifierProvider.autoDispose<NotificationsController, NotificationsState>(
      NotificationsController.new,
    );
