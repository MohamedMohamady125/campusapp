import 'dart:async';

import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/food_runs/data/runner_location_service.dart';
import 'package:campusconnect/features/food_runs/presentation/run_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How often the runner's device pushes a fresh GPS ping while en route.
/// Uber/Lyft cadence: frequent enough to feel live, sparse enough to be kind
/// to the battery and the poll endpoint.
const kLocationShareInterval = Duration(seconds: 8);

/// Mounted only in the runner's section while the run is en route. On mount it
/// asks for foreground location permission, then pushes one ping immediately
/// and every [kLocationShareInterval] after — stopping the moment it unmounts
/// (run wrapped/cancelled, or the runner leaves the screen). Renders a small
/// "sharing your live location" reassurance chip so the runner knows GPS is on.
class RunnerLocationBroadcaster extends ConsumerStatefulWidget {
  const RunnerLocationBroadcaster({required this.runId, super.key});

  final String runId;

  @override
  ConsumerState<RunnerLocationBroadcaster> createState() =>
      _RunnerLocationBroadcasterState();
}

class _RunnerLocationBroadcasterState
    extends ConsumerState<RunnerLocationBroadcaster> {
  Timer? _timer;
  bool _permitted = false;
  bool _resolving = true;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    final service = ref.read(runnerLocationServiceProvider);
    final ok = await service.ensurePermission();
    if (!mounted) return;
    setState(() {
      _permitted = ok;
      _resolving = false;
    });
    if (!ok) return;
    await _pushOnce();
    _timer = Timer.periodic(kLocationShareInterval, (_) => _pushOnce());
  }

  Future<void> _pushOnce() async {
    final service = ref.read(runnerLocationServiceProvider);
    final pos = await service.current();
    if (pos == null || !mounted) return;
    await ref
        .read(runDetailControllerProvider(widget.runId).notifier)
        .pushLocation(pos.lat, pos.lng)
        .catchError((_) {
          // A dropped ping is fine — the next tick retries. Never surface a
          // transient GPS/network blip to the runner mid-run.
        });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    if (_resolving) return const SizedBox.shrink();

    final (icon, text, color) = _permitted
        ? (
            Icons.my_location,
            'Sharing your live location with your requesters',
            colors.primary,
          )
        : (
            Icons.location_disabled_outlined,
            'Location off — turn it on so requesters can track you',
            colors.error,
          );

    return Container(
      padding: EdgeInsets.all(tokens.space3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: tokens.brSm,
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          SizedBox(width: tokens.space2),
          Expanded(
            child: Text(
              text,
              style: context.text.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
