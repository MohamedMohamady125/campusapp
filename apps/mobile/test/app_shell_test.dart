import 'package:campusconnect/core/flags/flags_provider.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/food_runs/data/runs_repository.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:campusconnect/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/fake_auth.dart';
import 'helpers/fake_conversations.dart';

/// Flags controller pinned to a fixed set — no network on build.
class _FakeFlags extends FlagsController {
  _FakeFlags(this.flags);

  final Set<String> flags;

  @override
  Set<String> build() => flags;
}

class _MockRunsRepository extends Mock implements RunsRepository {}

const Set<String> _allTabs = {
  kTabFoodRuns,
  kTabMarketplace,
  kTabTutoring,
  kTabChats,
};

Widget _authedApp({Set<String> flags = _allTabs}) {
  final runs = _MockRunsRepository();
  when(
    () => runs.fetchFeed(cursor: any(named: 'cursor')),
  ).thenAnswer((_) async => const RunsPage(items: []));
  when(runs.fetchMyRuns).thenAnswer((_) async => []);
  return ProviderScope(
    overrides: [
      authControllerProvider.overrideWith(
        () => FakeAuthController(authedState()),
      ),
      flagsProvider.overrideWith(() => _FakeFlags(flags)),
      runsRepositoryProvider.overrideWithValue(runs),
      conversationsRepositoryProvider.overrideWithValue(
        FakeConversationsRepository(),
      ),
    ],
    child: const CampusConnectApp(),
  );
}

void main() {
  testWidgets('app shell shows Runs first plus the flagged tabs + profile', (
    tester,
  ) async {
    await tester.pumpWidget(_authedApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in ['Runs', 'Market', 'Tutors', 'Chats', 'Profile']) {
      expect(find.text(label), findsWidgets);
    }
    // Food runs is the initial branch (hero tab, runs-first launch).
    expect(find.text('Food runs'), findsOneWidget);
    expect(find.text('No runs right now'), findsOneWidget);
  });

  testWidgets('tab taps switch branches', (tester) async {
    await tester.pumpWidget(_authedApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Market'));
    await tester.pumpAndSettle();
    expect(find.text('Search listings'), findsOneWidget);

    await tester.tap(find.text('Tutors'));
    await tester.pumpAndSettle();
    // App bar title + the guidance empty-state title (spec §12.5).
    expect(find.text('Find a tutor'), findsWidgets);

    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();
    expect(find.text('No messages yet'), findsOneWidget); // Messages tab
    expect(find.text('Groups'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Test Student'), findsOneWidget);
    // Sign out sits below the fold on the small test surface.
    await tester.scrollUntilVisible(find.text('Sign out'), 200);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('default flags hide market/tutors/chats tabs', (tester) async {
    await tester.pumpWidget(_authedApp(flags: kDefaultEnabledTabs));
    await tester.pumpAndSettle();

    expect(find.text('Runs'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
    for (final hidden in ['Market', 'Tutors', 'Chats']) {
      expect(find.text(hidden), findsNothing);
    }
  });

  testWidgets('core shell meets a11y tap-target guideline', (tester) async {
    await tester.pumpWidget(_authedApp());
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });
}
