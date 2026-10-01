# campus_api.api.AuthApi

## Load the API package
```dart
import 'package:campus_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**checkEmailApiV1AuthCheckEmailPost**](AuthApi.md#checkemailapiv1authcheckemailpost) | **POST** /api/v1/auth/check-email | Check Email
[**forgotPasswordApiV1AuthForgotPasswordPost**](AuthApi.md#forgotpasswordapiv1authforgotpasswordpost) | **POST** /api/v1/auth/forgot-password | Forgot Password
[**loginApiV1AuthLoginPost**](AuthApi.md#loginapiv1authloginpost) | **POST** /api/v1/auth/login | Login
[**logoutApiV1AuthLogoutPost**](AuthApi.md#logoutapiv1authlogoutpost) | **POST** /api/v1/auth/logout | Logout
[**refreshApiV1AuthRefreshPost**](AuthApi.md#refreshapiv1authrefreshpost) | **POST** /api/v1/auth/refresh | Refresh
[**registerApiV1AuthRegisterPost**](AuthApi.md#registerapiv1authregisterpost) | **POST** /api/v1/auth/register | Register
[**resendCodeApiV1AuthResendCodePost**](AuthApi.md#resendcodeapiv1authresendcodepost) | **POST** /api/v1/auth/resend-code | Resend Code
[**resetPasswordApiV1AuthResetPasswordPost**](AuthApi.md#resetpasswordapiv1authresetpasswordpost) | **POST** /api/v1/auth/reset-password | Reset Password
[**verifyApiV1AuthVerifyPost**](AuthApi.md#verifyapiv1authverifypost) | **POST** /api/v1/auth/verify | Verify


# **checkEmailApiV1AuthCheckEmailPost**
> CheckEmailResponse checkEmailApiV1AuthCheckEmailPost(checkEmailRequest)

Check Email

Login/registration UX hint: does an account exist for this email?

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getAuthApi();
final CheckEmailRequest checkEmailRequest = ; // CheckEmailRequest | 

try {
    final response = api.checkEmailApiV1AuthCheckEmailPost(checkEmailRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->checkEmailApiV1AuthCheckEmailPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **checkEmailRequest** | [**CheckEmailRequest**](CheckEmailRequest.md)|  | 

### Return type

[**CheckEmailResponse**](CheckEmailResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **forgotPasswordApiV1AuthForgotPasswordPost**
> AppSchemasAuthMessageResponse forgotPasswordApiV1AuthForgotPasswordPost(forgotPasswordRequest)

Forgot Password

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getAuthApi();
final ForgotPasswordRequest forgotPasswordRequest = ; // ForgotPasswordRequest | 

try {
    final response = api.forgotPasswordApiV1AuthForgotPasswordPost(forgotPasswordRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->forgotPasswordApiV1AuthForgotPasswordPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **forgotPasswordRequest** | [**ForgotPasswordRequest**](ForgotPasswordRequest.md)|  | 

### Return type

[**AppSchemasAuthMessageResponse**](AppSchemasAuthMessageResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **loginApiV1AuthLoginPost**
> TokenResponse loginApiV1AuthLoginPost(loginRequest)

Login

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getAuthApi();
final LoginRequest loginRequest = ; // LoginRequest | 

try {
    final response = api.loginApiV1AuthLoginPost(loginRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->loginApiV1AuthLoginPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginRequest** | [**LoginRequest**](LoginRequest.md)|  | 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logoutApiV1AuthLogoutPost**
> AppSchemasAuthMessageResponse logoutApiV1AuthLogoutPost(logoutRequest)

Logout

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getAuthApi();
final LogoutRequest logoutRequest = ; // LogoutRequest | 

try {
    final response = api.logoutApiV1AuthLogoutPost(logoutRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->logoutApiV1AuthLogoutPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **logoutRequest** | [**LogoutRequest**](LogoutRequest.md)|  | 

### Return type

[**AppSchemasAuthMessageResponse**](AppSchemasAuthMessageResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshApiV1AuthRefreshPost**
> TokenResponse refreshApiV1AuthRefreshPost(refreshRequest)

Refresh

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getAuthApi();
final RefreshRequest refreshRequest = ; // RefreshRequest | 

try {
    final response = api.refreshApiV1AuthRefreshPost(refreshRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->refreshApiV1AuthRefreshPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshRequest** | [**RefreshRequest**](RefreshRequest.md)|  | 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **registerApiV1AuthRegisterPost**
> RegisterResponse registerApiV1AuthRegisterPost(registerRequest)

Register

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getAuthApi();
final RegisterRequest registerRequest = ; // RegisterRequest | 

try {
    final response = api.registerApiV1AuthRegisterPost(registerRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->registerApiV1AuthRegisterPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerRequest** | [**RegisterRequest**](RegisterRequest.md)|  | 

### Return type

[**RegisterResponse**](RegisterResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resendCodeApiV1AuthResendCodePost**
> AppSchemasAuthMessageResponse resendCodeApiV1AuthResendCodePost(resendCodeRequest)

Resend Code

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getAuthApi();
final ResendCodeRequest resendCodeRequest = ; // ResendCodeRequest | 

try {
    final response = api.resendCodeApiV1AuthResendCodePost(resendCodeRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->resendCodeApiV1AuthResendCodePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **resendCodeRequest** | [**ResendCodeRequest**](ResendCodeRequest.md)|  | 

### Return type

[**AppSchemasAuthMessageResponse**](AppSchemasAuthMessageResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resetPasswordApiV1AuthResetPasswordPost**
> AppSchemasAuthMessageResponse resetPasswordApiV1AuthResetPasswordPost(resetPasswordRequest)

Reset Password

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getAuthApi();
final ResetPasswordRequest resetPasswordRequest = ; // ResetPasswordRequest | 

try {
    final response = api.resetPasswordApiV1AuthResetPasswordPost(resetPasswordRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->resetPasswordApiV1AuthResetPasswordPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **resetPasswordRequest** | [**ResetPasswordRequest**](ResetPasswordRequest.md)|  | 

### Return type

[**AppSchemasAuthMessageResponse**](AppSchemasAuthMessageResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **verifyApiV1AuthVerifyPost**
> AppSchemasAuthMessageResponse verifyApiV1AuthVerifyPost(verifyRequest)

Verify

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getAuthApi();
final VerifyRequest verifyRequest = ; // VerifyRequest | 

try {
    final response = api.verifyApiV1AuthVerifyPost(verifyRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->verifyApiV1AuthVerifyPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **verifyRequest** | [**VerifyRequest**](VerifyRequest.md)|  | 

### Return type

[**AppSchemasAuthMessageResponse**](AppSchemasAuthMessageResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

