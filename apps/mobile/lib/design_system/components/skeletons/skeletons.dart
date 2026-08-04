import 'dart:async' show unawaited;

import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Shimmering placeholder box (spec §13.1).
///
/// Skeletons must match the final layout's exact geometry; shimmer runs at
/// `Durations.long2` with `Easing.linear`, and is disabled when the OS asks
/// for reduced motion.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Durations.long2,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      unawaited(_controller.repeat(reverse: true));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          shape: widget.shape,
          borderRadius: widget.shape == BoxShape.circle
              ? null
              : widget.borderRadius,
          color: Color.lerp(
            colors.surfaceContainerHighest,
            colors.surfaceContainerHigh,
            _controller.value,
          ),
        ),
      ),
    );
  }
}

/// Skeleton matching `ListingCard` geometry exactly (spec §13.1).
class ListingCardSkeleton extends StatelessWidget {
  const ListingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AspectRatio(aspectRatio: 1, child: SkeletonBox()),
          Padding(
            padding: EdgeInsets.all(tokens.space3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 56, height: 18, borderRadius: tokens.brSm),
                SizedBox(height: tokens.space2),
                SkeletonBox(
                  width: double.infinity,
                  height: 16,
                  borderRadius: tokens.brSm,
                ),
                SizedBox(height: tokens.space2),
                Row(
                  children: [
                    const SkeletonBox(
                      width: 24,
                      height: 24,
                      shape: BoxShape.circle,
                    ),
                    SizedBox(width: tokens.space2),
                    SkeletonBox(
                      width: 96,
                      height: 12,
                      borderRadius: tokens.brSm,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton matching `TutorCard` / `ChatListRow` geometry.
class ListRowSkeleton extends StatelessWidget {
  const ListRowSkeleton({super.key, this.height = 88});

  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space4,
          vertical: tokens.space3,
        ),
        child: Row(
          children: [
            const SkeletonBox(width: 56, height: 56, shape: BoxShape.circle),
            SizedBox(width: tokens.space3),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: 140,
                    height: 14,
                    borderRadius: tokens.brSm,
                  ),
                  SizedBox(height: tokens.space2),
                  SkeletonBox(
                    width: double.infinity,
                    height: 12,
                    borderRadius: tokens.brSm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
