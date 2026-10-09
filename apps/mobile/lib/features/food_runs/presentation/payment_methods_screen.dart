import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/food_runs/data/runs_repository.dart';
import 'package:campusconnect/features/food_runs/presentation/payment_method_display.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manage the off-app payment rails a runner advertises (food-runs spec).
/// CampusConnect never moves money — these handles are shown to people the
/// runner accepts, so they can pay in Venmo/Zelle/Cash App/etc. directly.
class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  bool _saving = false;

  List<PaymentMethod> get _methods =>
      ref.watch(authControllerProvider).user?.paymentMethods.toList() ??
      const [];

  Future<void> _persist(List<PaymentMethod> next) async {
    setState(() => _saving = true);
    try {
      await ref.read(runsRepositoryProvider).savePaymentMethods(next);
      await ref.read(authControllerProvider.notifier).refreshProfile();
    } on Object catch (e) {
      if (mounted) _snack(apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addOrEdit({PaymentMethod? existing}) async {
    final used = _methods
        .map((m) => m.type)
        .where((t) => t != existing?.type)
        .toSet();
    final result = await showModalBottomSheet<PaymentMethod>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PaymentMethodEditor(existing: existing, usedTypes: used),
    );
    if (result == null) return;
    final next = [
      for (final m in _methods)
        if (m.type != result.type && m.type != existing?.type) m,
      result,
    ];
    await _persist(next);
  }

  Future<void> _remove(PaymentMethod method) async {
    // QA S-02: removal is one tap on a trash icon — confirm first.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove ${method.type.label}?'),
        content: Text(
          'People you accept will no longer see ${method.handle}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _persist([
      for (final m in _methods)
        if (m.type != method.type) m,
    ]);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final methods = _methods;
    final canAdd = methods.length < kSelectablePaymentTypes.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment methods')),
      body: ListView(
        padding: EdgeInsets.all(tokens.space4),
        children: [
          Text(
            'Shown to people you accept, so they can pay you off-app.',
            style: context.text.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.space4),
          if (methods.isEmpty)
            _EmptyMethods(onAdd: _saving ? null : _addOrEdit)
          else
            // Hairline-bordered surface instead of an elevated Card — same
            // airy language as the runs feed cards.
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: tokens.brMd,
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < methods.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: 56),
                    _MethodTile(
                      method: methods[i],
                      onEdit: _saving
                          ? null
                          : () => _addOrEdit(existing: methods[i]),
                      onRemove: _saving ? null : () => _remove(methods[i]),
                    ),
                  ],
                ],
              ),
            ),
          SizedBox(height: tokens.space4),
          if (methods.isNotEmpty && canAdd)
            OutlinedButton.icon(
              onPressed: _saving ? null : _addOrEdit,
              icon: const Icon(Icons.add),
              label: const Text('Add another method'),
            ),
          if (_saving) ...[
            SizedBox(height: tokens.space4),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.onEdit,
    required this.onRemove,
  });

  final PaymentMethod method;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(method.type.icon),
      title: Text(method.type.label),
      subtitle: Text(method.handle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: 'Remove',
            icon: Icon(Icons.delete_outline, color: context.colors.error),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _EmptyMethods extends StatelessWidget {
  const _EmptyMethods({required this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(tokens.space5),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: tokens.brSm,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 40,
            color: colors.onSurfaceVariant,
          ),
          SizedBox(height: tokens.space3),
          Text(
            'No payment methods yet',
            style: context.text.titleSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.space1),
          Text(
            'Add one so you can charge a fee on your runs.',
            style: context.text.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.space4),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add a payment method'),
          ),
        ],
      ),
    );
  }
}

/// Bottom-sheet editor: pick a rail + enter its handle (phone, email, or
/// username). Returns the built [PaymentMethod] on save, or null on cancel.
/// No QR attachment — a payer can't scan a QR shown on their own phone.
class _PaymentMethodEditor extends ConsumerStatefulWidget {
  const _PaymentMethodEditor({required this.existing, required this.usedTypes});

  final PaymentMethod? existing;
  final Set<PaymentMethodType> usedTypes;

  @override
  ConsumerState<_PaymentMethodEditor> createState() =>
      _PaymentMethodEditorState();
}

class _PaymentMethodEditorState extends ConsumerState<_PaymentMethodEditor> {
  late PaymentMethodType _type;
  late final TextEditingController _handle;

  @override
  void initState() {
    super.initState();
    final available = kSelectablePaymentTypes
        .where((t) => !widget.usedTypes.contains(t))
        .toList();
    _type =
        widget.existing?.type ??
        (available.isEmpty ? kSelectablePaymentTypes.first : available.first);
    _handle = TextEditingController(text: widget.existing?.handle ?? '');
  }

  @override
  void dispose() {
    _handle.dispose();
    super.dispose();
  }

  String? _handleError;

  /// Per-rail sanity checks (QA M-08: Cash App accepted "two words").
  /// Light-touch — the handle lives off-app, so we only catch obvious typos.
  String? _validateHandle(String handle) {
    if (handle.length < 2) return 'Enter the handle people pay you at.';
    if (_type == PaymentMethodType.cashapp && handle.contains(' ')) {
      return r'Cashtags have no spaces — e.g. $yourcashtag.';
    }
    if (_type == PaymentMethodType.venmo && handle.contains(' ')) {
      return 'Venmo usernames have no spaces — e.g. @your-venmo.';
    }
    return null;
  }

  void _save() {
    final handle = _handle.text.trim();
    final error = _validateHandle(handle);
    if (error != null) {
      // QA S-02: a dead Save button told the tester nothing — explain.
      setState(() => _handleError = error);
      return;
    }
    Navigator.of(context).pop(
      PaymentMethod(
        (b) => b
          ..type = _type
          ..handle = handle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final options = kSelectablePaymentTypes
        .where((t) => t == _type || !widget.usedTypes.contains(t))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: tokens.space4,
        right: tokens.space4,
        top: tokens.space4,
        bottom: MediaQuery.of(context).viewInsets.bottom + tokens.space4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing == null ? 'Add payment method' : 'Edit method',
            style: context.text.titleMedium,
          ),
          SizedBox(height: tokens.space4),
          DropdownButtonFormField<PaymentMethodType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'App'),
            items: [
              for (final t in options)
                DropdownMenuItem(
                  value: t,
                  child: Row(
                    children: [
                      Icon(t.icon, size: 20),
                      SizedBox(width: tokens.space2),
                      Text(t.label),
                    ],
                  ),
                ),
            ],
            onChanged: (t) => setState(() {
              _type = t ?? _type;
              _handleError = null;
            }),
          ),
          SizedBox(height: tokens.space3),
          TextField(
            controller: _handle,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Phone, email, or username',
              hintText: _type.handleHint,
              errorText: _handleError,
            ),
            onChanged: (_) {
              if (_handleError != null) setState(() => _handleError = null);
            },
            onSubmitted: (_) => _save(),
          ),
          SizedBox(height: tokens.space5),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
