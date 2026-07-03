import 'package:test/test.dart';
import 'package:campus_api/campus_api.dart';


/// tests for ConversationsApi
void main() {
  final instance = CampusApi().getConversationsApi();

  group(ConversationsApi, () {
    // Create Conversation
    //
    //Future<ConversationResponse> createConversationApiV1ConversationsPost(ConversationCreateRequest conversationCreateRequest) async
    test('test createConversationApiV1ConversationsPost', () async {
      // TODO
    });

    // List Conversations
    //
    //Future<ConversationPageResponse> listConversationsApiV1ConversationsGet({ String cursor, int limit }) async
    test('test listConversationsApiV1ConversationsGet', () async {
      // TODO
    });

    // List Messages
    //
    //Future<MessagePageResponse> listMessagesApiV1ConversationsConversationIdMessagesGet(String conversationId, { String cursor, int limit }) async
    test('test listMessagesApiV1ConversationsConversationIdMessagesGet', () async {
      // TODO
    });

    // Mark Read
    //
    //Future markReadApiV1ConversationsConversationIdReadPost(String conversationId) async
    test('test markReadApiV1ConversationsConversationIdReadPost', () async {
      // TODO
    });

    // Send Message
    //
    //Future<AppSchemasConversationMessageResponse> sendMessageApiV1ConversationsConversationIdMessagesPost(String conversationId, MessageCreateRequest messageCreateRequest) async
    test('test sendMessageApiV1ConversationsConversationIdMessagesPost', () async {
      // TODO
    });

  });
}
