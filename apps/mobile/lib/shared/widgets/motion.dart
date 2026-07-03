import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Tactile press feedback: scales to 0.97 within ~100ms on touch-down and
/// springs back in ~200ms (design brief §motion). Honors reduce-motion.
class PressableScale extends StatefulWidget {
  const PressableScale({required this.child, this.onTap, super.key});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.press,
    reverseDuration: AppMotion.release,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeOutBack,
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (!_reduceMotion) _controller.forward().ignore();
      },
      onTapUp: (_) {
        if (!_reduceMotion) _controller.reverse().ignore();
      },
      onTapCancel: () {
        if (!_reduceMotion) _controller.reverse().ignore();
      },
      onTap: widget.onTap,
      child: ScaleTransition(scale: scale, child: widget.child),
    );
  }
}

/// One-shot staggered entrance: fades in + translates 12px up over ~280ms
/// with an emphasized-decelerate curve (design brief §motion). Stagger by
/// [index]; capped so deep list items don't wait forever. Finite animation —
/// safe with `pumpAndSettle`. Honors reduce-motion.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({required this.child, this.index = 0, super.key});

  final Widget child;
  final int index;

  /// Cap stagger to the first ~6 items (design brief).
  static const int _staggerCap = 6;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.entrance,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    final delay =
        AppMotion.stagger *
        widget.index.clamp(0, FadeSlideIn._staggerCap).toDouble();
    Future<void>.delayed(delay, () {
      if (mounted) _controller.forward().ignore();
    }).ignore();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.decelerate,
    );
    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 12 * (1 - curved.value)),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
