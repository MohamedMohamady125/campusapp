import 'package:campusconnect/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// Community chats (J3 entry point). Directory lands in M7 UI work.
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: const EmptyState(
        icon: Icons.forum_outlined,
        title: 'Join the conversation',
        message: 'Browse the directory and join groups for your major.',
        actionLabel: 'Browse directory',
      ),
    );
  }
}
