import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/env.dart';
import 'package:campusconnect/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Attaches the access token and transparently refreshes it once on 401
/// (spec §8: rotating refresh; M3 dio interceptors).
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._storage, this._dio);

  final TokenStorage _storage;
  final Dio _dio;

  static const _authPaths = [
    '/api/v1/auth/login',
    '/api/v1/auth/register',
    '/api/v1/auth/verify',
    '/api/v1/auth/resend-code',
    '/api/v1/auth/refresh',
    '/api/v1/auth/forgot-password',
    '/api/v1/auth/reset-password',
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_authPaths.contains(options.path)) {
      final token = await _storage.readAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final isRetry = err.requestOptions.extra['auth_retried'] == true;
    if (status != 401 ||
        isRetry ||
        _authPaths.contains(err.requestOptions.path)) {
      return handler.next(err);
    }
    final refresh = await _storage.readRefreshToken();
    if (refresh == null) return handler.next(err);
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final body = res.data!;
      await _storage.save(
        accessToken: body['access_token'] as String,
        refreshToken: body['refresh_token'] as String,
      );
      final opts = err.requestOptions
        ..extra['auth_retried'] = true
        ..headers['Authorization'] = 'Bearer ${body['access_token']}';
      final retried = await _dio.fetch<dynamic>(opts);
      return handler.resolve(retried);
    } on DioException {
      await _storage.clear(); // refresh rotation failed → sign out locally
      return handler.next(err);
    }
  }
}

/// Generated typed client (spec §2.3) — single instance, auth-aware dio.
final campusApiProvider = Provider<CampusApi>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  // Strip empty/null query params — the generated client serializes optional
  // params as empty strings which the server rejects as invalid.
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters.removeWhere(
          (_, v) => v == null || v == 'null' || v == '',
        );
        handler.next(options);
      },
    ),
  );
  dio.interceptors.add(AuthInterceptor(storage, dio));
  return CampusApi(dio: dio);
});
