import 'package:test/test.dart';
import 'package:campus_api/campus_api.dart';


/// tests for AuthApi
void main() {
  final instance = CampusApi().getAuthApi();

  group(AuthApi, () {
    // Forgot Password
    //
    //Future<AppSchemasAuthMessageResponse> forgotPasswordApiV1AuthForgotPasswordPost(ForgotPasswordRequest forgotPasswordRequest) async
    test('test forgotPasswordApiV1AuthForgotPasswordPost', () async {
      // TODO
    });

    // Login
    //
    //Future<TokenResponse> loginApiV1AuthLoginPost(LoginRequest loginRequest) async
    test('test loginApiV1AuthLoginPost', () async {
      // TODO
    });

    // Logout
    //
    //Future<AppSchemasAuthMessageResponse> logoutApiV1AuthLogoutPost(LogoutRequest logoutRequest) async
    test('test logoutApiV1AuthLogoutPost', () async {
      // TODO
    });

    // Refresh
    //
    //Future<TokenResponse> refreshApiV1AuthRefreshPost(RefreshRequest refreshRequest) async
    test('test refreshApiV1AuthRefreshPost', () async {
      // TODO
    });

    // Register
    //
    //Future<RegisterResponse> registerApiV1AuthRegisterPost(RegisterRequest registerRequest) async
    test('test registerApiV1AuthRegisterPost', () async {
      // TODO
    });

    // Resend Code
    //
    //Future<AppSchemasAuthMessageResponse> resendCodeApiV1AuthResendCodePost(ResendCodeRequest resendCodeRequest) async
    test('test resendCodeApiV1AuthResendCodePost', () async {
      // TODO
    });

    // Reset Password
    //
    //Future<AppSchemasAuthMessageResponse> resetPasswordApiV1AuthResetPasswordPost(ResetPasswordRequest resetPasswordRequest) async
    test('test resetPasswordApiV1AuthResetPasswordPost', () async {
      // TODO
    });

    // Verify
    //
    //Future<AppSchemasAuthMessageResponse> verifyApiV1AuthVerifyPost(VerifyRequest verifyRequest) async
    test('test verifyApiV1AuthVerifyPost', () async {
      // TODO
    });

  });
}
