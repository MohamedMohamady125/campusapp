import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/components/pressable.dart';
import 'package:campusconnect/design_system/components/reputation_chip.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_motion.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/food_runs/presentation/run_format.dart';
import 'package:go_router/go_router.dart';

/// One run as a compact row: urgency accent bar, destination + runner trust
/// line, fee + spots on the right. Hairline border, no elevation.
/// Shared by the feed and the My Runs tab.
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
        : '${runner.displayName} · New runner';
    final statusVisible = showStatus && run.status != RunStatus.open;
    final accent = statusVisible
        ? runStatusColor(context, run.status)
        : _urgencyColor(context, run.leavingAt);

    return Pressable(
      onTap: () => context.go('/runs/run/${run.id}'),
      child: Container(
        padding: EdgeInsets.all(tokens.space3),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: tokens.brMd,
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: AppMotion.resolve(context, AppMotion.micro),
              curve: AppMotion.standard,
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: tokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    run.foodSpot.name,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: tokens.space1),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  run.feeCents == 0 ? 'Free' : runFeeAmount(run.feeCents),
                  style: AppTextStyles.titleSmall.copyWith(
                    color: run.feeCents == 0
                        ? tokens.success
                        : colors.onSurface,
                  ),
                ),
                SizedBox(height: tokens.space1),
                Text(
                  statusVisible ? runStatusLabel(run.status) : spotsLabel(run),
                  style: context.text.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String spotsLabel(RunResponse run) {
  final left = run.spotsMax - run.acceptedCount;
  if (run.acceptedCount == 0) return '${run.spotsMax} spots open';
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
