import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/features/chats/presentation/chat_directory.dart';
import 'package:campusconnect/features/messaging/presentation/conversations_screen.dart';
import 'package:campusconnect/features/notifications/presentation/notification_bell.dart';

/// Chats area (spec §12.4): "Messages" (1:1 conversations) and
/// "Groups" (community chat directory, J3).
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          actions: const [NotificationBell()],
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
