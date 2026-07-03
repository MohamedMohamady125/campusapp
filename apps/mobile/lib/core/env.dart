/// Environment configuration (spec §2.2 core/env).
///
/// Override at build time: `flutter run --dart-define=API_BASE_URL=https://api.example.com/api/v1`.
abstract final class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );
}
