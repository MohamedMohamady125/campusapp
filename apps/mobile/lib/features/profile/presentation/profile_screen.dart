import 'dart:async' show unawaited;

import 'package:campusconnect/core/legal.dart';
import 'package:campusconnect/core/theme_mode_provider.dart';
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
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Edit profile'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go('/profile/edit'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: tokens.space3),
                Card(
                  child: Column(
                    children: [
                      // QA M-06: the greyed Notifications row looked broken.
                      // There are no per-type prefs yet — the bell in every
                      // app bar is the whole story, so the row is gone.
                      // QA S-05: Appearance is a real picker now.
                      ListTile(
                        leading: const Icon(Icons.brightness_6_outlined),
                        title: const Text('Appearance'),
                        subtitle: Text(
                          _themeModeLabel(ref.watch(themeModeProvider)),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _pickThemeMode(context, ref),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: const Text('Terms of Service'),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () => unawaited(openLegalUrl(kTermsUrl)),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text('Privacy Policy'),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () => unawaited(openLegalUrl(kPrivacyUrl)),
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
                    // QA S-03: signing out from a list tap is too easy to
                    // fat-finger — confirm first.
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Sign out?'),
                          content: const Text(
                            "You'll need your password to sign back in.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('Stay signed in'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: const Text('Sign out'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed ?? false) {
                        await ref
                            .read(authControllerProvider.notifier)
                            .logOut();
                      }
                    },
                  ),
                ),
                SizedBox(height: tokens.space6),
              ],
            ),
    );
  }
}

String _themeModeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.light => 'Light',
  ThemeMode.dark => 'Dark',
  ThemeMode.system => 'Match device',
};

/// Appearance picker (QA S-05): Light / Dark / Match device, persisted
/// locally via [themeModeProvider].
void _pickThemeMode(BuildContext context, WidgetRef ref) {
  final current = ref.read(themeModeProvider);
  unawaited(
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in const [
              ThemeMode.light,
              ThemeMode.dark,
              ThemeMode.system,
            ])
              ListTile(
                leading: Icon(switch (mode) {
                  ThemeMode.light => Icons.light_mode_outlined,
                  ThemeMode.dark => Icons.dark_mode_outlined,
                  ThemeMode.system => Icons.phone_iphone_outlined,
                }),
                title: Text(_themeModeLabel(mode)),
                trailing: mode == current
                    ? Icon(
                        Icons.check_rounded,
                        color: Theme.of(sheetContext).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  unawaited(
                    ref.read(themeModeProvider.notifier).set(mode),
                  );
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    ),
  );
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
