import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/network/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reads the behaviour-insights aggregate (GET /admin/behavior).
/// Moderator/admin only — the API enforces it; the UI hides the entry.
class BehaviorRepository {
  BehaviorRepository(this._api);

  final CampusApi _api;

  Future<BehaviorResponse> fetch({required int days}) async {
    final api = _api.getAnalyticsApi();
    final resp = await api.adminBehaviorApiV1AdminBehaviorGet(days: days);
    return resp.data!;
  }
}

final behaviorRepositoryProvider = Provider<BehaviorRepository>(
  (ref) => BehaviorRepository(ref.watch(campusApiProvider)),
);

/// One fetch per selected window; autoDispose so stale windows refetch.
final AutoDisposeFutureProviderFamily<BehaviorResponse, int>
behaviorInsightsProvider = FutureProvider.autoDispose
    .family<BehaviorResponse, int>(
      (ref, days) => ref.watch(behaviorRepositoryProvider).fetch(days: days),
    );
