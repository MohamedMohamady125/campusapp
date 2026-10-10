import 'dart:async' show unawaited;
import 'dart:math' as math;

import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_motion.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:flutter/physics.dart' show SpringDescription, SpringSimulation;
import 'package:flutter/services.dart' show HapticFeedback;

/// Uber/Lyft-style slide-to-confirm control for committed, high-stakes
/// actions (advance a run, confirm received). Dragging the thumb across the
/// track arms the action; releasing early springs back with real physics.
///
/// Interaction contract (skill: touch & interaction / animation):
/// * Thumb tracks the finger 1:1 (gesture-feedback) with a trailing fill.
/// * Haptic on grab, tick at the arming threshold, heavy impact on commit.
/// * Fling-to-commit: a decisive rightward fling past the halfway point
///   commits even if the finger lifts before the threshold — matching the
///   projected physics instead of punishing a fast, confident gesture.
/// * Spring-back uses [SpringSimulation] — physical, interruptible motion,
///   and fires on drag *cancel* too (scroll steal, incoming call), so the
///   thumb is never stranded mid-track.
/// * While [onConfirmed] runs, the thumb pins at the end with a spinner,
///   then flashes a check before the widget resets (submit-feedback). If
///   the action throws, the track shakes, the thumb flashes the error
///   color and springs home — a visible "rejected", never a silent reset.
/// * No bare long-press commit: sliding is the gesture. The press-and-hold
///   fallback only exists under reduce-motion, and screen readers commit
///   via the semantics tap action (gesture-alternative).
/// * Accessibility: exposed as a button; track is 56px tall (≥44pt target).
class SlideToConfirm extends StatefulWidget {
  const SlideToConfirm({
    required this.label,
    required this.onConfirmed,
    super.key,
    this.icon = Icons.arrow_forward_rounded,
    this.color,
    this.enabled = true,
  });

  /// Instruction shown on the track, e.g. "Slide — I'm at the store".
  final String label;

  /// The committed action. The control shows progress while it runs; on
  /// success it flashes a check, on error it shakes and springs back.
  final Future<void> Function() onConfirmed;

  /// Thumb glyph. Defaults to a forward arrow.
  final IconData icon;

  /// Track/thumb accent. Defaults to the theme primary.
  final Color? color;

  final bool enabled;

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm>
    with TickerProviderStateMixin {
  static const double _height = 56;
  static const double _thumbInset = 4;
  static const double _thumbSize = _height - _thumbInset * 2;

  /// Fraction of the track the thumb must cross to arm the action.
  static const double _armThreshold = 0.8;

  /// Fling escape hatch: releasing past this point with a strong rightward
  /// velocity commits — the projected motion would have reached the end.
  static const double _flingThreshold = 0.5;

  /// Rightward release velocity (track-fractions/second) that counts as a
  /// deliberate fling rather than a drift.
  static const double _flingVelocity = 2;

  /// 0 → resting, 1 → fully slid. Driven by drag + spring-back.
  late final AnimationController _position = AnimationController(
    vsync: this,
    duration: AppMotion.enter,
  );

  /// Looping chevron shimmer that hints "slide me" (swipe-clarity). Only
  /// runs while the control is actually slidable — not when disabled,
  /// busy, or under reduce-motion (battery + distraction).
  late final AnimationController _hint = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  /// Horizontal shake on failure — the canonical "rejected" gesture.
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  bool _dragging = false;
  bool _armedTickFired = false;
  _Phase _phase = _Phase.idle;

  @override
  void dispose() {
    _position.dispose();
    _hint.dispose();
    _shake.dispose();
    super.dispose();
  }

  bool get _interactive => widget.enabled && _phase == _Phase.idle;

  @override
  void didUpdateWidget(SlideToConfirm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Disabled mid-drag (e.g. state refreshed underneath the finger):
    // abandon the drag and send the thumb home.
    if (!widget.enabled && oldWidget.enabled && _dragging) {
      _dragging = false;
      _springBack(0);
    }
  }

  void _syncHint() {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final shouldRun = _interactive && !_dragging && !reduceMotion;
    if (shouldRun && !_hint.isAnimating) {
      unawaited(_hint.repeat());
    } else if (!shouldRun && _hint.isAnimating) {
      _hint
        ..stop()
        ..value = 0;
    }
  }

  /// Usable travel. Clamped so pathological widths can't divide by ≤0.
  double _travel(double trackWidth) => math.max(
    1,
    trackWidth - _thumbSize - _thumbInset * 2,
  );

  void _onDragStart(DragStartDetails _) {
    if (!_interactive) return;
    _position.stop();
    setState(() => _dragging = true);
    unawaited(HapticFeedback.selectionClick());
  }

  void _onDragUpdate(DragUpdateDetails details, double trackWidth) {
    if (!_dragging) return;
    _position.value = (_position.value + details.delta.dx / _travel(trackWidth))
        .clamp(0.0, 1.0);
    final armed = _position.value >= _armThreshold;
    if (armed && !_armedTickFired) {
      _armedTickFired = true;
      unawaited(HapticFeedback.mediumImpact());
    } else if (!armed) {
      _armedTickFired = false;
    }
  }

  void _onDragEnd(DragEndDetails details, double trackWidth) {
    if (!_dragging) return;
    setState(() => _dragging = false);
    final velocity = details.velocity.pixelsPerSecond.dx / _travel(trackWidth);
    final past = _position.value >= _armThreshold;
    final flung =
        _position.value >= _flingThreshold && velocity >= _flingVelocity;
    if (past || flung) {
      unawaited(_commit());
    } else {
      _springBack(velocity);
    }
  }

  void _onDragCancel() {
    if (!_dragging) return;
    setState(() => _dragging = false);
    _springBack(0);
  }

  /// Physical spring return — interruptible, velocity-aware (spring-physics).
  void _springBack(double velocity) {
    _armedTickFired = false;
    if (MediaQuery.disableAnimationsOf(context)) {
      _position.value = 0;
      return;
    }
    const spring = SpringDescription(mass: 1, stiffness: 500, damping: 32);
    unawaited(
      _position.animateWith(
        SpringSimulation(spring, _position.value, 0, velocity),
      ),
    );
  }

  Future<void> _commit() async {
    if (_phase != _Phase.idle) return; // double-fire guard (a11y + gesture)
    setState(() => _phase = _Phase.busy);
    unawaited(HapticFeedback.heavyImpact());
    unawaited(
      _position.animateTo(
        1,
        duration: AppMotion.resolve(context, AppMotion.feedback),
      ),
    );
    var failed = false;
    try {
      await widget.onConfirmed();
    } on Object {
      // Callers surface the message (snackbar via their own catch); the
      // control's job is to make the rejection visible, not to crash the
      // zone from an unawaited future.
      failed = true;
    }
    if (!mounted) return;
    await (failed ? _reject() : _celebrate());
  }

  /// Success: flash the check (Nielsen: within flow-of-thought) then reset
  /// so the control is ready for its next life (status may have advanced).
  Future<void> _celebrate() async {
    setState(() => _phase = _Phase.done);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _reset();
  }

  /// Failure: error haptic + horizontal shake + error-colored thumb, then
  /// spring home. The caller surfaces the message (snackbar); the control
  /// makes the rejection *felt*.
  Future<void> _reject() async {
    setState(() => _phase = _Phase.error);
    unawaited(HapticFeedback.vibrate());
    if (!MediaQuery.disableAnimationsOf(context)) {
      _shake.value = 0;
      await _shake.forward();
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 450));
    }
    _reset();
  }

  void _reset() {
    if (!mounted) return;
    setState(() => _phase = _Phase.idle);
    _springBack(0);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final accent = widget.color ?? colors.primary;
    final onAccent = widget.color == null ? colors.onPrimary : Colors.white;
    final disabled = !widget.enabled;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    _syncHint();

    final thumbColor = switch (_phase) {
      _Phase.done => tokens.success,
      _Phase.error => colors.error,
      _ => accent,
    };

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      hint: widget.enabled ? 'Double tap to confirm' : null,
      onTap: _interactive ? () => unawaited(_commit()) : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: (d) => _onDragUpdate(d, trackWidth),
            onHorizontalDragEnd: (d) => _onDragEnd(d, trackWidth),
            onHorizontalDragCancel: _onDragCancel,
            // Reduce-motion fallback only: press-and-hold commits without
            // sliding (gesture-alternative). Everyone else must slide —
            // a bare long-press on a high-stakes control is an accidental
            // commit waiting to happen.
            onLongPress: reduceMotion && _interactive
                ? () => unawaited(_commit())
                : null,
            child: AnimatedOpacity(
              opacity: disabled ? 0.5 : 1,
              duration: AppMotion.resolve(context, AppMotion.micro),
              child: AnimatedBuilder(
                animation: Listenable.merge([_position, _hint, _shake]),
                builder: (context, _) {
                  final t = _position.value;
                  final x = _thumbInset + _travel(trackWidth) * t;
                  // Damped sine: ±8px fading out over the shake run.
                  final shakeT = _shake.value;
                  final shakeDx = _shake.isAnimating || shakeT > 0
                      ? math.sin(shakeT * math.pi * 5) * 8 * (1 - shakeT)
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(shakeDx, 0),
                    child: Container(
                      height: _height,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: tokens.brFull,
                        border: Border.all(
                          color: _phase == _Phase.error
                              ? colors.error
                              : colors.outlineVariant,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          // Progress fill trailing the thumb
                          // (gesture-feedback).
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: x + _thumbSize / 2 + _thumbInset,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: thumbColor.withValues(
                                  alpha: 0.18 + 0.5 * t,
                                ),
                              ),
                            ),
                          ),
                          // Label + shimmering chevrons, fading as you
                          // slide. Inset past the resting thumb so long
                          // labels never collide with it on small phones.
                          Positioned.fill(
                            left: _thumbSize + _thumbInset * 2,
                            right: tokens.space3,
                            child: Opacity(
                              opacity: (1 - t * 1.6).clamp(0.0, 1.0),
                              child: _TrackLabel(
                                label: widget.label,
                                shimmer: _hint.isAnimating ? _hint.value : null,
                              ),
                            ),
                          ),
                          // The thumb.
                          Positioned(
                            left: x,
                            top: _thumbInset,
                            child: _Thumb(
                              size: _thumbSize,
                              color: thumbColor,
                              onColor: onAccent,
                              icon: widget.icon,
                              phase: _phase,
                              lifted: _dragging,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _Phase { idle, busy, done, error }

class _TrackLabel extends StatelessWidget {
  const _TrackLabel({required this.label, required this.shimmer});

  final String label;

  /// 0–1 loop position for the shimmer sweep; null disables it.
  final double? shimmer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = context.text.titleSmall?.copyWith(
      color: colors.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    final text = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            style: base,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: colors.onSurfaceVariant,
        ),
      ],
    );
    final t = shimmer;
    if (t == null) return Center(child: text);
    // A soft highlight sweeping left→right — the canonical "slide me"
    // affordance.
    return Center(
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            colors.onSurfaceVariant,
            colors.onSurface,
            colors.onSurfaceVariant,
          ],
          stops: [
            (t * 1.6 - 0.45).clamp(0.0, 1.0),
            (t * 1.6 - 0.25).clamp(0.0, 1.0),
            (t * 1.6 - 0.05).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: text,
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.size,
    required this.color,
    required this.onColor,
    required this.icon,
    required this.phase,
    required this.lifted,
  });

  final double size;
  final Color color;
  final Color onColor;
  final IconData icon;
  final _Phase phase;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.resolve(context, AppMotion.feedback),
      curve: AppMotion.standard,
      width: size,
      height: size,
      transform: Matrix4.identity()
        ..scaleByDouble(lifted ? 1.06 : 1, lifted ? 1.06 : 1, 1, 1),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: lifted ? 0.30 : 0.18),
            blurRadius: lifted ? 10 : 6,
            offset: Offset(0, lifted ? 4 : 2),
          ),
        ],
      ),
      child: Center(
        child: switch (phase) {
          _Phase.busy => SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: onColor),
          ),
          _Phase.done => Icon(Icons.check_rounded, color: onColor),
          _Phase.error => Icon(Icons.close_rounded, color: onColor),
          _Phase.idle => Icon(icon, color: onColor),
        },
      ),
    );
  }
}
