import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/components/pressable.dart';
import 'package:campusconnect/design_system/components/reputation_chip.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_colors.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/food_runs/presentation/run_format.dart';
import 'package:campusconnect/features/food_runs/presentation/spot_image.dart';
import 'package:go_router/go_router.dart';

/// One run as an image-led delivery card: full-width spot photo banner with
/// the fee pill floating on it, then destination + live meta + runner trust
/// line below. White card, hairline border, soft shadow — floats off the
/// tinted canvas. Shared by the feed and the My Runs tab.
class RunRow extends StatelessWidget {
  const RunRow({required this.run, this.showStatus = false, super.key});

  final RunResponse run;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final runner = run.runner;
    final rated = runner.ratingCount > 0;
    final ratingText = ReputationChip.formatRating(
      runner.reputationScore.toDouble(),
    );
    final trustLine = rated
        ? '${runner.displayName} · ★ $ratingText (${runner.ratingCount})'
        // "New member" everywhere (QA S-06) — same wording as ReputationChip.
        : '${runner.displayName} · New member';
    final statusVisible = showStatus && run.status != RunStatus.open;
    final accent = statusVisible
        ? runStatusColor(context, run.status)
        : _urgencyColor(context, run.leavingAt);
    final metaLabel = statusVisible
        ? runStatusLabel(run.status)
        : leavingLabel(run.leavingAt);

    return Pressable(
      onTap: () => context.go('/runs/run/${run.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: tokens.brLg,
          border: Border.all(color: colors.outlineVariant),
          boxShadow: AppShadows.sm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo banner — the card leads with food, not text.
            SizedBox(
              height: 132,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SpotImage(
                    name: run.foodSpot.name,
                    imageUrl: run.foodSpot.imageUrl,
                  ),
                  // Fee pill floats on the photo, top-right.
                  Positioned(
                    top: tokens.space2,
                    right: tokens.space2,
                    child: _FeePill(feeCents: run.feeCents),
                  ),
                  // Live meta pill (status or closing time), bottom-left.
                  Positioned(
                    left: tokens.space2,
                    bottom: tokens.space2,
                    child: _MetaPill(label: metaLabel, accent: accent),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(tokens.space3),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          run.foodSpot.name,
                          style: AppTextStyles.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          trustLine,
                          style: context.text.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: tokens.space2),
                  Text(
                    spotsLabel(run),
                    style: context.text.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
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

/// Frosted white pill over the photo carrying the live meta (closing time
/// or run status) with its urgency dot.
class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space2,
        vertical: tokens.space1,
      ),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: StadiumBorder(),
        shadows: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          SizedBox(width: tokens.space1),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Chunky stadium fee pill — "Free" goes green-tinted, paid fees solid white
/// with brand-blue text so it reads crisply over any photo.
class _FeePill extends StatelessWidget {
  const _FeePill({required this.feeCents});

  final int feeCents;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final free = feeCents == 0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space3,
        vertical: tokens.space1 + 2,
      ),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: StadiumBorder(),
        shadows: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        free ? 'Free' : runFeeAmount(feeCents),
        style: AppTextStyles.titleSmall.copyWith(
          color: free ? context.tokens.success : AppColors.primaryDark,
        ),
      ),
    );
  }
}

String spotsLabel(RunResponse run) {
  final left = run.spotsMax - run.acceptedCount;
  if (run.acceptedCount == 0) {
    return run.spotsMax == 1 ? '1 spot open' : '${run.spotsMax} spots open';
  }
  if (left <= 0) return 'Full';
  return '${run.acceptedCount} joined · $left left';
}

Color _urgencyColor(BuildContext context, DateTime leavingAt) {
  final tokens = context.tokens;
  final urgent =
      leavingAt.toUtc().difference(DateTime.now().toUtc()) <
      const Duration(minutes: 10);
  return urgent ? tokens.warning : tokens.success;
}
