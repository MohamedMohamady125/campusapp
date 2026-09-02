import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/components/pressable.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/food_runs/data/runs_repository.dart';
import 'package:campusconnect/features/food_runs/presentation/payment_method_display.dart';
import 'package:campusconnect/features/food_runs/presentation/runs_feed_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Start-a-run form: where you're going, when you're leaving, what it
/// costs to tag along. Paid/prepay runs require a payment method —
/// prompted inline, saved via PATCH /users/me before submit.
class CreateRunScreen extends ConsumerStatefulWidget {
  const CreateRunScreen({super.key});

  @override
  ConsumerState<CreateRunScreen> createState() => _CreateRunScreenState();
}

class _CreateRunScreenState extends ConsumerState<CreateRunScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fee = TextEditingController();
  final _note = TextEditingController();
  final _quickHandle = TextEditingController();

  FoodSpotResponse? _spot;
  int _leavingMinutes = 15;
  int _spotsMax = 3;
  bool _prepay = false;
  bool _diningDollars = false;
  bool _submitting = false;
  List<FoodSpotResponse> _spots = [];
  bool _hasPaymentMethod = false;
  PaymentMethodType _quickType = kSelectablePaymentTypes.first;

  static const _quickMinutes = [10, 15, 30, 45];

  @override
  void initState() {
    super.initState();
    final repo = ref.read(runsRepositoryProvider);
    repo.fetchSpots().then((spots) {
      if (mounted) setState(() => _spots = spots);
    }).ignore();
    repo.fetchMe().then((me) {
      if (mounted) {
        setState(() => _hasPaymentMethod = me.paymentMethods.isNotEmpty);
      }
    }).ignore();
  }

  @override
  void dispose() {
    _fee.dispose();
    _note.dispose();
    _quickHandle.dispose();
    super.dispose();
  }

  int? _feeCents() {
    final raw = _fee.text.trim().replaceFirst(r'$', '');
    if (raw.isEmpty) return 0;
    final value = double.tryParse(raw);
    if (value == null || value < 0) return null;
    final cents = (value * 100).round();
    return cents > 2000 ? null : cents;
  }

  bool get _needsPayment {
    final fee = _feeCents() ?? 0;
    if (fee == 0 && !_prepay) return false;
    return !_hasPaymentMethod;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_spot == null) {
      _snack("Pick where you're headed first.");
      return;
    }
    if (_needsPayment && _quickHandle.text.trim().length < 2) {
      _snack('Add a payment handle so people can pay you.');
      return;
    }
    setState(() => _submitting = true);
    final repo = ref.read(runsRepositoryProvider);
    try {
      if (_needsPayment) {
        final me = await repo.savePaymentMethods([
          PaymentMethod(
            (b) => b
              ..type = _quickType
              ..handle = _quickHandle.text.trim(),
          ),
        ]);
        _hasPaymentMethod = me.paymentMethods.isNotEmpty;
      }
      final run = await repo.createRun(
        foodSpotId: _spot!.id,
        leavingAt: DateTime.now().toUtc().add(
          Duration(minutes: _leavingMinutes),
        ),
        feeCents: _feeCents()!,
        spotsMax: _spotsMax,
        prepayRequired: _prepay,
        paysWithDiningDollars: _diningDollars,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      ref.read(runsFeedControllerProvider.notifier).refresh().ignore();
      if (!mounted) return;
      _snack('Run posted. Orders incoming!');
      context.go('/runs/run/${run.id}');
    } on Object catch (e) {
      if (mounted) _snack(apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickSpot() async {
    final picked = await showModalBottomSheet<FoodSpotResponse>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SpotPickerSheet(spots: _spots),
    );
    if (picked != null && mounted) setState(() => _spot = picked);
  }

  Future<void> _customLeaving() async {
    final controller = TextEditingController(text: '$_leavingMinutes');
    final minutes = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leaving in how many minutes?'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'min'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(int.tryParse(controller.text.trim())),
            child: const Text('Set'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (minutes != null && minutes > 0 && minutes <= 24 * 60 && mounted) {
      setState(() => _leavingMinutes = minutes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Start a run')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.space4),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SectionLabel(label: 'Where are you headed?'),
                SizedBox(height: tokens.space2),
                Pressable(
                  onTap: _pickSpot,
                  child: Container(
                    padding: EdgeInsets.all(tokens.space4),
                    decoration: BoxDecoration(
                      borderRadius: tokens.brSm,
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _spot == null
                              ? Icons.storefront_outlined
                              : Icons.check_circle_outline,
                          color: _spot == null
                              ? colors.onSurfaceVariant
                              : tokens.success,
                        ),
                        SizedBox(width: tokens.space3),
                        Expanded(
                          child: Text(
                            _spot?.name ?? 'Pick a food spot',
                            style: context.text.titleSmall?.copyWith(
                              color: _spot == null
                                  ? colors.onSurfaceVariant
                                  : colors.onSurface,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.expand_more,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: tokens.space6),

                const _SectionLabel(label: 'Leaving in'),
                SizedBox(height: tokens.space2),
                Wrap(
                  spacing: tokens.space2,
                  children: [
                    for (final m in _quickMinutes)
                      ChoiceChip(
                        label: Text('${m}m'),
                        selected: _leavingMinutes == m,
                        onSelected: (_) => setState(() => _leavingMinutes = m),
                      ),
                    ChoiceChip(
                      label: Text(
                        _quickMinutes.contains(_leavingMinutes)
                            ? 'Custom'
                            : '${_leavingMinutes}m',
                      ),
                      selected: !_quickMinutes.contains(_leavingMinutes),
                      onSelected: (_) => _customLeaving(),
                    ),
                  ],
                ),
                SizedBox(height: tokens.space6),

                const _SectionLabel(label: 'The deal'),
                SizedBox(height: tokens.space3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _fee,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Fee per order',
                          prefixText: r'$ ',
                          hintText: '0 = free',
                        ),
                        validator: (_) =>
                            _feeCents() == null ? r'Between $0 and $20' : null,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    SizedBox(width: tokens.space3),
                    Expanded(
                      child: _SpotsStepper(
                        value: _spotsMax,
                        onChanged: (v) => setState(() => _spotsMax = v),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.space2),
                SwitchListTile(
                  value: _prepay,
                  onChanged: (v) => setState(() => _prepay = v),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Require prepay'),
                  subtitle: const Text(
                    'People pay you before you order',
                  ),
                ),
                SwitchListTile(
                  value: _diningDollars,
                  onChanged: (v) => setState(() => _diningDollars = v),
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    Icons.credit_card_outlined,
                    color: colors.onSurfaceVariant,
                  ),
                  title: const Text('Paying with dining dollars'),
                  subtitle: const Text(
                    "You'll buy on your meal plan — "
                    'people still pay you back',
                  ),
                ),
                if (_needsPayment) ...[
                  SizedBox(height: tokens.space3),
                  _PaymentPromptCard(
                    type: _quickType,
                    handle: _quickHandle,
                    onTypeChanged: (t) => setState(() => _quickType = t),
                  ),
                ],
                SizedBox(height: tokens.space6),

                const _SectionLabel(label: 'Anything else?'),
                SizedBox(height: tokens.space3),
                TextFormField(
                  controller: _note,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    hintText: 'e.g. Cash-only spot, keep orders simple',
                    alignLabelWithHint: true,
                  ),
                ),
                SizedBox(height: tokens.space8),

                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: context.colors.onPrimary,
                          ),
                        )
                      : const Text('Post run'),
                ),
                SizedBox(height: tokens.space2),
                Text(
                  'Payment stays off-app — accepted people see your '
                  'payment methods.',
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: .8),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: tokens.space6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -- Eyebrow micro-label (Fifty Free: Inter 11/w700, ls 1, UPPERCASE) --
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(), style: AppTextStyles.label);
  }
}

/// 1–10 spots stepper — a stepper beats a keyboard for a tiny range.
class _SpotsStepper extends StatelessWidget {
  const _SpotsStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Spots'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: 'Fewer spots',
            visualDensity: VisualDensity.compact,
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline, size: 20),
          ),
          Text(
            '$value',
            style: context.text.titleMedium?.copyWith(
              color: colors.onSurface,
            ),
          ),
          IconButton(
            tooltip: 'More spots',
            visualDensity: VisualDensity.compact,
            onPressed: value < 10 ? () => onChanged(value + 1) : null,
            icon: Icon(
              Icons.add_circle_outline,
              size: 20,
              color: value < 10 ? colors.onSurface : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline payment prompt: paid/prepay runs can't post without a method
/// (the API enforces PAYMENT_METHOD_REQUIRED — we fix it before submit).
/// You can add more rails later in Profile → Payment methods.
class _PaymentPromptCard extends StatelessWidget {
  const _PaymentPromptCard({
    required this.type,
    required this.handle,
    required this.onTypeChanged,
  });

  final PaymentMethodType type;
  final TextEditingController handle;
  final ValueChanged<PaymentMethodType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.space4),
      decoration: BoxDecoration(
        color: tokens.warningContainer,
        borderRadius: tokens.brSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: tokens.warning,
              ),
              SizedBox(width: tokens.space2),
              Expanded(
                child: Text(
                  'How will people pay you?',
                  style: context.text.titleSmall,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space3),
          DropdownButtonFormField<PaymentMethodType>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'App'),
            items: [
              for (final t in kSelectablePaymentTypes)
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
            onChanged: (t) => onTypeChanged(t ?? type),
          ),
          SizedBox(height: tokens.space2),
          TextFormField(
            controller: handle,
            decoration: InputDecoration(
              labelText: 'Handle',
              hintText: type.handleHint,
            ),
          ),
        ],
      ),
    );
  }
}

/// Searchable, grouped (campus / off-campus) food-spot picker sheet.
class _SpotPickerSheet extends StatefulWidget {
  const _SpotPickerSheet({required this.spots});

  final List<FoodSpotResponse> spots;

  @override
  State<_SpotPickerSheet> createState() => _SpotPickerSheetState();
}

class _SpotPickerSheetState extends State<_SpotPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final filtered = widget.spots
        .where((s) => s.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final campus = filtered
        .where((s) => s.category == FoodSpotCategory.campus)
        .toList();
    final offCampus = filtered
        .where((s) => s.category == FoodSpotCategory.offCampus)
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      builder: (context, scroll) => Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.space4,
          tokens.space3,
          tokens.space4,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Where to?', style: AppTextStyles.subheading),
            SizedBox(height: tokens.space3),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search spots',
              ),
              onChanged: (q) => setState(() => _query = q.trim()),
            ),
            SizedBox(height: tokens.space2),
            Expanded(
              child: widget.spots.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      controller: scroll,
                      children: [
                        if (campus.isNotEmpty) ...[
                          _groupHeader(context, 'On campus'),
                          for (final s in campus) _spotTile(context, s),
                        ],
                        if (offCampus.isNotEmpty) ...[
                          _groupHeader(context, 'Off campus'),
                          for (final s in offCampus) _spotTile(context, s),
                        ],
                        if (filtered.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(tokens.space6),
                            child: Center(
                              child: Text(
                                'No spots match that.',
                                style: context.text.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
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

  Widget _groupHeader(BuildContext context, String label) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.only(top: tokens.space3, bottom: tokens.space1),
      child: Text(label.toUpperCase(), style: AppTextStyles.label),
    );
  }

  Widget _spotTile(BuildContext context, FoodSpotResponse spot) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        spot.category == FoodSpotCategory.campus
            ? Icons.school_outlined
            : Icons.storefront_outlined,
      ),
      title: Text(spot.name),
      subtitle: spot.description == null ? null : Text(spot.description!),
      onTap: () => Navigator.of(context).pop(spot),
    );
  }
}
