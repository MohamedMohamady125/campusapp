import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/components/pressable.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_colors.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/food_runs/data/runs_repository.dart';
import 'package:campusconnect/features/food_runs/presentation/payment_method_display.dart';
import 'package:campusconnect/features/food_runs/presentation/run_format.dart';
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
  final _note = TextEditingController();
  final _quickHandle = TextEditingController();

  FoodSpotResponse? _spot;
  // Defaults to the current time; the user picks an exact departure time.
  DateTime _leavingAt = DateTime.now();
  // Per-order fee the runner charges, in cents. Steps in $0.25, capped $20.
  int _feeCentsValue = 200;
  int _spotsMax = 3;
  bool _prepay = false;
  bool _submitting = false;
  List<FoodSpotResponse> _spots = [];
  bool _hasPaymentMethod = false;
  PaymentMethodType _quickType = kSelectablePaymentTypes.first;

  @override
  void initState() {
    super.initState();
    _leavingAt = DateTime.now();
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
    _note.dispose();
    _quickHandle.dispose();
    super.dispose();
  }

  bool get _needsPayment {
    if (_feeCentsValue == 0 && !_prepay) return false;
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
        leavingAt: _leavingAt.toUtc(),
        feeCents: _feeCentsValue,
        spotsMax: _spotsMax,
        prepayRequired: _prepay,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      ref.read(runsFeedControllerProvider.notifier).pokeAfterMutation();
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

  /// Bumps the departure to a round offset from *now* (the quick chips).
  void _quickLeaving(Duration offset) {
    setState(() => _leavingAt = DateTime.now().add(offset));
  }

  /// Exact chosen time for the picker card, e.g. `3:45 PM`, `Tomorrow 8:00 AM`.
  String _leavingDisplay() {
    final now = DateTime.now();
    final time = clockTime(_leavingAt);
    final target = DateTime(_leavingAt.year, _leavingAt.month, _leavingAt.day);
    final today = DateTime(now.year, now.month, now.day);
    final days = target.difference(today).inDays;
    if (days == 0) return time;
    if (days == 1) return 'Tomorrow $time';
    return '${_leavingAt.month}/${_leavingAt.day} $time';
  }

  /// Opens the native clock picker for an exact departure time. A time that has
  /// already passed today rolls to tomorrow so it's never in the past.
  Future<void> _pickLeavingTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_leavingAt),
      helpText: 'What time are you leaving?',
    );
    if (picked == null || !mounted) return;
    final now = DateTime.now();
    var when = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );
    if (when.isBefore(now.subtract(const Duration(minutes: 1)))) {
      when = when.add(const Duration(days: 1));
    }
    setState(() => _leavingAt = when);
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

                const _SectionLabel(label: 'When are you leaving?'),
                SizedBox(height: tokens.space2),
                Pressable(
                  onTap: _pickLeavingTime,
                  child: Container(
                    padding: EdgeInsets.all(tokens.space4),
                    decoration: BoxDecoration(
                      borderRadius: tokens.brSm,
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, color: colors.primary),
                        SizedBox(width: tokens.space3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _leavingDisplay(),
                                style: context.text.titleMedium?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Tap to pick an exact time',
                                style: context.text.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: tokens.space3),
                Wrap(
                  spacing: tokens.space2,
                  children: [
                    ActionChip(
                      label: const Text('Now'),
                      onPressed: () => _quickLeaving(Duration.zero),
                    ),
                    ActionChip(
                      label: const Text('+15 min'),
                      onPressed: () =>
                          _quickLeaving(const Duration(minutes: 15)),
                    ),
                    ActionChip(
                      label: const Text('+30 min'),
                      onPressed: () =>
                          _quickLeaving(const Duration(minutes: 30)),
                    ),
                    ActionChip(
                      label: const Text('+1 hr'),
                      onPressed: () => _quickLeaving(const Duration(hours: 1)),
                    ),
                  ],
                ),
                SizedBox(height: tokens.space6),

                const _SectionLabel(label: 'The deal'),
                SizedBox(height: tokens.space3),
                _StepperField(
                  label: 'Fee per order',
                  valueLabel: _feeCentsValue == 0
                      ? 'Free'
                      : runFeeAmount(_feeCentsValue),
                  onDecrement: _feeCentsValue > 0
                      ? () => setState(
                          () => _feeCentsValue = (_feeCentsValue - 25).clamp(
                            0,
                            2000,
                          ),
                        )
                      : null,
                  onIncrement: _feeCentsValue < 2000
                      ? () => setState(
                          () => _feeCentsValue = (_feeCentsValue + 25).clamp(
                            0,
                            2000,
                          ),
                        )
                      : null,
                ),
                SizedBox(height: tokens.space3),
                _StepperField(
                  label: 'Spots',
                  valueLabel: '$_spotsMax',
                  onDecrement: _spotsMax > 1
                      ? () => setState(() => _spotsMax -= 1)
                      : null,
                  onIncrement: _spotsMax < 10
                      ? () => setState(() => _spotsMax += 1)
                      : null,
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
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: Colors.white,
                  ),
                  child: _submitting
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Post run · takes orders now'),
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

/// A labelled −/+ stepper row (fee, spots): eyebrow label left, big tabular
/// value flanked by round steppers right. A stepper beats a keyboard for a
/// tiny range and reads cleanly in the "Fifty Free" language.
class _StepperField extends StatelessWidget {
  const _StepperField({
    required this.label,
    required this.valueLabel,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final String valueLabel;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space4,
        vertical: tokens.space3,
      ),
      decoration: BoxDecoration(
        borderRadius: tokens.brSm,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label.toUpperCase(), style: AppTextStyles.label),
          ),
          IconButton(
            tooltip: 'Less',
            visualDensity: VisualDensity.compact,
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_circle_outline, size: 24),
          ),
          SizedBox(
            width: 72,
            child: Text(
              valueLabel,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
          IconButton(
            tooltip: 'More',
            visualDensity: VisualDensity.compact,
            onPressed: onIncrement,
            icon: const Icon(Icons.add_circle_outline, size: 24),
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
