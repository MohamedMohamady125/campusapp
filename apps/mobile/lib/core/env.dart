/// Environment configuration (spec §2.2 core/env).
///
/// Override at build time:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com`.
/// Generated client paths already include `/api/v1`.
abstract final class Env {
  // IPv4 loopback, not `localhost`: on macOS the browser can resolve
  // `localhost` to IPv6 `::1`, where the dev API (bound IPv4 0.0.0.0) isn't
  // listening — the socket fails and the app reports "cannot reach server".
  // Android emulators still override this with `10.0.2.2` at build time.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}
