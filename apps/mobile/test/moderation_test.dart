import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/components/tombstone_bubble.dart';
import 'package:campusconnect/design_system/theme/app_theme.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/chats/data/chats_repository.dart';
import 'package:campusconnect/features/chats/presentation/moderation_sheet.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:campusconnect/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_auth.dart';
import 'helpers/fake_conversations.dart';

ChatResponse _chat() => ChatResponse(
  (b) => b
    ..id = 'chat-1'
    ..name = 'CS majors'
    ..slug = 'cs-majors'
    ..visibility = ChatVisibility.open
    // Owned by the signed-in test user so moderation is enabled.
    ..createdById = 'u-1'
    ..memberCap = 200
    ..memberCount = 42
    ..createdAt = DateTime.utc(2026),
);

ChatMessageResponse _deletedMsg() => ChatMessageResponse(
  (b) => b
    ..id = 'cm-1'
    ..chatId = 'chat-1'
    ..senderId = 'u-9'
    ..body = ''
    ..createdAt = DateTime.utc(2026)
    ..deletedAt = DateTime.utc(2026, 1, 2)
    ..deletedReason = 'spam',
);

class _FakeChatsRepository implements ChatsRepository {
  @override
  Future<List<ChatResponse>> directory() async => [_chat()];

  @override
  Future<List<ChatResponse>> myChats() async => [_chat()];

  @override
  Future<void> join(String chatId) async {}

  @override
  Future<void> leave(String chatId) async {}

  @override
  Future<List<ChatMessageResponse>> fetchMessages(String chatId) async => [
    _deletedMsg(),
  ];

  @override
  Future<ChatMessageResponse> postMessage(String chatId, String body) =>
      throw UnimplementedError();

  @override
  Future<void> deleteMessage(
    String chatId,
    String messageId,
    String reason,
  ) async {}

  @override
  Future<void> muteMember(
    String chatId,
    String userId, {
    required int minutes,
    required String reason,
  }) async {}

  @override
  Future<void> banMember(
    String chatId,
    String userId, {
    String? reason,
  }) async {}

  @override
  Future<void> promoteMember(String chatId, String userId) async {}
}

void main() {
  testWidgets('tombstone bubble shows moderator by-line and reason', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Column(
            children: [
              TombstoneBubble(isMine: false, reason: 'spam'),
              TombstoneBubble(isMine: true, deletedByName: 'Ava'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Removed by moderator'), findsOneWidget);
    expect(find.text('Reason: spam'), findsOneWidget);
    expect(find.text('Removed by Ava'), findsOneWidget);
  });

  testWidgets('delete dialog disables confirm until reason is valid', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: DeleteMessageDialog()),
      ),
    );

    FilledButton confirm() => tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Delete'),
    );

    // Empty and too-short reasons keep the button disabled.
    expect(confirm().onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'ab');
    await tester.pump();
    expect(confirm().onPressed, isNull);

    // A valid reason (>= 3 chars) enables it.
    await tester.enterText(find.byType(TextField), 'spam');
    await tester.pump();
    expect(confirm().onPressed, isNotNull);
  });

  testWidgets('deleted message renders a tombstone in the chat room', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => FakeAuthController(authedState()),
          ),
          chatsRepositoryProvider.overrideWithValue(_FakeChatsRepository()),
          conversationsRepositoryProvider.overrideWithValue(
            FakeConversationsRepository(),
          ),
        ],
        child: const CampusConnectApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CS majors'));
    await tester.pumpAndSettle();

    expect(find.byType(TombstoneBubble), findsOneWidget);
    expect(find.text('Removed by moderator'), findsOneWidget);
    expect(find.text('Reason: spam'), findsOneWidget);
  });
}
