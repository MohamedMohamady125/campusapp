import 'package:test/test.dart';
import 'package:campus_api/campus_api.dart';


/// tests for AdminApi
void main() {
  final instance = CampusApi().getAdminApi();

  group(AdminApi, () {
    // Admin Metrics
    //
    //Future<MetricsResponse> adminMetricsApiV1AdminMetricsGet({ int days }) async
    test('test adminMetricsApiV1AdminMetricsGet', () async {
      // TODO
    });

  });
}
