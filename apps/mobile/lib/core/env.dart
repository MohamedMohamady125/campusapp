/// Environment configuration (spec §2.2 core/env).
///
/// Override at build time:
/// `flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000`.
/// Generated client paths already include `/api/v1`.
abstract final class Env {
  // Hosted API (Railway). Default for ALL builds — a plain `flutter run`
  // must always hit a reachable backend, not a loopback that only works when
  // a local dev server happens to be running ("backend isn't reachable").
  static const _prod = 'https://campusconnect-api-production.up.railway.app';

  /// Base URL for the API host. An explicit `--dart-define=API_BASE_URL`
  /// always wins (point it at `http://127.0.0.1:8000` for local dev, or
  /// `http://10.0.2.2:8000` on an Android emulator); otherwise every build
  /// defaults to the deployed prod API.
  static const String apiBaseUrl = bool.hasEnvironment('API_BASE_URL')
      ? String.fromEnvironment('API_BASE_URL')
      : _prod;
}
