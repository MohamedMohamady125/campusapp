import 'package:campusconnect/features/chats/presentation/chat_directory.dart';
import 'package:campusconnect/features/messaging/presentation/conversations_screen.dart';
import 'package:flutter/material.dart';

/// Chats area: "Messages" (1:1 conversations, M5) and "Groups"
/// (community chat directory, M7 / journey J3).
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
            ChatDirectoryList(),
          ],
        ),
      ),
    );
  }
}
