import 'package:test/test.dart';
import 'package:campus_api/campus_api.dart';


/// tests for MetaApi
void main() {
  final instance = CampusApi().getMetaApi();

  group(MetaApi, () {
    // Get Flags
    //
    //Future<BuiltList<FlagItem>> getFlagsApiV1FlagsGet() async
    test('test getFlagsApiV1FlagsGet', () async {
      // TODO
    });

    // Health
    //
    //Future<HealthResponse> healthApiV1HealthGet() async
    test('test healthApiV1HealthGet', () async {
      // TODO
    });

    // Ready
    //
    //Future<ReadyResponse> readyApiV1HealthReadyGet() async
    test('test readyApiV1HealthReadyGet', () async {
      // TODO
    });

  });
}
