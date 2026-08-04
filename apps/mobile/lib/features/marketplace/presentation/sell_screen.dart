import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/marketplace/data/listings_repository.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Sell flow (J1, whole.md §5.2): minimal-friction listing form with a
/// 3-step progress indicator. Photo capture + signed-URL upload wires in
/// with image_picker later — the API's image-upload-url endpoint is live.
class SellScreen extends ConsumerStatefulWidget {
  const SellScreen({super.key});

  @override
  ConsumerState<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends ConsumerState<SellScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  ListingCategory _category = ListingCategory.textbooks;
  ListingCondition _condition = ListingCondition.good;
  bool _submitting = false;
  final List<String> _photoLabels = [];

  /// Current visual step (0=photos, 1=details, 2=desc).
  int get _currentStep {
    if (_photoLabels.isNotEmpty &&
        _title.text.trim().length >= 3 &&
        _parsePriceCents(_price.text) != null) {
      return 2;
    }
    if (_photoLabels.isNotEmpty) return 1;
    return 0;
  }

  static const _categoryLabels = <ListingCategory, String>{
    ListingCategory.textbooks: 'Textbooks',
    ListingCategory.furniture: 'Furniture',
    ListingCategory.electronics: 'Electronics',
    ListingCategory.tickets: 'Tickets',
    ListingCategory.clothing: 'Clothing',
    ListingCategory.other: 'Other',
  };

  static const _conditionLabels = <ListingCondition, String>{
    ListingCondition.new_: 'New',
    ListingCondition.likeNew: 'Like new',
    ListingCondition.good: 'Good',
    ListingCondition.fair: 'Fair',
    ListingCondition.poor: 'Poor',
  };

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  int? _parsePriceCents(String raw) {
    final value = double.tryParse(raw.trim().replaceFirst(r'$', ''));
    if (value == null || value < 0) return null;
    return (value * 100).round();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(listingsRepositoryProvider)
          .createListing(
            title: _title.text.trim(),
            description: _description.text.trim(),
            priceCents: _parsePriceCents(_price.text)!,
            category: _category,
            condition: _condition,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Listing posted.')));
      await ref.read(browseControllerProvider.notifier).refresh();
      if (mounted) context.go('/market');
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('Sell something')),
      body: SafeArea(
        child: Column(
          children: [
            // -- Step indicator --
            _StepIndicator(currentStep: _currentStep),
            // -- Form body --
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(tokens.space4),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section: Photos
                      const _SectionLabel(label: 'Photos'),
                      SizedBox(height: tokens.space2),
                      _PhotoUploadArea(
                        photos: _photoLabels,
                        onAdd: () {
                          setState(() {
                            _photoLabels.add(
                              'Photo ${_photoLabels.length + 1}',
                            );
                          });
                        },
                        onRemove: (i) {
                          setState(() {
                            _photoLabels.removeAt(i);
                          });
                        },
                      ),
                      SizedBox(height: tokens.space6),

                      // Section: Details
                      const _SectionLabel(label: 'Details'),
                      SizedBox(height: tokens.space3),
                      TextFormField(
                        controller: _title,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'e.g. Calculus: Early Transcendentals',
                        ),
                        validator: (v) => (v == null || v.trim().length < 3)
                            ? 'Give it a short title'
                            : null,
                        onChanged: (_) => setState(() {}),
                      ),
                      SizedBox(height: tokens.space3),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _price,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Price',
                                prefixText: r'$ ',
                              ),
                              validator: (v) =>
                                  _parsePriceCents(v ?? '') == null
                                  ? 'Enter a price'
                                  : null,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          SizedBox(width: tokens.space3),
                          Expanded(
                            child: DropdownButtonFormField<ListingCondition>(
                              initialValue: _condition,
                              decoration: const InputDecoration(
                                labelText: 'Condition',
                              ),
                              items: [
                                for (final e in _conditionLabels.entries)
                                  DropdownMenuItem(
                                    value: e.key,
                                    child: Text(e.value),
                                  ),
                              ],
                              onChanged: (v) => setState(
                                () => _condition = v ?? _condition,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: tokens.space3),
                      DropdownButtonFormField<ListingCategory>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: [
                          for (final e in _categoryLabels.entries)
                            DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                        ],
                        onChanged: (v) =>
                            setState(() => _category = v ?? _category),
                      ),
                      SizedBox(height: tokens.space6),

                      // Section: Description
                      const _SectionLabel(label: 'Description'),
                      SizedBox(height: tokens.space3),
                      TextFormField(
                        controller: _description,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Condition details, pickup spot...',
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Add a short description'
                            : null,
                      ),
                      SizedBox(height: tokens.space8),

                      // -- Submit button --
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? SizedBox.square(
                                  dimension: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: context.colors.onPrimary,
                                  ),
                                )
                              : const Text('Post listing'),
                        ),
                      ),
                      SizedBox(height: tokens.space2),
                      Text(
                        'Listings expire after 90 days. '
                        'You can renew anytime.',
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant.withValues(
                            alpha: .8,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: tokens.space6),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -- Step indicator bar (whole.md §5.2) — neutral progress, hairline base --
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  static const _labels = ['Photos', 'Details', 'Description'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space4,
        vertical: tokens.space3,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  margin: EdgeInsets.symmetric(horizontal: tokens.space2),
                  color: i <= currentStep
                      ? colors.onSurface
                      : colors.outlineVariant,
                ),
              ),
            _StepDot(
              index: i,
              label: _labels[i],
              isActive: i <= currentStep,
              isCurrent: i == currentStep,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.index,
    required this.label,
    required this.isActive,
    required this.isCurrent,
  });

  final int index;
  final String label;
  final bool isActive;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: Durations.short4,
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? colors.onSurface : colors.surfaceContainerHigh,
            border: isActive ? null : Border.all(color: colors.outlineVariant),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: text.labelSmall?.copyWith(
                color: isActive ? colors.surface : colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: text.labelSmall?.copyWith(
            color: isActive ? colors.onSurface : colors.onSurfaceVariant,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// -- Section header (whole.md §6: 13/w600 onSurfaceVariant, ls 0.4) --
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: context.text.labelMedium?.copyWith(
        fontSize: 13,
        color: context.colors.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}

// -- Photo upload area with dashed hairline border (Law 1: no fills) --
class _PhotoUploadArea extends StatelessWidget {
  const _PhotoUploadArea({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    if (photos.isEmpty) {
      // Large inviting upload area
      return GestureDetector(
        onTap: onAdd,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: colors.outlineVariant,
            radius: tokens.radiusMd,
          ),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: tokens.brMd,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    color: colors.onSurface,
                    size: 24,
                  ),
                ),
                SizedBox(height: tokens.space3),
                Text(
                  'Add photos',
                  style: text.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: tokens.space1),
                Text(
                  'Up to 5 photos. Tap to get started.',
                  style: text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Photo thumbnails + add more
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (var i = 0; i < photos.length; i++)
                Padding(
                  padding: EdgeInsets.only(right: tokens.space2),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: tokens.brMd,
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              color: colors.onSurfaceVariant,
                              size: 28,
                            ),
                            SizedBox(height: tokens.space1),
                            Text(
                              photos[i],
                              style: text.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => onRemove(i),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHigh,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.outlineVariant,
                              ),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (photos.length < 5)
                GestureDetector(
                  onTap: onAdd,
                  child: CustomPaint(
                    painter: _DashedBorderPainter(
                      color: colors.outlineVariant,
                      radius: tokens.radiusMd,
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: tokens.brMd,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: colors.onSurface,
                            size: 24,
                          ),
                          SizedBox(height: tokens.space1),
                          Text(
                            'Add more',
                            style: text.labelSmall?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: tokens.space2),
          child: Text(
            'Photos upload via signed URL to S3. '
            'Pending moderation review.',
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// Paints a dashed rounded-rect border.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
