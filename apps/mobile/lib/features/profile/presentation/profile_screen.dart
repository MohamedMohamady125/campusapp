import 'package:campusconnect/design_system/components/reputation_chip.dart';
import 'package:campusconnect/design_system/components/verified_avatar.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Profile (spec §12.7): one identity, one reputation. Verified avatar,
/// reputation with count (never a bare average, spec §4.2), account
/// actions in sentence case (spec §14.1).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final tokens = context.tokens;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(tokens.space4),
              children: [
                Column(
                  children: [
                    VerifiedAvatar(
                      name: user.displayName,
                      size: AvatarSize.xl,
                    ),
                    SizedBox(height: tokens.space3),
                    Text(
                      user.displayName,
                      style: context.text.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: tokens.space1),
                    Text(
                      'Verified student · ${user.email}',
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: tokens.space2),
                    ReputationChip(
                      rating: user.ratingCount > 0
                          ? user.reputationScore.toDouble()
                          : null,
                      ratingCount: user.ratingCount,
                      variant: ReputationVariant.detailed,
                    ),
                  ],
                ),
                SizedBox(height: tokens.space5),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.storefront_outlined),
                        title: const Text('My listings'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go('/profile/my-listings'),
                      ),
                      const Divider(height: 1, indent: 56),
                      const ListTile(
                        leading: Icon(Icons.person_outline),
                        title: Text('Edit profile'),
                        trailing: Icon(Icons.chevron_right),
                        // Editing lands with a later milestone.
                        enabled: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: tokens.space3),
                Card(
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.notifications_outlined),
                        title: Text('Notifications'),
                        trailing: Icon(Icons.chevron_right),
                        enabled: false,
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.brightness_6_outlined),
                        title: const Text('Appearance'),
                        subtitle: const Text('Follows your device setting'),
                        trailing: Icon(
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: tokens.space3),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.logout, color: colors.error),
                    title: Text(
                      'Sign out',
                      style: TextStyle(color: colors.error),
                    ),
                    onTap: () =>
                        ref.read(authControllerProvider.notifier).logOut(),
                  ),
                ),
                SizedBox(height: tokens.space6),
              ],
            ),
    );
  }
}
