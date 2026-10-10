import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_motion.dart';

/// Rolling text swap for live values (fees, counters, "Earn up to $X").
///
/// When [text] changes, the old value slides up and fades out while the new
/// one slides in from below — the odometer feel of modern dashboards —
/// instead of snapping. Timing from [AppMotion.micro]; collapses to a plain
/// swap under reduce-motion.
class RollText extends StatelessWidget {
  const RollText({
    required this.text,
    super.key,
    this.style,
    this.textAlign,
    this.alignment = Alignment.center,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  /// How in/out texts stack while swapping (match the host row's alignment).
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.resolve(context, AppMotion.micro),
      switchInCurve: AppMotion.decelerate,
      switchOutCurve: AppMotion.accelerate,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: alignment,
        children: [...previousChildren, ?currentChild],
      ),
      transitionBuilder: (child, animation) {
        // Entering text rises into place; exiting text continues upward.
        final entering = child.key == ValueKey<String>(text);
        final offset = Tween<Offset>(
          begin: Offset(0, entering ? 0.6 : -0.6),
          end: Offset.zero,
        ).animate(animation);
        return ClipRect(
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          ),
        );
      },
      child: Text(
        text,
        key: ValueKey<String>(text),
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}
