import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/chats/data/chats_repository.dart';
import 'package:campusconnect/shared/widgets/empty_state.dart';
import 'package:campusconnect/shared/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final AutoDisposeFutureProvider<List<ChatResponse>>
chatDirectoryProvider = FutureProvider.autoDispose(
  (ref) =>
      ref.watch(chatsRepositoryProvider).directory(),
);

/// Community chat directory (J3, spec §6.4):
/// browse → join → post. Tapping a chat joins it
/// (idempotent) and opens the room — <=3 taps.
class ChatDirectoryList extends ConsumerWidget {
  const ChatDirectoryList({super.key});

  static const _visibilityIcons =
      <ChatVisibility, IconData>{
    ChatVisibility.open: Icons.public,
    ChatVisibility.request: Icons.lock_open,
    ChatVisibility.private: Icons.lock_outline,
  };

  static const _visibilityLabels =
      <ChatVisibility, String>{
    ChatVisibility.open: 'Open',
    ChatVisibility.request: 'Request to join',
    ChatVisibility.private: 'Private',
  };

  Future<void> _openChat(
    BuildContext context,
    WidgetRef ref,
    ChatResponse chat,
  ) async {
    try {
      await ref
          .read(chatsRepositoryProvider)
          .join(chat.id);
      if (context.mounted) {
        context.go(
          '/chats/room/${chat.id}',
          extra: chat.name,
        );
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directory =
        ref.watch(chatDirectoryProvider);
    return directory.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not load the directory',
        message:
            'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: () =>
            ref.invalidate(chatDirectoryProvider),
      ),
      data: (chats) => chats.isEmpty
          ? const EmptyState(
              icon: Icons.forum_outlined,
              title: 'No groups yet',
              message:
                  'Groups for majors and interests '
                  'will appear here.',
            )
          : RefreshIndicator(
              onRefresh: () => ref.refresh(
                chatDirectoryProvider.future,
              ),
              child: ListView.separated(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(
                  AppSpacing.lg,
                ),
                itemCount: chats.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(
                  height: AppSpacing.md,
                ),
                itemBuilder: (context, i) {
                  final chat = chats[i];
                  return FadeSlideIn(
                    index: i,
                    child: _GroupCard(
                      chat: chat,
                      visibilityIcon:
                          _visibilityIcons[
                              chat.visibility] ??
                              Icons.public,
                      visibilityLabel:
                          _visibilityLabels[
                              chat.visibility] ??
                              'Open',
                      onTap: () => _openChat(
                        context,
                        ref,
                        chat,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.chat,
    required this.visibilityIcon,
    required this.visibilityLabel,
    required this.onTap,
  });

  final ChatResponse chat;
  final IconData visibilityIcon;
  final String visibilityLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius:
              BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: scheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            // Group avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primaryContainer,
                    scheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  AppRadius.md,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                chat.name.isEmpty
                    ? '#'
                    : chat.name[0].toUpperCase(),
                style: text.titleLarge?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Name + description
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: AppSpacing.xs,
                  ),
                  if (chat.description?.isNotEmpty ??
                      false)
                    Text(
                      chat.description!,
                      style: text.bodySmall?.copyWith(
                        color:
                            scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      '${chat.memberCount}'
                      '/${chat.memberCap} members',
                      style: text.bodySmall?.copyWith(
                        color:
                            scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Visibility + members column
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Icon(
                  visibilityIcon,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(
                  height: AppSpacing.xs,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 14,
                      color:
                          scheme.onSurfaceVariant,
                    ),
                    const SizedBox(
                      width: AppSpacing.xs,
                    ),
                    Text(
                      '${chat.memberCount}',
                      style:
                          text.labelSmall?.copyWith(
                        color:
                            scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
