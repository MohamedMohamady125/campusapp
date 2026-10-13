# campus_api.api.EmailsApi

## Load the API package
```dart
import 'package:campus_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**unsubscribeApiV1EmailsUnsubscribeGet**](EmailsApi.md#unsubscribeapiv1emailsunsubscribeget) | **GET** /api/v1/emails/unsubscribe | Unsubscribe


# **unsubscribeApiV1EmailsUnsubscribeGet**
> String unsubscribeApiV1EmailsUnsubscribeGet(token)

Unsubscribe

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getEmailsApi();
final String token = token_example; // String | 

try {
    final response = api.unsubscribeApiV1EmailsUnsubscribeGet(token);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EmailsApi->unsubscribeApiV1EmailsUnsubscribeGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 

### Return type

**String**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/html, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

