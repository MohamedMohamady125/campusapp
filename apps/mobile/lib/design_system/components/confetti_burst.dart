import 'dart:async' show unawaited;
import 'dart:math' as math;

import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:flutter/services.dart' show HapticFeedback;

/// Fires a short, celebratory confetti burst over the whole screen — the
/// gamified "run complete" moment (Duolingo/Uber-style delight).
///
/// * Pure [CustomPainter] + one [OverlayEntry]; no packages, no layout shift.
/// * `IgnorePointer` — never blocks input (no-blocking-animation).
/// * Respects reduce-motion: haptic only, no particles (reduced-motion).
/// * Self-removing after ~1.4s; safe to call repeatedly.
void showConfettiBurst(BuildContext context) {
  unawaited(HapticFeedback.mediumImpact());
  if (MediaQuery.disableAnimationsOf(context)) return;
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => IgnorePointer(
      child: _ConfettiLayer(onDone: () => entry.remove()),
    ),
  );
  overlay.insert(entry);
}

class _ConfettiLayer extends StatefulWidget {
  const _ConfettiLayer({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<_ConfettiLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _particles = List.generate(48, (_) => _Particle.random(rng));
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
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) => CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(
          t: _t.value,
          particles: _particles,
          palette: [
            colors.primary,
            colors.tertiary,
            colors.secondary,
            const Color(0xFFFFC53D), // celebratory gold
            const Color(0xFF34C759), // success green
          ],
        ),
      ),
    );
  }
}

/// One piece of confetti: launched from the bottom-center arc with an
/// initial velocity, then pure ballistics (gravity) + spin.
class _Particle {
  _Particle({
    required this.angle,
    required this.speed,
    required this.spin,
    required this.size,
    required this.colorIndex,
    required this.originX,
    required this.drag,
  });

  factory _Particle.random(math.Random rng) => _Particle(
    // Launch upward within a ±55° cone.
    angle: -math.pi / 2 + (rng.nextDouble() - 0.5) * (math.pi * 0.62),
    speed: 0.9 + rng.nextDouble() * 1.4,
    spin: (rng.nextDouble() - 0.5) * 18,
    size: 5 + rng.nextDouble() * 5,
    colorIndex: rng.nextInt(1 << 16),
    originX: 0.3 + rng.nextDouble() * 0.4,
    drag: 0.75 + rng.nextDouble() * 0.2,
  );

  final double angle;
  final double speed;
  final double spin;
  final double size;
  final int colorIndex;
  final double originX;
  final double drag;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.t,
    required this.particles,
    required this.palette,
  });

  final double t;
  final List<_Particle> particles;
  final List<Color> palette;

  static const double _gravity = 2.4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // Fade the whole burst out over the final third.
    final fade = (1 - (t - 0.66) / 0.34).clamp(0.0, 1.0);
    for (final p in particles) {
      final v = p.speed * math.pow(p.drag, t * 10);
      final x =
          p.originX * size.width + math.cos(p.angle) * v * t * size.width * 0.9;
      final y =
          size.height * 0.85 +
          math.sin(p.angle) * v * t * size.height * 1.1 +
          _gravity * t * t * size.height * 0.5;
      if (y > size.height + 20) continue;
      paint.color = palette[p.colorIndex % palette.length].withValues(
        alpha: fade,
      );
      // Rectangles read as confetti better than dots; cheap to draw.
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(p.spin * t)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.6,
            ),
            const Radius.circular(1.5),
          ),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.t != t;
}
