import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/chats/data/chats_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final AutoDisposeFutureProvider<List<ChatResponse>> chatDirectoryProvider =
    FutureProvider.autoDispose(
      (ref) => ref.watch(chatsRepositoryProvider).directory(),
    );

/// Community chat directory (J3, spec §12.4): browse → join → post.
/// Tapping a chat joins it (idempotent) and opens the room — ≤3 taps.
class ChatDirectoryList extends ConsumerWidget {
  const ChatDirectoryList({super.key});

  static const _visibilityLabels = <ChatVisibility, String>{
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
      loading: () => ListView(
        children: const [
          ListRowSkeleton(),
          ListRowSkeleton(),
          ListRowSkeleton(),
        ],
      ),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: "Couldn't load the directory",
        body: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(chatDirectoryProvider),
      ),
      data: (chats) => chats.isEmpty
          ? const EmptyState(
              icon: Icons.forum_outlined,
              title: 'No groups yet',
              body: 'Groups for majors and interests will appear here.',
            )
          : RefreshIndicator(
              onRefresh: () => ref.refresh(chatDirectoryProvider.future),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(context.tokens.space4),
                itemCount: chats.length,
                separatorBuilder: (_, _) =>
                    SizedBox(height: context.tokens.space2),
                itemBuilder: (context, i) {
                  final chat = chats[i];
                  return _GroupCard(
                    chat: chat,
                    visibilityLabel:
                        _visibilityLabels[chat.visibility] ?? 'Open',
                    onTap: () => _openChat(context, ref, chat),
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
    required this.visibilityLabel,
    required this.onTap,
  });

  final ChatResponse chat;
  final String visibilityLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return MergeSemantics(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(tokens.space3),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: tokens.brSm,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    chat.name.isEmpty ? '#' : chat.name[0].toUpperCase(),
                    style: context.text.titleMedium?.copyWith(
                      color: colors.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: tokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleSmall,
                      ),
                      SizedBox(height: tokens.space1),
                      Text(
                        chat.description?.isNotEmpty ?? false
                            ? chat.description!
                            : '$visibilityLabel group',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: tokens.space2),
                Text(
                  '${chat.memberCount} members',
                  style: context.text.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
