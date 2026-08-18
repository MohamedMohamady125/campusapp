import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/network/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifications via the generated client (spec §4.1 notifications).
class NotificationsRepository {
  NotificationsRepository(this._api);

  final CampusApi _api;

  NotificationsApi get _notifications => _api.getNotificationsApi();

  /// One page of notifications plus the server's unread count.
  Future<NotificationPageResponse> fetchPage({
    String? cursor,
    int limit = 20,
  }) async {
    final res = await _notifications.listNotificationsApiV1NotificationsGet(
      cursor: cursor,
      limit: limit,
    );
    return res.data!;
  }

  /// Marks the given notifications read.
  Future<void> markRead(List<String> ids) async {
    await _notifications.markNotificationsReadApiV1NotificationsReadPost(
      notificationsReadRequest: NotificationsReadRequest(
        (b) => b.ids.addAll(ids),
      ),
    );
  }

  /// Marks every notification read (`ids` omitted = all, per the API).
  Future<void> markAllRead() async {
    await _notifications.markNotificationsReadApiV1NotificationsReadPost(
      notificationsReadRequest: NotificationsReadRequest(),
    );
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.watch(campusApiProvider)),
);
