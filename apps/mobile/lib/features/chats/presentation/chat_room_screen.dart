import 'dart:async';

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/chats/data/chats_repository.dart';
import 'package:campusconnect/shared/widgets/chat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for one chat room; messages ascending by
/// `createdAt`.
class ChatRoomState {
  const ChatRoomState({
    this.messages = const [],
    this.loading = true,
  });

  final List<ChatMessageResponse> messages;
  final bool loading;
}

/// Chat room controller (M7): polling refresh +
/// optimistic post with rollback (§6.3), mirroring
/// the M5 thread controller.
class ChatRoomController
    extends AutoDisposeFamilyNotifier<
      ChatRoomState,
      String
    > {
  ChatsRepository get _repo =>
      ref.read(chatsRepositoryProvider);

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
      final sorted = [...items]..sort(
          (a, b) => a.createdAt.compareTo(b.createdAt),
        );
      state = ChatRoomState(
        messages: [...sorted, ...local],
        loading: false,
      );
    } on Object {
      state = ChatRoomState(
        messages: state.messages,
        loading: false,
      );
    }
  }

  Future<bool> send(
    String body,
    String senderId,
  ) async {
    final local = ChatMessageResponse(
      (b) => b
        ..id = 'local-'
            '${DateTime.now().microsecondsSinceEpoch}'
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
      final sent =
          await _repo.postMessage(arg, body);
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
        messages: state.messages
            .where((m) => m.id != local.id)
            .toList(),
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
chatRoomControllerProvider = NotifierProvider
    .autoDispose
    .family<ChatRoomController, ChatRoomState, String>(
  ChatRoomController.new,
);

/// Group chat room (J3, spec §6.4): reversed message
/// list + composer.
class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({
    required this.chatId,
    this.title,
    super.key,
  });

  final String chatId;
  final String? title;

  @override
  ConsumerState<ChatRoomScreen> createState() =>
      _ChatRoomScreenState();
}

class _ChatRoomScreenState
    extends ConsumerState<ChatRoomScreen> {
  final _composer = TextEditingController();
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        ref
            .read(
              chatRoomControllerProvider(
                widget.chatId,
              ).notifier,
            )
            .refresh()
            .ignore();
      },
    );
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
    final myId =
        ref.read(authControllerProvider).user?.id ??
            '';
    _composer.clear();
    final ok = await ref
        .read(
          chatRoomControllerProvider(
            widget.chatId,
          ).notifier,
        )
        .send(body, myId);
    if (!ok && mounted) {
      _composer.text = body;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Message failed to send. Try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      chatRoomControllerProvider(widget.chatId),
    );
    final myId =
        ref.watch(authControllerProvider).user?.id;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Small group icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(
                  AppRadius.sm,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                (widget.title ?? 'C')
                    .substring(0, 1)
                    .toUpperCase(),
                style: text.labelLarge?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                widget.title ?? 'Chat',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages
            Expanded(
              child: state.loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : state.messages.isEmpty
                      ? _EmptyChatHint(scheme: scheme)
                      : ListView.builder(
                          reverse: true,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          itemCount:
                              state.messages.length,
                          itemBuilder: (context, i) {
                            final msg = state.messages[
                              state.messages.length -
                                  1 -
                                  i
                            ];
                            return ChatBubble(
                              body: msg.body,
                              isMine:
                                  msg.senderId ==
                                  myId,
                              pending: msg.id
                                  .startsWith(
                                    'local-',
                                  ),
                            );
                          },
                        ),
            ),
            // Composer
            ChatComposer(
              controller: _composer,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChatHint extends StatelessWidget {
  const _EmptyChatHint({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: scheme.primaryContainer
                    .withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_rounded,
                size: 28,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Start the conversation',
              style: text.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Be the first to say hello!',
              style: text.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
