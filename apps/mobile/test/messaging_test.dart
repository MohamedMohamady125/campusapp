import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:campusconnect/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_auth.dart';
import 'helpers/fake_conversations.dart';

Widget _app(FakeConversationsRepository repo) => ProviderScope(
  overrides: [
    authControllerProvider.overrideWith(
      () => FakeAuthController(authedState()),
    ),
    conversationsRepositoryProvider.overrideWithValue(repo),
  ],
  child: const CampusConnectApp(),
);

Future<void> _openThread(WidgetTester tester) async {
  await tester.tap(find.text('Chats'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Sara Seller'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('conversations inbox lists peers and opens a thread', (
    tester,
  ) async {
    final repo = FakeConversationsRepository(
      conversations: [fakeConversation()],
    )..messages = [fakeMessage('m-1', 'u-2', 'Is the lamp available?', 1)];
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await _openThread(tester);

    expect(find.text('Is the lamp available?'), findsOneWidget);
    expect(repo.markReadCalls, greaterThan(0));
  });

  testWidgets('optimistic send shows the bubble immediately', (tester) async {
    final repo = FakeConversationsRepository(
      conversations: [fakeConversation()],
    );
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await _openThread(tester);

    await tester.enterText(find.byType(TextField), 'Yes, still here!');
    await tester.pump(); // rebuild enables the send button
    await tester.tap(find.byTooltip('Send'));
    await tester.pump(); // one frame — before the fake network resolves

    expect(find.text('Yes, still here!'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(repo.messages.single.body, 'Yes, still here!');
  });

  testWidgets('failed send rolls back and restores the input', (
    tester,
  ) async {
    final repo = FakeConversationsRepository(
      conversations: [fakeConversation()],
    )..failSend = true;
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await _openThread(tester);

    await tester.enterText(find.byType(TextField), 'Hello?');
    await tester.pump(); // rebuild enables the send button
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();

    // Bubble rolled back; text restored in the composer for retry (§6.3).
    expect(find.text("That didn't send. Try again."), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'Hello?');
    expect(repo.messages, isEmpty);
  });
}
