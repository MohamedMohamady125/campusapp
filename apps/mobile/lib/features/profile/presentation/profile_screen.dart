import 'package:campusconnect/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// Profile & settings. Auth flow wires in during M2 UI work.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const EmptyState(
        icon: Icons.person_outline,
        title: 'Sign in with your campus email',
        message: 'One verified .edu identity across all three journeys.',
        actionLabel: 'Sign in',
      ),
    );
  }
}
