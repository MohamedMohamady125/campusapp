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
[**createDropoffApiV1RunsDropoffsPost**](RunsApi.md#createdropoffapiv1runsdropoffspost) | **POST** /api/v1/runs/dropoffs | Create Dropoff
[**createRunApiV1RunsPost**](RunsApi.md#createrunapiv1runspost) | **POST** /api/v1/runs | Create Run
[**createSpotApiV1RunsSpotsPost**](RunsApi.md#createspotapiv1runsspotspost) | **POST** /api/v1/runs/spots | Create Spot
[**declineOrderApiV1RunsRunIdOrdersOrderIdDeclinePost**](RunsApi.md#declineorderapiv1runsrunidordersorderiddeclinepost) | **POST** /api/v1/runs/{run_id}/orders/{order_id}/decline | Decline Order
[**getRunApiV1RunsRunIdGet**](RunsApi.md#getrunapiv1runsrunidget) | **GET** /api/v1/runs/{run_id} | Get Run
[**listDropoffsApiV1RunsDropoffsGet**](RunsApi.md#listdropoffsapiv1runsdropoffsget) | **GET** /api/v1/runs/dropoffs | List Dropoffs
[**listSpotsApiV1RunsSpotsGet**](RunsApi.md#listspotsapiv1runsspotsget) | **GET** /api/v1/runs/spots | List Spots
[**markArrivedApiV1RunsRunIdOrdersOrderIdArrivedPost**](RunsApi.md#markarrivedapiv1runsrunidordersorderidarrivedpost) | **POST** /api/v1/runs/{run_id}/orders/{order_id}/arrived | Mark Arrived
[**markDeliveredApiV1RunsRunIdOrdersOrderIdDeliveredPost**](RunsApi.md#markdeliveredapiv1runsrunidordersorderiddeliveredpost) | **POST** /api/v1/runs/{run_id}/orders/{order_id}/delivered | Mark Delivered
[**markNoShowApiV1RunsRunIdOrdersOrderIdNoShowPost**](RunsApi.md#marknoshowapiv1runsrunidordersorderidnoshowpost) | **POST** /api/v1/runs/{run_id}/orders/{order_id}/no-show | Mark No Show
[**myRunsApiV1RunsMineGet**](RunsApi.md#myrunsapiv1runsmineget) | **GET** /api/v1/runs/mine | My Runs
[**paymentProofUploadUrlApiV1RunsRunIdOrdersOrderIdPaymentProofUploadUrlPost**](RunsApi.md#paymentproofuploadurlapiv1runsrunidordersorderidpaymentproofuploadurlpost) | **POST** /api/v1/runs/{run_id}/orders/{order_id}/payment-proof-upload-url | Payment Proof Upload Url
[**requestSpotApiV1RunsRunIdOrdersPost**](RunsApi.md#requestspotapiv1runsrunidorderspost) | **POST** /api/v1/runs/{run_id}/orders | Request Spot
[**runFeedApiV1RunsGet**](RunsApi.md#runfeedapiv1runsget) | **GET** /api/v1/runs | Run Feed
[**submitPaymentProofApiV1RunsRunIdOrdersOrderIdPaymentProofPost**](RunsApi.md#submitpaymentproofapiv1runsrunidordersorderidpaymentproofpost) | **POST** /api/v1/runs/{run_id}/orders/{order_id}/payment-proof | Submit Payment Proof
[**updateLocationApiV1RunsRunIdLocationPost**](RunsApi.md#updatelocationapiv1runsrunidlocationpost) | **POST** /api/v1/runs/{run_id}/location | Update Location
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

# **createDropoffApiV1RunsDropoffsPost**
> DropoffLocationResponse createDropoffApiV1RunsDropoffsPost(dropoffLocationCreateRequest)

Create Dropoff

Admin-only: add a valid drop-off point (dorm hall, landmark).

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final DropoffLocationCreateRequest dropoffLocationCreateRequest = ; // DropoffLocationCreateRequest | 

try {
    final response = api.createDropoffApiV1RunsDropoffsPost(dropoffLocationCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->createDropoffApiV1RunsDropoffsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dropoffLocationCreateRequest** | [**DropoffLocationCreateRequest**](DropoffLocationCreateRequest.md)|  | 

### Return type

[**DropoffLocationResponse**](DropoffLocationResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
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

# **createSpotApiV1RunsSpotsPost**
> FoodSpotResponse createSpotApiV1RunsSpotsPost(foodSpotCreateRequest)

Create Spot

Admin-only: add a campus/off-campus food spot to the catalog.

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final FoodSpotCreateRequest foodSpotCreateRequest = ; // FoodSpotCreateRequest | 

try {
    final response = api.createSpotApiV1RunsSpotsPost(foodSpotCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->createSpotApiV1RunsSpotsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **foodSpotCreateRequest** | [**FoodSpotCreateRequest**](FoodSpotCreateRequest.md)|  | 

### Return type

[**FoodSpotResponse**](FoodSpotResponse.md)

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

# **listDropoffsApiV1RunsDropoffsGet**
> BuiltList<DropoffLocationResponse> listDropoffsApiV1RunsDropoffsGet()

List Dropoffs

Valid drop-off points requesters choose from when joining a run.

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();

try {
    final response = api.listDropoffsApiV1RunsDropoffsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->listDropoffsApiV1RunsDropoffsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;DropoffLocationResponse&gt;**](DropoffLocationResponse.md)

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

# **markArrivedApiV1RunsRunIdOrdersOrderIdArrivedPost**
> RunResponse markArrivedApiV1RunsRunIdOrdersOrderIdArrivedPost(runId, orderId)

Mark Arrived

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String runId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.markArrivedApiV1RunsRunIdOrdersOrderIdArrivedPost(runId, orderId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->markArrivedApiV1RunsRunIdOrdersOrderIdArrivedPost: $e\n');
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

# **paymentProofUploadUrlApiV1RunsRunIdOrdersOrderIdPaymentProofUploadUrlPost**
> PaymentProofUploadUrlResponse paymentProofUploadUrlApiV1RunsRunIdOrdersOrderIdPaymentProofUploadUrlPost(runId, orderId, paymentProofUploadUrlRequest)

Payment Proof Upload Url

Requester gets a signed URL to upload their transaction screenshot.

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String runId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final PaymentProofUploadUrlRequest paymentProofUploadUrlRequest = ; // PaymentProofUploadUrlRequest | 

try {
    final response = api.paymentProofUploadUrlApiV1RunsRunIdOrdersOrderIdPaymentProofUploadUrlPost(runId, orderId, paymentProofUploadUrlRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->paymentProofUploadUrlApiV1RunsRunIdOrdersOrderIdPaymentProofUploadUrlPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runId** | **String**|  | 
 **orderId** | **String**|  | 
 **paymentProofUploadUrlRequest** | [**PaymentProofUploadUrlRequest**](PaymentProofUploadUrlRequest.md)|  | 

### Return type

[**PaymentProofUploadUrlResponse**](PaymentProofUploadUrlResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
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
> RunPageResponse runFeedApiV1RunsGet(cursor, limit)

Run Feed

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String cursor = cursor_example; // String | 
final int limit = 56; // int | 

try {
    final response = api.runFeedApiV1RunsGet(cursor, limit);
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

### Return type

[**RunPageResponse**](RunPageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **submitPaymentProofApiV1RunsRunIdOrdersOrderIdPaymentProofPost**
> RunResponse submitPaymentProofApiV1RunsRunIdOrdersOrderIdPaymentProofPost(runId, orderId, paymentProofSubmitRequest)

Submit Payment Proof

Requester confirms off-app payment; proof surfaces on the runner's card.

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String runId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final PaymentProofSubmitRequest paymentProofSubmitRequest = ; // PaymentProofSubmitRequest | 

try {
    final response = api.submitPaymentProofApiV1RunsRunIdOrdersOrderIdPaymentProofPost(runId, orderId, paymentProofSubmitRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->submitPaymentProofApiV1RunsRunIdOrdersOrderIdPaymentProofPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runId** | **String**|  | 
 **orderId** | **String**|  | 
 **paymentProofSubmitRequest** | [**PaymentProofSubmitRequest**](PaymentProofSubmitRequest.md)|  | 

### Return type

[**RunResponse**](RunResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateLocationApiV1RunsRunIdLocationPost**
> RunResponse updateLocationApiV1RunsRunIdLocationPost(runId, runLocationUpdateRequest)

Update Location

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRunsApi();
final String runId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final RunLocationUpdateRequest runLocationUpdateRequest = ; // RunLocationUpdateRequest | 

try {
    final response = api.updateLocationApiV1RunsRunIdLocationPost(runId, runLocationUpdateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RunsApi->updateLocationApiV1RunsRunIdLocationPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runId** | **String**|  | 
 **runLocationUpdateRequest** | [**RunLocationUpdateRequest**](RunLocationUpdateRequest.md)|  | 

### Return type

[**RunResponse**](RunResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
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

