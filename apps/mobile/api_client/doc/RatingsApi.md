# campus_api.api.RatingsApi

## Load the API package
```dart
import 'package:campus_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createRatingApiV1RatingsPost**](RatingsApi.md#createratingapiv1ratingspost) | **POST** /api/v1/ratings | Create Rating
[**listUserRatingsApiV1UsersUserIdRatingsGet**](RatingsApi.md#listuserratingsapiv1usersuseridratingsget) | **GET** /api/v1/users/{user_id}/ratings | List User Ratings


# **createRatingApiV1RatingsPost**
> RatingResponse createRatingApiV1RatingsPost(ratingCreateRequest)

Create Rating

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRatingsApi();
final RatingCreateRequest ratingCreateRequest = ; // RatingCreateRequest | 

try {
    final response = api.createRatingApiV1RatingsPost(ratingCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RatingsApi->createRatingApiV1RatingsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ratingCreateRequest** | [**RatingCreateRequest**](RatingCreateRequest.md)|  | 

### Return type

[**RatingResponse**](RatingResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listUserRatingsApiV1UsersUserIdRatingsGet**
> RatingPageResponse listUserRatingsApiV1UsersUserIdRatingsGet(userId, cursor, limit)

List User Ratings

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getRatingsApi();
final String userId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String cursor = cursor_example; // String | 
final int limit = 56; // int | 

try {
    final response = api.listUserRatingsApiV1UsersUserIdRatingsGet(userId, cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RatingsApi->listUserRatingsApiV1UsersUserIdRatingsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**RatingPageResponse**](RatingPageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

