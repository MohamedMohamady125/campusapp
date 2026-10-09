import 'dart:async';

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/food_runs/data/runner_location_service.dart';
import 'package:campusconnect/features/food_runs/presentation/runner_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// Runner's multi-stop delivery navigator (Change 8). Takes every accepted
/// order that has admin-recorded drop-off coordinates, reads the runner's live
/// GPS, and lays them out in the most efficient nearest-neighbor order from the
/// runner's position — on a map (numbered pins + route line) and as an ordered
/// checklist below. No external routing API: campus drops are close together so
/// a greedy walk over straight-line distance sequences them well.
class RunnerRouteCard extends ConsumerStatefulWidget {
  const RunnerRouteCard({required this.run, super.key});

  final RunResponse run;

  @override
  ConsumerState<RunnerRouteCard> createState() => _RunnerRouteCardState();
}

const _distance = Distance();

class _RunnerRouteCardState extends ConsumerState<RunnerRouteCard> {
  final MapController _map = MapController();
  LatLng? _start;
  bool _resolving = true;

  @override
  void initState() {
    super.initState();
    unawaited(_resolveStart());
  }

  /// Prefer the runner's own broadcast position (already flowing while en
  /// route); otherwise take one GPS reading; fall back to the food spot so the
  /// route still renders even without a fix.
  Future<void> _resolveStart() async {
    final loc = widget.run.runnerLocation;
    if (loc != null) {
      setState(() {
        _start = LatLng(loc.lat.toDouble(), loc.lng.toDouble());
        _resolving = false;
      });
      return;
    }
    final pos = await ref.read(runnerLocationServiceProvider).current();
    if (!mounted) return;
    setState(() {
      if (pos != null) {
        _start = LatLng(pos.lat, pos.lng);
      } else {
        final spot = widget.run.foodSpot;
        if (spot.lat != null && spot.lng != null) {
          _start = LatLng(spot.lat!.toDouble(), spot.lng!.toDouble());
        }
      }
      _resolving = false;
    });
  }

  List<RouteStop> _stops() {
    final orders = widget.run.orders?.toList() ?? const <RunOrderResponse>[];
    return [
      for (final o in orders)
        if (o.status == RunOrderStatus.accepted &&
            o.dropoffLat != null &&
            o.dropoffLng != null)
          RouteStop(
            orderId: o.id,
            requesterName: o.requester.displayName,
            hall: o.dropoff,
            orderText: o.orderText,
            point: LatLng(o.dropoffLat!.toDouble(), o.dropoffLng!.toDouble()),
          ),
    ];
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final stops = _stops();
    if (stops.isEmpty) return const SizedBox.shrink();

    final start = _start;
    final ordered = start == null ? stops : optimizeRoute(start, stops);
    final line = <LatLng>[
      ?start,
      for (final s in ordered) s.point,
    ];
    final meters = start == null ? 0.0 : routeMeters(start, ordered);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: tokens.brMd,
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space4,
              tokens.space3,
              tokens.space4,
              tokens.space2,
            ),
            child: Row(
              children: [
                Icon(Icons.route_outlined, size: 18, color: colors.primary),
                SizedBox(width: tokens.space2),
                Text('DELIVERY ROUTE', style: AppTextStyles.label),
                const Spacer(),
                if (meters > 0)
                  Text(
                    _distanceLabel(meters),
                    style: context.text.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          if (_resolving)
            const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              height: 180,
              child: FlutterMap(
                mapController: _map,
                options: MapOptions(
                  initialCenter: line.isNotEmpty
                      ? line.first
                      : ordered.first.point,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags:
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.drag |
                        InteractiveFlag.doubleTapZoom,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.campusconnect.app',
                  ),
                  if (line.length > 1)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: line,
                          strokeWidth: 4,
                          color: colors.primary.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      if (start != null)
                        Marker(
                          point: start,
                          width: 44,
                          height: 44,
                          child: _StartPin(color: colors.primary),
                        ),
                      for (var i = 0; i < ordered.length; i++)
                        Marker(
                          point: ordered[i].point,
                          width: 34,
                          height: 34,
                          child: _StopPin(
                            index: i + 1,
                            color: colors.secondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          // Ordered checklist mirroring the numbered map pins: stop 1 is the
          // runner's next delivery, each row shows the walking leg to it.
          for (var i = 0; i < ordered.length; i++)
            _RouteStopRow(
              index: i + 1,
              stop: ordered[i],
              isLast: i == ordered.length - 1,
              legMeters: start == null
                  ? null
                  : _distance(
                      i == 0 ? start : ordered[i - 1].point,
                      ordered[i].point,
                    ),
            ),
        ],
      ),
    );
  }

  String _distanceLabel(double meters) {
    if (meters < 1000) return '≈ ${meters.round()} m';
    return '≈ ${(meters / 1000).toStringAsFixed(1)} km';
  }
}

/// One row in the ordered stop checklist: the sequence number, who + which
/// hall to deliver to.
class _RouteStopRow extends StatelessWidget {
  const _RouteStopRow({
    required this.index,
    required this.stop,
    required this.isLast,
    this.legMeters,
  });

  final int index;
  final RouteStop stop;
  final bool isLast;

  /// Walking distance of the leg INTO this stop (from the runner for stop 1,
  /// from the previous stop otherwise). Null when we have no start fix.
  final double? legMeters;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final isNext = index == 1;
    final meters = legMeters;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space4,
        vertical: tokens.space3,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: colors.outlineVariant),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // Stop 1 wears the brand primary (it matches the runner pin and
              // the route line) so "go here first" reads at a glance.
              color: isNext ? colors.primary : colors.secondary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: context.text.labelSmall?.copyWith(
                color: isNext ? colors.onPrimary : colors.onSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: tokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.hall,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: isNext ? FontWeight.w700 : null,
                  ),
                ),
                Text(
                  stop.orderText.isEmpty
                      ? stop.requesterName
                      : '${stop.requesterName} · ${stop.orderText}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isNext) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.space2,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .10),
                borderRadius: tokens.brFull,
              ),
              child: Text(
                'NEXT',
                style: context.text.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .6,
                ),
              ),
            ),
            SizedBox(width: tokens.space2),
          ],
          if (meters != null)
            Text(
              meters < 1000
                  ? '${meters.round()} m'
                  : '${(meters / 1000).toStringAsFixed(1)} km',
              style: context.text.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

/// The runner's own position marker.
class _StartPin extends StatelessWidget {
  const _StartPin({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

/// A numbered destination pin.
class _StopPin extends StatelessWidget {
  const _StopPin({required this.index, required this.color});

  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        '$index',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}
