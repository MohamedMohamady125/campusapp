import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Concrete report reasons (spec §4.6) — specific, not abstract categories.
const kReportReasons = <String>[
  'Scam or fake listing',
  'Harassment',
  'Not a real student',
  'Item not as described',
  'Inappropriate content',
  'Something else',
];

/// Opens the three-step report flow (spec §10.8). Returns after submission.
Future<void> showReportSheet(
  BuildContext context, {
  required String targetName,
  required Future<void> Function(String reason, String detail) onSubmit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ReportSheet(targetName: targetName, onSubmit: onSubmit),
  );
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.targetName, required this.onSubmit});

  final String targetName;
  final Future<void> Function(String reason, String detail) onSubmit;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  int _step = 0;
  String? _reason;
  final _detail = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(_reason!, _detail.text.trim());
      if (mounted) setState(() => _step = 2);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(
        left: tokens.space4,
        right: tokens.space4,
        bottom: MediaQuery.viewInsetsOf(context).bottom + tokens.space4,
      ),
      child: AnimatedSize(
        duration: Durations.short4,
        curve: Easing.standard,
        child: switch (_step) {
          0 => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Report', style: context.text.titleMedium),
              SizedBox(height: tokens.space2),
              RadioGroup<String>(
                groupValue: _reason,
                onChanged: (v) => setState(() {
                  _reason = v;
                  _step = 1;
                }),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final reason in kReportReasons)
                      SizedBox(
                        height: 56,
                        child: RadioListTile<String>(
                          value: reason,
                          title: Text(reason, style: context.text.bodyLarge),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          1 => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => setState(() => _step = 0),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      _reason ?? '',
                      style: context.text.titleMedium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: tokens.space2),
              TextField(
                controller: _detail,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Anything else we should know? (optional)',
                ),
              ),
              SizedBox(height: tokens.space4),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(_submitting ? 'Sending…' : 'Submit report'),
                ),
              ),
              SizedBox(height: tokens.space2),
            ],
          ),
          _ => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: tokens.space4),
              Icon(Icons.check_circle_outline, size: 48, color: tokens.success),
              SizedBox(height: tokens.space4),
              Text('Thanks', style: context.text.titleMedium),
              SizedBox(height: tokens.space2),
              Text(
                'A moderator will review this within 24 hours. '
                "We won't tell ${widget.targetName} who reported them.",
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: tokens.space4),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
              SizedBox(height: tokens.space2),
            ],
          ),
        },
      ),
    );
  }
}
