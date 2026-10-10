# campus_api.api.AnalyticsApi

## Load the API package
```dart
import 'package:campus_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminBehaviorApiV1AdminBehaviorGet**](AnalyticsApi.md#adminbehaviorapiv1adminbehaviorget) | **GET** /api/v1/admin/behavior | Admin Behavior
[**ingestEventsApiV1AnalyticsEventsPost**](AnalyticsApi.md#ingesteventsapiv1analyticseventspost) | **POST** /api/v1/analytics/events | Ingest Events


# **adminBehaviorApiV1AdminBehaviorGet**
> BehaviorResponse adminBehaviorApiV1AdminBehaviorGet(days)

Admin Behavior

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getAnalyticsApi();
final int days = 56; // int | 

try {
    final response = api.adminBehaviorApiV1AdminBehaviorGet(days);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AnalyticsApi->adminBehaviorApiV1AdminBehaviorGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **days** | **int**|  | [optional] [default to 14]

### Return type

[**BehaviorResponse**](BehaviorResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **ingestEventsApiV1AnalyticsEventsPost**
> ingestEventsApiV1AnalyticsEventsPost(clientEventBatchRequest)

Ingest Events

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getAnalyticsApi();
final ClientEventBatchRequest clientEventBatchRequest = ; // ClientEventBatchRequest | 

try {
    api.ingestEventsApiV1AnalyticsEventsPost(clientEventBatchRequest);
} on DioException catch (e) {
    print('Exception when calling AnalyticsApi->ingestEventsApiV1AnalyticsEventsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **clientEventBatchRequest** | [**ClientEventBatchRequest**](ClientEventBatchRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

