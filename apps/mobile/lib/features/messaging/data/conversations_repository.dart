import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/network/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1:1 conversations + messages via the generated client (spec §4.1).
class ConversationsRepository {
  ConversationsRepository(this._api);

  final CampusApi _api;

  ConversationsApi get _conversations => _api.getConversationsApi();

  Future<List<ConversationResponse>> fetchConversations() async {
    final res = await _conversations.listConversationsApiV1ConversationsGet();
    return res.data!.items.toList();
  }

  Future<List<AppSchemasConversationMessageResponse>> fetchMessages(
    String conversationId,
  ) async {
    final res = await _conversations
        .listMessagesApiV1ConversationsConversationIdMessagesGet(
          conversationId: conversationId,
          limit: 50,
        );
    return res.data!.items.toList();
  }

  Future<AppSchemasConversationMessageResponse> sendMessage(
    String conversationId,
    String body,
  ) async {
    final res = await _conversations
        .sendMessageApiV1ConversationsConversationIdMessagesPost(
          conversationId: conversationId,
          messageCreateRequest: MessageCreateRequest((b) => b..body = body),
        );
    return res.data!;
  }

  Future<void> markRead(String conversationId) async {
    await _conversations.markReadApiV1ConversationsConversationIdReadPost(
      conversationId: conversationId,
    );
  }

  /// Opens (or creates) a conversation with [recipientId], optionally tied
  /// to a listing/tutoring context — used by "Message seller/tutor" CTAs.
  Future<ConversationResponse> openConversation({
    required String recipientId,
    ConversationContext? contextType,
    String? contextId,
  }) async {
    final res = await _conversations.createConversationApiV1ConversationsPost(
      conversationCreateRequest: ConversationCreateRequest(
        (b) => b
          ..recipientId = recipientId
          ..contextType = contextType
          ..contextId = contextId,
      ),
    );
    return res.data!;
  }
}

final conversationsRepositoryProvider = Provider<ConversationsRepository>(
  (ref) => ConversationsRepository(ref.watch(campusApiProvider)),
);
