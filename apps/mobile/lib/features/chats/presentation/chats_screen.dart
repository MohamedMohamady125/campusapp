import 'package:campusconnect/features/messaging/presentation/conversations_screen.dart';
import 'package:campusconnect/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// Chats area: "Messages" (1:1 conversations, M5) and "Groups"
/// (community chat directory, lands with the M7 UI).
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Messages'),
              Tab(text: 'Groups'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ConversationsList(),
            EmptyState(
              icon: Icons.forum_outlined,
              title: 'Join the conversation',
              message: 'Browse the directory and join groups for your major.',
              actionLabel: 'Browse directory',
            ),
          ],
        ),
      ),
    );
  }
}
