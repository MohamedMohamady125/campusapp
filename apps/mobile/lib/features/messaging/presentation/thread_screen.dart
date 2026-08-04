import 'dart:async';

import 'package:campusconnect/design_system/components/composer.dart';
import 'package:campusconnect/design_system/components/message_bubble.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/messaging/presentation/thread_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One conversation thread (spec §12.4): reversed message list with
/// spec §10.5 bubbles, optimistic send + input restore on rollback,
/// smart polling (§7.4).
class ThreadScreen extends ConsumerStatefulWidget {
  const ThreadScreen({required this.conversationId, this.title, super.key});

  final String conversationId;
  final String? title;

  @override
  ConsumerState<ThreadScreen> createState() => _ThreadScreenState();
}

/// `3:07 PM`-style label without pulling in intl.
String _timeLabel(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${t.hour < 12 ? 'AM' : 'PM'}';
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

  Future<void> _send(String body) async {
    final myId = ref.read(authControllerProvider).user?.id ?? '';
    final ok = await ref
        .read(threadControllerProvider(widget.conversationId).notifier)
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
    final state = ref.watch(threadControllerProvider(widget.conversationId));
    final myId = ref.watch(authControllerProvider).user?.id;
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Conversation')),
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
                            showTimestamp: pending || i == 0,
                            timestamp: _timeLabel(msg.createdAt.toLocal()),
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
