import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Live "where's my runner" map (Uber/Lyft-style). Rendered only when the run
/// response carries [RunResponse.runnerLocation] — i.e. the viewer is entitled
/// (runner or accepted requester) and the runner is en route. Tiles come from
/// OpenStreetMap so no API key is required.
class LiveMapCard extends StatefulWidget {
  const LiveMapCard({required this.run, super.key});

  final RunResponse run;

  @override
  State<LiveMapCard> createState() => _LiveMapCardState();
}

class _LiveMapCardState extends State<LiveMapCard> {
  final MapController _map = MapController();

  LatLng get _runnerPoint {
    final loc = widget.run.runnerLocation!;
    return LatLng(loc.lat.toDouble(), loc.lng.toDouble());
  }

  LatLng? get _destinationPoint {
    final spot = widget.run.foodSpot;
    final lat = spot.lat;
    final lng = spot.lng;
    if (lat == null || lng == null) return null;
    return LatLng(lat.toDouble(), lng.toDouble());
  }

  @override
  void didUpdateWidget(covariant LiveMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final prev = oldWidget.run.runnerLocation;
    final next = widget.run.runnerLocation;
    // Follow the runner as fresh pings arrive, keeping the user's zoom level.
    if (next != null &&
        (prev == null || prev.lat != next.lat || prev.lng != next.lng)) {
      _map.move(_runnerPoint, _map.camera.zoom);
    }
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
    final destination = _destinationPoint;

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
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: _runnerPoint,
                    initialZoom: 15.5,
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
                    MarkerLayer(
                      markers: [
                        if (destination != null)
                          Marker(
                            point: destination,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.storefront,
                              color: colors.secondary,
                              size: 32,
                            ),
                          ),
                        Marker(
                          point: _runnerPoint,
                          width: 46,
                          height: 46,
                          child: _RunnerPin(color: colors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  left: tokens.space2,
                  top: tokens.space2,
                  child: _LiveBadge(
                    updatedAt: widget.run.runnerLocation!.updatedAt,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(tokens.space3),
            child: Row(
              children: [
                Icon(
                  Icons.navigation_outlined,
                  size: 16,
                  color: colors.primary,
                ),
                SizedBox(width: tokens.space2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ON THE WAY TO YOU',
                        style: context.text.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: tokens.space1),
                      Text(
                        '${widget.run.runner.displayName} is on the way to '
                        '${widget.run.foodSpot.name}',
                        style: context.text.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A pulsing dot pin for the runner's live position.
class _RunnerPin extends StatelessWidget {
  const _RunnerPin({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 22,
        height: 22,
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

/// "Live · updated Ns ago" overlay chip. A ping older than ~5 minutes isn't
/// live anymore — the badge goes gray and says when the runner was last
/// seen, in humane units (never "5670m ago").
class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.updatedAt});

  final DateTime updatedAt;

  bool get _stale =>
      DateTime.now().difference(updatedAt) > const Duration(minutes: 5);

  String get _ago {
    final diff = DateTime.now().difference(updatedAt);
    if (diff.inSeconds < 10) return 'just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return 'over a day ago';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space3,
        vertical: tokens.space1,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: tokens.brFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _stale ? const Color(0xFF9CA3AF) : const Color(0xFF34D399),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: tokens.space2),
          Text(
            _stale ? 'Last seen $_ago' : 'Live · $_ago',
            style: context.text.labelSmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
