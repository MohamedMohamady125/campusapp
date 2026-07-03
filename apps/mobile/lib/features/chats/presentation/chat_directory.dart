import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/features/chats/data/chats_repository.dart';
import 'package:campusconnect/shared/widgets/empty_state.dart';
import 'package:campusconnect/shared/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final AutoDisposeFutureProvider<List<ChatResponse>> chatDirectoryProvider =
    FutureProvider.autoDispose(
      (ref) => ref.watch(chatsRepositoryProvider).directory(),
    );

/// Community chat directory (J3, spec §6.4): browse → join → post.
/// Tapping a chat joins it (idempotent) and opens the room — ≤3 taps.
class ChatDirectoryList extends ConsumerWidget {
  const ChatDirectoryList({super.key});

  static const _visibilityIcons = <ChatVisibility, IconData>{
    ChatVisibility.open: Icons.public,
    ChatVisibility.request: Icons.lock_open,
    ChatVisibility.private: Icons.lock_outline,
  };

  Future<void> _openChat(
    BuildContext context,
    WidgetRef ref,
    ChatResponse chat,
  ) async {
    try {
      await ref.read(chatsRepositoryProvider).join(chat.id);
      if (context.mounted) {
        context.go('/chats/room/${chat.id}', extra: chat.name);
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directory = ref.watch(chatDirectoryProvider);
    return directory.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not load the directory',
        message: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(chatDirectoryProvider),
      ),
      data: (chats) => chats.isEmpty
          ? const EmptyState(
              icon: Icons.forum_outlined,
              title: 'No groups yet',
              message: 'Groups for majors and interests will appear here.',
            )
          : RefreshIndicator(
              onRefresh: () => ref.refresh(chatDirectoryProvider.future),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: chats.length,
                itemBuilder: (context, i) {
                  final chat = chats[i];
                  final scheme = Theme.of(context).colorScheme;
                  return FadeSlideIn(
                    index: i,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        foregroundColor: scheme.onPrimaryContainer,
                        child: Text(
                          chat.name.isEmpty ? '#' : chat.name[0].toUpperCase(),
                        ),
                      ),
                      title: Text(chat.name),
                      subtitle: Text(
                        chat.description?.isNotEmpty ?? false
                            ? chat.description!
                            : '${chat.memberCount}/${chat.memberCap} members',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        _visibilityIcons[chat.visibility] ?? Icons.public,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                      onTap: () => _openChat(context, ref, chat),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
