import 'dart:async';

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/food_runs/data/runs_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Detail poll cadence: the run screen is the live surface — status walks,
/// accepts, and the group chat link all appear without a manual refresh.
const kRunDetailPollInterval = Duration(seconds: 5);

/// Statuses during which the detail screen keeps polling.
const Set<RunStatus> _activeStatuses = {
  RunStatus.open,
  RunStatus.locked,
  RunStatus.atStore,
  RunStatus.delivering,
};

/// One run's detail state.
@immutable
class RunDetailState {
  const RunDetailState({this.run, this.loading = true, this.error});

  final RunResponse? run;
  final bool loading;
  final String? error;
}

/// Run detail controller: 5s poll while the run is active, plus every
/// runner/requester action. Mutations re-sync from the server response and
/// rethrow so screens surface the human error message (never silent).
class RunDetailController
    extends AutoDisposeFamilyNotifier<RunDetailState, String> {
  Timer? _poll;

  @override
  RunDetailState build(String arg) {
    ref.onDispose(() => _poll?.cancel());
    _poll = Timer.periodic(kRunDetailPollInterval, (_) {
      final status = state.run?.status;
      if (status == null || _activeStatuses.contains(status)) {
        refresh().ignore();
      }
    });
    unawaited(Future.microtask(refresh));
    return const RunDetailState();
  }

  RunsRepository get _repo => ref.read(runsRepositoryProvider);

  Future<void> refresh() async {
    try {
      final run = await _repo.fetchRun(arg);
      state = RunDetailState(run: run, loading: false);
    } on Object catch (e) {
      debugPrint('RunDetailController.refresh ERROR: $e');
      state = RunDetailState(
        run: state.run,
        loading: false,
        error: state.run == null ? e.toString() : null,
      );
    }
  }

  Future<void> _mutate(Future<RunResponse> Function() action) async {
    final run = await action();
    state = RunDetailState(run: run, loading: false);
  }

  Future<void> requestSpot(String orderText, String dropoff) =>
      _mutate(() => _repo.requestSpot(arg, orderText, dropoff));

  Future<void> withdraw(String orderId) async {
    await _repo.withdrawOrder(arg, orderId);
    await refresh();
  }

  Future<void> accept(String orderId) =>
      _mutate(() => _repo.acceptOrder(arg, orderId));

  Future<void> decline(String orderId) =>
      _mutate(() => _repo.declineOrder(arg, orderId));

  Future<void> markDelivered(String orderId) =>
      _mutate(() => _repo.markDelivered(arg, orderId));

  Future<void> markNoShow(String orderId) =>
      _mutate(() => _repo.markNoShow(arg, orderId));

  Future<void> confirmReceived(String orderId) =>
      _mutate(() => _repo.confirmReceived(arg, orderId));

  Future<void> updateStatus(RunStatus status) =>
      _mutate(() => _repo.updateStatus(arg, status));

  Future<void> cancelRun() => _mutate(() => _repo.cancelRun(arg));
}

final AutoDisposeNotifierProviderFamily<
  RunDetailController,
  RunDetailState,
  String
>
runDetailControllerProvider = NotifierProvider.autoDispose
    .family<RunDetailController, RunDetailState, String>(
      RunDetailController.new,
    );
