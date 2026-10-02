import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/components/pressable.dart';
import 'package:campusconnect/design_system/components/reputation_chip.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_colors.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/food_runs/presentation/run_format.dart';
import 'package:go_router/go_router.dart';

/// One run as a food-delivery-style card: branded spot tile, destination +
/// live meta + runner trust line, and a chunky fee pill. White card with a
/// hairline border and soft shadow so it floats off the tinted canvas.
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
    final metaLabel = statusVisible
        ? runStatusLabel(run.status)
        : leavingLabel(run.leavingAt);

    return Pressable(
      onTap: () => context.go('/runs/run/${run.id}'),
      child: Container(
        padding: EdgeInsets.all(tokens.space3),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: tokens.brLg,
          border: Border.all(color: colors.outlineVariant),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            _SpotTile(name: run.foodSpot.name, accent: accent),
            SizedBox(width: tokens.space3),
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
                  SizedBox(height: tokens.space1),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: tokens.space1),
                      Flexible(
                        child: Text(
                          metaLabel,
                          style: context.text.bodySmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _FeePill(feeCents: run.feeCents),
                SizedBox(height: tokens.space2),
                Text(
                  spotsLabel(run),
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

/// Branded monogram tile standing in for a food-spot photo (the API has no
/// spot imagery yet) — soft blue gradient square with the spot's initial,
/// like a delivery app's restaurant avatar.
class _SpotTile extends StatelessWidget {
  const _SpotTile({required this.name, required this.accent});

  final String name;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBg, AppColors.primaryMuted],
        ),
        borderRadius: tokens.brMd,
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.avatarLetter.copyWith(fontSize: 22),
        ),
      ),
    );
  }
}

/// Chunky stadium fee pill — "Free" goes green-tinted, paid fees blue-tinted.
class _FeePill extends StatelessWidget {
  const _FeePill({required this.feeCents});

  final int feeCents;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final free = feeCents == 0;
    final bg = free
        ? tokens.success.withValues(alpha: .12)
        : AppColors.primaryBg;
    final fg = free ? tokens.success : AppColors.primaryDark;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space3,
        vertical: tokens.space1 + 2,
      ),
      decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
      child: Text(
        free ? 'Free' : runFeeAmount(feeCents),
        style: AppTextStyles.titleSmall.copyWith(color: fg),
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
