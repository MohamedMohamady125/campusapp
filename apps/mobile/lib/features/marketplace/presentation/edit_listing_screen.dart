import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/marketplace/data/listings_repository.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_controller.dart';
import 'package:campusconnect/features/marketplace/presentation/listing_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Edit an existing listing — pre-filled form with current values.
class EditListingScreen extends ConsumerStatefulWidget {
  const EditListingScreen({required this.listingId, super.key});

  final String listingId;

  @override
  ConsumerState<EditListingScreen> createState() =>
      _EditListingScreenState();
}

class _EditListingScreenState
    extends ConsumerState<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  ListingCategory _category = ListingCategory.textbooks;
  ListingCondition _condition = ListingCondition.good;
  bool _submitting = false;
  bool _loaded = false;

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

  void _prefill(ListingResponse listing) {
    if (_loaded) return;
    _loaded = true;
    _title.text = listing.title;
    _description.text = listing.description;
    _price.text = (listing.priceCents / 100).toStringAsFixed(2);
    _category = listing.category;
    _condition = listing.condition;
  }

  int? _parsePriceCents(String raw) {
    final value =
        double.tryParse(raw.trim().replaceFirst(r'$', ''));
    if (value == null || value < 0) return null;
    return (value * 100).round();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(listingsRepositoryProvider)
          .updateListing(
            id: widget.listingId,
            title: _title.text.trim(),
            description: _description.text.trim(),
            priceCents: _parsePriceCents(_price.text),
            category: _category,
            condition: _condition,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing updated!')),
      );
      ref.invalidate(
        listingDetailProvider(widget.listingId),
      );
      await ref
          .read(browseControllerProvider.notifier)
          .refresh();
      if (mounted) context.pop();
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(
      listingDetailProvider(widget.listingId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Edit listing')),
      body: detail.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Failed to load: ${apiErrorMessage(e)}'),
        ),
        data: (listing) {
          _prefill(listing);
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                autovalidateMode:
                    AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _title,
                      textCapitalization:
                          TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().length < 3)
                              ? 'Give it a short title'
                              : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
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
                              ? 'Enter a valid price'
                              : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DropdownButtonFormField<ListingCategory>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: [
                        for (final e
                            in _categoryLabels.entries)
                          DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                      ],
                      onChanged: (v) => setState(
                        () => _category = v ?? _category,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DropdownButtonFormField<ListingCondition>(
                      initialValue: _condition,
                      decoration: const InputDecoration(
                        labelText: 'Condition',
                      ),
                      items: [
                        for (final e
                            in _conditionLabels.entries)
                          DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                      ],
                      onChanged: (v) => setState(
                        () => _condition = v ?? _condition,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _description,
                      maxLines: 4,
                      textCapitalization:
                          TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Add a short description'
                              : null,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed:
                          _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox.square(
                              dimension: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save changes'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
