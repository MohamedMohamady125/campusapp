import 'dart:async';

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for one conversation thread. Messages are kept ascending by
/// `createdAt` so the reversed ListView shows newest at the bottom.
class ThreadState {
  const ThreadState({
    this.messages = const [],
    this.loading = true,
    this.error,
  });

  final List<AppSchemasConversationMessageResponse> messages;
  final bool loading;
  final String? error;

  ThreadState copyWith({
    List<AppSchemasConversationMessageResponse>? messages,
    bool? loading,
  }) => ThreadState(
    messages: messages ?? this.messages,
    loading: loading ?? this.loading,
  );
}

/// Thread controller (M5, spec §6.3): polling refresh + optimistic send
/// with rollback on failure.
class ThreadController extends AutoDisposeFamilyNotifier<ThreadState, String> {
  ConversationsRepository get _repo =>
      ref.read(conversationsRepositoryProvider);

  @override
  ThreadState build(String arg) {
    unawaited(Future.microtask(refresh));
    return const ThreadState();
  }

  Future<void> refresh() async {
    try {
      final items = await _repo.fetchMessages(arg);
      // Keep any optimistic (still in-flight) local messages on top.
      final local = state.messages
          .where((m) => m.id.startsWith('local-'))
          .toList();
      final sorted = [...items]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      state = ThreadState(messages: [...sorted, ...local], loading: false);
      unawaited(_repo.markRead(arg));
    } on Object {
      state = ThreadState(
        messages: state.messages,
        loading: false,
        error: 'Could not load messages.',
      );
    }
  }

  /// Optimistic send: the bubble appears immediately; on failure it is
  /// rolled back and `false` is returned so the UI can restore the input.
  Future<bool> send(String body, String senderId) async {
    final local = AppSchemasConversationMessageResponse(
      (b) => b
        ..id = 'local-${DateTime.now().microsecondsSinceEpoch}'
        ..conversationId = arg
        ..senderId = senderId
        ..body = body
        ..createdAt = DateTime.now().toUtc(),
    );
    state = state.copyWith(messages: [...state.messages, local]);
    try {
      final sent = await _repo.sendMessage(arg, body);
      state = state.copyWith(
        messages: [
          for (final m in state.messages)
            if (m.id == local.id) sent else m,
        ],
      );
      return true;
    } on Object {
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != local.id).toList(),
      );
      return false;
    }
  }
}

final AutoDisposeNotifierProviderFamily<ThreadController, ThreadState, String>
threadControllerProvider = NotifierProvider.autoDispose
    .family<ThreadController, ThreadState, String>(ThreadController.new);
