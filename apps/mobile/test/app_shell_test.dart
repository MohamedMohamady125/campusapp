import 'package:campusconnect/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app shell shows bottom nav with the 3 core areas + profile', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: CampusConnectApp()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in ['Market', 'Tutors', 'Chats', 'Profile']) {
      expect(find.text(label), findsOneWidget);
    }
    // Marketplace is the initial branch (J1 first).
    expect(find.text('Marketplace'), findsOneWidget);
  });

  testWidgets('tab taps switch branches', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CampusConnectApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tutors'));
    await tester.pumpAndSettle();
    expect(find.text('Find a tutor'), findsOneWidget);

    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();
    expect(find.text('Join the conversation'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in with your campus email'), findsOneWidget);
  });

  testWidgets('core shell meets a11y tap-target guideline', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CampusConnectApp()));
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });
}
