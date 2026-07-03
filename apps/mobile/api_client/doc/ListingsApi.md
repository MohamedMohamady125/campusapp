# campus_api.api.ListingsApi

## Load the API package
```dart
import 'package:campus_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createListingApiV1ListingsPost**](ListingsApi.md#createlistingapiv1listingspost) | **POST** /api/v1/listings | Create Listing
[**deleteListingApiV1ListingsListingIdDelete**](ListingsApi.md#deletelistingapiv1listingslistingiddelete) | **DELETE** /api/v1/listings/{listing_id} | Delete Listing
[**getListingApiV1ListingsListingIdGet**](ListingsApi.md#getlistingapiv1listingslistingidget) | **GET** /api/v1/listings/{listing_id} | Get Listing
[**imageUploadUrlApiV1ListingsListingIdImageUploadUrlPost**](ListingsApi.md#imageuploadurlapiv1listingslistingidimageuploadurlpost) | **POST** /api/v1/listings/{listing_id}/image-upload-url | Image Upload Url
[**listListingsApiV1ListingsGet**](ListingsApi.md#listlistingsapiv1listingsget) | **GET** /api/v1/listings | List Listings
[**markSoldApiV1ListingsListingIdMarkSoldPost**](ListingsApi.md#marksoldapiv1listingslistingidmarksoldpost) | **POST** /api/v1/listings/{listing_id}/mark-sold | Mark Sold
[**promoteListingApiV1ListingsListingIdPromotePost**](ListingsApi.md#promotelistingapiv1listingslistingidpromotepost) | **POST** /api/v1/listings/{listing_id}/promote | Promote Listing
[**updateListingApiV1ListingsListingIdPatch**](ListingsApi.md#updatelistingapiv1listingslistingidpatch) | **PATCH** /api/v1/listings/{listing_id} | Update Listing


# **createListingApiV1ListingsPost**
> ListingResponse createListingApiV1ListingsPost(listingCreateRequest)

Create Listing

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getListingsApi();
final ListingCreateRequest listingCreateRequest = ; // ListingCreateRequest | 

try {
    final response = api.createListingApiV1ListingsPost(listingCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ListingsApi->createListingApiV1ListingsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listingCreateRequest** | [**ListingCreateRequest**](ListingCreateRequest.md)|  | 

### Return type

[**ListingResponse**](ListingResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteListingApiV1ListingsListingIdDelete**
> deleteListingApiV1ListingsListingIdDelete(listingId)

Delete Listing

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getListingsApi();
final String listingId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.deleteListingApiV1ListingsListingIdDelete(listingId);
} on DioException catch (e) {
    print('Exception when calling ListingsApi->deleteListingApiV1ListingsListingIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listingId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getListingApiV1ListingsListingIdGet**
> ListingResponse getListingApiV1ListingsListingIdGet(listingId)

Get Listing

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getListingsApi();
final String listingId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getListingApiV1ListingsListingIdGet(listingId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ListingsApi->getListingApiV1ListingsListingIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listingId** | **String**|  | 

### Return type

[**ListingResponse**](ListingResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **imageUploadUrlApiV1ListingsListingIdImageUploadUrlPost**
> ImageUploadUrlResponse imageUploadUrlApiV1ListingsListingIdImageUploadUrlPost(listingId, imageUploadUrlRequest)

Image Upload Url

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getListingsApi();
final String listingId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final ImageUploadUrlRequest imageUploadUrlRequest = ; // ImageUploadUrlRequest | 

try {
    final response = api.imageUploadUrlApiV1ListingsListingIdImageUploadUrlPost(listingId, imageUploadUrlRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ListingsApi->imageUploadUrlApiV1ListingsListingIdImageUploadUrlPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listingId** | **String**|  | 
 **imageUploadUrlRequest** | [**ImageUploadUrlRequest**](ImageUploadUrlRequest.md)|  | 

### Return type

[**ImageUploadUrlResponse**](ImageUploadUrlResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listListingsApiV1ListingsGet**
> ListingPageResponse listListingsApiV1ListingsGet(q, category, condition, minPrice, maxPrice, cursor, limit)

List Listings

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getListingsApi();
final String q = q_example; // String | 
final ListingCategory category = ; // ListingCategory | 
final ListingCondition condition = ; // ListingCondition | 
final int minPrice = 56; // int | 
final int maxPrice = 56; // int | 
final String cursor = cursor_example; // String | 
final int limit = 56; // int | 

try {
    final response = api.listListingsApiV1ListingsGet(q, category, condition, minPrice, maxPrice, cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ListingsApi->listListingsApiV1ListingsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | [optional] 
 **category** | [**ListingCategory**](.md)|  | [optional] 
 **condition** | [**ListingCondition**](.md)|  | [optional] 
 **minPrice** | **int**|  | [optional] 
 **maxPrice** | **int**|  | [optional] 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**ListingPageResponse**](ListingPageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markSoldApiV1ListingsListingIdMarkSoldPost**
> ListingResponse markSoldApiV1ListingsListingIdMarkSoldPost(listingId)

Mark Sold

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getListingsApi();
final String listingId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.markSoldApiV1ListingsListingIdMarkSoldPost(listingId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ListingsApi->markSoldApiV1ListingsListingIdMarkSoldPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listingId** | **String**|  | 

### Return type

[**ListingResponse**](ListingResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **promoteListingApiV1ListingsListingIdPromotePost**
> ListingResponse promoteListingApiV1ListingsListingIdPromotePost(listingId)

Promote Listing

Promoted listings rail (spec §13.1) — 403 FEATURE_DISABLED while the flag is off.

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getListingsApi();
final String listingId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.promoteListingApiV1ListingsListingIdPromotePost(listingId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ListingsApi->promoteListingApiV1ListingsListingIdPromotePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listingId** | **String**|  | 

### Return type

[**ListingResponse**](ListingResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateListingApiV1ListingsListingIdPatch**
> ListingResponse updateListingApiV1ListingsListingIdPatch(listingId, listingUpdateRequest)

Update Listing

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getListingsApi();
final String listingId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final ListingUpdateRequest listingUpdateRequest = ; // ListingUpdateRequest | 

try {
    final response = api.updateListingApiV1ListingsListingIdPatch(listingId, listingUpdateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ListingsApi->updateListingApiV1ListingsListingIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **listingId** | **String**|  | 
 **listingUpdateRequest** | [**ListingUpdateRequest**](ListingUpdateRequest.md)|  | 

### Return type

[**ListingResponse**](ListingResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

