import 'package:campusconnect/core/flags/flags_provider.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_motion.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/auth/presentation/forgot_password_screen.dart';
import 'package:campusconnect/features/auth/presentation/login_screen.dart';
import 'package:campusconnect/features/auth/presentation/register_screen.dart';
import 'package:campusconnect/features/auth/presentation/verify_screen.dart';
import 'package:campusconnect/features/chats/presentation/chat_room_screen.dart';
import 'package:campusconnect/features/chats/presentation/chats_screen.dart';
import 'package:campusconnect/features/food_runs/presentation/create_run_screen.dart';
import 'package:campusconnect/features/food_runs/presentation/my_runs_screen.dart';
import 'package:campusconnect/features/food_runs/presentation/payment_methods_screen.dart';
import 'package:campusconnect/features/food_runs/presentation/run_detail_screen.dart';
import 'package:campusconnect/features/food_runs/presentation/runs_feed_screen.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_screen.dart';
import 'package:campusconnect/features/marketplace/presentation/edit_listing_screen.dart';
import 'package:campusconnect/features/marketplace/presentation/listing_detail_screen.dart';
import 'package:campusconnect/features/marketplace/presentation/my_listings_screen.dart';
import 'package:campusconnect/features/marketplace/presentation/sell_screen.dart';
import 'package:campusconnect/features/messaging/presentation/thread_screen.dart';
import 'package:campusconnect/features/notifications/presentation/notifications_screen.dart';
import 'package:campusconnect/features/profile/presentation/edit_profile_screen.dart';
import 'package:campusconnect/features/profile/presentation/profile_screen.dart';
import 'package:campusconnect/features/tutoring/presentation/tutor_search_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Shared fade+slide-up transition for pushed screens (300ms, M3 decelerate).
/// Respects reduce-motion — falls back to instant swap.
CustomTransitionPage<void> _slidePage({
  required Widget child,
  required GoRouterState state,
}) => CustomTransitionPage<void>(
  key: state.pageKey,
  child: child,
  reverseTransitionDuration: AppMotion.micro,
  transitionsBuilder: (context, animation, _, child) {
    if (MediaQuery.of(context).disableAnimations) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.decelerate,
      reverseCurve: AppMotion.accelerate,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  },
);

const _authLocations = {'/login', '/register', '/verify', '/forgot-password'};

/// Location prefix → the flag that must be on to visit it. Runs and
/// profile are always reachable.
const _flaggedPrefixes = <String, String>{
  '/market': kTabMarketplace,
  // My listings is marketplace UI living under /profile — gate it with the
  // same flag so no Sell entry point survives while the tab is off (QA M-07).
  '/profile/my-listings': kTabMarketplace,
  '/tutors': kTabTutoring,
  '/chats': kTabChats,
};

/// App routes: auth screens outside the shell, bottom-nav shell with Food
/// Runs as the hero tab (runs-first launch). Branches stay static; the
/// NavigationBar shows only flag-enabled tabs, and a redirect guard keeps
/// hidden tabs unreachable by URL too.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ValueNotifier(ref.read(authControllerProvider).status);
  ref
    ..onDispose(auth.dispose)
    ..listen(
      authControllerProvider,
      (_, next) => auth.value = next.status,
    );

  return GoRouter(
    initialLocation: '/runs',
    refreshListenable: auth,
    redirect: (context, state) {
      final status = auth.value;
      final onAuthScreen = _authLocations.contains(state.matchedLocation);
      if (status == AuthStatus.unknown) return null; // bootstrap in flight
      if (status == AuthStatus.unauthenticated) {
        return onAuthScreen ? null : '/login';
      }
      if (onAuthScreen) return '/runs';
      // Flag-hidden tabs bounce to the hero tab. Read (not watch) so the
      // router itself never rebuilds on a flag flip.
      final flags = ref.read(flagsProvider);
      for (final entry in _flaggedPrefixes.entries) {
        if (state.matchedLocation.startsWith(entry.key) &&
            !flags.contains(entry.value)) {
          return '/runs';
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/verify',
        builder: (_, state) => VerifyScreen(email: state.extra! as String),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      // Pushed over the shell from any tab's bell (Sprint 6).
      GoRoute(
        path: '/notifications',
        pageBuilder: (_, state) =>
            _slidePage(state: state, child: const NotificationsScreen()),
      ),
      // Standalone 1:1 thread, pushed over the shell. Lives OUTSIDE the
      // flag-gated /chats prefix so run-order chats (and DM notification
      // deep links) work while the Chats tab is hidden for launch.
      GoRoute(
        path: '/messages/:id',
        pageBuilder: (_, state) => _slidePage(
          state: state,
          child: ThreadScreen(
            conversationId: state.pathParameters['id']!,
            title: state.extra as String?,
          ),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/runs',
                builder: (_, _) => const RunsFeedScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    pageBuilder: (_, state) => _slidePage(
                      state: state,
                      child: const CreateRunScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'run/:id',
                    pageBuilder: (_, state) => _slidePage(
                      state: state,
                      child: RunDetailScreen(
                        runId: state.pathParameters['id']!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/market',
                builder: (_, _) => const BrowseScreen(),
                routes: [
                  GoRoute(
                    path: 'sell',
                    pageBuilder: (_, state) => _slidePage(
                      state: state,
                      child: const SellScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'listing/:id',
                    pageBuilder: (_, state) => _slidePage(
                      state: state,
                      child: ListingDetailScreen(
                        listingId: state.pathParameters['id']!,
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        pageBuilder: (_, state) => _slidePage(
                          state: state,
                          child: EditListingScreen(
                            listingId: state.pathParameters['id']!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tutors',
                builder: (_, _) => const TutorSearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chats',
                builder: (_, _) => const ChatsScreen(),
                routes: [
                  GoRoute(
                    path: 'conversation/:id',
                    pageBuilder: (_, state) => _slidePage(
                      state: state,
                      child: ThreadScreen(
                        conversationId: state.pathParameters['id']!,
                        title: state.extra as String?,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'room/:id',
                    pageBuilder: (_, state) => _slidePage(
                      state: state,
                      child: ChatRoomScreen(
                        chatId: state.pathParameters['id']!,
                        title: state.extra as String?,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'my-listings',
                    builder: (_, _) => const MyListingsScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (_, state) => _slidePage(
                      state: state,
                      child: const EditProfileScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'payment-methods',
                    pageBuilder: (_, state) => _slidePage(
                      state: state,
                      child: const PaymentMethodsScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Appended after profile so earlier branch indices stay stable;
          // the visible tab order is defined in _AppShell._tabs.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-runs',
                builder: (_, _) => const MyRunsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// One visible tab: which branch it maps to + how it renders.
class _TabSpec {
  const _TabSpec({
    required this.branchIndex,
    required this.destination,
  });

  final int branchIndex;
  final NavigationDestination destination;
}

class _AppShell extends ConsumerWidget {
  const _AppShell({required this.shell});

  final StatefulNavigationShell shell;

  /// Builds the visible tabs from the enabled flags. Branch order is
  /// fixed (runs=0, market=1, tutors=2, chats=3, profile=4, my-runs=5);
  /// visibility is flag-driven so hidden tabs return with a DB row flip.
  static List<_TabSpec> _tabs(Set<String> flags) => [
    const _TabSpec(
      branchIndex: 0,
      destination: NavigationDestination(
        icon: Icon(Icons.directions_run_outlined),
        selectedIcon: Icon(Icons.directions_run),
        label: 'Runs',
      ),
    ),
    const _TabSpec(
      branchIndex: 5,
      destination: NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: 'My Runs',
      ),
    ),
    if (flags.contains(kTabMarketplace))
      const _TabSpec(
        branchIndex: 1,
        destination: NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront),
          label: 'Market',
        ),
      ),
    if (flags.contains(kTabTutoring))
      const _TabSpec(
        branchIndex: 2,
        destination: NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: 'Tutors',
        ),
      ),
    if (flags.contains(kTabChats))
      const _TabSpec(
        branchIndex: 3,
        destination: NavigationDestination(
          icon: Icon(Icons.forum_outlined),
          selectedIcon: Icon(Icons.forum),
          label: 'Chats',
        ),
      ),
    const _TabSpec(
      branchIndex: 4,
      destination: NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = _tabs(ref.watch(flagsProvider));
    // If the active branch was just flag-hidden, highlight the hero tab.
    final visibleIndex = tabs
        .indexWhere((t) => t.branchIndex == shell.currentIndex)
        .clamp(0, tabs.length - 1);

    return Scaffold(
      body: shell,
      // 1px outlineVariant top border — Fifty Free hairline (#EEF1F2 via
      // the scheme) in place of elevation.
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: visibleIndex,
          onDestinationSelected: (i) {
            final branch = tabs[i].branchIndex;
            shell.goBranch(
              branch,
              initialLocation: branch == shell.currentIndex,
            );
          },
          destinations: [for (final tab in tabs) tab.destination],
        ),
      ),
    );
  }
}
