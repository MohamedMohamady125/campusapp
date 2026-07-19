import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/marketplace/data/listings_repository.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Sell flow (J1, spec §1): minimal-friction listing form.
/// Photo capture + signed-URL upload wires in with image_picker later —
/// the API's image-upload-url endpoint is already live.
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing posted!')),
      );
      await ref.read(browseControllerProvider.notifier).refresh();
      if (mounted) context.go('/market');
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sell something')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo upload area
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
                    setState(() => _photoLabels.removeAt(i));
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
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
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixText: r'$ ',
                  ),
                  validator: (v) => _parsePriceCents(v ?? '') == null
                      ? 'Enter a price like 25.00'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<ListingCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final entry in _categoryLabels.entries)
                      DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                  ],
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<ListingCondition>(
                  initialValue: _condition,
                  decoration: const InputDecoration(labelText: 'Condition'),
                  items: [
                    for (final entry in _conditionLabels.entries)
                      DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                  ],
                  onChanged: (v) =>
                      setState(() => _condition = v ?? _condition),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _description,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Condition details, pickup spot…',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Add a short description'
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Post listing'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (var i = 0; i < photos.length; i++)
                Padding(
                  padding: const EdgeInsets.only(
                    right: AppSpacing.sm,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color:
                              scheme.surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(
                            AppRadius.md,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              color:
                                  scheme.onSurfaceVariant,
                            ),
                            const SizedBox(
                              height: AppSpacing.xs,
                            ),
                            Text(
                              photos[i],
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => onRemove(i),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor:
                                scheme.error,
                            foregroundColor:
                                scheme.onError,
                            child: const Icon(
                              Icons.close,
                              size: 14,
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
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: scheme.outlineVariant,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppRadius.md,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: scheme.primary,
                        ),
                        const SizedBox(
                          height: AppSpacing.xs,
                        ),
                        Text(
                          'Add photo',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: scheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (photos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
            ),
            child: Text(
              'Photos upload via signed URL to S3. '
              'Pending moderation review.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
      ],
    );
  }
}
