import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/chats/presentation/chat_directory.dart';
import 'package:campusconnect/features/messaging/presentation/conversations_screen.dart';
import 'package:flutter/material.dart';

/// Chats area: "Messages" (1:1 conversations, M5) and
/// "Groups" (community chat directory, M7 / journey J3).
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: scheme.onSurface,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('Messages'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 18,
                      color: scheme.onSurface,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('Groups'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ConversationsList(),
            ChatDirectoryList(),
          ],
        ),
      ),
    );
  }
}
