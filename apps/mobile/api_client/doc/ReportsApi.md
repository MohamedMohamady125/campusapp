# campus_api.api.ReportsApi

## Load the API package
```dart
import 'package:campus_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createReportApiV1ReportsPost**](ReportsApi.md#createreportapiv1reportspost) | **POST** /api/v1/reports | Create Report
[**listReportsApiV1AdminReportsGet**](ReportsApi.md#listreportsapiv1adminreportsget) | **GET** /api/v1/admin/reports | List Reports
[**updateReportApiV1AdminReportsReportIdPatch**](ReportsApi.md#updatereportapiv1adminreportsreportidpatch) | **PATCH** /api/v1/admin/reports/{report_id} | Update Report


# **createReportApiV1ReportsPost**
> ReportResponse createReportApiV1ReportsPost(reportCreateRequest)

Create Report

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getReportsApi();
final ReportCreateRequest reportCreateRequest = ; // ReportCreateRequest | 

try {
    final response = api.createReportApiV1ReportsPost(reportCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReportsApi->createReportApiV1ReportsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reportCreateRequest** | [**ReportCreateRequest**](ReportCreateRequest.md)|  | 

### Return type

[**ReportResponse**](ReportResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listReportsApiV1AdminReportsGet**
> ReportPageResponse listReportsApiV1AdminReportsGet(cursor, limit)

List Reports

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getReportsApi();
final String cursor = cursor_example; // String | 
final int limit = 56; // int | 

try {
    final response = api.listReportsApiV1AdminReportsGet(cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReportsApi->listReportsApiV1AdminReportsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**ReportPageResponse**](ReportPageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateReportApiV1AdminReportsReportIdPatch**
> ReportResponse updateReportApiV1AdminReportsReportIdPatch(reportId, reportUpdateRequest)

Update Report

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getReportsApi();
final String reportId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final ReportUpdateRequest reportUpdateRequest = ; // ReportUpdateRequest | 

try {
    final response = api.updateReportApiV1AdminReportsReportIdPatch(reportId, reportUpdateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReportsApi->updateReportApiV1AdminReportsReportIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reportId** | **String**|  | 
 **reportUpdateRequest** | [**ReportUpdateRequest**](ReportUpdateRequest.md)|  | 

### Return type

[**ReportResponse**](ReportResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

