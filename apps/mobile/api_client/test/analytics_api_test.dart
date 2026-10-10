import 'package:test/test.dart';
import 'package:campus_api/campus_api.dart';


/// tests for AnalyticsApi
void main() {
  final instance = CampusApi().getAnalyticsApi();

  group(AnalyticsApi, () {
    // Admin Behavior
    //
    //Future<BehaviorResponse> adminBehaviorApiV1AdminBehaviorGet({ int days }) async
    test('test adminBehaviorApiV1AdminBehaviorGet', () async {
      // TODO
    });

    // Ingest Events
    //
    //Future ingestEventsApiV1AnalyticsEventsPost(ClientEventBatchRequest clientEventBatchRequest) async
    test('test ingestEventsApiV1AnalyticsEventsPost', () async {
      // TODO
    });

  });
}
