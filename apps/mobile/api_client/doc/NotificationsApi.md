# campus_api.api.NotificationsApi

## Load the API package
```dart
import 'package:campus_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listNotificationsApiV1NotificationsGet**](NotificationsApi.md#listnotificationsapiv1notificationsget) | **GET** /api/v1/notifications | List Notifications
[**markNotificationsReadApiV1NotificationsReadPost**](NotificationsApi.md#marknotificationsreadapiv1notificationsreadpost) | **POST** /api/v1/notifications/read | Mark Notifications Read
[**updatePreferencesApiV1NotificationsPreferencesPatch**](NotificationsApi.md#updatepreferencesapiv1notificationspreferencespatch) | **PATCH** /api/v1/notifications/preferences | Update Preferences


# **listNotificationsApiV1NotificationsGet**
> NotificationPageResponse listNotificationsApiV1NotificationsGet(cursor, limit)

List Notifications

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getNotificationsApi();
final String cursor = cursor_example; // String | 
final int limit = 56; // int | 

try {
    final response = api.listNotificationsApiV1NotificationsGet(cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationsApi->listNotificationsApiV1NotificationsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**NotificationPageResponse**](NotificationPageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markNotificationsReadApiV1NotificationsReadPost**
> markNotificationsReadApiV1NotificationsReadPost(notificationsReadRequest)

Mark Notifications Read

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getNotificationsApi();
final NotificationsReadRequest notificationsReadRequest = ; // NotificationsReadRequest | 

try {
    api.markNotificationsReadApiV1NotificationsReadPost(notificationsReadRequest);
} on DioException catch (e) {
    print('Exception when calling NotificationsApi->markNotificationsReadApiV1NotificationsReadPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **notificationsReadRequest** | [**NotificationsReadRequest**](NotificationsReadRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePreferencesApiV1NotificationsPreferencesPatch**
> BuiltList<NotificationPreferenceItem> updatePreferencesApiV1NotificationsPreferencesPatch(notificationPreferencesUpdateRequest)

Update Preferences

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getNotificationsApi();
final NotificationPreferencesUpdateRequest notificationPreferencesUpdateRequest = ; // NotificationPreferencesUpdateRequest | 

try {
    final response = api.updatePreferencesApiV1NotificationsPreferencesPatch(notificationPreferencesUpdateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationsApi->updatePreferencesApiV1NotificationsPreferencesPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **notificationPreferencesUpdateRequest** | [**NotificationPreferencesUpdateRequest**](NotificationPreferencesUpdateRequest.md)|  | 

### Return type

[**BuiltList&lt;NotificationPreferenceItem&gt;**](NotificationPreferenceItem.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

