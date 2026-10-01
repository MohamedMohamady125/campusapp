# campus_api.api.ImagesApi

## Load the API package
```dart
import 'package:campus_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getImageApiV1ImagesImageIdGet**](ImagesApi.md#getimageapiv1imagesimageidget) | **GET** /api/v1/images/{image_id} | Get Image
[**uploadImageApiV1ImagesPost**](ImagesApi.md#uploadimageapiv1imagespost) | **POST** /api/v1/images | Upload Image


# **getImageApiV1ImagesImageIdGet**
> JsonObject getImageApiV1ImagesImageIdGet(imageId)

Get Image

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getImagesApi();
final String imageId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getImageApiV1ImagesImageIdGet(imageId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ImagesApi->getImageApiV1ImagesImageIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **imageId** | **String**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadImageApiV1ImagesPost**
> ImageUploadResponse uploadImageApiV1ImagesPost(imageUploadRequest)

Upload Image

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getImagesApi();
final ImageUploadRequest imageUploadRequest = ; // ImageUploadRequest | 

try {
    final response = api.uploadImageApiV1ImagesPost(imageUploadRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ImagesApi->uploadImageApiV1ImagesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **imageUploadRequest** | [**ImageUploadRequest**](ImageUploadRequest.md)|  | 

### Return type

[**ImageUploadResponse**](ImageUploadResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

