# campus_api.api.TutoringApi

## Load the API package
```dart
import 'package:campus_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**autocompleteCoursesApiV1CoursesGet**](TutoringApi.md#autocompletecoursesapiv1coursesget) | **GET** /api/v1/courses | Autocomplete Courses
[**cancelTutorPremiumApiV1TutoringPremiumSubscriptionDelete**](TutoringApi.md#canceltutorpremiumapiv1tutoringpremiumsubscriptiondelete) | **DELETE** /api/v1/tutoring/premium/subscription | Cancel Tutor Premium
[**createOfferingApiV1TutoringOfferingsPost**](TutoringApi.md#createofferingapiv1tutoringofferingspost) | **POST** /api/v1/tutoring/offerings | Create Offering
[**deleteOfferingApiV1TutoringOfferingsOfferingIdDelete**](TutoringApi.md#deleteofferingapiv1tutoringofferingsofferingiddelete) | **DELETE** /api/v1/tutoring/offerings/{offering_id} | Delete Offering
[**rankedTutorsApiV1TutoringTutorsGet**](TutoringApi.md#rankedtutorsapiv1tutoringtutorsget) | **GET** /api/v1/tutoring/tutors | Ranked Tutors
[**subscribeTutorPremiumApiV1TutoringPremiumSubscriptionPost**](TutoringApi.md#subscribetutorpremiumapiv1tutoringpremiumsubscriptionpost) | **POST** /api/v1/tutoring/premium/subscription | Subscribe Tutor Premium


# **autocompleteCoursesApiV1CoursesGet**
> BuiltList<CourseResponse> autocompleteCoursesApiV1CoursesGet(q)

Autocomplete Courses

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getTutoringApi();
final String q = q_example; // String | 

try {
    final response = api.autocompleteCoursesApiV1CoursesGet(q);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TutoringApi->autocompleteCoursesApiV1CoursesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | 

### Return type

[**BuiltList&lt;CourseResponse&gt;**](CourseResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cancelTutorPremiumApiV1TutoringPremiumSubscriptionDelete**
> SubscriptionResponse cancelTutorPremiumApiV1TutoringPremiumSubscriptionDelete()

Cancel Tutor Premium

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getTutoringApi();

try {
    final response = api.cancelTutorPremiumApiV1TutoringPremiumSubscriptionDelete();
    print(response);
} on DioException catch (e) {
    print('Exception when calling TutoringApi->cancelTutorPremiumApiV1TutoringPremiumSubscriptionDelete: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SubscriptionResponse**](SubscriptionResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createOfferingApiV1TutoringOfferingsPost**
> OfferingResponse createOfferingApiV1TutoringOfferingsPost(offeringCreateRequest)

Create Offering

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getTutoringApi();
final OfferingCreateRequest offeringCreateRequest = ; // OfferingCreateRequest | 

try {
    final response = api.createOfferingApiV1TutoringOfferingsPost(offeringCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TutoringApi->createOfferingApiV1TutoringOfferingsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **offeringCreateRequest** | [**OfferingCreateRequest**](OfferingCreateRequest.md)|  | 

### Return type

[**OfferingResponse**](OfferingResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteOfferingApiV1TutoringOfferingsOfferingIdDelete**
> deleteOfferingApiV1TutoringOfferingsOfferingIdDelete(offeringId)

Delete Offering

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getTutoringApi();
final String offeringId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.deleteOfferingApiV1TutoringOfferingsOfferingIdDelete(offeringId);
} on DioException catch (e) {
    print('Exception when calling TutoringApi->deleteOfferingApiV1TutoringOfferingsOfferingIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **offeringId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rankedTutorsApiV1TutoringTutorsGet**
> TutorSearchResponse rankedTutorsApiV1TutoringTutorsGet(course)

Ranked Tutors

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getTutoringApi();
final String course = course_example; // String | 

try {
    final response = api.rankedTutorsApiV1TutoringTutorsGet(course);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TutoringApi->rankedTutorsApiV1TutoringTutorsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **course** | **String**|  | 

### Return type

[**TutorSearchResponse**](TutorSearchResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **subscribeTutorPremiumApiV1TutoringPremiumSubscriptionPost**
> SubscriptionResponse subscribeTutorPremiumApiV1TutoringPremiumSubscriptionPost()

Subscribe Tutor Premium

Tutor premium rail (spec §13.2) — 403 FEATURE_DISABLED while the flag is off.

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getTutoringApi();

try {
    final response = api.subscribeTutorPremiumApiV1TutoringPremiumSubscriptionPost();
    print(response);
} on DioException catch (e) {
    print('Exception when calling TutoringApi->subscribeTutorPremiumApiV1TutoringPremiumSubscriptionPost: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SubscriptionResponse**](SubscriptionResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

