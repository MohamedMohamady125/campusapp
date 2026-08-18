import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Moderator actions on a chat message (Sprint 6).
enum ModerationAction { delete, mute, ban, promote }

/// Bottom sheet of moderator actions; returns the chosen action or null.
/// "Make moderator" only shows for owners ([canPromote]).
Future<ModerationAction?> showModerationSheet(
  BuildContext context, {
  required bool canPromote,
}) {
  return showModalBottomSheet<ModerationAction>(
    context: context,
    builder: (sheetContext) {
      final tokens = sheetContext.tokens;
      final colors = sheetContext.colors;
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.space2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.delete_outline, color: colors.error),
                title: Text(
                  'Delete message',
                  style: sheetContext.text.bodyLarge?.copyWith(
                    color: colors.error,
                  ),
                ),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ModerationAction.delete),
              ),
              ListTile(
                leading: const Icon(Icons.volume_off_outlined),
                title: const Text('Mute member'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ModerationAction.mute),
              ),
              ListTile(
                leading: Icon(
                  Icons.remove_circle_outline,
                  color: colors.error,
                ),
                title: Text(
                  'Ban member',
                  style: sheetContext.text.bodyLarge?.copyWith(
                    color: colors.error,
                  ),
                ),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ModerationAction.ban),
              ),
              if (canPromote)
                ListTile(
                  leading: const Icon(Icons.add_moderator_outlined),
                  title: const Text('Make moderator'),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(ModerationAction.promote),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// Mute duration choices (label, minutes).
const kMuteDurations = <(String, int)>[
  ('15 min', 15),
  ('1 hour', 60),
  ('24 hours', 1440),
];

const _kReasonMin = 3;
const _kReasonMax = 300;

bool _reasonValid(String reason) {
  final trimmed = reason.trim();
  return trimmed.length >= _kReasonMin && trimmed.length <= _kReasonMax;
}

/// Reason dialog for deleting a message; pops with the reason or null.
/// Confirm stays disabled until the reason is 3..300 chars (API contract).
Future<String?> showDeleteMessageDialog(BuildContext context) =>
    showDialog<String>(
      context: context,
      builder: (_) => const DeleteMessageDialog(),
    );

/// Public for widget tests: validates the required moderation reason.
class DeleteMessageDialog extends StatefulWidget {
  const DeleteMessageDialog({super.key});

  @override
  State<DeleteMessageDialog> createState() => _DeleteMessageDialogState();
}

class _DeleteMessageDialogState extends State<DeleteMessageDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valid = _reasonValid(_reason.text);
    return AlertDialog(
      title: const Text('Delete message'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The message is replaced by a tombstone everyone can see. '
            'A reason is required.',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.tokens.space3),
          TextField(
            controller: _reason,
            autofocus: true,
            maxLength: _kReasonMax,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'e.g. spam',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.colors.error,
            foregroundColor: context.colors.onError,
          ),
          onPressed: valid
              ? () => Navigator.of(context).pop(_reason.text.trim())
              : null,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

/// Mute dialog; pops with `(minutes, reason)` or null on cancel.
Future<(int, String)?> showMuteMemberDialog(BuildContext context) =>
    showDialog<(int, String)>(
      context: context,
      builder: (_) => const MuteMemberDialog(),
    );

/// Public for widget tests: duration choices + required reason.
class MuteMemberDialog extends StatefulWidget {
  const MuteMemberDialog({super.key});

  @override
  State<MuteMemberDialog> createState() => _MuteMemberDialogState();
}

class _MuteMemberDialogState extends State<MuteMemberDialog> {
  final _reason = TextEditingController();
  int _minutes = 60;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final valid = _reasonValid(_reason.text);
    return AlertDialog(
      title: const Text('Mute member'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: tokens.space2,
            children: [
              for (final (label, minutes) in kMuteDurations)
                ChoiceChip(
                  label: Text(label),
                  selected: _minutes == minutes,
                  onSelected: (_) => setState(() => _minutes = minutes),
                ),
            ],
          ),
          SizedBox(height: tokens.space3),
          TextField(
            controller: _reason,
            maxLength: _kReasonMax,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'Why is this member being muted?',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: valid
              ? () => Navigator.of(context).pop((_minutes, _reason.text.trim()))
              : null,
          child: const Text('Mute'),
        ),
      ],
    );
  }
}

/// Ban confirm dialog; pops with `(reason,)` on confirm (reason optional,
/// but 3..300 when provided) or null on cancel.
Future<(String?,)?> showBanMemberDialog(BuildContext context) =>
    showDialog<(String?,)>(
      context: context,
      builder: (_) => const BanMemberDialog(),
    );

/// Public for widget tests: confirm + optional reason.
class BanMemberDialog extends StatefulWidget {
  const BanMemberDialog({super.key});

  @override
  State<BanMemberDialog> createState() => _BanMemberDialogState();
}

class _BanMemberDialogState extends State<BanMemberDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = _reason.text.trim();
    final valid = trimmed.isEmpty || _reasonValid(trimmed);
    return AlertDialog(
      title: const Text('Ban member?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'They lose access to this group permanently.',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.tokens.space3),
          TextField(
            controller: _reason,
            maxLength: _kReasonMax,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.colors.error,
            foregroundColor: context.colors.onError,
          ),
          onPressed: valid
              ? () => Navigator.of(
                  context,
                ).pop((trimmed.isEmpty ? null : trimmed,))
              : null,
          child: const Text('Ban'),
        ),
      ],
    );
  }
}
