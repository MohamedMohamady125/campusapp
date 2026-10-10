import 'dart:async' show Completer, unawaited;

import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_colors.dart';
import 'package:flutter/services.dart' show HapticFeedback;

/// Flashes a centered "success check" moment: an ink disc pops in and a
/// white checkmark draws itself stroke-by-stroke, then the whole thing
/// fades away (~900ms total). The modern dashboard confirmation pattern.
///
/// * Pure [CustomPainter] + one [OverlayEntry]; no packages, no layout shift.
/// * `IgnorePointer` — never blocks input.
/// * Respects reduce-motion: haptic only, no overlay.
/// * Returns once the moment has played so callers can sequence navigation.
Future<void> showSuccessCheck(BuildContext context) async {
  unawaited(HapticFeedback.mediumImpact());
  if (MediaQuery.disableAnimationsOf(context)) return;
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  final done = Completer<void>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => IgnorePointer(
      child: _SuccessCheckLayer(
        onDone: () {
          entry.remove();
          done.complete();
        },
      ),
    ),
  );
  overlay.insert(entry);
  return done.future;
}

class _SuccessCheckLayer extends StatefulWidget {
  const _SuccessCheckLayer({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_SuccessCheckLayer> createState() => _SuccessCheckLayerState();
}

class _SuccessCheckLayerState extends State<_SuccessCheckLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _t.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDone();
    });
    unawaited(_t.forward());
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) => CustomPaint(
        size: Size.infinite,
        painter: _SuccessCheckPainter(t: _t.value),
      ),
    );
  }
}

class _SuccessCheckPainter extends CustomPainter {
  _SuccessCheckPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    // Phases: 0–.35 disc pops in · .25–.7 check draws · .78–1 fade out.
    final pop = Curves.easeOutBack.transform((t / 0.35).clamp(0.0, 1.0));
    final draw = Curves.easeOutCubic.transform(
      ((t - 0.25) / 0.45).clamp(0.0, 1.0),
    );
    final fade = 1 - ((t - 0.78) / 0.22).clamp(0.0, 1.0);

    final center = Offset(size.width / 2, size.height / 2);
    const radius = 44.0;

    final disc = Paint()..color = AppColors.ink.withValues(alpha: 0.94 * fade);
    canvas.drawCircle(center, radius * pop, disc);

    if (draw <= 0) return;
    final check = Path()
      ..moveTo(center.dx - 18, center.dy + 1)
      ..lineTo(center.dx - 5, center.dy + 14)
      ..lineTo(center.dx + 19, center.dy - 12);
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: fade)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Draw the check stroke-by-stroke via path metrics.
    for (final metric in check.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * draw), stroke);
    }
  }

  @override
  bool shouldRepaint(_SuccessCheckPainter oldDelegate) => oldDelegate.t != t;
}
