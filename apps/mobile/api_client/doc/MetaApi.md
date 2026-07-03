# campus_api.api.MetaApi

## Load the API package
```dart
import 'package:campus_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getFlagsApiV1FlagsGet**](MetaApi.md#getflagsapiv1flagsget) | **GET** /api/v1/flags | Get Flags
[**healthApiV1HealthGet**](MetaApi.md#healthapiv1healthget) | **GET** /api/v1/health | Health
[**readyApiV1HealthReadyGet**](MetaApi.md#readyapiv1healthreadyget) | **GET** /api/v1/health/ready | Ready


# **getFlagsApiV1FlagsGet**
> BuiltList<FlagItem> getFlagsApiV1FlagsGet()

Get Flags

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getMetaApi();

try {
    final response = api.getFlagsApiV1FlagsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MetaApi->getFlagsApiV1FlagsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;FlagItem&gt;**](FlagItem.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **healthApiV1HealthGet**
> HealthResponse healthApiV1HealthGet()

Health

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getMetaApi();

try {
    final response = api.healthApiV1HealthGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MetaApi->healthApiV1HealthGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**HealthResponse**](HealthResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **readyApiV1HealthReadyGet**
> ReadyResponse readyApiV1HealthReadyGet()

Ready

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getMetaApi();

try {
    final response = api.readyApiV1HealthReadyGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MetaApi->readyApiV1HealthReadyGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ReadyResponse**](ReadyResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

