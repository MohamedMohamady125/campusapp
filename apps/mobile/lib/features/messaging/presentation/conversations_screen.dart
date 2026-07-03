import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:campusconnect/shared/widgets/empty_state.dart';
import 'package:campusconnect/shared/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final AutoDisposeFutureProvider<List<ConversationResponse>>
conversationsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(conversationsRepositoryProvider).fetchConversations(),
);

/// Inbox of 1:1 conversations (M5, spec §6.4) — the "Messages" tab
/// inside the Chats area.
class ConversationsList extends ConsumerWidget {
  const ConversationsList({super.key});

  static const _contextIcons = <ConversationContext, IconData>{
    ConversationContext.listing: Icons.storefront_outlined,
    ConversationContext.tutoring: Icons.school_outlined,
    ConversationContext.direct: Icons.person_outline,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
    final myId = ref.watch(authControllerProvider).user?.id;

    return conversations.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not load messages',
        message: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(conversationsProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'No messages yet',
            message: 'Message a seller or tutor to start a conversation.',
            actionLabel: 'Browse the marketplace',
            onAction: () => context.go('/market'),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(conversationsProvider.future),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final convo = items[i];
              final other = convo.participants.firstWhere(
                (p) => p.id != myId,
                orElse: () => convo.participants.first,
              );
              final scheme = Theme.of(context).colorScheme;
              return FadeSlideIn(
                index: i,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    foregroundColor: scheme.onPrimaryContainer,
                    child: Text(
                      other.displayName.isEmpty
                          ? '?'
                          : other.displayName[0].toUpperCase(),
                    ),
                  ),
                  title: Text(other.displayName),
                  subtitle: Text(convo.contextType.name),
                  trailing: Icon(
                    _contextIcons[convo.contextType] ?? Icons.person_outline,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
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
