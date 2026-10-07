import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// One GPS reading — plain lat/lng so nothing above this layer depends on the
/// geolocator package.
typedef LivePosition = ({double lat, double lng});

/// Reads the runner's device location for live tracking. Wrapped behind an
/// interface (spec §2.5) so widget tests can inject a fake without touching
/// real GPS or platform permission dialogs.
abstract class RunnerLocationService {
  /// Ask for (or confirm) foreground location permission. Returns false if the
  /// user denied it or location services are off.
  Future<bool> ensurePermission();

  /// Current position, or null if unavailable / not permitted.
  Future<LivePosition?> current();
}

/// Real implementation backed by geolocator.
class GeolocatorRunnerLocationService implements RunnerLocationService {
  const GeolocatorRunnerLocationService();

  @override
  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<LivePosition?> current() async {
    // Everything here can hang or throw (no GPS fix, services toggled off
    // mid-call, web permission quirks). Bound it and swallow failures so
    // callers always resolve — a null just means "route without my position".
    try {
      if (!await ensurePermission()) return null;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return (lat: pos.latitude, lng: pos.longitude);
    } on Exception {
      // Fall back to the OS-cached last fix (instant, often good enough on
      // campus); null if there has never been one.
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last == null) return null;
        return (lat: last.latitude, lng: last.longitude);
      } on Exception {
        return null;
      }
    }
  }
}

final runnerLocationServiceProvider = Provider<RunnerLocationService>(
  (ref) => const GeolocatorRunnerLocationService(),
);
