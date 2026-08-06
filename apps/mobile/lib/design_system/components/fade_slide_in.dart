import 'dart:async' show unawaited;

import 'package:campusconnect/design_system/material.dart';

/// Entrance animation (Fifty Free §6): fade in + slide up 16px, 320ms,
/// easeOutExpo-ish curve, staggered by `index * 40ms` (index clamped to 10).
/// Respects reduce-motion.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({required this.child, super.key, this.index = 0});

  final Widget child;
  final int index;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  static const _curve = Cubic(0.16, 1, 0.3, 1);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: widget.index.clamp(0, 10) * 40);
    unawaited(
      Future<void>.delayed(delay, () {
        if (mounted) unawaited(_controller.forward());
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    final anim = CurvedAnimation(parent: _controller, curve: _curve);
    return FadeTransition(
      opacity: anim,
      child: AnimatedBuilder(
        animation: anim,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 16 * (1 - anim.value)),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
