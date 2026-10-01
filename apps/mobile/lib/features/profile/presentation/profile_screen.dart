import 'package:campusconnect/design_system/components/reputation_chip.dart';
import 'package:campusconnect/design_system/components/verified_avatar.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/notifications/presentation/notification_bell.dart';
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
      appBar: AppBar(
        title: const Text('Profile'),
        actions: const [NotificationBell()],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(tokens.space4),
              children: [
                _ProfileHeaderCard(
                  displayName: user.displayName,
                  email: user.email,
                  reputationScore: user.reputationScore,
                  ratingCount: user.ratingCount,
                ),
                SizedBox(height: tokens.space5),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.account_balance_wallet_outlined,
                        ),
                        title: const Text('Payment methods'),
                        subtitle: const Text('How runners get paid off-app'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go('/profile/payment-methods'),
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

/// Identity card + real reputation stats (spec §4.2: never a bare average —
/// pair the score with its count). Only RATING and RATINGS are shown; on-time
/// %, per-spot history, etc. have no API yet and are deliberately omitted.
class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.displayName,
    required this.email,
    required this.reputationScore,
    required this.ratingCount,
  });

  final String displayName;
  final String email;
  final num reputationScore;
  final int ratingCount;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final rated = ratingCount > 0;
    return Container(
      padding: EdgeInsets.all(tokens.space5),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: tokens.brLg,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          VerifiedAvatar(name: displayName, size: AvatarSize.xl),
          SizedBox(height: tokens.space3),
          Text(
            displayName,
            style: AppTextStyles.profileName,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.space1),
          Text(
            'Verified student · $email',
            style: context.text.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.space4),
          Divider(height: 1, color: colors.outlineVariant),
          SizedBox(height: tokens.space4),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'RATING',
                  value: rated
                      ? ReputationChip.formatRating(reputationScore.toDouble())
                      : '—',
                  showStar: rated,
                ),
              ),
              Container(width: 1, height: 36, color: colors.outlineVariant),
              Expanded(
                child: _Stat(label: 'RATINGS', value: '$ratingCount'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single label-over-number stat cell for the profile header.
class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.showStar = false,
  });

  final String label;
  final String value;
  final bool showStar;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showStar) ...[
              Icon(Icons.star_rounded, size: 22, color: tokens.ratingStar),
              SizedBox(width: tokens.space1),
            ],
            Text(value, style: AppTextStyles.stat),
          ],
        ),
        SizedBox(height: tokens.space1),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }
}
