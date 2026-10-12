# campus_api.api.AdminApi

## Load the API package
```dart
import 'package:campus_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminMetricsApiV1AdminMetricsGet**](AdminApi.md#adminmetricsapiv1adminmetricsget) | **GET** /api/v1/admin/metrics | Admin Metrics
[**sendBroadcastApiV1AdminNotificationsPost**](AdminApi.md#sendbroadcastapiv1adminnotificationspost) | **POST** /api/v1/admin/notifications | Send Broadcast


# **adminMetricsApiV1AdminMetricsGet**
> MetricsResponse adminMetricsApiV1AdminMetricsGet(days)

Admin Metrics

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getAdminApi();
final int days = 56; // int | 

try {
    final response = api.adminMetricsApiV1AdminMetricsGet(days);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminMetricsApiV1AdminMetricsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **days** | **int**|  | [optional] [default to 14]

### Return type

[**MetricsResponse**](MetricsResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendBroadcastApiV1AdminNotificationsPost**
> AdminBroadcastResponse sendBroadcastApiV1AdminNotificationsPost(adminBroadcastRequest)

Send Broadcast

Send a custom announcement (in-app feed + push) to chosen users or everyone.

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getAdminApi();
final AdminBroadcastRequest adminBroadcastRequest = ; // AdminBroadcastRequest | 

try {
    final response = api.sendBroadcastApiV1AdminNotificationsPost(adminBroadcastRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->sendBroadcastApiV1AdminNotificationsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminBroadcastRequest** | [**AdminBroadcastRequest**](AdminBroadcastRequest.md)|  | 

### Return type

[**AdminBroadcastResponse**](AdminBroadcastResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

