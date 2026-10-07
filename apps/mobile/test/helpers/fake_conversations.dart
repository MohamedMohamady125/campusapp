import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';

UserPublicResponse fakePeer() => UserPublicResponse(
  (b) => b
    ..id = 'u-2'
    ..displayName = 'Sara Seller'
    ..ratingCount = 12
    ..reputationScore = 4.6
    ..createdAt = DateTime.utc(2026),
);

ConversationResponse fakeConversation() => ConversationResponse(
  (b) => b
    ..id = 'c-1'
    ..contextType = ConversationContext.listing
    ..createdAt = DateTime.utc(2026)
    ..participants.replace([
      fakePeer(),
      UserPublicResponse(
        (u) => u
          ..id = 'u-1'
          ..displayName = 'Test Student'
          ..ratingCount = 3
          ..reputationScore = 4.2
          ..createdAt = DateTime.utc(2026),
      ),
    ]),
);

AppSchemasConversationMessageResponse fakeMessage(
  String id,
  String sender,
  String body,
  int minute,
) => AppSchemasConversationMessageResponse(
  (b) => b
    ..id = id
    ..conversationId = 'c-1'
    ..senderId = sender
    ..body = body
    ..createdAt = DateTime.utc(2026, 1, 1, 12, minute),
);

class FakeConversationsRepository implements ConversationsRepository {
  FakeConversationsRepository({this.conversations = const []});

  final List<ConversationResponse> conversations;
  List<AppSchemasConversationMessageResponse> messages = [];
  bool failSend = false;
  int markReadCalls = 0;

  @override
  Future<List<ConversationResponse>> fetchConversations() async =>
      conversations;

  @override
  Future<ConversationResponse> fetchConversation(
    String conversationId,
  ) async => fakeConversation();

  @override
  Future<List<AppSchemasConversationMessageResponse>> fetchMessages(
    String conversationId,
  ) async => messages;

  @override
  Future<AppSchemasConversationMessageResponse> sendMessage(
    String conversationId,
    String body,
  ) async {
    if (failSend) throw Exception('network down');
    final sent = fakeMessage('m-${messages.length + 1}', 'u-1', body, 30);
    messages = [...messages, sent];
    return sent;
  }

  @override
  Future<void> markRead(String conversationId) async {
    markReadCalls++;
  }

  @override
  Future<ConversationResponse> openConversation({
    required String recipientId,
    ConversationContext? contextType,
    String? contextId,
  }) async => fakeConversation();
}
