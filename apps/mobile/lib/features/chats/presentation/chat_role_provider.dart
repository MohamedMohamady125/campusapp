import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/chats/data/chats_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current user's role in a chat (Sprint 6 moderation gate).
///
/// The API exposes no members-list endpoint yet, so the only role we can
/// detect client-side is `owner` (via `created_by_id` on the chat record in
/// "my chats"). Non-owner moderators therefore render as plain members until
/// a members endpoint ships — the server still enforces their powers.
/// Any failure degrades to `member`, which simply hides moderation UI.
final AutoDisposeFutureProviderFamily<ChatRole, String> chatRoleProvider =
    FutureProvider.autoDispose.family<ChatRole, String>((ref, chatId) async {
      final myId = ref.watch(
        authControllerProvider.select((s) => s.user?.id),
      );
      if (myId == null) return ChatRole.member;
      try {
        final chats = await ref.watch(chatsRepositoryProvider).myChats();
        for (final chat in chats) {
          if (chat.id == chatId) {
            return chat.createdById == myId ? ChatRole.owner : ChatRole.member;
          }
        }
      } on Object {
        // Fall through — treat as a plain member.
      }
      return ChatRole.member;
    });
