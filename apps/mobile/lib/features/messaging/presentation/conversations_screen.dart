import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/utils/auto_refresh.dart';
import 'package:campusconnect/design_system/components/chat_list_row.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/fade_slide_in.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final AutoDisposeFutureProvider<List<ConversationResponse>>
conversationsProvider = FutureProvider.autoDispose((ref) {
  ref.autoRefresh(); // inbox stays live — new threads appear on their own
  return ref.watch(conversationsRepositoryProvider).fetchConversations();
});

/// Inbox of 1:1 conversations (spec §12.4) — the "Messages" tab inside
/// the Chats area. Rows are the shared [ChatListRow] (spec §10.5).
class ConversationsList extends ConsumerWidget {
  const ConversationsList({super.key});

  static const _contextLabels = <ConversationContext, String>{
    ConversationContext.listing: 'Marketplace',
    ConversationContext.tutoring: 'Tutoring',
    ConversationContext.direct: 'Direct',
    ConversationContext.run: 'Food run',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
    final myId = ref.watch(authControllerProvider).user?.id;

    return conversations.when(
      loading: () => ListView(
        children: const [
          ListRowSkeleton(height: 72),
          ListRowSkeleton(height: 72),
          ListRowSkeleton(height: 72),
        ],
      ),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: "Couldn't load messages",
        body: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(conversationsProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          // Empty-state copy per spec §13.2.
          return EmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'No messages yet',
            body:
                'When you contact a seller or a tutor, '
                'the conversation shows up here.',
            actionLabel: 'Browse the marketplace',
            onAction: () => context.go('/market'),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(conversationsProvider.future),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(indent: 84, height: 1),
            itemBuilder: (context, i) {
              final convo = items[i];
              final other = convo.participants.firstWhere(
                (p) => p.id != myId,
                orElse: () => convo.participants.first,
              );
              return FadeSlideIn(
                index: i,
                child: ChatListRow(
                  name: other.displayName,
                  // API doesn't expose a last-message preview yet; the
                  // context origin is the most useful line we have.
                  preview: _contextLabels[convo.contextType] ?? 'Conversation',
                  onTap: () => context.go(
                    '/chats/conversation/${convo.id}',
                    extra: other.displayName,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
