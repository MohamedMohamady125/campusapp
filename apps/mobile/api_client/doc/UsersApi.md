# campus_api.api.UsersApi

## Load the API package
```dart
import 'package:campus_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getMeApiV1UsersMeGet**](UsersApi.md#getmeapiv1usersmeget) | **GET** /api/v1/users/me | Get Me
[**getPublicProfileApiV1UsersUserIdGet**](UsersApi.md#getpublicprofileapiv1usersuseridget) | **GET** /api/v1/users/{user_id} | Get Public Profile
[**paymentQrUploadUrlApiV1UsersMePaymentQrUploadUrlPost**](UsersApi.md#paymentqruploadurlapiv1usersmepaymentqruploadurlpost) | **POST** /api/v1/users/me/payment-qr-upload-url | Payment Qr Upload Url
[**updateMeApiV1UsersMePatch**](UsersApi.md#updatemeapiv1usersmepatch) | **PATCH** /api/v1/users/me | Update Me


# **getMeApiV1UsersMeGet**
> UserMeResponse getMeApiV1UsersMeGet()

Get Me

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getUsersApi();

try {
    final response = api.getMeApiV1UsersMeGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->getMeApiV1UsersMeGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**UserMeResponse**](UserMeResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPublicProfileApiV1UsersUserIdGet**
> UserPublicResponse getPublicProfileApiV1UsersUserIdGet(userId)

Get Public Profile

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getUsersApi();
final String userId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getPublicProfileApiV1UsersUserIdGet(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->getPublicProfileApiV1UsersUserIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 

### Return type

[**UserPublicResponse**](UserPublicResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **paymentQrUploadUrlApiV1UsersMePaymentQrUploadUrlPost**
> PaymentQrUploadUrlResponse paymentQrUploadUrlApiV1UsersMePaymentQrUploadUrlPost(paymentQrUploadUrlRequest)

Payment Qr Upload Url

Signed-URL direct upload for a payment-app QR code image (food-runs spec: payment is off-app — the QR just lets a requester scan-to-pay).

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getUsersApi();
final PaymentQrUploadUrlRequest paymentQrUploadUrlRequest = ; // PaymentQrUploadUrlRequest | 

try {
    final response = api.paymentQrUploadUrlApiV1UsersMePaymentQrUploadUrlPost(paymentQrUploadUrlRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->paymentQrUploadUrlApiV1UsersMePaymentQrUploadUrlPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **paymentQrUploadUrlRequest** | [**PaymentQrUploadUrlRequest**](PaymentQrUploadUrlRequest.md)|  | 

### Return type

[**PaymentQrUploadUrlResponse**](PaymentQrUploadUrlResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateMeApiV1UsersMePatch**
> UserMeResponse updateMeApiV1UsersMePatch(userUpdateRequest)

Update Me

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getUsersApi();
final UserUpdateRequest userUpdateRequest = ; // UserUpdateRequest | 

try {
    final response = api.updateMeApiV1UsersMePatch(userUpdateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->updateMeApiV1UsersMePatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userUpdateRequest** | [**UserUpdateRequest**](UserUpdateRequest.md)|  | 

### Return type

[**UserMeResponse**](UserMeResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

