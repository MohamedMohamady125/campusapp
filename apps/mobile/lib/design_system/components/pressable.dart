import 'dart:async' show unawaited;

import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_motion.dart';
import 'package:flutter/services.dart' show HapticFeedback;

/// Press feedback for tappable cards/rows (Fifty Free §6).
///
/// Scales to 0.97 and dims to 90% opacity while pressed, springs back on
/// release, and fires a light haptic on tap. Timing comes from
/// [AppMotion.feedback] (100ms — Nielsen's "instantaneous" limit) so the touch
/// reads as direct manipulation. Collapses to no motion under reduce-motion.
class Pressable extends StatefulWidget {
  const Pressable({required this.child, super.key, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
              unawaited(HapticFeedback.lightImpact());
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: AppMotion.resolve(context, AppMotion.feedback),
        curve: AppMotion.standard,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.9 : 1,
          duration: AppMotion.resolve(context, AppMotion.feedback),
          curve: AppMotion.standard,
          child: widget.child,
        ),
      ),
    );
  }
}
