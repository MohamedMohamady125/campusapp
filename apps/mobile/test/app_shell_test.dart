import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:campusconnect/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_auth.dart';
import 'helpers/fake_conversations.dart';

Widget _authedApp() => ProviderScope(
  overrides: [
    authControllerProvider.overrideWith(
      () => FakeAuthController(authedState()),
    ),
    conversationsRepositoryProvider.overrideWithValue(
      FakeConversationsRepository(),
    ),
  ],
  child: const CampusConnectApp(),
);

void main() {
  testWidgets('app shell shows bottom nav with the 3 core areas + profile', (
    tester,
  ) async {
    await tester.pumpWidget(_authedApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in ['Market', 'Tutors', 'Chats', 'Profile']) {
      expect(find.text(label), findsOneWidget);
    }
    // Marketplace is the initial branch (J1 first).
    expect(find.text('Marketplace'), findsOneWidget);
  });

  testWidgets('tab taps switch branches', (tester) async {
    await tester.pumpWidget(_authedApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tutors'));
    await tester.pumpAndSettle();
    expect(find.text('Find a tutor'), findsOneWidget);

    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();
    expect(find.text('No messages yet'), findsOneWidget); // Messages tab
    expect(find.text('Groups'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Test Student'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('core shell meets a11y tap-target guideline', (tester) async {
    await tester.pumpWidget(_authedApp());
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });
}
