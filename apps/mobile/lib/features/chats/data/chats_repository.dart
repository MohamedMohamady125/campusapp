import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/network/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Community chats via the generated client (spec §4.1 chats).
class ChatsRepository {
  ChatsRepository(this._api);

  final CampusApi _api;

  ChatsApi get _chats => _api.getChatsApi();

  Future<List<ChatResponse>> directory() async {
    final res = await _chats.chatDirectoryApiV1ChatsDirectoryGet(limit: 50);
    return res.data!.items.toList();
  }

  /// Chats the current user belongs to — used for owner detection (Sprint 6).
  Future<List<ChatResponse>> myChats() async {
    final res = await _chats.myChatsApiV1ChatsGet(limit: 50);
    return res.data!.items.toList();
  }

  /// Joins a chat; already-a-member conflicts are treated as success so
  /// the J3 tap-through is idempotent.
  Future<void> join(String chatId) async {
    try {
      await _chats.joinChatApiV1ChatsChatIdJoinPost(chatId: chatId);
    } on DioException catch (e) {
      if (e.response?.statusCode != 409) rethrow;
    }
  }

  Future<void> leave(String chatId) async {
    await _chats.leaveChatApiV1ChatsChatIdLeavePost(chatId: chatId);
  }

  Future<List<ChatMessageResponse>> fetchMessages(String chatId) async {
    final res = await _chats.listChatMessagesApiV1ChatsChatIdMessagesGet(
      chatId: chatId,
      limit: 50,
    );
    return res.data!.items.toList();
  }

  Future<ChatMessageResponse> postMessage(String chatId, String body) async {
    final res = await _chats.postChatMessageApiV1ChatsChatIdMessagesPost(
      chatId: chatId,
      chatMessageCreateRequest: ChatMessageCreateRequest((b) => b.body = body),
    );
    return res.data!;
  }

  // -- Moderation (Sprint 6): mods/owners only; the API enforces roles. -----

  /// Deletes a message with a required reason (3..300 chars, API-validated).
  Future<void> deleteMessage(
    String chatId,
    String messageId,
    String reason,
  ) async {
    await _chats.deleteChatMessageApiV1ChatsChatIdMessagesMessageIdDeletePost(
      chatId: chatId,
      messageId: messageId,
      chatMessageDeleteRequest: ChatMessageDeleteRequest(
        (b) => b.reason = reason,
      ),
    );
  }

  Future<void> muteMember(
    String chatId,
    String userId, {
    required int minutes,
    required String reason,
  }) async {
    await _chats.muteMemberApiV1ChatsChatIdMembersUserIdMutePost(
      chatId: chatId,
      userId: userId,
      muteRequest: MuteRequest(
        (b) => b
          ..minutes = minutes
          ..reason = reason,
      ),
    );
  }

  Future<void> banMember(String chatId, String userId, {String? reason}) async {
    await _chats.banMemberApiV1ChatsChatIdMembersUserIdBanPost(
      chatId: chatId,
      userId: userId,
      banRequest: reason == null ? null : BanRequest((b) => b.reason = reason),
    );
  }

  /// Promotes a member to moderator (owner only; 409 `ALREADY_MOD`).
  Future<void> promoteMember(String chatId, String userId) async {
    await _chats.promoteMemberApiV1ChatsChatIdMembersUserIdPromotePost(
      chatId: chatId,
      userId: userId,
    );
  }
}

final chatsRepositoryProvider = Provider<ChatsRepository>(
  (ref) => ChatsRepository(ref.watch(campusApiProvider)),
);
