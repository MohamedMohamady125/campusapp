import 'dart:async';

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/auth/data/auth_repository.dart';
import 'package:dio/dio.dart';
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
    if (!await _repo.hasSession()) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final me = await _repo.fetchMe();
      state = AuthState(status: AuthStatus.authenticated, user: me);
    } on DioException {
      // Stored tokens rejected (and refresh failed) — treat as signed out.
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
