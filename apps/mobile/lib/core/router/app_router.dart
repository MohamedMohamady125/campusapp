import 'package:campusconnect/core/flags/flags_provider.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/auth/presentation/login_screen.dart';
import 'package:campusconnect/features/auth/presentation/register_screen.dart';
import 'package:campusconnect/features/auth/presentation/verify_screen.dart';
import 'package:campusconnect/features/chats/presentation/chat_room_screen.dart';
import 'package:campusconnect/features/chats/presentation/chats_screen.dart';
import 'package:campusconnect/features/food_runs/presentation/create_run_screen.dart';
import 'package:campusconnect/features/food_runs/presentation/run_detail_screen.dart';
import 'package:campusconnect/features/food_runs/presentation/runs_feed_screen.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_screen.dart';
import 'package:campusconnect/features/marketplace/presentation/edit_listing_screen.dart';
import 'package:campusconnect/features/marketplace/presentation/listing_detail_screen.dart';
import 'package:campusconnect/features/marketplace/presentation/my_listings_screen.dart';
import 'package:campusconnect/features/marketplace/presentation/sell_screen.dart';
import 'package:campusconnect/features/messaging/presentation/thread_screen.dart';
import 'package:campusconnect/features/notifications/presentation/notifications_screen.dart';
import 'package:campusconnect/features/profile/presentation/profile_screen.dart';
import 'package:campusconnect/features/tutoring/presentation/tutor_search_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _authLocations = {'/login', '/register', '/verify'};

/// Location prefix → the flag that must be on to visit it. Runs and
/// profile are always reachable.
const _flaggedPrefixes = <String, String>{
  '/market': kTabMarketplace,
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
      // Pushed over the shell from any tab's bell (Sprint 6).
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsScreen(),
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
                    builder: (_, _) => const CreateRunScreen(),
                  ),
                  GoRoute(
                    path: 'run/:id',
                    builder: (_, state) => RunDetailScreen(
                      runId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'chat',
                        builder: (_, state) {
                          final (conversationId, title) =
                              state.extra! as (String, String?);
                          return ThreadScreen(
                            conversationId: conversationId,
                            title: title,
                          );
                        },
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
                path: '/market',
                builder: (_, _) => const BrowseScreen(),
                routes: [
                  GoRoute(
                    path: 'sell',
                    builder: (_, _) => const SellScreen(),
                  ),
                  GoRoute(
                    path: 'listing/:id',
                    builder: (_, state) => ListingDetailScreen(
                      listingId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (_, state) => EditListingScreen(
                          listingId: state.pathParameters['id']!,
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
                    builder: (_, state) => ThreadScreen(
                      conversationId: state.pathParameters['id']!,
                      title: state.extra as String?,
                    ),
                  ),
                  GoRoute(
                    path: 'room/:id',
                    builder: (_, state) => ChatRoomScreen(
                      chatId: state.pathParameters['id']!,
                      title: state.extra as String?,
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
                ],
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
  /// fixed (runs=0, market=1, tutors=2, chats=3, profile=4); visibility
  /// is flag-driven so hidden tabs return with a DB row flip.
  static List<_TabSpec> _tabs(Set<String> flags) => [
    const _TabSpec(
      branchIndex: 0,
      destination: NavigationDestination(
        icon: Icon(Icons.directions_run_outlined),
        selectedIcon: Icon(Icons.directions_run),
        label: 'Runs',
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
