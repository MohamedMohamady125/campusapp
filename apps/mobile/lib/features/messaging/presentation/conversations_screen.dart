import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:campusconnect/shared/widgets/empty_state.dart';
import 'package:campusconnect/shared/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final AutoDisposeFutureProvider<List<ConversationResponse>>
conversationsProvider = FutureProvider.autoDispose(
  (ref) => ref
      .watch(conversationsRepositoryProvider)
      .fetchConversations(),
);

/// Inbox of 1:1 conversations (M5, spec §6.4) — the
/// "Messages" tab inside the Chats area.
class ConversationsList extends ConsumerWidget {
  const ConversationsList({super.key});

  static const _contextIcons =
      <ConversationContext, IconData>{
    ConversationContext.listing:
        Icons.storefront_outlined,
    ConversationContext.tutoring:
        Icons.school_outlined,
    ConversationContext.direct: Icons.person_outline,
  };

  static const _contextLabels =
      <ConversationContext, String>{
    ConversationContext.listing: 'Marketplace',
    ConversationContext.tutoring: 'Tutoring',
    ConversationContext.direct: 'Direct',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations =
        ref.watch(conversationsProvider);
    final myId =
        ref.watch(authControllerProvider).user?.id;

    return conversations.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not load messages',
        message:
            'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: () =>
            ref.invalidate(conversationsProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'No messages yet',
            message:
                'Message a seller or tutor to start '
                'a conversation.',
            actionLabel: 'Browse the marketplace',
            onAction: () => context.go('/market'),
          );
        }
        return RefreshIndicator(
          onRefresh: () =>
              ref.refresh(conversationsProvider.future),
          child: ListView.separated(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
            ),
            itemCount: items.length,
            separatorBuilder: (_, _) =>
                const Divider(
              indent: 76, // avatar + spacing
              height: 1,
            ),
            itemBuilder: (context, i) {
              final convo = items[i];
              final other =
                  convo.participants.firstWhere(
                (p) => p.id != myId,
                orElse: () =>
                    convo.participants.first,
              );
              return FadeSlideIn(
                index: i,
                child: _ConversationTile(
                  convo: convo,
                  other: other,
                  contextIcon:
                      _contextIcons[convo.contextType] ??
                          Icons.person_outline,
                  contextLabel:
                      _contextLabels[convo.contextType] ??
                          'Chat',
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.convo,
    required this.other,
    required this.contextIcon,
    required this.contextLabel,
  });

  final ConversationResponse convo;
  final UserPublicResponse other;
  final IconData contextIcon;
  final String contextLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return PressableScale(
      onTap: () => context.go(
        '/chats/conversation/${convo.id}',
        extra: other.displayName,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Avatar with context badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      scheme.primaryContainer,
                  foregroundColor:
                      scheme.onPrimaryContainer,
                  child: Text(
                    other.displayName.isEmpty
                        ? '?'
                        : other.displayName[0]
                            .toUpperCase(),
                    style: text.titleMedium?.copyWith(
                      color:
                          scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color:
                          scheme.secondaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: scheme.surface,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      contextIcon,
                      size: 10,
                      color: scheme
                          .onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            // Name + last message preview
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    other.displayName,
                    style: text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: AppSpacing.xs,
                  ),
                  Text(
                    contextLabel,
                    style: text.bodySmall?.copyWith(
                      color:
                          scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
