import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Profile: shows the signed-in user (one identity,
/// one reputation -- spec SS1) and the sign-out action.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                // -- Gradient header with avatar --
                _ProfileHeader(
                  displayName: user.displayName,
                  email: user.email,
                  reputationScore: user.reputationScore.toDouble(),
                  ratingCount: user.ratingCount,
                  scheme: scheme,
                  tt: tt,
                ),
                const SizedBox(height: AppSpacing.xl),

                // -- Stats row --
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: _StatsRow(
                    reputationScore: user.reputationScore.toDouble(),
                    ratingCount: user.ratingCount,
                    scheme: scheme,
                    tt: tt,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // -- Account section --
                _SectionHeader(title: 'Account', tt: tt),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Card(
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.storefront_rounded,
                          iconColor: scheme.primary,
                          title: 'My Listings',
                          subtitle: 'Manage your posts',
                          onTap: () => context.go(
                            '/profile/my-listings',
                          ),
                          scheme: scheme,
                        ),
                        Divider(
                          height: 1,
                          indent: AppSpacing.xxxl + AppSpacing.lg,
                          color: scheme.outlineVariant
                              .withAlpha(100),
                        ),
                        _SettingsTile(
                          icon: Icons.person_outline_rounded,
                          iconColor: scheme.primary,
                          title: 'Edit Profile',
                          subtitle:
                              'Name, major, bio & avatar',
                          onTap: () {},
                          scheme: scheme,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // -- Preferences section --
                _SectionHeader(
                  title: 'Preferences',
                  tt: tt,
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Card(
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon:
                              Icons.notifications_outlined,
                          iconColor: scheme.tertiary,
                          title: 'Notifications',
                          subtitle: 'Manage alerts',
                          onTap: () {},
                          scheme: scheme,
                        ),
                        Divider(
                          height: 1,
                          indent: AppSpacing.xxxl +
                              AppSpacing.lg,
                          color: scheme.outlineVariant
                              .withAlpha(100),
                        ),
                        _ThemeToggleTile(scheme: scheme),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // -- Sign out --
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Card(
                    child: _SettingsTile(
                      icon: Icons.logout_rounded,
                      iconColor: scheme.error,
                      title: 'Sign Out',
                      titleColor: scheme.error,
                      onTap: () => ref
                          .read(
                            authControllerProvider.notifier,
                          )
                          .logOut(),
                      scheme: scheme,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
    );
  }
}

// -- Gradient header with large avatar --
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.reputationScore,
    required this.ratingCount,
    required this.scheme,
    required this.tt,
  });

  final String displayName;
  final String email;
  final double reputationScore;
  final int ratingCount;
  final ColorScheme scheme;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        top: topPad + AppSpacing.xl,
        bottom: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            scheme.primary.withAlpha(180),
            scheme.tertiary.withAlpha(160),
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withAlpha(200),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 44,
              backgroundColor:
                  Colors.white.withAlpha(230),
              child: Text(
                displayName.isEmpty
                    ? '?'
                    : displayName[0].toUpperCase(),
                style: tt.headlineMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            displayName,
            style: tt.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            email,
            style: tt.bodySmall?.copyWith(
              color: Colors.white.withAlpha(200),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Reputation badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(
                AppRadius.pill,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Color(0xFFFBBF24),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${reputationScore.toStringAsFixed(1)}'
                  '  ($ratingCount ratings)',
                  style: tt.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -- Stats row with 3 columns --
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.reputationScore,
    required this.ratingCount,
    required this.scheme,
    required this.tt,
  });

  final double reputationScore;
  final int ratingCount;
  final ColorScheme scheme;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.sm,
        ),
        child: Row(
          children: [
            _StatItem(
              value:
                  reputationScore.toStringAsFixed(1),
              label: 'Rating',
              icon: Icons.star_rounded,
              iconColor: const Color(0xFFFBBF24),
              tt: tt,
              scheme: scheme,
            ),
            _divider(scheme),
            _StatItem(
              value: '$ratingCount',
              label: 'Reviews',
              icon: Icons.rate_review_outlined,
              iconColor: scheme.tertiary,
              tt: tt,
              scheme: scheme,
            ),
            _divider(scheme),
            _StatItem(
              value: 'New',
              label: 'Member',
              icon: Icons.calendar_today_outlined,
              iconColor: scheme.primary,
              tt: tt,
              scheme: scheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(ColorScheme s) {
    return Container(
      width: 1,
      height: 36,
      color: s.outlineVariant.withAlpha(100),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.tt,
    required this.scheme,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final TextTheme tt;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// -- Section header --
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.tt,
  });

  final String title;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
      ),
      child: Text(
        title.toUpperCase(),
        style: tt.labelMedium?.copyWith(
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// -- Reusable settings tile --
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    required this.scheme,
    this.subtitle,
    this.titleColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(25),
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(
        title,
        style: tt.titleSmall?.copyWith(
          color: titleColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: tt.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: scheme.onSurfaceVariant.withAlpha(150),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
    );
  }
}

// -- Theme toggle tile with switch --
class _ThemeToggleTile extends StatelessWidget {
  const _ThemeToggleTile({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: scheme.tertiary.withAlpha(25),
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
        ),
        child: Icon(
          isDark
              ? Icons.dark_mode_rounded
              : Icons.light_mode_rounded,
          size: 20,
          color: scheme.tertiary,
        ),
      ),
      title: Text(
        'Appearance',
        style: tt.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        isDark ? 'Dark mode' : 'Light mode',
        style: tt.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: scheme.onSurfaceVariant.withAlpha(150),
      ),
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
    );
  }
}
