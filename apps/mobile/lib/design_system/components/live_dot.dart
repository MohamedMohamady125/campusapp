import 'dart:async' show unawaited;

import 'package:campusconnect/design_system/material.dart';

/// A "live" indicator dot with a soft expanding pulse ring — the universal
/// "this is happening right now" signal (Uber/Twitch-style).
///
/// * Pure transform/opacity animation — no layout, no jank.
/// * Reduce-motion: renders a static dot (reduced-motion).
class LiveDot extends StatefulWidget {
  const LiveDot({required this.color, super.key, this.size = 6});

  final Color color;
  final double size;

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    unawaited(_t.repeat());
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
    );
    if (MediaQuery.disableAnimationsOf(context)) return dot;
    return SizedBox(
      // Ring needs room to breathe without shifting neighbours.
      width: widget.size * 2.6,
      height: widget.size * 2.6,
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, child) {
          final t = _t.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Expanding, fading pulse ring.
              Transform.scale(
                scale: 1 + t * 1.6,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(
                      alpha: (1 - t) * 0.35,
                    ),
                  ),
                ),
              ),
              child!,
            ],
          );
        },
        child: dot,
      ),
    );
  }
}
