import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/auth/presentation/login_screen.dart';
import 'package:campusconnect/features/auth/presentation/register_screen.dart';
import 'package:campusconnect/features/auth/presentation/verify_screen.dart';
import 'package:campusconnect/features/chats/presentation/chats_screen.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_screen.dart';
import 'package:campusconnect/features/marketplace/presentation/listing_detail_screen.dart';
import 'package:campusconnect/features/marketplace/presentation/sell_screen.dart';
import 'package:campusconnect/features/profile/presentation/profile_screen.dart';
import 'package:campusconnect/features/tutoring/presentation/tutor_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _authLocations = {'/login', '/register', '/verify'};

/// App routes: auth screens outside the shell, bottom-nav shell for the
/// 3 core areas + profile (spec §6.3). Guarded per M2 acceptance —
/// unauthenticated users are redirected to /login.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ValueNotifier(ref.read(authControllerProvider).status);
  ref
    ..onDispose(auth.dispose)
    ..listen(
      authControllerProvider,
      (_, next) => auth.value = next.status,
    );

  return GoRouter(
    initialLocation: '/market',
    refreshListenable: auth,
    redirect: (context, state) {
      final status = auth.value;
      final onAuthScreen = _authLocations.contains(state.matchedLocation);
      if (status == AuthStatus.unknown) return null; // bootstrap in flight
      if (status == AuthStatus.unauthenticated) {
        return onAuthScreen ? null : '/login';
      }
      return onAuthScreen ? '/market' : null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/verify',
        builder: (_, state) => VerifyScreen(email: state.extra! as String),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _AppShell(shell: shell),
        branches: [
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
              GoRoute(path: '/chats', builder: (_, _) => const ChatsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Market',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Tutors',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
