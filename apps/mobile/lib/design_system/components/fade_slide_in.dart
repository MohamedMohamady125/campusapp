import 'dart:async' show unawaited;

import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_motion.dart';

/// Entrance animation (Fifty Free §6): fade in + slide up 16px, staggered per
/// item. Timing and curve come from [AppMotion] ([AppMotion.enter] with the M3
/// emphasized-decelerate "arriving" curve, [AppMotion.stagger] between items).
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
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.enter,
  );

  @override
  void initState() {
    super.initState();
    final delay = AppMotion.stagger * widget.index.clamp(0, 10);
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
    final anim = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.decelerate,
    );
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
