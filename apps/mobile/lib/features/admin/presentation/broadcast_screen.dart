import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/admin/data/broadcast_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Admin announcement composer: free-form title/body, sent as an in-app
/// notification + push to everyone or to specific students by email.
class BroadcastScreen extends ConsumerStatefulWidget {
  const BroadcastScreen({super.key});

  @override
  ConsumerState<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends ConsumerState<BroadcastScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _emails = TextEditingController();
  bool _everyone = true;
  bool _sending = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _emails.dispose();
    super.dispose();
  }

  List<String> get _emailList => _emails.text
      .split(RegExp(r'[\s,;]+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final emails = _everyone ? const <String>[] : _emailList;
    final who = _everyone
        ? 'every active student'
        : '${emails.length} ${emails.length == 1 ? 'student' : 'students'}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send announcement?'),
        content: Text('"${_title.text.trim()}" will notify $who.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _sending = true);
    try {
      final result = await ref
          .read(broadcastRepositoryProvider)
          .send(
            title: _title.text.trim(),
            body: _body.text.trim(),
            emails: emails,
          );
      if (!mounted) return;
      final unknown = result.unknownEmails;
      final suffix = unknown.isEmpty ? '' : ' Unknown: ${unknown.join(', ')}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sent to ${result.sent}.$suffix')),
      );
      _title.clear();
      _body.clear();
      _emails.clear();
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('Send announcement')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.space4),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Delivered as a push notification and an in-app '
                  'notification, exactly as written.',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: tokens.space4),
                TextFormField(
                  controller: _title,
                  maxLength: 80,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Enter a title' : null,
                ),
                SizedBox(height: tokens.space3),
                TextFormField(
                  controller: _body,
                  maxLength: 300,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Message (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
                SizedBox(height: tokens.space4),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Everyone')),
                    ButtonSegment(value: false, label: Text('Specific emails')),
                  ],
                  selected: {_everyone},
                  showSelectedIcon: false,
                  onSelectionChanged: (sel) =>
                      setState(() => _everyone = sel.first),
                ),
                if (!_everyone) ...[
                  SizedBox(height: tokens.space3),
                  TextFormField(
                    controller: _emails,
                    minLines: 2,
                    maxLines: 5,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Emails',
                      hintText: 'one@campus.edu, two@campus.edu',
                      alignLabelWithHint: true,
                    ),
                    validator: (_) => _everyone || _emailList.isNotEmpty
                        ? null
                        : 'Add at least one email',
                  ),
                ],
                SizedBox(height: tokens.space5),
                FilledButton(
                  onPressed: _sending ? null : _send,
                  child: _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send announcement'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
