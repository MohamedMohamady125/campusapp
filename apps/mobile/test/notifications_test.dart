import 'package:built_value/json_object.dart';
import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/chats/data/chats_repository.dart';
import 'package:campusconnect/features/chats/presentation/chat_room_screen.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:campusconnect/features/notifications/data/notifications_repository.dart';
import 'package:campusconnect/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/fake_auth.dart';
import 'helpers/fake_conversations.dart';
import 'helpers/fake_flags.dart';

class _MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

ChatResponse _chat() => ChatResponse(
  (b) => b
    ..id = 'chat-1'
    ..name = 'CS majors'
    ..slug = 'cs-majors'
    ..visibility = ChatVisibility.open
    ..createdById = 'u-9'
    ..memberCap = 200
    ..memberCount = 42
    ..createdAt = DateTime.utc(2026),
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
    ChatMessageResponse(
      (b) => b
        ..id = 'cm-1'
        ..chatId = chatId
        ..senderId = 'u-9'
        ..body = 'Welcome to CS majors!'
        ..createdAt = DateTime.utc(2026),
    ),
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

NotificationResponse _notif(
  String id,
  String type,
  Map<String, Object?> payload, {
  bool read = false,
}) => NotificationResponse(
  (b) => b
    ..id = id
    ..type = type
    ..createdAt = DateTime.now().toUtc()
    ..readAt = read ? DateTime.now().toUtc() : null
    ..payload.replace({
      for (final entry in payload.entries)
        entry.key: switch (entry.value) {
          null => null,
          final v => JsonObject(v),
        },
    }),
);

NotificationPageResponse _page(
  List<NotificationResponse> items, {
  int unread = 0,
  String? nextCursor,
}) => NotificationPageResponse(
  (b) => b
    ..items.replace(items)
    ..unreadCount = unread
    ..nextCursor = nextCursor,
);

void main() {
  late _MockNotificationsRepository notifications;

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  Widget app() {
    return ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(
          () => FakeAuthController(authedState()),
        ),
        notificationsRepositoryProvider.overrideWithValue(notifications),
        chatsRepositoryProvider.overrideWithValue(_FakeChatsRepository()),
        conversationsRepositoryProvider.overrideWithValue(
          FakeConversationsRepository(),
        ),
        ...shellOverrides(),
      ],
      child: const CampusConnectApp(),
    );
  }

  void stubPage(NotificationPageResponse page) {
    notifications = _MockNotificationsRepository();
    when(
      () => notifications.fetchPage(
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => page);
    when(() => notifications.markRead(any())).thenAnswer((_) async {});
    when(() => notifications.markAllRead()).thenAnswer((_) async {});
  }

  testWidgets(
    'notifications screen renders every type, unread styling, and '
    'tapping a chat_message deep-links to the room',
    (tester) async {
      stubPage(
        _page(
          [
            _notif('n1', 'chat_message', {
              'chat_id': 'chat-1',
              'message_id': 'm1',
              'sender_id': 'u-9',
              'sender_name': 'Maya',
              'chat_name': 'CS majors',
              'count': 1,
            }),
            _notif('n2', 'chat_message', {
              'chat_id': 'chat-1',
              'message_id': 'm2',
              'sender_id': 'u-9',
              'sender_name': 'Maya',
              'chat_name': 'CS majors',
              'count': 3,
            }),
            _notif('n3', 'chat_mention', {
              'chat_id': 'chat-1',
              'message_id': 'm3',
              'sender_id': 'u-8',
              'sender_name': 'Sam',
              'chat_name': 'CS majors',
            }),
            _notif('n4', 'dm_message', {
              'conversation_id': 'c-1',
              'message_id': 'm4',
              'sender_id': 'u-2',
              'sender_name': 'Riley',
              'count': 2,
            }),
            // Legacy/unknown payload must render a generic row, not crash.
            _notif('n5', 'listing_sold', {}, read: true),
          ],
          unread: 4,
        ),
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Notifications').first);
      await tester.pumpAndSettle();

      expect(find.text('Maya in CS majors'), findsOneWidget);
      expect(
        find.text('Maya and 2 more messages in CS majors'),
        findsOneWidget,
      );
      expect(find.text('Sam mentioned you in CS majors'), findsOneWidget);
      expect(find.text('Riley and 1 more message'), findsOneWidget);
      expect(find.text('You have a new notification'), findsOneWidget);

      // Unread rows carry the dot; the read legacy row does not.
      expect(find.byKey(const ValueKey('unread-dot-n1')), findsOneWidget);
      expect(find.byKey(const ValueKey('unread-dot-n5')), findsNothing);

      await tester.tap(find.text('Maya in CS majors'));
      await tester.pumpAndSettle();

      // Optimistic mark-read fired, and we deep-linked into the chat room.
      verify(() => notifications.markRead(['n1'])).called(1);
      expect(find.byType(ChatRoomScreen), findsOneWidget);
      expect(find.text('Welcome to CS majors!'), findsOneWidget);
    },
  );

  testWidgets('dm_message single-count copy and empty state', (tester) async {
    stubPage(
      _page([
        _notif('n1', 'dm_message', {
          'conversation_id': 'c-1',
          'message_id': 'm1',
          'sender_id': 'u-2',
          'sender_name': 'Riley',
          'count': 1,
        }),
      ], unread: 1),
    );
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Notifications').first);
    await tester.pumpAndSettle();

    expect(find.text('Riley sent you a message'), findsOneWidget);

    // Mark all read clears the badge state and the row styling.
    await tester.tap(find.text('Mark all read'));
    await tester.pumpAndSettle();
    verify(() => notifications.markAllRead()).called(1);
    expect(find.byKey(const ValueKey('unread-dot-n1')), findsNothing);
  });

  testWidgets('bell badge shows the unread count', (tester) async {
    stubPage(_page([], unread: 3));
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('3'), findsWidgets);
  });

  testWidgets('bell badge caps its display at 9+', (tester) async {
    stubPage(_page([], unread: 25));
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('9+'), findsWidgets);
    expect(find.text('25'), findsNothing);
  });
}
