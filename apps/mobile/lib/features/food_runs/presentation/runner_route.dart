import 'package:latlong2/latlong.dart';

/// One delivery stop the runner must reach: the order it belongs to, who to
/// hand it to, what the order is, the drop-off hall name, and coordinates.
class RouteStop {
  const RouteStop({
    required this.orderId,
    required this.requesterName,
    required this.hall,
    required this.point,
    this.orderText = '',
  });

  final String orderId;
  final String requesterName;
  final String hall;
  final LatLng point;

  /// What to hand over at this stop — shown on the checklist row so the
  /// dasher never has to open the order card mid-walk.
  final String orderText;
}

const _distance = Distance();

/// Orders [stops] into an efficient visiting sequence starting from [start]
/// using a greedy nearest-neighbor heuristic (Change 8 — "most efficient
/// route according to his location").
///
/// Nearest-neighbor is O(n²) but n here is the number of accepted orders on a
/// single run (a handful), so it's instant and needs no external routing API.
/// It walks straight-line (haversine) distance between the admin-recorded
/// drop-off coordinates — good enough to sequence a walking campus route.
List<RouteStop> optimizeRoute(LatLng start, List<RouteStop> stops) {
  final remaining = [...stops];
  final ordered = <RouteStop>[];
  var cursor = start;
  while (remaining.isNotEmpty) {
    var bestIndex = 0;
    var bestMeters = _distance(cursor, remaining[0].point);
    for (var i = 1; i < remaining.length; i++) {
      final meters = _distance(cursor, remaining[i].point);
      if (meters < bestMeters) {
        bestMeters = meters;
        bestIndex = i;
      }
    }
    final next = remaining.removeAt(bestIndex);
    ordered.add(next);
    cursor = next.point;
  }
  return ordered;
}

/// Total straight-line walking distance (metres) of visiting [ordered] in
/// sequence from [start]. Used for the "≈ Nm total" route summary.
double routeMeters(LatLng start, List<RouteStop> ordered) {
  var total = 0.0;
  var cursor = start;
  for (final stop in ordered) {
    total += _distance(cursor, stop.point);
    cursor = stop.point;
  }
  return total;
}
