# campus_api.model.RunResponse

## Load the model package
```dart
import 'package:campus_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**acceptedCount** | **int** |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**feeCents** | **int** |  | 
**foodSpot** | [**FoodSpotResponse**](FoodSpotResponse.md) |  | 
**id** | **String** |  | 
**isMine** | **bool** |  | [optional] [default to false]
**leavingAt** | [**DateTime**](DateTime.md) |  | 
**myOrder** | [**RunOrderResponse**](RunOrderResponse.md) |  | [optional] 
**note** | **String** |  | 
**orders** | [**BuiltList&lt;RunOrderResponse&gt;**](RunOrderResponse.md) |  | [optional] [default to ListBuilder()]
**paymentPrefs** | **BuiltList&lt;String&gt;** |  | [optional] [default to ListBuilder()]
**pendingCount** | **int** |  | 
**prepayRequired** | **bool** |  | 
**runner** | [**RunUserSummary**](RunUserSummary.md) |  | 
**runnerLocation** | [**RunLocation**](RunLocation.md) |  | [optional] 
**spotsMax** | **int** |  | 
**status** | [**RunStatus**](RunStatus.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


