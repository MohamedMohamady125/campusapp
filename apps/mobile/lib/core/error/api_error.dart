import 'package:dio/dio.dart';

/// Extracts the human message from the API error envelope (spec §4.2):
/// `{"error": {"code": "...", "message": "...", "details": {}}}`.
String apiErrorMessage(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final envelope = data['error'];
      if (envelope is Map<String, dynamic>) {
        final message = envelope['message'];
        if (message is String && message.isNotEmpty) return message;
      }
      // FastAPI validation errors (422) use {"detail": [...]}.
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Cannot reach the server. Check your connection.';
    }
  }
  return fallback;
}
