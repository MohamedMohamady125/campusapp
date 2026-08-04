import 'dart:async';

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/components/composer.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/message_bubble.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/chats/data/chats_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatRoomControllerProvider(widget.chatId));
    final myId = ref.watch(authControllerProvider).user?.id;
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
                        return Padding(
                          padding: EdgeInsets.only(bottom: tokens.space2),
                          child: MessageBubble(
                            body: msg.body,
                            isMine: msg.senderId == myId,
                            status: pending
                                ? MessageStatus.sending
                                : MessageStatus.sent,
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
