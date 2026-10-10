import 'dart:io' show Platform;

import 'package:campus_api/campus_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_activities/live_activities.dart';

/// App group shared with the widget extension (see docs/push/PUSH_SETUP.md).
const kRunLiveActivityAppGroup =
    'group.edu.campus.campusconnect.liveactivities';

/// Requester-side iOS Live Activity: a DoorDash-style run tracker on the
/// lock screen + Dynamic Island while someone is out getting your food.
///
/// No-ops everywhere Live Activities can't run (Android, web, iOS < 16.1,
/// user disabled, widget extension not yet added to the Xcode project) —
/// the in-app run screen remains the source of truth.
class RunLiveActivityService {
  final LiveActivities _plugin = LiveActivities();
  bool _ready = false;
  bool _unavailable = false;
  final Set<String> _active = {};

  Future<bool> _ensureReady() async {
    if (_unavailable) return false;
    if (_ready) return true;
    if (kIsWeb || !Platform.isIOS) {
      _unavailable = true;
      return false;
    }
    try {
      await _plugin.init(appGroupId: kRunLiveActivityAppGroup);
      if (!await _plugin.areActivitiesEnabled()) {
        _unavailable = true;
        return false;
      }
      _ready = true;
      return true;
    } on Object {
      _unavailable = true; // extension/app-group missing — stay silent
      return false;
    }
  }

  /// Reconcile the Live Activity with the latest run snapshot. Called on
  /// every run-detail refresh; cheap no-op when nothing is trackable.
  Future<void> sync(RunResponse run) async {
    final order = run.myOrder;
    final tracking =
        order != null &&
        (order.status == RunOrderStatus.accepted ||
            order.status == RunOrderStatus.delivered) &&
        const {
          RunStatus.locked,
          RunStatus.atStore,
          RunStatus.delivering,
        }.contains(run.status);
    if (!tracking) {
      await _end(run.id);
      return;
    }
    if (!await _ensureReady()) return;
    try {
      await _plugin.createOrUpdateActivity(
        run.id,
        _payload(run, order),
        staleIn: const Duration(hours: 2),
      );
      _active.add(run.id);
    } on Object {
      // Live Activity is a garnish — never let it break the run screen.
    }
  }

  Map<String, String> _payload(RunResponse run, RunOrderResponse order) {
    final (stage, label) = switch (run.status) {
      RunStatus.atStore => ('1', 'At ${run.foodSpot.name}'),
      RunStatus.delivering =>
        order.arrivedAt != null
            ? ('3', 'Runner is at ${order.dropoff}!')
            : ('2', 'On the way to ${order.dropoff}'),
      _ => ('0', 'Heading to ${run.foodSpot.name}'),
    };
    return {
      'spotName': run.foodSpot.name,
      'runnerName': run.runner.displayName,
      'dropoff': order.dropoff,
      'stage': stage,
      'statusLabel': label,
      // Epoch millis the widget turns into the live 5-minute pickup timer.
      'arrivedAtEpoch':
          order.arrivedAt?.millisecondsSinceEpoch.toString() ?? '',
    };
  }

  Future<void> _end(String runId) async {
    if (!_active.remove(runId) || !_ready) return;
    try {
      await _plugin.endActivity(runId);
    } on Object {
      // Already gone — fine.
    }
  }
}

final runLiveActivityProvider = Provider<RunLiveActivityService>(
  (ref) => RunLiveActivityService(),
);
