import 'dart:async';

import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/messaging/presentation/thread_controller.dart';
import 'package:campusconnect/shared/widgets/chat_ui.dart';
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
                        return ChatBubble(
                          body: msg.body,
                          isMine: msg.senderId == myId,
                          pending: msg.id.startsWith('local-'),
                        );
                      },
                    ),
            ),
            ChatComposer(controller: _composer, onSend: _send),
          ],
        ),
      ),
    );
  }
}
