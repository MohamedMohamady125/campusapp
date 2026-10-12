import 'package:built_collection/built_collection.dart';
import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/network/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sends a staff announcement (POST /admin/notifications). Admin only —
/// the API enforces it; the UI hides the entry.
class BroadcastRepository {
  BroadcastRepository(this._api);

  final CampusApi _api;

  /// Returns (sent count, unknown emails). Empty [emails] = everyone.
  Future<AdminBroadcastResponse> send({
    required String title,
    required String body,
    required List<String> emails,
  }) async {
    final resp = await _api
        .getAdminApi()
        .sendBroadcastApiV1AdminNotificationsPost(
          adminBroadcastRequest: AdminBroadcastRequest(
            (b) => b
              ..title = title
              ..body = body
              ..emails = emails.isEmpty ? null : ListBuilder(emails),
          ),
        );
    return resp.data!;
  }
}

final broadcastRepositoryProvider = Provider<BroadcastRepository>(
  (ref) => BroadcastRepository(ref.watch(campusApiProvider)),
);
