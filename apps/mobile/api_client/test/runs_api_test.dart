import 'package:test/test.dart';
import 'package:campus_api/campus_api.dart';


/// tests for RunsApi
void main() {
  final instance = CampusApi().getRunsApi();

  group(RunsApi, () {
    // Accept Order
    //
    //Future<RunResponse> acceptOrderApiV1RunsRunIdOrdersOrderIdAcceptPost(String runId, String orderId) async
    test('test acceptOrderApiV1RunsRunIdOrdersOrderIdAcceptPost', () async {
      // TODO
    });

    // Cancel Run
    //
    //Future<RunResponse> cancelRunApiV1RunsRunIdCancelPost(String runId) async
    test('test cancelRunApiV1RunsRunIdCancelPost', () async {
      // TODO
    });

    // Confirm Received
    //
    //Future<RunResponse> confirmReceivedApiV1RunsRunIdOrdersOrderIdReceivedPost(String runId, String orderId) async
    test('test confirmReceivedApiV1RunsRunIdOrdersOrderIdReceivedPost', () async {
      // TODO
    });

    // Create Run
    //
    //Future<RunResponse> createRunApiV1RunsPost(RunCreateRequest runCreateRequest) async
    test('test createRunApiV1RunsPost', () async {
      // TODO
    });

    // Decline Order
    //
    //Future<RunResponse> declineOrderApiV1RunsRunIdOrdersOrderIdDeclinePost(String runId, String orderId) async
    test('test declineOrderApiV1RunsRunIdOrdersOrderIdDeclinePost', () async {
      // TODO
    });

    // Get Run
    //
    //Future<RunResponse> getRunApiV1RunsRunIdGet(String runId) async
    test('test getRunApiV1RunsRunIdGet', () async {
      // TODO
    });

    // List Spots
    //
    //Future<BuiltList<FoodSpotResponse>> listSpotsApiV1RunsSpotsGet() async
    test('test listSpotsApiV1RunsSpotsGet', () async {
      // TODO
    });

    // Mark Delivered
    //
    //Future<RunResponse> markDeliveredApiV1RunsRunIdOrdersOrderIdDeliveredPost(String runId, String orderId) async
    test('test markDeliveredApiV1RunsRunIdOrdersOrderIdDeliveredPost', () async {
      // TODO
    });

    // Mark No Show
    //
    //Future<RunResponse> markNoShowApiV1RunsRunIdOrdersOrderIdNoShowPost(String runId, String orderId) async
    test('test markNoShowApiV1RunsRunIdOrdersOrderIdNoShowPost', () async {
      // TODO
    });

    // My Runs
    //
    //Future<RunPageResponse> myRunsApiV1RunsMineGet() async
    test('test myRunsApiV1RunsMineGet', () async {
      // TODO
    });

    // Request Spot
    //
    //Future<RunResponse> requestSpotApiV1RunsRunIdOrdersPost(String runId, RunOrderCreateRequest runOrderCreateRequest) async
    test('test requestSpotApiV1RunsRunIdOrdersPost', () async {
      // TODO
    });

    // Run Feed
    //
    //Future<RunPageResponse> runFeedApiV1RunsGet({ String cursor, int limit }) async
    test('test runFeedApiV1RunsGet', () async {
      // TODO
    });

    // Update Status
    //
    //Future<RunResponse> updateStatusApiV1RunsRunIdStatusPost(String runId, RunStatusUpdateRequest runStatusUpdateRequest) async
    test('test updateStatusApiV1RunsRunIdStatusPost', () async {
      // TODO
    });

    // Withdraw Order
    //
    //Future withdrawOrderApiV1RunsRunIdOrdersOrderIdDelete(String runId, String orderId) async
    test('test withdrawOrderApiV1RunsRunIdOrdersOrderIdDelete', () async {
      // TODO
    });

  });
}
