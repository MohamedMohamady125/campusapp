import 'dart:async';

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/auth/data/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Session status for the router guard (spec M2 acceptance: guarded routes).
enum AuthStatus { unknown, unauthenticated, authenticated }

@immutable
class AuthState {
  const AuthState({required this.status, this.user});

  final AuthStatus status;
  final UserMeResponse? user;

  AuthState copyWith({AuthStatus? status, UserMeResponse? user}) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
  );
}

/// Bootstraps the session from secure storage and drives login/logout.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    unawaited(Future.microtask(_bootstrap));
    return const AuthState(status: AuthStatus.unknown);
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> _bootstrap() async {
    // Never leave the app stuck on AuthStatus.unknown: a hung secure-storage
    // read or an unexpected error must land on the login screen, not a dead
    // shell with an empty feed and a spinning profile.
    try {
      final hasSession = await _repo.hasSession().timeout(
        const Duration(seconds: 5),
      );
      if (!hasSession) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      final me = await _repo.fetchMe();
      state = AuthState(status: AuthStatus.authenticated, user: me);
    } on Object {
      // Stored tokens rejected, storage unreadable, or network dead —
      // treat as signed out and let the user log back in.
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> logIn({required String email, required String password}) async {
    await _repo.login(email: email, password: password);
    final me = await _repo.fetchMe();
    state = AuthState(status: AuthStatus.authenticated, user: me);
  }

  Future<void> logOut() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshProfile() async {
    if (state.status != AuthStatus.authenticated) return;
    state = state.copyWith(user: await _repo.fetchMe());
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
