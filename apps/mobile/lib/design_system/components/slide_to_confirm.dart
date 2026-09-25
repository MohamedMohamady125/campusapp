import 'dart:async' show unawaited;

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
/// * Spring-back uses [SpringSimulation] — physical, interruptible motion.
/// * While [onConfirmed] runs, the thumb pins at the end with a spinner,
///   then flashes a check before the widget resets (submit-feedback).
/// * Accessibility: exposed as a button — screen readers and reduce-motion
///   users double-tap/tap-hold to confirm without the gesture
///   (gesture-alternative). Track is 56px tall (≥44pt target).
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

  /// The committed action. The control shows progress while it runs and
  /// resets itself when it completes or throws (errors surface upstream).
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
  static const double _armThreshold = 0.85;

  /// 0 → resting, 1 → fully slid. Driven by drag + spring-back.
  late final AnimationController _position = AnimationController(
    vsync: this,
    duration: AppMotion.enter,
  );

  /// Looping chevron shimmer that hints "slide me" (swipe-clarity).
  late final AnimationController _hint = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  bool _dragging = false;
  bool _armedTickFired = false;
  _Phase _phase = _Phase.idle;

  @override
  void initState() {
    super.initState();
    unawaited(_hint.repeat());
  }

  @override
  void dispose() {
    _position.dispose();
    _hint.dispose();
    super.dispose();
  }

  bool get _interactive => widget.enabled && _phase == _Phase.idle;

  double _travel(double trackWidth) =>
      trackWidth - _thumbSize - _thumbInset * 2;

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
    if (_position.value >= _armThreshold) {
      unawaited(_commit());
    } else {
      _springBack(details.velocity.pixelsPerSecond.dx / _travel(trackWidth));
    }
  }

  /// Physical spring return — interruptible, velocity-aware (spring-physics).
  void _springBack(double velocity) {
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
    _armedTickFired = false;
  }

  Future<void> _commit() async {
    setState(() => _phase = _Phase.busy);
    unawaited(HapticFeedback.heavyImpact());
    unawaited(
      _position.animateTo(
        1,
        duration: AppMotion.resolve(context, AppMotion.feedback),
      ),
    );
    try {
      await widget.onConfirmed();
      if (!mounted) return;
      setState(() => _phase = _Phase.done);
      // Let the check register (Nielsen: within flow-of-thought), then reset
      // so the control is ready for its next life (status may have advanced).
      await Future<void>.delayed(const Duration(milliseconds: 700));
    } finally {
      if (mounted) {
        setState(() => _phase = _Phase.idle);
        _position.value = 0;
        _armedTickFired = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final accent = widget.color ?? colors.primary;
    final onAccent = widget.color == null ? colors.onPrimary : Colors.white;
    final disabled = !widget.enabled;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      hint: 'Double tap to confirm',
      onTap: _interactive ? () => unawaited(_commit()) : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: (d) => _onDragUpdate(d, trackWidth),
            onHorizontalDragEnd: (d) => _onDragEnd(d, trackWidth),
            // Reduce-motion / switch-access fallback: a long-press commits
            // without any sliding (gesture-alternative).
            onLongPress: _interactive ? () => unawaited(_commit()) : null,
            child: AnimatedOpacity(
              opacity: disabled ? 0.5 : 1,
              duration: AppMotion.resolve(context, AppMotion.micro),
              child: AnimatedBuilder(
                animation: Listenable.merge([_position, _hint]),
                builder: (context, _) {
                  final t = _position.value;
                  final x = _thumbInset + _travel(trackWidth) * t;
                  return Container(
                    height: _height,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: tokens.brFull,
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Progress fill trailing the thumb (gesture-feedback).
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: x + _thumbSize / 2 + _thumbInset,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color:
                                  (_phase == _Phase.done
                                          ? tokens.success
                                          : accent)
                                      .withValues(alpha: 0.18 + 0.5 * t),
                            ),
                          ),
                        ),
                        // Label + shimmering chevrons, fading as you slide.
                        Positioned.fill(
                          child: Opacity(
                            opacity: (1 - t * 1.6).clamp(0.0, 1.0),
                            child: _TrackLabel(
                              label: widget.label,
                              shimmer: reduceMotion ? null : _hint.value,
                            ),
                          ),
                        ),
                        // The thumb.
                        Positioned(
                          left: x,
                          top: _thumbInset,
                          child: _Thumb(
                            size: _thumbSize,
                            color: _phase == _Phase.done
                                ? tokens.success
                                : accent,
                            onColor: onAccent,
                            icon: widget.icon,
                            phase: _phase,
                            lifted: _dragging,
                          ),
                        ),
                      ],
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

enum _Phase { idle, busy, done }

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
      children: [
        Text(label, style: base, overflow: TextOverflow.ellipsis),
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
          _Phase.idle => Icon(icon, color: onColor),
        },
      ),
    );
  }
}
