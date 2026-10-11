# campus_api.model.RunOrderResponse

## Load the model package
```dart
import 'package:campus_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**actualPriceCents** | **int** |  | [optional] 
**arrivedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**dropoff** | **String** |  | 
**dropoffLat** | **num** |  | [optional] 
**dropoffLng** | **num** |  | [optional] 
**id** | **String** |  | 
**itemPriceCents** | **int** |  | [optional] [default to 0]
**noShowEligibleAt** | [**DateTime**](DateTime.md) |  | [optional] 
**orderText** | **String** |  | 
**paymentConfirmedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**paymentNote** | **String** |  | [optional] 
**paymentProofUrl** | **String** |  | [optional] 
**paymentSubmittedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**ratedByMe** | **bool** |  | [optional] [default to false]
**requester** | [**RunUserSummary**](RunUserSummary.md) |  | 
**runId** | **String** |  | 
**status** | [**RunOrderStatus**](RunOrderStatus.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


