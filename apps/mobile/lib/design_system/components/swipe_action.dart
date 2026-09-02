import 'dart:async' show unawaited;

import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_motion.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:flutter/services.dart' show HapticFeedback;

/// A horizontal swipe accelerator that reveals a coloured action panel as the
/// user drags [child] sideways and fires the matching callback once the drag
/// passes a commit threshold, then springs the card back to rest.
///
/// This is an **accelerator, never the only path**: the wrapped content should
/// still expose tap targets for the same actions, so keyboard/AT users and
/// anyone who prefers tapping are unaffected (Fitts's & Hick's laws — a swipe
/// is faster for the power user, a button is discoverable for everyone).
///
/// Motion follows [AppMotion]: the spring-back honours reduce-motion, and
/// haptics mark the two moments that matter — arming (crossing the threshold)
/// and committing (release past it) — so the gesture feels physical without a
/// visual cue (Nielsen: feedback within 0.1s).
class SwipeAction extends StatefulWidget {
  const SwipeAction({
    required this.child,
    super.key,
    this.onSwipeRight,
    this.onSwipeLeft,
    this.rightIcon,
    this.leftIcon,
    this.rightLabel,
    this.leftLabel,
    this.rightColor,
    this.leftColor,
    this.borderRadius,
  });

  final Widget child;

  /// Fired when the user commits a rightward swipe. Rightward is the positive /
  /// affirmative direction by convention (accept, keep, confirm).
  final VoidCallback? onSwipeRight;

  /// Fired when the user commits a leftward swipe (dismiss, decline).
  final VoidCallback? onSwipeLeft;

  final IconData? rightIcon;
  final IconData? leftIcon;
  final String? rightLabel;
  final String? leftLabel;
  final Color? rightColor;
  final Color? leftColor;
  final BorderRadiusGeometry? borderRadius;

  @override
  State<SwipeAction> createState() => _SwipeActionState();
}

class _SwipeActionState extends State<SwipeAction>
    with SingleTickerProviderStateMixin {
  /// Fraction of the card width the user must clear to commit an action.
  static const _thresholdFraction = 0.32;

  /// Hard cap on how far the card can be dragged, as a fraction of its width,
  /// so the panel always reads as "peeking", never fully torn off.
  static const _maxDragFraction = 0.5;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.enter,
  );

  double _dragExtent = 0;
  double _width = 1;
  bool _armed = false;

  bool get _canRight => widget.onSwipeRight != null;
  bool get _canLeft => widget.onSwipeLeft != null;
  double get _threshold => _width * _thresholdFraction;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onUpdate(DragUpdateDetails details) {
    var next = _dragExtent + details.primaryDelta!;
    if (!_canRight && next > 0) next = 0;
    if (!_canLeft && next < 0) next = 0;
    final maxDrag = _width * _maxDragFraction;
    next = next.clamp(-maxDrag, maxDrag);

    final armed = next.abs() >= _threshold;
    if (armed && !_armed) unawaited(HapticFeedback.mediumImpact());
    setState(() {
      _dragExtent = next;
      _armed = armed;
    });
  }

  void _onEnd(DragEndDetails details) {
    if (_armed) {
      unawaited(HapticFeedback.selectionClick());
      if (_dragExtent > 0) {
        widget.onSwipeRight?.call();
      } else {
        widget.onSwipeLeft?.call();
      }
    }
    _armed = false;
    _springBack();
  }

  void _springBack() {
    final start = _dragExtent;
    final anim = _controller.drive(
      Tween<double>(begin: start, end: 0).chain(
        CurveTween(curve: AppMotion.decelerate),
      ),
    );
    void listener() => setState(() => _dragExtent = anim.value);
    anim.addListener(listener);
    _controller
      ..reset()
      ..duration = AppMotion.resolve(context, AppMotion.enter);
    unawaited(
      _controller.forward().whenComplete(() {
        anim.removeListener(listener);
        if (mounted) setState(() => _dragExtent = 0);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.zero;
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        return GestureDetector(
          onHorizontalDragUpdate: (_canRight || _canLeft) ? _onUpdate : null,
          onHorizontalDragEnd: (_canRight || _canLeft) ? _onEnd : null,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: radius,
                  child: _RevealPanel(
                    extent: _dragExtent,
                    armed: _armed,
                    rightIcon: widget.rightIcon,
                    leftIcon: widget.leftIcon,
                    rightLabel: widget.rightLabel,
                    leftLabel: widget.leftLabel,
                    rightColor: widget.rightColor,
                    leftColor: widget.leftColor,
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(_dragExtent, 0),
                child: widget.child,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The coloured panel revealed behind the card. Fills the side the card is
/// being dragged away from, brightening once [armed].
class _RevealPanel extends StatelessWidget {
  const _RevealPanel({
    required this.extent,
    required this.armed,
    this.rightIcon,
    this.leftIcon,
    this.rightLabel,
    this.leftLabel,
    this.rightColor,
    this.leftColor,
  });

  final double extent;
  final bool armed;
  final IconData? rightIcon;
  final IconData? leftIcon;
  final String? rightLabel;
  final String? leftLabel;
  final Color? rightColor;
  final Color? leftColor;

  @override
  Widget build(BuildContext context) {
    if (extent == 0) return const SizedBox.shrink();
    final colors = context.colors;
    final draggingRight = extent > 0;
    final base = draggingRight
        ? (rightColor ?? colors.primary)
        : (leftColor ?? colors.error);
    final icon = draggingRight ? rightIcon : leftIcon;
    final label = draggingRight ? rightLabel : leftLabel;
    final tokens = context.tokens;

    return ColoredBox(
      color: armed ? base : base.withValues(alpha: 0.65),
      child: Align(
        alignment: draggingRight ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.space5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, color: colors.onPrimary, size: 20),
              if (icon != null && label != null) SizedBox(width: tokens.space2),
              if (label != null)
                Text(
                  label,
                  style: context.text.labelLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
