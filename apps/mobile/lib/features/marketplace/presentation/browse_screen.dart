import 'package:campusconnect/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// Marketplace browse (J1 entry point). Listing feed lands in M4 UI work.
class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: const EmptyState(
        icon: Icons.storefront_outlined,
        title: 'No listings yet',
        message:
            'Be the first to post — snap a photo and sell in under a minute.',
        actionLabel: 'Post the first one',
      ),
    );
  }
}
