import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/marketplace/data/listings_repository.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Sell flow (J1, spec SS1): minimal-friction listing form.
/// Photo capture + signed-URL upload wires in with
/// image_picker later -- the API's image-upload-url
/// endpoint is already live.
class SellScreen extends ConsumerStatefulWidget {
  const SellScreen({super.key});

  @override
  ConsumerState<SellScreen> createState() =>
      _SellScreenState();
}

class _SellScreenState extends ConsumerState<SellScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  ListingCategory _category =
      ListingCategory.textbooks;
  ListingCondition _condition =
      ListingCondition.good;
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

  static const _categoryLabels =
      <ListingCategory, String>{
    ListingCategory.textbooks: 'Textbooks',
    ListingCategory.furniture: 'Furniture',
    ListingCategory.electronics: 'Electronics',
    ListingCategory.tickets: 'Tickets',
    ListingCategory.clothing: 'Clothing',
    ListingCategory.other: 'Other',
  };

  static const _conditionLabels =
      <ListingCondition, String>{
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
    final value = double.tryParse(
      raw.trim().replaceFirst(r'$', ''),
    );
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
            priceCents:
                _parsePriceCents(_price.text)!,
            category: _category,
            condition: _condition,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing posted!'),
        ),
      );
      await ref
          .read(browseControllerProvider.notifier)
          .refresh();
      if (mounted) context.go('/market');
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorMessage(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell something'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // -- Step indicator --
            _StepIndicator(
              currentStep: _currentStep,
              scheme: scheme,
              tt: tt,
            ),
            // -- Form body --
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(
                  AppSpacing.lg,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode:
                      AutovalidateMode
                          .onUserInteraction,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      // Section: Photos
                      _SectionLabel(
                        icon: Icons
                            .camera_alt_outlined,
                        label: 'Photos',
                        tt: tt,
                        scheme: scheme,
                      ),
                      const SizedBox(
                        height: AppSpacing.sm,
                      ),
                      _PhotoUploadArea(
                        photos: _photoLabels,
                        onAdd: () {
                          setState(() {
                            _photoLabels.add(
                              'Photo '
                              '${_photoLabels.length + 1}',
                            );
                          });
                        },
                        onRemove: (i) {
                          setState(() {
                            _photoLabels.removeAt(i);
                          });
                        },
                      ),
                      const SizedBox(
                        height: AppSpacing.xl,
                      ),

                      // Section: Details
                      _SectionLabel(
                        icon: Icons.edit_outlined,
                        label: 'Details',
                        tt: tt,
                        scheme: scheme,
                      ),
                      const SizedBox(
                        height: AppSpacing.md,
                      ),
                      TextFormField(
                        controller: _title,
                        textCapitalization:
                            TextCapitalization
                                .sentences,
                        decoration:
                            const InputDecoration(
                          labelText: 'Title',
                          hintText: 'e.g. Calculus:'
                              ' Early Transcendentals',
                        ),
                        validator: (v) =>
                            (v == null ||
                                    v.trim().length <
                                        3)
                                ? 'Give it a short'
                                    ' title'
                                : null,
                        onChanged: (_) =>
                            setState(() {}),
                      ),
                      const SizedBox(
                        height: AppSpacing.md,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _price,
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: true,
                              ),
                              decoration:
                                  const InputDecoration(
                                labelText: 'Price',
                                prefixText: r'$ ',
                              ),
                              validator: (v) =>
                                  _parsePriceCents(
                                            v ?? '',
                                          ) ==
                                          null
                                      ? 'Enter a'
                                          ' price'
                                      : null,
                              onChanged: (_) =>
                                  setState(() {}),
                            ),
                          ),
                          const SizedBox(
                            width: AppSpacing.md,
                          ),
                          Expanded(
                            child:
                                DropdownButtonFormField<
                                    ListingCondition>(
                              initialValue:
                                  _condition,
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Condition',
                              ),
                              items: [
                                for (final e
                                    in _conditionLabels
                                        .entries)
                                  DropdownMenuItem(
                                    value: e.key,
                                    child:
                                        Text(e.value),
                                  ),
                              ],
                              onChanged: (v) =>
                                  setState(
                                () => _condition =
                                    v ?? _condition,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: AppSpacing.md,
                      ),
                      DropdownButtonFormField<
                          ListingCategory>(
                        initialValue: _category,
                        decoration:
                            const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: [
                          for (final e
                              in _categoryLabels
                                  .entries)
                            DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                        ],
                        onChanged: (v) => setState(
                          () => _category =
                              v ?? _category,
                        ),
                      ),
                      const SizedBox(
                        height: AppSpacing.xl,
                      ),

                      // Section: Description
                      _SectionLabel(
                        icon: Icons
                            .description_outlined,
                        label: 'Description',
                        tt: tt,
                        scheme: scheme,
                      ),
                      const SizedBox(
                        height: AppSpacing.md,
                      ),
                      TextFormField(
                        controller: _description,
                        maxLines: 4,
                        textCapitalization:
                            TextCapitalization
                                .sentences,
                        decoration:
                            const InputDecoration(
                          labelText: 'Description',
                          hintText:
                              'Condition details,'
                              ' pickup spot...',
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => (v ==
                                    null ||
                                v.trim().isEmpty)
                            ? 'Add a short'
                                ' description'
                            : null,
                      ),
                      const SizedBox(
                        height: AppSpacing.xxl,
                      ),

                      // -- Submit button --
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _submitting
                              ? null
                              : _submit,
                          style:
                              FilledButton.styleFrom(
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                AppRadius.lg,
                              ),
                            ),
                            textStyle:
                                tt.titleSmall
                                    ?.copyWith(
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox
                                  .square(
                                  dimension: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    const Icon(
                                      Icons
                                          .rocket_launch_rounded,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width:
                                          AppSpacing
                                              .sm,
                                    ),
                                    Text(
                                      'Post Listing'
                                          .toUpperCase(),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: AppSpacing.xl,
                      ),
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

// -- Step indicator bar --
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.scheme,
    required this.tt,
  });

  final int currentStep;
  final ColorScheme scheme;
  final TextTheme tt;

  static const _labels = [
    'Photos',
    'Details',
    'Description',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withAlpha(80),
          ),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: i <= currentStep
                        ? scheme.primary
                        : scheme.outlineVariant
                            .withAlpha(80),
                    borderRadius:
                        BorderRadius.circular(1),
                  ),
                ),
              ),
            _StepDot(
              index: i,
              label: _labels[i],
              isActive: i <= currentStep,
              isCurrent: i == currentStep,
              scheme: scheme,
              tt: tt,
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
    required this.scheme,
    required this.tt,
  });

  final int index;
  final String label;
  final bool isActive;
  final bool isCurrent;
  final ColorScheme scheme;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: AppMotion.release,
          width: isCurrent ? 28 : 24,
          height: isCurrent ? 28 : 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? scheme.primary
                : scheme.surfaceContainerHighest,
            border: isCurrent
                ? Border.all(
                    color: scheme.primary
                        .withAlpha(80),
                    width: 3,
                  )
                : null,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: tt.labelSmall?.copyWith(
                color: isActive
                    ? scheme.onPrimary
                    : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: isActive
                ? scheme.primary
                : scheme.onSurfaceVariant,
            fontWeight: isCurrent
                ? FontWeight.w700
                : FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// -- Section label with icon --
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.tt,
    required this.scheme,
  });

  final IconData icon;
  final String label;
  final TextTheme tt;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label.toUpperCase(),
          style: tt.labelMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// -- Photo upload area with dashed border --
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
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (photos.isEmpty) {
      // Large inviting upload area
      return GestureDetector(
        onTap: onAdd,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: scheme.primary.withAlpha(120),
            radius: AppRadius.lg,
          ),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color:
                  scheme.primary.withAlpha(12),
              borderRadius:
                  BorderRadius.circular(
                AppRadius.lg,
              ),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: scheme.primary
                        .withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_a_photo_rounded,
                    color: scheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.md,
                ),
                Text(
                  'Add photos',
                  style: tt.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.xs,
                ),
                Text(
                  'Up to 5 photos. '
                  'Tap to get started.',
                  style: tt.bodySmall?.copyWith(
                    color:
                        scheme.onSurfaceVariant,
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
              for (var i = 0;
                  i < photos.length;
                  i++)
                Padding(
                  padding: const EdgeInsets.only(
                    right: AppSpacing.sm,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: scheme
                              .surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(
                            AppRadius.md,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(
                              Icons
                                  .image_rounded,
                              color: scheme
                                  .onSurfaceVariant,
                              size: 28,
                            ),
                            const SizedBox(
                              height:
                                  AppSpacing.xs,
                            ),
                            Text(
                              photos[i],
                              style: tt
                                  .labelSmall
                                  ?.copyWith(
                                color: scheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () =>
                              onRemove(i),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration:
                                BoxDecoration(
                              color:
                                  scheme.error,
                              shape:
                                  BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors
                                      .black
                                      .withAlpha(
                                    40,
                                  ),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color:
                                  scheme.onError,
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
                      color: scheme.primary
                          .withAlpha(100),
                      radius: AppRadius.md,
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: scheme.primary
                            .withAlpha(8),
                        borderRadius:
                            BorderRadius.circular(
                          AppRadius.md,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Icon(
                            Icons
                                .add_photo_alternate_outlined,
                            color:
                                scheme.primary,
                            size: 24,
                          ),
                          const SizedBox(
                            height:
                                AppSpacing.xs,
                          ),
                          Text(
                            'Add more',
                            style: tt.labelSmall
                                ?.copyWith(
                              color:
                                  scheme.primary,
                              fontWeight:
                                  FontWeight.w600,
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
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
          ),
          child: Text(
            'Photos upload via signed URL to S3. '
            'Pending moderation review.',
            style: tt.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints a dashed rounded-rect border.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
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
          metric.extractPath(
            distance,
            next.clamp(0, metric.length),
          ),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(
    _DashedBorderPainter old,
  ) =>
      old.color != color || old.radius != radius;
}
