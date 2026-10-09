import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/theme/app_theme.dart';
import 'package:campusconnect/features/food_runs/data/runner_location_service.dart';
import 'package:campusconnect/features/food_runs/presentation/runner_route_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deterministic GPS double: resolves instantly with a fixed position (or
/// null), so these tests prove the route card can never hang on a fix.
class _FakeLocation implements RunnerLocationService {
  _FakeLocation(this.position);

  final LivePosition? position;
  int calls = 0;

  @override
  Future<bool> ensurePermission() async => position != null;

  @override
  Future<LivePosition?> current() async {
    calls++;
    return position;
  }
}

RunUserSummary _user(String name) => RunUserSummary(
  (b) => b
    ..id = 'u-$name'
    ..displayName = name
    ..reputationScore = 5
    ..ratingCount = 1,
);

RunOrderResponse _order(
  String id,
  String hall,
  double? lat,
  double? lng, {
  RunOrderStatus status = RunOrderStatus.accepted,
}) => RunOrderResponse(
  (b) => b
    ..id = id
    ..runId = 'run-1'
    ..orderText = 'food'
    ..dropoff = hall
    ..dropoffLat = lat
    ..dropoffLng = lng
    ..status = status
    ..createdAt = DateTime.utc(2026)
    ..requester.replace(_user('req-$id')),
);

RunResponse _run(
  List<RunOrderResponse> orders, {
  RunLocation? runnerLocation,
}) => RunResponse(
  (b) => b
    ..id = 'run-1'
    ..feeCents = 200
    ..prepayRequired = false
    ..spotsMax = 3
    ..acceptedCount = orders.length
    ..pendingCount = 0
    ..leavingAt = DateTime.utc(2026)
    ..createdAt = DateTime.utc(2026)
    ..status = RunStatus.delivering
    ..runner.replace(_user('runner'))
    ..runnerLocation = runnerLocation?.toBuilder()
    ..orders.replace(orders)
    ..foodSpot.replace(
      FoodSpotResponse(
        (s) => s
          // Chick-fil-A (Lopes Way) — real OSM coordinate.
          ..id = 'spot-1'
          ..name = 'Chick-fil-A'
          ..category = FoodSpotCategory.campus
          ..lat = 33.512883
          ..lng = -112.122559,
      ),
    ),
);

Future<void> _pump(
  WidgetTester tester,
  RunResponse run,
  RunnerLocationService gps,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [runnerLocationServiceProvider.overrideWithValue(gps)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SingleChildScrollView(child: RunnerRouteCard(run: run)),
        ),
      ),
    ),
  );
  // Settle the async start-fix + map layout; map tiles 400 in tests, which
  // flutter_map tolerates (grey tiles) — the route logic must not care.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  // Real GCU drop-off coordinates (from the seeded catalog):
  // walking north-west from Chick-fil-A the true order is
  // 29th Ave Garage → Sonora Apartments → Acacia Hall.
  final garage = _order('o-garage', '29th Ave Garage', 33.510164, -112.123512);
  final sonora = _order('o-sonora', 'Sonora Apartments', 33.5148, -112.1278);
  final acacia = _order('o-acacia', 'Acacia Hall', 33.516246, -112.132258);

  testWidgets('orders stops nearest-first from the GPS fix, numbered with '
      'NEXT badge and leg distances', (tester) async {
    // Runner standing at the food spot; stops passed deliberately shuffled.
    final gps = _FakeLocation((lat: 33.512883, lng: -112.122559));
    await _pump(tester, _run([acacia, garage, sonora]), gps);

    expect(find.text('DELIVERY ROUTE'), findsOneWidget);
    // Greedy nearest-neighbor sequence as rendered top-to-bottom.
    final rows = ['29th Ave Garage', 'Sonora Apartments', 'Acacia Hall'];
    final positions = [
      for (final hall in rows) tester.getTopLeft(find.text(hall)).dy,
    ];
    expect(positions[0], lessThan(positions[1]));
    expect(positions[1], lessThan(positions[2]));
    // Stop 1 is flagged as the next delivery; every row shows a leg distance.
    expect(find.text('NEXT'), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'^\d+ m$|^\d+\.\d km$')),
      findsNWidgets(3),
    );
  });

  testWidgets('prefers the broadcast runnerLocation and never touches GPS', (
    tester,
  ) async {
    final gps = _FakeLocation(null);
    final run = _run(
      [garage, acacia],
      runnerLocation: RunLocation(
        (b) => b
          // Broadcast position next to Acacia → Acacia must come first.
          ..lat = 33.5161
          ..lng = -112.1320
          ..updatedAt = DateTime.utc(2026),
      ),
    );
    await _pump(tester, run, gps);

    expect(gps.calls, 0);
    expect(
      tester.getTopLeft(find.text('Acacia Hall')).dy,
      lessThan(tester.getTopLeft(find.text('29th Ave Garage')).dy),
    );
  });

  testWidgets('GPS unavailable → falls back to the food spot and still '
      'renders the ordered checklist (no eternal spinner)', (tester) async {
    final gps = _FakeLocation(null);
    await _pump(tester, _run([acacia, garage]), gps);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    // From Chick-fil-A the garage is closer than Acacia.
    expect(find.text('NEXT'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('29th Ave Garage')).dy,
      lessThan(tester.getTopLeft(find.text('Acacia Hall')).dy),
    );
  });

  testWidgets('skips orders without coordinates or not accepted; hides the '
      'card when no routable stop remains', (tester) async {
    final gps = _FakeLocation((lat: 33.512883, lng: -112.122559));
    final noCoords = _order('o-null', 'Mystery Hall', null, null);
    final pending = _order(
      'o-pending',
      'Juniper Hall',
      33.5143,
      -112.1312,
      status: RunOrderStatus.requested,
    );
    await _pump(tester, _run([noCoords, pending, garage]), gps);
    expect(find.text('29th Ave Garage'), findsOneWidget);
    expect(find.text('Mystery Hall'), findsNothing);
    expect(find.text('Juniper Hall'), findsNothing);

    await _pump(tester, _run([noCoords, pending]), gps);
    expect(find.text('DELIVERY ROUTE'), findsNothing);
  });
}
