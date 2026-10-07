import 'dart:async';

import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_motion.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// No-show counter (DoorDash-style). The runner taps "I'm here" at a
/// drop-off, the server stamps `arrived_at`, and both sides watch the same
/// 5-minute wall-clock window tick down. Expiry *unlocks* the runner's
/// No-show button — the server refuses it earlier (ARRIVAL_REQUIRED /
/// NO_SHOW_TOO_EARLY), so the UI and API can never disagree.
///
/// Must match `NO_SHOW_WAIT` in `apps/api/app/services/run_service.py`.
const kNoShowWait = Duration(minutes: 5);

String _mmss(Duration d) {
  final s = d.inSeconds.clamp(0, kNoShowWait.inSeconds);
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// Remaining window, computed from the wall clock every tick (never a local
/// decrement) so the countdown stays accurate across rebuilds, polls and
/// backgrounding.
Duration _remaining(DateTime arrivedAt) {
  final end = arrivedAt.toUtc().add(kNoShowWait);
  final left = end.difference(DateTime.now().toUtc());
  return left.isNegative ? Duration.zero : left;
}

/// Urgency colour ramp: calm success → warning → error as the window drains.
Color _urgencyColor(BuildContext context, Duration remaining) {
  final tokens = context.tokens;
  final f = 1 - remaining.inMilliseconds / kNoShowWait.inMilliseconds;
  if (f >= 1) return context.colors.error;
  return f < .5
      ? Color.lerp(tokens.success, tokens.warning, f * 2)!
      : Color.lerp(tokens.warning, context.colors.error, (f - .5) * 2)!;
}

/// Shared 1s wall-clock ticker. Rebuilds [builder] with the live remaining
/// duration; stops ticking once the window has fully elapsed.
class _CountdownTicker extends StatefulWidget {
  const _CountdownTicker({required this.arrivedAt, required this.builder});

  final DateTime arrivedAt;
  final Widget Function(BuildContext context, Duration remaining) builder;

  @override
  State<_CountdownTicker> createState() => _CountdownTickerState();
}

class _CountdownTickerState extends State<_CountdownTicker> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
      if (_remaining(widget.arrivedAt) == Duration.zero) {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _remaining(widget.arrivedAt));
}

/// Dasher side: the post-"I'm here" action block for one accepted order —
/// animated countdown strip + Delivered / No-show buttons, with No-show held
/// locked until the window elapses.
class ArrivedActions extends StatelessWidget {
  const ArrivedActions({
    required this.arrivedAt,
    required this.onDelivered,
    required this.onNoShow,
    super.key,
  });

  final DateTime arrivedAt;
  final VoidCallback onDelivered;
  final VoidCallback onNoShow;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return _CountdownTicker(
      arrivedAt: arrivedAt,
      builder: (context, remaining) {
        final expired = remaining == Duration.zero;
        final color = _urgencyColor(context, remaining);
        final elapsedFraction =
            1 - remaining.inMilliseconds / kNoShowWait.inMilliseconds;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: AppMotion.resolve(context, AppMotion.micro),
              width: double.infinity,
              padding: EdgeInsets.all(tokens.space3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: tokens.brXs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        expired
                            ? Icons.timer_off_outlined
                            : Icons.timer_outlined,
                        size: 16,
                        color: color,
                      ),
                      SizedBox(width: tokens.space2),
                      Expanded(
                        child: Text(
                          expired
                              ? 'Window elapsed — no-show unlocked.'
                              : 'Waiting for them to show up…',
                          style: context.text.bodySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!expired)
                        Text(
                          _mmss(remaining),
                          style: context.text.titleSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: tokens.space2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: TweenAnimationBuilder<double>(
                      // Animate between per-second fractions so the bar
                      // drains continuously instead of stepping.
                      tween: Tween(end: elapsedFraction.clamp(0, 1)),
                      duration: AppMotion.resolve(
                        context,
                        const Duration(seconds: 1),
                      ),
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 4,
                        color: color,
                        backgroundColor: color.withValues(alpha: .18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.space3),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onDelivered,
                    child: const Text('Delivered'),
                  ),
                ),
                SizedBox(width: tokens.space2),
                Expanded(
                  child: OutlinedButton(
                    // Locked until the window elapses — mirrors the server's
                    // NO_SHOW_TOO_EARLY guard so a tap can never 409.
                    onPressed: expired ? onNoShow : null,
                    style: expired
                        ? OutlinedButton.styleFrom(
                            foregroundColor: context.colors.error,
                          )
                        : null,
                    child: Text(
                      expired ? 'No-show' : 'No-show ${_mmss(remaining)}',
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Requester side: urgent "your runner is here" banner with the live window.
/// Pulses gently while time remains (collapses to static under reduce-motion),
/// shifts to the error palette once the window is gone.
class RunnerHereBanner extends StatefulWidget {
  const RunnerHereBanner({
    required this.arrivedAt,
    required this.dropoff,
    super.key,
  });

  final DateTime arrivedAt;
  final String dropoff;

  @override
  State<RunnerHereBanner> createState() => _RunnerHereBannerState();
}

class _RunnerHereBannerState extends State<RunnerHereBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return _CountdownTicker(
      arrivedAt: widget.arrivedAt,
      builder: (context, remaining) {
        final expired = remaining == Duration.zero;
        final color = _urgencyColor(context, remaining);
        if (!expired && !reduceMotion) {
          if (!_pulse.isAnimating) {
            unawaited(_pulse.repeat(reverse: true));
          }
        } else {
          _pulse
            ..stop()
            ..value = 0;
        }
        return AnimatedContainer(
          duration: AppMotion.resolve(context, AppMotion.micro),
          width: double.infinity,
          padding: EdgeInsets.all(tokens.space4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: tokens.brSm,
            border: Border.all(color: color.withValues(alpha: .35)),
          ),
          child: Row(
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 1, end: 1.18).animate(
                  CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                ),
                child: Icon(
                  expired ? Icons.timer_off_outlined : Icons.hail_rounded,
                  color: color,
                  size: 28,
                ),
              ),
              SizedBox(width: tokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expired ? 'Window closed' : 'Your runner is here!',
                      style: context.text.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      expired
                          ? 'Time ran out — the runner may mark a no-show.'
                          : 'Meet them at ${widget.dropoff} '
                                'before the timer runs out.',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!expired) ...[
                SizedBox(width: tokens.space3),
                Text(
                  _mmss(remaining),
                  style: context.text.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
