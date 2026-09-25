import 'package:campusconnect/features/food_runs/presentation/runner_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

RouteStop _stop(String id, double lat, double lng) => RouteStop(
  orderId: id,
  requesterName: id,
  hall: id,
  point: LatLng(lat, lng),
);

void main() {
  group('optimizeRoute (nearest-neighbor)', () {
    test('visits the closest stop first', () {
      const start = LatLng(0, 0);
      final near = _stop('near', 0.001, 0);
      final far = _stop('far', 0.01, 0);
      // Deliberately pass the far stop first to prove it reorders.
      final ordered = optimizeRoute(start, [far, near]);
      expect(ordered.map((s) => s.orderId), ['near', 'far']);
    });

    test('produces a full greedy chain from the start point', () {
      const start = LatLng(0, 0);
      final a = _stop('a', 0.001, 0);
      final b = _stop('b', 0.002, 0);
      final c = _stop('c', 0.003, 0);
      final ordered = optimizeRoute(start, [c, a, b]);
      expect(ordered.map((s) => s.orderId), ['a', 'b', 'c']);
    });

    test('keeps every stop exactly once and handles empty input', () {
      const start = LatLng(1, 1);
      expect(optimizeRoute(start, const []), isEmpty);
      final stops = [_stop('a', 1, 1.01), _stop('b', 1, 1.02)];
      final ordered = optimizeRoute(start, stops);
      expect(ordered.length, 2);
      expect(ordered.map((s) => s.orderId).toSet(), {'a', 'b'});
    });

    test('routeMeters accumulates the ordered leg distances', () {
      const start = LatLng(0, 0);
      final ordered = [_stop('a', 0.001, 0), _stop('b', 0.002, 0)];
      final total = routeMeters(start, ordered);
      // ~111m per 0.001° latitude → two legs ≈ 222m, allow tolerance.
      expect(total, greaterThan(180));
      expect(total, lessThan(260));
    });
  });
}
