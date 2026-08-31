import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/food_runs/data/runs_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Two-way run rating sheet (POST /ratings, context `run`,
/// context_id = RunOrder id). Double-rates come back as a friendly line.
Future<void> showRateRunSheet(
  BuildContext context, {
  required String ratedUserId,
  required String ratedName,
  required String orderId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _RateRunSheet(
      ratedUserId: ratedUserId,
      ratedName: ratedName,
      orderId: orderId,
    ),
  );
}

class _RateRunSheet extends ConsumerStatefulWidget {
  const _RateRunSheet({
    required this.ratedUserId,
    required this.ratedName,
    required this.orderId,
  });

  final String ratedUserId;
  final String ratedName;
  final String orderId;

  @override
  ConsumerState<_RateRunSheet> createState() => _RateRunSheetState();
}

class _RateRunSheetState extends ConsumerState<_RateRunSheet> {
  final _comment = TextEditingController();
  int _stars = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
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
            comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
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
    return Padding(
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
          Text(
            'How was ${widget.ratedName}?',
            style: AppTextStyles.subheading,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.space4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var star = 1; star <= 5; star++)
                IconButton(
                  tooltip: '$star star${star == 1 ? '' : 's'}',
                  iconSize: 36,
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
          TextField(
            controller: _comment,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Comment (optional)',
              hintText: 'Fast, friendly, fries intact…',
            ),
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
        ],
      ),
    );
  }
}
