import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/network/api_provider.dart';
import 'package:campusconnect/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth flows against the generated client (spec §4.1 auth endpoints, M2).
/// Persists the JWT pair in secure storage on login; clears it on logout.
class AuthRepository {
  AuthRepository(this._api, this._storage);

  final CampusApi _api;
  final TokenStorage _storage;

  AuthApi get _auth => _api.getAuthApi();

  Future<String> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final res = await _auth.registerApiV1AuthRegisterPost(
      registerRequest: RegisterRequest(
        (b) => b
          ..email = email
          ..password = password
          ..displayName = displayName,
      ),
    );
    return res.data!.userId;
  }

  Future<void> verify({required String email, required String code}) async {
    await _auth.verifyApiV1AuthVerifyPost(
      verifyRequest: VerifyRequest(
        (b) => b
          ..email = email
          ..code = code,
      ),
    );
  }

  Future<void> resendCode({required String email}) async {
    await _auth.resendCodeApiV1AuthResendCodePost(
      resendCodeRequest: ResendCodeRequest((b) => b..email = email),
    );
  }

  Future<void> login({required String email, required String password}) async {
    final res = await _auth.loginApiV1AuthLoginPost(
      loginRequest: LoginRequest(
        (b) => b
          ..email = email
          ..password = password,
      ),
    );
    final tokens = res.data!;
    await _storage.save(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  Future<void> logout() async {
    final refresh = await _storage.readRefreshToken();
    if (refresh != null) {
      try {
        await _auth.logoutApiV1AuthLogoutPost(
          logoutRequest: LogoutRequest((b) => b..refreshToken = refresh),
        );
      } on DioException {
        // Server-side revoke is best effort — always sign out locally.
      }
    }
    await _storage.clear();
  }

  /// Whether a session exists locally (token presence, not validity —
  /// the refresh interceptor handles expiry transparently).
  Future<bool> hasSession() async => await _storage.readRefreshToken() != null;

  Future<UserMeResponse> fetchMe() async {
    final res = await _api.getUsersApi().getMeApiV1UsersMeGet();
    return res.data!;
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(campusApiProvider),
    ref.watch(tokenStorageProvider),
  ),
);
