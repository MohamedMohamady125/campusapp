import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/components/pressable.dart';
import 'package:campusconnect/design_system/components/reputation_chip.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_colors.dart';
import 'package:campusconnect/design_system/theme/app_motion.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/food_runs/data/runs_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One-tap quality signals; selecting them composes the rating comment so the
/// happy path needs zero typing (real POST /ratings, no new field).
/// Role-aware (QA M-04): a requester rates the *delivery*, a runner rates
/// the *customer* — delivery tags like "Still hot" make no sense in reverse.
const _runnerTags = <String>[
  'On time',
  'Order correct',
  'Great comms',
  'Still hot',
];
const _customerTags = <String>[
  'Paid fast',
  'Clear order',
  'Easy drop-off',
  'Friendly',
];

/// Two-way run rating sheet (POST /ratings, context `run`,
/// context_id = RunOrder id). Double-rates come back as a friendly line.
/// [ratingRunner] = true when a requester rates the runner (delivery tags);
/// false when the runner rates a customer (customer tags).
Future<void> showRateRunSheet(
  BuildContext context, {
  required String ratedUserId,
  required String ratedName,
  required String orderId,
  bool ratingRunner = true,
  String? dropoff,
  num? currentRating,
  int ratingCount = 0,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RateRunSheet(
      ratedUserId: ratedUserId,
      ratedName: ratedName,
      orderId: orderId,
      ratingRunner: ratingRunner,
      dropoff: dropoff,
      currentRating: currentRating,
      ratingCount: ratingCount,
    ),
  );
}

class _RateRunSheet extends ConsumerStatefulWidget {
  const _RateRunSheet({
    required this.ratedUserId,
    required this.ratedName,
    required this.orderId,
    required this.ratingCount,
    required this.ratingRunner,
    this.dropoff,
    this.currentRating,
  });

  final String ratedUserId;
  final String ratedName;
  final String orderId;
  final bool ratingRunner;
  final String? dropoff;
  final num? currentRating;
  final int ratingCount;

  @override
  ConsumerState<_RateRunSheet> createState() => _RateRunSheetState();
}

class _RateRunSheetState extends ConsumerState<_RateRunSheet> {
  final _comment = TextEditingController();
  final _commentFocus = FocusNode();
  final _tags = <String>{};
  int _stars = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  /// Folds selected quick-tags and free text into the single `comment` the API
  /// accepts, so chips and typing share one real submit path.
  List<String> get _quickTags =>
      widget.ratingRunner ? _runnerTags : _customerTags;

  String? _composedComment() {
    final free = _comment.text.trim();
    final tags = _quickTags.where(_tags.contains).toList();
    final parts = <String>[
      if (tags.isNotEmpty) tags.join(' · '),
      if (free.isNotEmpty) free,
    ];
    return parts.isEmpty ? null : parts.join(' — ');
  }

  Future<void> _submit() async {
    if (_stars == 0) return;
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(runsRepositoryProvider)
          .submitRating(
            ratedUserId: widget.ratedUserId,
            orderId: widget.orderId,
            stars: _stars,
            comment: _composedComment(),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Thanks! Reputation updated.')),
      );
    } on Object catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(e, fallback: "You've already rated this run."),
          ),
        ),
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: ColoredBox(
        color: context.colors.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Hero(dropoff: widget.dropoff, ratedName: widget.ratedName),
            Padding(
              padding: EdgeInsets.only(
                left: tokens.space4,
                right: tokens.space4,
                top: tokens.space4,
                bottom: MediaQuery.viewInsetsOf(context).bottom + tokens.space6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var star = 1; star <= 5; star++)
                        IconButton(
                          tooltip: '$star star${star == 1 ? '' : 's'}',
                          iconSize: 40,
                          onPressed: () => setState(() => _stars = star),
                          icon: Icon(
                            star <= _stars ? Icons.star : Icons.star_border,
                            color: star <= _stars
                                ? tokens.ratingStar
                                : context.colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: tokens.space3),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: tokens.space2,
                    runSpacing: tokens.space2,
                    children: [
                      for (final tag in _quickTags)
                        _TagPill(
                          label: tag,
                          selected: _tags.contains(tag),
                          onTap: () => setState(
                            () => _tags.contains(tag)
                                ? _tags.remove(tag)
                                : _tags.add(tag),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: tokens.space4),
                  TextField(
                    controller: _comment,
                    focusNode: _commentFocus,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Add a note (optional)',
                      hintText: 'Fast, friendly, fries intact…',
                    ),
                  ),
                  SizedBox(height: tokens.space3),
                  _ReputationPreview(
                    ratedName: widget.ratedName,
                    currentRating: widget.currentRating,
                    ratingCount: widget.ratingCount,
                  ),
                  SizedBox(height: tokens.space4),
                  FilledButton(
                    onPressed: _stars == 0 || _submitting ? null : _submit,
                    child: _submitting
                        ? SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: context.colors.onPrimary,
                            ),
                          )
                        : const Text('Submit rating'),
                  ),
                  SizedBox(height: tokens.space1),
                  TextButton(
                    onPressed: _submitting ? null : _commentFocus.requestFocus,
                    child: const Text('Something went wrong? Tell them'),
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

/// Dark ink header framing the delivery this rating is about.
class _Hero extends StatelessWidget {
  const _Hero({required this.ratedName, this.dropoff});

  final String? dropoff;
  final String ratedName;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final title = dropoff == null
        ? 'How was $ratedName?'
        : 'Delivered to $dropoff';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.space5),
      color: AppColors.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RATE YOUR RUN',
            style: AppTextStyles.labelWide.copyWith(
              color: Colors.white.withValues(alpha: .6),
            ),
          ),
          SizedBox(height: tokens.space2),
          Text(
            title,
            style: AppTextStyles.heading.copyWith(color: Colors.white),
          ),
          if (dropoff != null) ...[
            SizedBox(height: tokens.space1),
            Text(
              'How did $ratedName do?',
              style: context.text.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: .7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Toggleable quick-tag pill — same custom stadium language as the runs feed
/// filters (stock FilterChip clips labels and looks off-brand).
class _TagPill extends StatelessWidget {
  const _TagPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.resolve(context, AppMotion.micro),
          curve: AppMotion.emphasized,
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space4,
            vertical: tokens.space2 + 2,
          ),
          decoration: ShapeDecoration(
            color: selected ? colors.primary : colors.surface,
            shape: StadiumBorder(
              side: selected
                  ? BorderSide.none
                  : BorderSide(color: colors.outlineVariant),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: context.text.labelMedium?.copyWith(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? Colors.white : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows the rated peer's real reputation so the rater sees the impact.
class _ReputationPreview extends StatelessWidget {
  const _ReputationPreview({
    required this.ratedName,
    required this.ratingCount,
    this.currentRating,
  });

  final String ratedName;
  final num? currentRating;
  final int ratingCount;

  @override
  Widget build(BuildContext context) {
    final text = ratingCount == 0 || currentRating == null
        ? 'New peer — your rating starts their reputation.'
        : '$ratedName is at '
              '${ReputationChip.formatRating(currentRating!.toDouble())} ★ '
              'across $ratingCount ratings. Your rating counts.';
    return Row(
      children: [
        Icon(
          Icons.trending_up,
          size: 16,
          color: context.colors.onSurfaceVariant,
        ),
        SizedBox(width: context.tokens.space2),
        Expanded(
          child: Text(
            text,
            style: context.text.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
