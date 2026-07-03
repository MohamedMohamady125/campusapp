import 'package:test/test.dart';
import 'package:campus_api/campus_api.dart';


/// tests for ReportsApi
void main() {
  final instance = CampusApi().getReportsApi();

  group(ReportsApi, () {
    // Create Report
    //
    //Future<ReportResponse> createReportApiV1ReportsPost(ReportCreateRequest reportCreateRequest) async
    test('test createReportApiV1ReportsPost', () async {
      // TODO
    });

    // List Reports
    //
    //Future<ReportPageResponse> listReportsApiV1AdminReportsGet({ String cursor, int limit }) async
    test('test listReportsApiV1AdminReportsGet', () async {
      // TODO
    });

    // Update Report
    //
    //Future<ReportResponse> updateReportApiV1AdminReportsReportIdPatch(String reportId, ReportUpdateRequest reportUpdateRequest) async
    test('test updateReportApiV1AdminReportsReportIdPatch', () async {
      // TODO
    });

  });
}
