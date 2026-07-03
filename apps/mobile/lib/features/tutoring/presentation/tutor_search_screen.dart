import 'package:campusconnect/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// Tutor search (J2 entry point). Ranked results land in M6 UI work.
class TutorSearchScreen extends StatelessWidget {
  const TutorSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a tutor')),
      body: const EmptyState(
        icon: Icons.school_outlined,
        title: 'Search by course code',
        message: 'Type a course like CS250 to see ranked peer tutors.',
        actionLabel: 'Search courses',
      ),
    );
  }
}
