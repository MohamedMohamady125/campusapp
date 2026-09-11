import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_auth.dart';
import 'helpers/fake_flags.dart';

Widget _app(AuthState initial) => ProviderScope(
  overrides: [
    authControllerProvider.overrideWith(() => FakeAuthController(initial)),
    ...shellOverrides(),
  ],
  child: const CampusConnectApp(),
);

void main() {
  testWidgets('guard redirects unauthenticated users to login', (
    tester,
  ) async {
    await tester.pumpWidget(_app(anonState));
    await tester.pumpAndSettle();

    expect(find.text('CampusConnect'), findsOneWidget);
    expect(find.text('Sign in'), findsWidgets);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('login form validates inline (spec §6.3 forgiving forms)', (
    tester,
  ) async {
    await tester.pumpWidget(_app(anonState));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tester.pumpAndSettle();
    expect(find.text('That does not look like an email'), findsOneWidget);
  });

  testWidgets('register form enforces .edu email and password length', (
    tester,
  ) async {
    await tester.pumpWidget(_app(anonState));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Create an account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsWidgets);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), 'me@gmail.com');
    await tester.enterText(fields.at(2), 'short');
    await tester.pumpAndSettle();
    expect(find.text('Use your .edu campus email'), findsOneWidget);
    expect(find.text('Use at least 8 characters'), findsOneWidget);
  });

  testWidgets('authenticated user is redirected off auth screens', (
    tester,
  ) async {
    await tester.pumpWidget(_app(authedState()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    // Runs-first launch: the food-runs feed is the landing screen.
    expect(find.text('Food Runs'), findsOneWidget);
  });

  testWidgets('sign out returns to login', (tester) async {
    await tester.pumpWidget(_app(authedState()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Sign out'), 200);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in with your campus email'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('auth screens meet a11y tap-target guidelines', (tester) async {
    await tester.pumpWidget(_app(anonState));
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });
}
