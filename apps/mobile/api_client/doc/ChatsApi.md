# campus_api.api.ChatsApi

## Load the API package
```dart
import 'package:campus_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**banMemberApiV1ChatsChatIdMembersUserIdBanPost**](ChatsApi.md#banmemberapiv1chatschatidmembersuseridbanpost) | **POST** /api/v1/chats/{chat_id}/members/{user_id}/ban | Ban Member
[**chatDirectoryApiV1ChatsDirectoryGet**](ChatsApi.md#chatdirectoryapiv1chatsdirectoryget) | **GET** /api/v1/chats/directory | Chat Directory
[**createChatApiV1ChatsPost**](ChatsApi.md#createchatapiv1chatspost) | **POST** /api/v1/chats | Create Chat
[**deleteChatMessageApiV1ChatsChatIdMessagesMessageIdDeletePost**](ChatsApi.md#deletechatmessageapiv1chatschatidmessagesmessageiddeletepost) | **POST** /api/v1/chats/{chat_id}/messages/{message_id}/delete | Delete Chat Message
[**joinChatApiV1ChatsChatIdJoinPost**](ChatsApi.md#joinchatapiv1chatschatidjoinpost) | **POST** /api/v1/chats/{chat_id}/join | Join Chat
[**leaveChatApiV1ChatsChatIdLeavePost**](ChatsApi.md#leavechatapiv1chatschatidleavepost) | **POST** /api/v1/chats/{chat_id}/leave | Leave Chat
[**listChatMessagesApiV1ChatsChatIdMessagesGet**](ChatsApi.md#listchatmessagesapiv1chatschatidmessagesget) | **GET** /api/v1/chats/{chat_id}/messages | List Chat Messages
[**muteMemberApiV1ChatsChatIdMembersUserIdMutePost**](ChatsApi.md#mutememberapiv1chatschatidmembersuseridmutepost) | **POST** /api/v1/chats/{chat_id}/members/{user_id}/mute | Mute Member
[**myChatsApiV1ChatsGet**](ChatsApi.md#mychatsapiv1chatsget) | **GET** /api/v1/chats | My Chats
[**postChatMessageApiV1ChatsChatIdMessagesPost**](ChatsApi.md#postchatmessageapiv1chatschatidmessagespost) | **POST** /api/v1/chats/{chat_id}/messages | Post Chat Message
[**promoteMemberApiV1ChatsChatIdMembersUserIdPromotePost**](ChatsApi.md#promotememberapiv1chatschatidmembersuseridpromotepost) | **POST** /api/v1/chats/{chat_id}/members/{user_id}/promote | Promote Member


# **banMemberApiV1ChatsChatIdMembersUserIdBanPost**
> ChatMembershipResponse banMemberApiV1ChatsChatIdMembersUserIdBanPost(chatId, userId, banRequest)

Ban Member

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getChatsApi();
final String chatId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String userId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final BanRequest banRequest = ; // BanRequest | 

try {
    final response = api.banMemberApiV1ChatsChatIdMembersUserIdBanPost(chatId, userId, banRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatsApi->banMemberApiV1ChatsChatIdMembersUserIdBanPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatId** | **String**|  | 
 **userId** | **String**|  | 
 **banRequest** | [**BanRequest**](BanRequest.md)|  | [optional] 

### Return type

[**ChatMembershipResponse**](ChatMembershipResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **chatDirectoryApiV1ChatsDirectoryGet**
> ChatPageResponse chatDirectoryApiV1ChatsDirectoryGet(cursor, limit)

Chat Directory

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getChatsApi();
final String cursor = cursor_example; // String | 
final int limit = 56; // int | 

try {
    final response = api.chatDirectoryApiV1ChatsDirectoryGet(cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatsApi->chatDirectoryApiV1ChatsDirectoryGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**ChatPageResponse**](ChatPageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createChatApiV1ChatsPost**
> ChatResponse createChatApiV1ChatsPost(chatCreateRequest)

Create Chat

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getChatsApi();
final ChatCreateRequest chatCreateRequest = ; // ChatCreateRequest | 

try {
    final response = api.createChatApiV1ChatsPost(chatCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatsApi->createChatApiV1ChatsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatCreateRequest** | [**ChatCreateRequest**](ChatCreateRequest.md)|  | 

### Return type

[**ChatResponse**](ChatResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteChatMessageApiV1ChatsChatIdMessagesMessageIdDeletePost**
> deleteChatMessageApiV1ChatsChatIdMessagesMessageIdDeletePost(chatId, messageId, chatMessageDeleteRequest)

Delete Chat Message

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getChatsApi();
final String chatId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String messageId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final ChatMessageDeleteRequest chatMessageDeleteRequest = ; // ChatMessageDeleteRequest | 

try {
    api.deleteChatMessageApiV1ChatsChatIdMessagesMessageIdDeletePost(chatId, messageId, chatMessageDeleteRequest);
} on DioException catch (e) {
    print('Exception when calling ChatsApi->deleteChatMessageApiV1ChatsChatIdMessagesMessageIdDeletePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatId** | **String**|  | 
 **messageId** | **String**|  | 
 **chatMessageDeleteRequest** | [**ChatMessageDeleteRequest**](ChatMessageDeleteRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **joinChatApiV1ChatsChatIdJoinPost**
> ChatMembershipResponse joinChatApiV1ChatsChatIdJoinPost(chatId)

Join Chat

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getChatsApi();
final String chatId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.joinChatApiV1ChatsChatIdJoinPost(chatId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatsApi->joinChatApiV1ChatsChatIdJoinPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatId** | **String**|  | 

### Return type

[**ChatMembershipResponse**](ChatMembershipResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **leaveChatApiV1ChatsChatIdLeavePost**
> leaveChatApiV1ChatsChatIdLeavePost(chatId)

Leave Chat

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getChatsApi();
final String chatId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.leaveChatApiV1ChatsChatIdLeavePost(chatId);
} on DioException catch (e) {
    print('Exception when calling ChatsApi->leaveChatApiV1ChatsChatIdLeavePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listChatMessagesApiV1ChatsChatIdMessagesGet**
> ChatMessagePageResponse listChatMessagesApiV1ChatsChatIdMessagesGet(chatId, cursor, limit)

List Chat Messages

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getChatsApi();
final String chatId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String cursor = cursor_example; // String | 
final int limit = 56; // int | 

try {
    final response = api.listChatMessagesApiV1ChatsChatIdMessagesGet(chatId, cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatsApi->listChatMessagesApiV1ChatsChatIdMessagesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatId** | **String**|  | 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**ChatMessagePageResponse**](ChatMessagePageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **muteMemberApiV1ChatsChatIdMembersUserIdMutePost**
> ChatMembershipResponse muteMemberApiV1ChatsChatIdMembersUserIdMutePost(chatId, userId, muteRequest)

Mute Member

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getChatsApi();
final String chatId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String userId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final MuteRequest muteRequest = ; // MuteRequest | 

try {
    final response = api.muteMemberApiV1ChatsChatIdMembersUserIdMutePost(chatId, userId, muteRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatsApi->muteMemberApiV1ChatsChatIdMembersUserIdMutePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatId** | **String**|  | 
 **userId** | **String**|  | 
 **muteRequest** | [**MuteRequest**](MuteRequest.md)|  | 

### Return type

[**ChatMembershipResponse**](ChatMembershipResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **myChatsApiV1ChatsGet**
> ChatPageResponse myChatsApiV1ChatsGet(cursor, limit)

My Chats

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getChatsApi();
final String cursor = cursor_example; // String | 
final int limit = 56; // int | 

try {
    final response = api.myChatsApiV1ChatsGet(cursor, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatsApi->myChatsApiV1ChatsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**ChatPageResponse**](ChatPageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postChatMessageApiV1ChatsChatIdMessagesPost**
> ChatMessageResponse postChatMessageApiV1ChatsChatIdMessagesPost(chatId, chatMessageCreateRequest)

Post Chat Message

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getChatsApi();
final String chatId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final ChatMessageCreateRequest chatMessageCreateRequest = ; // ChatMessageCreateRequest | 

try {
    final response = api.postChatMessageApiV1ChatsChatIdMessagesPost(chatId, chatMessageCreateRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatsApi->postChatMessageApiV1ChatsChatIdMessagesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatId** | **String**|  | 
 **chatMessageCreateRequest** | [**ChatMessageCreateRequest**](ChatMessageCreateRequest.md)|  | 

### Return type

[**ChatMessageResponse**](ChatMessageResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **promoteMemberApiV1ChatsChatIdMembersUserIdPromotePost**
> ChatMembershipResponse promoteMemberApiV1ChatsChatIdMembersUserIdPromotePost(chatId, userId)

Promote Member

Owner-only: promote a member to moderator (Sprint 6).

### Example
```dart
import 'package:campus_api/api.dart';

final api = CampusApi().getChatsApi();
final String chatId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String userId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.promoteMemberApiV1ChatsChatIdMembersUserIdPromotePost(chatId, userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ChatsApi->promoteMemberApiV1ChatsChatIdMembersUserIdPromotePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **chatId** | **String**|  | 
 **userId** | **String**|  | 

### Return type

[**ChatMembershipResponse**](ChatMembershipResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

