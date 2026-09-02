import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/network/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One page of runs plus the cursor for the next (spec §2.4: every list
/// endpoint is cursor-paginated).
class RunsPage {
  const RunsPage({required this.items, this.nextCursor});

  final List<RunResponse> items;
  final String? nextCursor;
}

/// Food-runs reads/writes via the generated client (food-runs spec), plus
/// the small /users/me surface needed for the inline Venmo prompt.
class RunsRepository {
  RunsRepository(this._api);

  final CampusApi _api;

  RunsApi get _runs => _api.getRunsApi();

  Future<List<FoodSpotResponse>> fetchSpots() async {
    final res = await _runs.listSpotsApiV1RunsSpotsGet();
    return res.data!.toList();
  }

  Future<RunsPage> fetchFeed({
    String? cursor,
    bool diningDollars = false,
  }) async {
    final res = await _runs.runFeedApiV1RunsGet(
      cursor: cursor,
      diningDollars: diningDollars,
    );
    final page = res.data!;
    return RunsPage(items: page.items.toList(), nextCursor: page.nextCursor);
  }

  Future<List<RunResponse>> fetchMyRuns() async {
    final res = await _runs.myRunsApiV1RunsMineGet();
    return res.data!.items.toList();
  }

  Future<RunResponse> fetchRun(String runId) async {
    final res = await _runs.getRunApiV1RunsRunIdGet(runId: runId);
    return res.data!;
  }

  Future<RunResponse> createRun({
    required String foodSpotId,
    required DateTime leavingAt,
    required int feeCents,
    required int spotsMax,
    required bool prepayRequired,
    bool paysWithDiningDollars = false,
    String? note,
  }) async {
    final res = await _runs.createRunApiV1RunsPost(
      runCreateRequest: RunCreateRequest(
        (b) => b
          ..foodSpotId = foodSpotId
          ..leavingAt = leavingAt
          ..feeCents = feeCents
          ..spotsMax = spotsMax
          ..prepayRequired = prepayRequired
          ..paysWithDiningDollars = paysWithDiningDollars
          ..note = note,
      ),
    );
    return res.data!;
  }

  Future<RunResponse> requestSpot(
    String runId,
    String orderText,
    String dropoff, {
    String? pickupCode,
  }) async {
    final res = await _runs.requestSpotApiV1RunsRunIdOrdersPost(
      runId: runId,
      runOrderCreateRequest: RunOrderCreateRequest(
        (b) => b
          ..orderText = orderText
          ..dropoff = dropoff
          ..pickupCode = pickupCode,
      ),
    );
    return res.data!;
  }

  Future<void> withdrawOrder(String runId, String orderId) async {
    await _runs.withdrawOrderApiV1RunsRunIdOrdersOrderIdDelete(
      runId: runId,
      orderId: orderId,
    );
  }

  Future<RunResponse> acceptOrder(String runId, String orderId) async {
    final res = await _runs.acceptOrderApiV1RunsRunIdOrdersOrderIdAcceptPost(
      runId: runId,
      orderId: orderId,
    );
    return res.data!;
  }

  Future<RunResponse> declineOrder(String runId, String orderId) async {
    final res = await _runs.declineOrderApiV1RunsRunIdOrdersOrderIdDeclinePost(
      runId: runId,
      orderId: orderId,
    );
    return res.data!;
  }

  Future<RunResponse> markDelivered(String runId, String orderId) async {
    final res = await _runs
        .markDeliveredApiV1RunsRunIdOrdersOrderIdDeliveredPost(
          runId: runId,
          orderId: orderId,
        );
    return res.data!;
  }

  Future<RunResponse> markNoShow(String runId, String orderId) async {
    final res = await _runs.markNoShowApiV1RunsRunIdOrdersOrderIdNoShowPost(
      runId: runId,
      orderId: orderId,
    );
    return res.data!;
  }

  Future<RunResponse> confirmReceived(String runId, String orderId) async {
    final res = await _runs
        .confirmReceivedApiV1RunsRunIdOrdersOrderIdReceivedPost(
          runId: runId,
          orderId: orderId,
        );
    return res.data!;
  }

  Future<RunResponse> updateStatus(String runId, RunStatus status) async {
    final res = await _runs.updateStatusApiV1RunsRunIdStatusPost(
      runId: runId,
      runStatusUpdateRequest: RunStatusUpdateRequest((b) => b..status = status),
    );
    return res.data!;
  }

  Future<RunResponse> cancelRun(String runId) async {
    final res = await _runs.cancelRunApiV1RunsRunIdCancelPost(runId: runId);
    return res.data!;
  }

  /// Runner pushes one live GPS ping (Uber/Lyft-style tracking). Server only
  /// accepts it while the run is en route.
  Future<RunResponse> updateLocation(
    String runId,
    double lat,
    double lng,
  ) async {
    final res = await _runs.updateLocationApiV1RunsRunIdLocationPost(
      runId: runId,
      runLocationUpdateRequest: RunLocationUpdateRequest(
        (b) => b
          ..lat = lat
          ..lng = lng,
      ),
    );
    return res.data!;
  }

  /// Current profile — used to check for a payment method before paid runs.
  Future<UserMeResponse> fetchMe() async {
    final res = await _api.getUsersApi().getMeApiV1UsersMeGet();
    return res.data!;
  }

  /// Replaces the runner's payment methods wholesale (PATCH /users/me).
  Future<UserMeResponse> savePaymentMethods(
    List<PaymentMethod> methods,
  ) async {
    final res = await _api.getUsersApi().updateMeApiV1UsersMePatch(
      userUpdateRequest: UserUpdateRequest(
        (b) => b..paymentMethods.replace(methods),
      ),
    );
    return res.data!;
  }

  /// Two-way run rating (POST /ratings, context `run`, id = RunOrder id).
  Future<void> submitRating({
    required String ratedUserId,
    required String orderId,
    required int stars,
    String? comment,
  }) async {
    await _api.getRatingsApi().createRatingApiV1RatingsPost(
      ratingCreateRequest: RatingCreateRequest(
        (b) => b
          ..ratedUserId = ratedUserId
          ..contextType = RatingContext.run
          ..contextId = orderId
          ..stars = stars
          ..comment = comment,
      ),
    );
  }
}

final runsRepositoryProvider = Provider<RunsRepository>(
  (ref) => RunsRepository(ref.watch(campusApiProvider)),
);
