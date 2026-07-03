import 'dart:async';

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/messaging/presentation/thread_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One conversation thread (M5, spec §6.4): reversed message list,
/// composer with optimistic send + rollback, smart polling (§7.4).
class ThreadScreen extends ConsumerStatefulWidget {
  const ThreadScreen({required this.conversationId, this.title, super.key});

  final String conversationId;
  final String? title;

  @override
  ConsumerState<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends ConsumerState<ThreadScreen> {
  final _composer = TextEditingController();
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 5), (_) {
      ref
          .read(threadControllerProvider(widget.conversationId).notifier)
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
        .read(threadControllerProvider(widget.conversationId).notifier)
        .send(body, myId);
    if (!ok && mounted) {
      _composer.text = body; // restore input on rollback (§6.3)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message failed to send. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(threadControllerProvider(widget.conversationId));
    final myId = ref.watch(authControllerProvider).user?.id;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Conversation')),
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
                        return _MessageBubble(
                          message: msg,
                          isMine: msg.senderId == myId,
                        );
                      },
                    ),
            ),
            _Composer(controller: _composer, onSend: _send),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final AppSchemasConversationMessageResponse message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMine ? scheme.primaryContainer : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Text(
          message.body,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isMine ? scheme.onPrimaryContainer : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Message…'),
              onSubmitted: (_) => onSend().ignore(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton.filled(
            tooltip: 'Send',
            onPressed: () => onSend().ignore(),
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
