import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/chats/data/chats_repository.dart';
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
    ..description = 'All things computer science.'
    ..visibility = ChatVisibility.open
    ..createdById = 'u-9'
    ..memberCap = 200
    ..memberCount = 42
    ..createdAt = DateTime.utc(2026),
);

ChatMessageResponse _msg(String id, String sender, String body, int minute) =>
    ChatMessageResponse(
      (b) => b
        ..id = id
        ..chatId = 'chat-1'
        ..senderId = sender
        ..body = body
        ..createdAt = DateTime.utc(2026, 1, 1, 12, minute),
    );

class _FakeChatsRepository implements ChatsRepository {
  List<ChatMessageResponse> messages = [];
  int joinCalls = 0;
  bool failSend = false;

  @override
  Future<List<ChatResponse>> directory() async => [_chat()];

  @override
  Future<List<ChatResponse>> myChats() async => [_chat()];

  @override
  Future<void> join(String chatId) async {
    joinCalls++;
  }

  @override
  Future<void> leave(String chatId) async {}

  @override
  Future<List<ChatMessageResponse>> fetchMessages(String chatId) async =>
      messages;

  @override
  Future<ChatMessageResponse> postMessage(String chatId, String body) async {
    if (failSend) throw Exception('network down');
    final sent = _msg('cm-${messages.length + 1}', 'u-1', body, 30);
    messages = [...messages, sent];
    return sent;
  }

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
  late _FakeChatsRepository chats;

  Widget app() {
    chats = _FakeChatsRepository();
    return ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(
          () => FakeAuthController(authedState()),
        ),
        chatsRepositoryProvider.overrideWithValue(chats),
        conversationsRepositoryProvider.overrideWithValue(
          FakeConversationsRepository(),
        ),
      ],
      child: const CampusConnectApp(),
    );
  }

  Future<void> openDirectory(WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();
  }

  testWidgets('J3: directory lists groups and tap joins + opens the room', (
    tester,
  ) async {
    chats = _FakeChatsRepository();
    await openDirectory(tester);

    expect(find.text('CS majors'), findsOneWidget);
    expect(find.text('All things computer science.'), findsOneWidget);

    chats.messages = [_msg('cm-1', 'u-9', 'Welcome to CS majors!', 1)];
    await tester.tap(find.text('CS majors'));
    await tester.pumpAndSettle();

    expect(chats.joinCalls, 1);
    expect(find.text('Welcome to CS majors!'), findsOneWidget);
  });

  testWidgets('J3: posting in a room shows the message optimistically', (
    tester,
  ) async {
    await openDirectory(tester);
    await tester.tap(find.text('CS majors'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hey everyone!');
    await tester.pump(); // rebuild enables the send button
    await tester.tap(find.byTooltip('Send'));
    await tester.pump();

    expect(find.text('Hey everyone!'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(chats.messages.single.body, 'Hey everyone!');
  });

  testWidgets('failed chat post rolls back and restores the input', (
    tester,
  ) async {
    await openDirectory(tester);
    await tester.tap(find.text('CS majors'));
    await tester.pumpAndSettle();
    chats.failSend = true;

    await tester.enterText(find.byType(TextField), 'Anyone here?');
    await tester.pump(); // rebuild enables the send button
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();

    expect(find.text("That didn't send. Try again."), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'Anyone here?');
    expect(chats.messages, isEmpty);
  });

  testWidgets('chat directory meets a11y tap-target guidelines', (
    tester,
  ) async {
    await openDirectory(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });
}
