import 'dart:async';

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/components/composer.dart';
import 'package:campusconnect/design_system/components/message_bubble.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/food_runs/presentation/spot_image.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:campusconnect/features/messaging/presentation/thread_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Conversation detail (incl. run order context) for the pinned sub-header.
final AutoDisposeFutureProviderFamily<ConversationResponse, String>
conversationDetailProvider = FutureProvider.autoDispose
    .family<ConversationResponse, String>(
      (ref, id) =>
          ref.watch(conversationsRepositoryProvider).fetchConversation(id),
    );

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
    final runContext = ref
        .watch(conversationDetailProvider(widget.conversationId))
        .valueOrNull
        ?.runContext;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Conversation')),
      body: SafeArea(
        child: Column(
          children: [
            // Run chats keep the order + restaurant pinned for both parties.
            if (runContext != null) _RunOrderHeader(context_: runContext),
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
                            // Every message carries its time — no guessing
                            // when something was sent mid-run.
                            showTimestamp: true,
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

/// Always-visible run order summary pinned under the app bar: restaurant
/// photo + name, what was ordered, and where to drop it. Shown identically
/// to the runner and the orderer so the thread never loses its context.
class _RunOrderHeader extends StatelessWidget {
  const _RunOrderHeader({required this.context_});

  final RunChatContext context_;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space4,
        vertical: tokens.space3,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radiusSm),
            child: SizedBox(
              width: 44,
              height: 44,
              child: SpotImage(
                name: context_.spotName,
                imageUrl: context_.spotImageUrl,
                monogramFontSize: 16,
              ),
            ),
          ),
          SizedBox(width: tokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context_.spotName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: tokens.space1 / 2),
                Text(
                  '${context_.orderText} · Drop at ${context_.dropoff}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
