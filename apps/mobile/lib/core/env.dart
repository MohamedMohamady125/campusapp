import 'package:flutter/foundation.dart' show kReleaseMode;

/// Environment configuration (spec §2.2 core/env).
///
/// Override at build time:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com`.
/// Generated client paths already include `/api/v1`.
abstract final class Env {
  // Hosted API (Railway). Release builds (TestFlight/App Store) run on real
  // devices where a loopback address is unreachable, so they must default to
  // the deployed backend.
  static const _prod = 'https://campusconnect-api-production.up.railway.app';

  // IPv4 loopback, not `localhost`: on macOS the browser can resolve
  // `localhost` to IPv6 `::1`, where the dev API (bound IPv4 0.0.0.0) isn't
  // listening — the socket fails and the app reports "cannot reach server".
  // Android emulators still override this with `10.0.2.2` at build time.
  static const _localDev = 'http://127.0.0.1:8000';

  /// Base URL for the API host. An explicit `--dart-define=API_BASE_URL`
  /// always wins; otherwise release builds hit prod and debug builds hit the
  /// local dev server, so a TestFlight build never silently points at
  /// loopback and hangs on every request.
  static const String apiBaseUrl = bool.hasEnvironment('API_BASE_URL')
      ? String.fromEnvironment('API_BASE_URL')
      : (kReleaseMode ? _prod : _localDev);
}
