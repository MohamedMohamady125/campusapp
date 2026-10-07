# campus_api.api.ConversationsApi

## Load the API package
```dart
import 'package:campus_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createConversationApiV1ConversationsPost**](ConversationsApi.md#createconversationapiv1conversationspost) | **POST** /api/v1/conversations | Create Conversation
[**getConversationApiV1ConversationsConversationIdGet**](ConversationsApi.md#getconversationapiv1conversationsconversationidget) | **GET** /api/v1/conversations/{conversation_id} | Get Conversation
[**listConversationsApiV1ConversationsGet**](ConversationsApi.md#listconversationsapiv1conversationsget) | **GET** /api/v1/conversations | List Conversations
[**listMessagesApiV1ConversationsConversationIdMessagesGet**](ConversationsApi.md#listmessagesapiv1conversationsconversationidmessagesget) | **GET** /api/v1/conversations/{conversation_id}/messages | List Messages
[**markReadApiV1ConversationsConversationIdReadPost**](ConversationsApi.md#markreadapiv1conversationsconversationidreadpost) | **POST** /api/v1/conversations/{conversation_id}/read | Mark Read
[**sendMessageApiV1ConversationsConversationIdMessagesPost**](ConversationsApi.md#sendmessageapiv1conversationsconversationidmessagespost) | **POST** /api/v1/conversations/{conversation_id}/messages | Send Message


# **createConversationApiV1ConversationsPost**
> ConversationResponse createConversationApiV1ConversationsPost(conversationCreateRequest)

Create Conversation

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getConversationsApi();
final ConversationCreateRequest conversationCreateRequest = ; // ConversationCreateRequest | 

try {
    final response = api.createConversationApiV1ConversationsPost(conversationCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ConversationsApi->createConversationApiV1ConversationsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **conversationCreateRequest** | [**ConversationCreateRequest**](ConversationCreateRequest.md)|  | 

### Return type

[**ConversationResponse**](ConversationResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getConversationApiV1ConversationsConversationIdGet**
> ConversationResponse getConversationApiV1ConversationsConversationIdGet(conversationId)

Get Conversation

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getConversationsApi();
final String conversationId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getConversationApiV1ConversationsConversationIdGet(conversationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ConversationsApi->getConversationApiV1ConversationsConversationIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **conversationId** | **String**|  | 

### Return type

[**ConversationResponse**](ConversationResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listConversationsApiV1ConversationsGet**
> ConversationPageResponse listConversationsApiV1ConversationsGet(cursor, limit)

List Conversations

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getConversationsApi();
final String cursor = cursor_example; // String | 
final int limit = 56; // int | 

try {
    final response = api.listConversationsApiV1ConversationsGet(cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ConversationsApi->listConversationsApiV1ConversationsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**ConversationPageResponse**](ConversationPageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMessagesApiV1ConversationsConversationIdMessagesGet**
> MessagePageResponse listMessagesApiV1ConversationsConversationIdMessagesGet(conversationId, cursor, limit)

List Messages

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getConversationsApi();
final String conversationId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String cursor = cursor_example; // String | 
final int limit = 56; // int | 

try {
    final response = api.listMessagesApiV1ConversationsConversationIdMessagesGet(conversationId, cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ConversationsApi->listMessagesApiV1ConversationsConversationIdMessagesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **conversationId** | **String**|  | 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**MessagePageResponse**](MessagePageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markReadApiV1ConversationsConversationIdReadPost**
> markReadApiV1ConversationsConversationIdReadPost(conversationId)

Mark Read

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getConversationsApi();
final String conversationId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.markReadApiV1ConversationsConversationIdReadPost(conversationId);
} on DioException catch (e) {
    print('Exception when calling ConversationsApi->markReadApiV1ConversationsConversationIdReadPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **conversationId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendMessageApiV1ConversationsConversationIdMessagesPost**
> AppSchemasConversationMessageResponse sendMessageApiV1ConversationsConversationIdMessagesPost(conversationId, messageCreateRequest)

Send Message

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getConversationsApi();
final String conversationId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final MessageCreateRequest messageCreateRequest = ; // MessageCreateRequest | 

try {
    final response = api.sendMessageApiV1ConversationsConversationIdMessagesPost(conversationId, messageCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ConversationsApi->sendMessageApiV1ConversationsConversationIdMessagesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **conversationId** | **String**|  | 
 **messageCreateRequest** | [**MessageCreateRequest**](MessageCreateRequest.md)|  | 

### Return type

[**AppSchemasConversationMessageResponse**](AppSchemasConversationMessageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

