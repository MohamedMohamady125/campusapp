import 'dart:async';

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/chats/data/chats_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for one chat room; messages ascending by `createdAt`.
class ChatRoomState {
  const ChatRoomState({this.messages = const [], this.loading = true});

  final List<ChatMessageResponse> messages;
  final bool loading;
}

/// Chat room controller (M7): polling refresh + optimistic post with
/// rollback (§6.3), mirroring the M5 thread controller.
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
    .family<ChatRoomController, ChatRoomState, String>(ChatRoomController.new);

/// Group chat room (J3, spec §6.4): reversed message list + composer.
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

  Future<void> _send() async {
    final body = _composer.text.trim();
    if (body.isEmpty) return;
    final myId = ref.read(authControllerProvider).user?.id ?? '';
    _composer.clear();
    final ok = await ref
        .read(chatRoomControllerProvider(widget.chatId).notifier)
        .send(body, myId);
    if (!ok && mounted) {
      _composer.text = body;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message failed to send. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatRoomControllerProvider(widget.chatId));
    final myId = ref.watch(authControllerProvider).user?.id;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Chat')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: state.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: state.messages.length,
                      itemBuilder: (context, i) {
                        final msg =
                            state.messages[state.messages.length - 1 - i];
                        final mine = msg.senderId == myId;
                        return Align(
                          alignment: mine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: mine
                                  ? scheme.primaryContainer
                                  : scheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: Text(
                              msg.body,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: mine
                                        ? scheme.onPrimaryContainer
                                        : scheme.onSurface,
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _composer,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(hintText: 'Message…'),
                      onSubmitted: (_) => _send().ignore(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filled(
                    tooltip: 'Send',
                    onPressed: () => _send().ignore(),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
