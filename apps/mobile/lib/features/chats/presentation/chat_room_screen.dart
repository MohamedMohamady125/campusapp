import 'dart:async';

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/components/composer.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/message_bubble.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/components/tombstone_bubble.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/chats/data/chats_repository.dart';
import 'package:campusconnect/features/chats/presentation/chat_role_provider.dart';
import 'package:campusconnect/features/chats/presentation/moderation_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `3:07 PM`-style label without pulling in intl (matches thread_screen).
String _timeLabel(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${t.hour < 12 ? 'AM' : 'PM'}';
}

/// State for one chat room; messages ascending by `createdAt`.
class ChatRoomState {
  const ChatRoomState({this.messages = const [], this.loading = true});

  final List<ChatMessageResponse> messages;
  final bool loading;
}

/// Chat room controller (M7): polling refresh + optimistic post with
/// rollback (spec §6.3), mirroring the M5 thread controller.
class ChatRoomController
    extends AutoDisposeFamilyNotifier<ChatRoomState, String> {
  ChatsRepository get _repo => ref.read(chatsRepositoryProvider);

  @override
  ChatRoomState build(String arg) {
    unawaited(Future.microtask(refresh));
    return const ChatRoomState();
  }

  Future<void> refresh() async {
    try {
      final items = await _repo.fetchMessages(arg);
      final local = state.messages
          .where((m) => m.id.startsWith('local-'))
          .toList();
      final sorted = [...items]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      state = ChatRoomState(messages: [...sorted, ...local], loading: false);
    } on Object {
      state = ChatRoomState(messages: state.messages, loading: false);
    }
  }

  Future<bool> send(String body, String senderId) async {
    final local = ChatMessageResponse(
      (b) => b
        ..id = 'local-${DateTime.now().microsecondsSinceEpoch}'
        ..chatId = arg
        ..senderId = senderId
        ..body = body
        ..createdAt = DateTime.now().toUtc(),
    );
    state = ChatRoomState(
      messages: [...state.messages, local],
      loading: false,
    );
    try {
      final sent = await _repo.postMessage(arg, body);
      state = ChatRoomState(
        messages: [
          for (final m in state.messages)
            if (m.id == local.id) sent else m,
        ],
        loading: false,
      );
      return true;
    } on Object {
      state = ChatRoomState(
        messages: state.messages.where((m) => m.id != local.id).toList(),
        loading: false,
      );
      return false;
    }
  }

  /// Optimistically swaps a message for its tombstone after a moderator
  /// delete (Sprint 6); the next poll confirms the server state.
  void markDeleted(String messageId, {required String reason, String? byName}) {
    state = ChatRoomState(
      messages: [
        for (final m in state.messages)
          if (m.id == messageId)
            m.rebuild(
              (b) => b
                ..body = ''
                ..deletedAt = DateTime.now().toUtc()
                ..deletedReason = reason
                ..deletedByName = byName,
            )
          else
            m,
      ],
      loading: false,
    );
  }
}

final AutoDisposeNotifierProviderFamily<
  ChatRoomController,
  ChatRoomState,
  String
>
chatRoomControllerProvider = NotifierProvider.autoDispose
    .family<ChatRoomController, ChatRoomState, String>(
      ChatRoomController.new,
    );

/// Group chat room (J3, spec §12.4): reversed message list + composer.
class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({required this.chatId, this.title, super.key});

  final String chatId;
  final String? title;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _composer = TextEditingController();
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 5), (_) {
      ref
          .read(chatRoomControllerProvider(widget.chatId).notifier)
          .refresh()
          .ignore();
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _composer.dispose();
    super.dispose();
  }

  Future<void> _send(String body) async {
    final myId = ref.read(authControllerProvider).user?.id ?? '';
    final ok = await ref
        .read(chatRoomControllerProvider(widget.chatId).notifier)
        .send(body, myId);
    if (!ok && mounted) {
      _composer.text = body; // preserve input on rollback (spec §6.3)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("That didn't send. Try again.")),
      );
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Long-press moderation flow (Sprint 6): sheet → dialog → API call.
  Future<void> _moderate(
    ChatMessageResponse msg, {
    required bool isOwner,
  }) async {
    final action = await showModerationSheet(context, canPromote: isOwner);
    if (action == null || !mounted) return;
    final repo = ref.read(chatsRepositoryProvider);
    try {
      switch (action) {
        case ModerationAction.delete:
          final reason = await showDeleteMessageDialog(context);
          if (reason == null || !mounted) return;
          final myName = ref.read(authControllerProvider).user?.displayName;
          await repo.deleteMessage(widget.chatId, msg.id, reason);
          ref
              .read(chatRoomControllerProvider(widget.chatId).notifier)
              .markDeleted(msg.id, reason: reason, byName: myName);
        case ModerationAction.mute:
          final choice = await showMuteMemberDialog(context);
          if (choice == null || !mounted) return;
          await repo.muteMember(
            widget.chatId,
            msg.senderId,
            minutes: choice.$1,
            reason: choice.$2,
          );
          if (mounted) _snack('Member muted.');
        case ModerationAction.ban:
          final confirmed = await showBanMemberDialog(context);
          if (confirmed == null || !mounted) return;
          await repo.banMember(
            widget.chatId,
            msg.senderId,
            reason: confirmed.$1,
          );
          if (mounted) _snack('Member banned from this group.');
        case ModerationAction.promote:
          await repo.promoteMember(widget.chatId, msg.senderId);
          if (mounted) _snack('Member is now a moderator.');
      }
    } on Object catch (e) {
      // ALREADY_MOD (409) and friends surface their server message here.
      if (mounted) _snack(apiErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatRoomControllerProvider(widget.chatId));
    final myId = ref.watch(authControllerProvider).user?.id;
    final role = ref.watch(chatRoleProvider(widget.chatId)).valueOrNull;
    final isOwner = role == ChatRole.owner;
    final canModerate = isOwner || role == ChatRole.mod;
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Chat')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: state.loading
                  ? ListView(
                      children: const [
                        ListRowSkeleton(),
                        ListRowSkeleton(),
                        ListRowSkeleton(),
                      ],
                    )
                  : state.messages.isEmpty
                  // Empty-room copy per spec §13.2.
                  ? const EmptyState(
                      icon: Icons.forum_outlined,
                      title: "It's quiet in here",
                      body:
                          'Say something. Someone will answer — '
                          'this group has members online.',
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.all(tokens.space4),
                      itemCount: state.messages.length,
                      itemBuilder: (context, i) {
                        final msg =
                            state.messages[state.messages.length - 1 - i];
                        final pending = msg.id.startsWith('local-');
                        final mine = msg.senderId == myId;
                        if (msg.deletedAt != null) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: tokens.space2),
                            child: TombstoneBubble(
                              isMine: mine,
                              deletedByName: msg.deletedByName,
                              reason: msg.deletedReason,
                            ),
                          );
                        }
                        return Padding(
                          padding: EdgeInsets.only(bottom: tokens.space2),
                          child: MessageBubble(
                            body: msg.body,
                            isMine: mine,
                            status: pending
                                ? MessageStatus.sending
                                : MessageStatus.sent,
                            showTimestamp: true,
                            timestamp: _timeLabel(msg.createdAt.toLocal()),
                            onLongPress: canModerate && !mine && !pending
                                ? () =>
                                      _moderate(msg, isOwner: isOwner).ignore()
                                : null,
                          ),
                        );
                      },
                    ),
            ),
            Composer(
              controller: _composer,
              onSend: (body) => _send(body).ignore(),
            ),
          ],
        ),
      ),
    );
  }
}
