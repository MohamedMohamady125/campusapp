# campus_api.api.RunsApi

## Load the API package
```dart
import 'package:campus_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptOrderApiV1RunsRunIdOrdersOrderIdAcceptPost**](RunsApi.md#acceptorderapiv1runsrunidordersorderidacceptpost) | **POST** /api/v1/runs/{run_id}/orders/{order_id}/accept | Accept Order
[**cancelRunApiV1RunsRunIdCancelPost**](RunsApi.md#cancelrunapiv1runsrunidcancelpost) | **POST** /api/v1/runs/{run_id}/cancel | Cancel Run
[**confirmReceivedApiV1RunsRunIdOrdersOrderIdReceivedPost**](RunsApi.md#confirmreceivedapiv1runsrunidordersorderidreceivedpost) | **POST** /api/v1/runs/{run_id}/orders/{order_id}/received | Confirm Received
[**createRunApiV1RunsPost**](RunsApi.md#createrunapiv1runspost) | **POST** /api/v1/runs | Create Run
[**declineOrderApiV1RunsRunIdOrdersOrderIdDeclinePost**](RunsApi.md#declineorderapiv1runsrunidordersorderiddeclinepost) | **POST** /api/v1/runs/{run_id}/orders/{order_id}/decline | Decline Order
[**getRunApiV1RunsRunIdGet**](RunsApi.md#getrunapiv1runsrunidget) | **GET** /api/v1/runs/{run_id} | Get Run
[**listSpotsApiV1RunsSpotsGet**](RunsApi.md#listspotsapiv1runsspotsget) | **GET** /api/v1/runs/spots | List Spots
[**markDeliveredApiV1RunsRunIdOrdersOrderIdDeliveredPost**](RunsApi.md#markdeliveredapiv1runsrunidordersorderiddeliveredpost) | **POST** /api/v1/runs/{run_id}/orders/{order_id}/delivered | Mark Delivered
[**markNoShowApiV1RunsRunIdOrdersOrderIdNoShowPost**](RunsApi.md#marknoshowapiv1runsrunidordersorderidnoshowpost) | **POST** /api/v1/runs/{run_id}/orders/{order_id}/no-show | Mark No Show
[**myRunsApiV1RunsMineGet**](RunsApi.md#myrunsapiv1runsmineget) | **GET** /api/v1/runs/mine | My Runs
[**requestSpotApiV1RunsRunIdOrdersPost**](RunsApi.md#requestspotapiv1runsrunidorderspost) | **POST** /api/v1/runs/{run_id}/orders | Request Spot
[**runFeedApiV1RunsGet**](RunsApi.md#runfeedapiv1runsget) | **GET** /api/v1/runs | Run Feed
[**updateStatusApiV1RunsRunIdStatusPost**](RunsApi.md#updatestatusapiv1runsrunidstatuspost) | **POST** /api/v1/runs/{run_id}/status | Update Status
[**withdrawOrderApiV1RunsRunIdOrdersOrderIdDelete**](RunsApi.md#withdraworderapiv1runsrunidordersorderiddelete) | **DELETE** /api/v1/runs/{run_id}/orders/{order_id} | Withdraw Order


# **acceptOrderApiV1RunsRunIdOrdersOrderIdAcceptPost**
> RunResponse acceptOrderApiV1RunsRunIdOrdersOrderIdAcceptPost(runId, orderId)

Accept Order

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String runId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.acceptOrderApiV1RunsRunIdOrdersOrderIdAcceptPost(runId, orderId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->acceptOrderApiV1RunsRunIdOrdersOrderIdAcceptPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runId** | **String**|  | 
 **orderId** | **String**|  | 

### Return type

[**RunResponse**](RunResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cancelRunApiV1RunsRunIdCancelPost**
> RunResponse cancelRunApiV1RunsRunIdCancelPost(runId)

Cancel Run

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String runId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.cancelRunApiV1RunsRunIdCancelPost(runId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->cancelRunApiV1RunsRunIdCancelPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runId** | **String**|  | 

### Return type

[**RunResponse**](RunResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmReceivedApiV1RunsRunIdOrdersOrderIdReceivedPost**
> RunResponse confirmReceivedApiV1RunsRunIdOrdersOrderIdReceivedPost(runId, orderId)

Confirm Received

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String runId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.confirmReceivedApiV1RunsRunIdOrdersOrderIdReceivedPost(runId, orderId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->confirmReceivedApiV1RunsRunIdOrdersOrderIdReceivedPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runId** | **String**|  | 
 **orderId** | **String**|  | 

### Return type

[**RunResponse**](RunResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createRunApiV1RunsPost**
> RunResponse createRunApiV1RunsPost(runCreateRequest)

Create Run

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final RunCreateRequest runCreateRequest = ; // RunCreateRequest | 

try {
    final response = api.createRunApiV1RunsPost(runCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->createRunApiV1RunsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runCreateRequest** | [**RunCreateRequest**](RunCreateRequest.md)|  | 

### Return type

[**RunResponse**](RunResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **declineOrderApiV1RunsRunIdOrdersOrderIdDeclinePost**
> RunResponse declineOrderApiV1RunsRunIdOrdersOrderIdDeclinePost(runId, orderId)

Decline Order

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String runId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.declineOrderApiV1RunsRunIdOrdersOrderIdDeclinePost(runId, orderId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->declineOrderApiV1RunsRunIdOrdersOrderIdDeclinePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runId** | **String**|  | 
 **orderId** | **String**|  | 

### Return type

[**RunResponse**](RunResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRunApiV1RunsRunIdGet**
> RunResponse getRunApiV1RunsRunIdGet(runId)

Get Run

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String runId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getRunApiV1RunsRunIdGet(runId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->getRunApiV1RunsRunIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runId** | **String**|  | 

### Return type

[**RunResponse**](RunResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSpotsApiV1RunsSpotsGet**
> BuiltList<FoodSpotResponse> listSpotsApiV1RunsSpotsGet()

List Spots

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();

try {
    final response = api.listSpotsApiV1RunsSpotsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->listSpotsApiV1RunsSpotsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;FoodSpotResponse&gt;**](FoodSpotResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markDeliveredApiV1RunsRunIdOrdersOrderIdDeliveredPost**
> RunResponse markDeliveredApiV1RunsRunIdOrdersOrderIdDeliveredPost(runId, orderId)

Mark Delivered

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String runId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.markDeliveredApiV1RunsRunIdOrdersOrderIdDeliveredPost(runId, orderId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->markDeliveredApiV1RunsRunIdOrdersOrderIdDeliveredPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runId** | **String**|  | 
 **orderId** | **String**|  | 

### Return type

[**RunResponse**](RunResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markNoShowApiV1RunsRunIdOrdersOrderIdNoShowPost**
> RunResponse markNoShowApiV1RunsRunIdOrdersOrderIdNoShowPost(runId, orderId)

Mark No Show

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String runId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.markNoShowApiV1RunsRunIdOrdersOrderIdNoShowPost(runId, orderId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->markNoShowApiV1RunsRunIdOrdersOrderIdNoShowPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runId** | **String**|  | 
 **orderId** | **String**|  | 

### Return type

[**RunResponse**](RunResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **myRunsApiV1RunsMineGet**
> RunPageResponse myRunsApiV1RunsMineGet()

My Runs

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();

try {
    final response = api.myRunsApiV1RunsMineGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->myRunsApiV1RunsMineGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**RunPageResponse**](RunPageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestSpotApiV1RunsRunIdOrdersPost**
> RunResponse requestSpotApiV1RunsRunIdOrdersPost(runId, runOrderCreateRequest)

Request Spot

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String runId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final RunOrderCreateRequest runOrderCreateRequest = ; // RunOrderCreateRequest | 

try {
    final response = api.requestSpotApiV1RunsRunIdOrdersPost(runId, runOrderCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->requestSpotApiV1RunsRunIdOrdersPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runId** | **String**|  | 
 **runOrderCreateRequest** | [**RunOrderCreateRequest**](RunOrderCreateRequest.md)|  | 

### Return type

[**RunResponse**](RunResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **runFeedApiV1RunsGet**
> RunPageResponse runFeedApiV1RunsGet(cursor, limit, diningDollars)

Run Feed

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String cursor = cursor_example; // String | 
final int limit = 56; // int | 
final bool diningDollars = true; // bool | Only runs where the runner pays with dining dollars.

try {
    final response = api.runFeedApiV1RunsGet(cursor, limit, diningDollars);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->runFeedApiV1RunsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]
 **diningDollars** | **bool**| Only runs where the runner pays with dining dollars. | [optional] [default to false]

### Return type

[**RunPageResponse**](RunPageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateStatusApiV1RunsRunIdStatusPost**
> RunResponse updateStatusApiV1RunsRunIdStatusPost(runId, runStatusUpdateRequest)

Update Status

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String runId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final RunStatusUpdateRequest runStatusUpdateRequest = ; // RunStatusUpdateRequest | 

try {
    final response = api.updateStatusApiV1RunsRunIdStatusPost(runId, runStatusUpdateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->updateStatusApiV1RunsRunIdStatusPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runId** | **String**|  | 
 **runStatusUpdateRequest** | [**RunStatusUpdateRequest**](RunStatusUpdateRequest.md)|  | 

### Return type

[**RunResponse**](RunResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **withdrawOrderApiV1RunsRunIdOrdersOrderIdDelete**
> withdrawOrderApiV1RunsRunIdOrdersOrderIdDelete(runId, orderId)

Withdraw Order

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String runId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.withdrawOrderApiV1RunsRunIdOrdersOrderIdDelete(runId, orderId);
} on DioException catch (e) {
    print('Exception when calling RunsApi->withdrawOrderApiV1RunsRunIdOrdersOrderIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runId** | **String**|  | 
 **orderId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

