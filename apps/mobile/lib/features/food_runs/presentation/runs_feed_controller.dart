import 'dart:async';

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/food_runs/data/runs_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live-feed poll cadence: a run's spots fill in real time between classes,
/// so the feed refreshes itself while the app is up.
const kRunsFeedPollInterval = Duration(seconds: 10);

/// Feed state: accumulated pages of live runs plus the user's own runs.
@immutable
class RunsFeedState {
  const RunsFeedState({
    this.items = const [],
    this.myRuns = const [],
    this.nextCursor,
    this.loading = false,
    this.loadingMore = false,
    this.myRunsLoading = false,
    this.error,
  });

  final List<RunResponse> items;
  final List<RunResponse> myRuns;
  final String? nextCursor;
  final bool loading;
  final bool loadingMore;
  final bool myRunsLoading;
  final String? error;

  bool get hasMore => nextCursor != null;

  RunsFeedState _copyWith({
    List<RunResponse>? items,
    List<RunResponse>? myRuns,
    String? Function()? nextCursor,
    bool? loading,
    bool? loadingMore,
    bool? myRunsLoading,
    String? Function()? error,
  }) => RunsFeedState(
    items: items ?? this.items,
    myRuns: myRuns ?? this.myRuns,
    nextCursor: nextCursor != null ? nextCursor() : this.nextCursor,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    myRunsLoading: myRunsLoading ?? this.myRunsLoading,
    error: error != null ? error() : this.error,
  );
}

/// Runs feed controller: first load + pull-to-refresh + infinite scroll,
/// with a silent 15s poll so countdown chips and spot counts stay honest.
class RunsFeedController extends Notifier<RunsFeedState> {
  Timer? _poll;

  @override
  RunsFeedState build() {
    ref
      ..listen(authControllerProvider, (prev, next) {
        if (prev?.status != AuthStatus.authenticated &&
            next.status == AuthStatus.authenticated) {
          Future.microtask(refresh).ignore();
        }
      })
      ..onDispose(() => _poll?.cancel());
    _poll = Timer.periodic(kRunsFeedPollInterval, (_) => _pollTick());
    final auth = ref.read(authControllerProvider);
    if (auth.status == AuthStatus.authenticated) {
      Future.microtask(refresh).ignore();
    }
    return RunsFeedState(loading: auth.status == AuthStatus.authenticated);
  }

  RunsRepository get _repo => ref.read(runsRepositoryProvider);

  void _pollTick() {
    if (ref.read(authControllerProvider).status != AuthStatus.authenticated) {
      return;
    }
    // Silent refresh — never flip the skeletons back on for a poll.
    _silentRefresh().ignore();
  }

  Future<void> _silentRefresh() async {
    try {
      // Feed and "my runs" refresh together so both tabs stay live.
      final (page, mine) = await (
        _repo.fetchFeed(),
        _repo.fetchMyRuns(),
      ).wait;
      state = state._copyWith(
        items: page.items,
        myRuns: mine,
        nextCursor: () => page.nextCursor,
        error: () => null,
      );
    } on Object catch (e) {
      debugPrint('RunsFeedController.poll ERROR: $e');
    }
  }

  /// Fire-and-forget re-sync after any run mutation (post, request, accept…)
  /// so the feed reflects it immediately instead of waiting for the poll.
  void pokeAfterMutation() => _silentRefresh().ignore();

  Future<void> refresh() async {
    state = state._copyWith(loading: state.items.isEmpty, error: () => null);
    try {
      final page = await _repo.fetchFeed();
      state = state._copyWith(
        loading: false,
        items: page.items,
        nextCursor: () => page.nextCursor,
      );
    } on Object catch (e) {
      debugPrint('RunsFeedController.refresh ERROR: $e');
      state = state._copyWith(loading: false, error: e.toString);
    }
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loadingMore || state.loading) return;
    state = state._copyWith(loadingMore: true);
    try {
      final page = await _repo.fetchFeed(cursor: cursor);
      state = state._copyWith(
        loadingMore: false,
        items: [...state.items, ...page.items],
        nextCursor: () => page.nextCursor,
      );
    } on Object catch (e) {
      debugPrint('RunsFeedController.loadMore ERROR: $e');
      state = state._copyWith(loadingMore: false);
    }
  }

  Future<void> refreshMyRuns() async {
    state = state._copyWith(myRunsLoading: state.myRuns.isEmpty);
    try {
      final mine = await _repo.fetchMyRuns();
      state = state._copyWith(myRunsLoading: false, myRuns: mine);
    } on Object catch (e) {
      debugPrint('RunsFeedController.refreshMyRuns ERROR: $e');
      state = state._copyWith(myRunsLoading: false);
    }
  }
}

final runsFeedControllerProvider =
    NotifierProvider<RunsFeedController, RunsFeedState>(
      RunsFeedController.new,
    );
