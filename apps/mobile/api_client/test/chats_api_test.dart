import 'package:test/test.dart';
import 'package:campus_api/campus_api.dart';


/// tests for ChatsApi
void main() {
  final instance = CampusApi().getChatsApi();

  group(ChatsApi, () {
    // Ban Member
    //
    //Future<ChatMembershipResponse> banMemberApiV1ChatsChatIdMembersUserIdBanPost(String chatId, String userId) async
    test('test banMemberApiV1ChatsChatIdMembersUserIdBanPost', () async {
      // TODO
    });

    // Chat Directory
    //
    //Future<ChatPageResponse> chatDirectoryApiV1ChatsDirectoryGet({ String cursor, int limit }) async
    test('test chatDirectoryApiV1ChatsDirectoryGet', () async {
      // TODO
    });

    // Create Chat
    //
    //Future<ChatResponse> createChatApiV1ChatsPost(ChatCreateRequest chatCreateRequest) async
    test('test createChatApiV1ChatsPost', () async {
      // TODO
    });

    // Delete Chat Message
    //
    //Future deleteChatMessageApiV1ChatsChatIdMessagesMessageIdDeletePost(String chatId, String messageId) async
    test('test deleteChatMessageApiV1ChatsChatIdMessagesMessageIdDeletePost', () async {
      // TODO
    });

    // Join Chat
    //
    //Future<ChatMembershipResponse> joinChatApiV1ChatsChatIdJoinPost(String chatId) async
    test('test joinChatApiV1ChatsChatIdJoinPost', () async {
      // TODO
    });

    // Leave Chat
    //
    //Future leaveChatApiV1ChatsChatIdLeavePost(String chatId) async
    test('test leaveChatApiV1ChatsChatIdLeavePost', () async {
      // TODO
    });

    // List Chat Messages
    //
    //Future<ChatMessagePageResponse> listChatMessagesApiV1ChatsChatIdMessagesGet(String chatId, { String cursor, int limit }) async
    test('test listChatMessagesApiV1ChatsChatIdMessagesGet', () async {
      // TODO
    });

    // Mute Member
    //
    //Future<ChatMembershipResponse> muteMemberApiV1ChatsChatIdMembersUserIdMutePost(String chatId, String userId, MuteRequest muteRequest) async
    test('test muteMemberApiV1ChatsChatIdMembersUserIdMutePost', () async {
      // TODO
    });

    // My Chats
    //
    //Future<ChatPageResponse> myChatsApiV1ChatsGet({ String cursor, int limit }) async
    test('test myChatsApiV1ChatsGet', () async {
      // TODO
    });

    // Post Chat Message
    //
    //Future<ChatMessageResponse> postChatMessageApiV1ChatsChatIdMessagesPost(String chatId, ChatMessageCreateRequest chatMessageCreateRequest) async
    test('test postChatMessageApiV1ChatsChatIdMessagesPost', () async {
      // TODO
    });

  });
}
