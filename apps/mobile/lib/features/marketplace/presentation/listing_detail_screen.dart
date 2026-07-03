import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/marketplace/data/listings_repository.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_screen.dart';
import 'package:campusconnect/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final AutoDisposeFutureProviderFamily<ListingResponse, String>
listingDetailProvider = FutureProvider.autoDispose
    .family<ListingResponse, String>(
      (ref, id) => ref.watch(listingsRepositoryProvider).fetchListing(id),
    );

/// Listing detail (spec §6.4): gallery placeholder, seller card with
/// reputation, "Message seller" CTA (wires to messaging in M5 UI).
class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({required this.listingId, super.key});

  final String listingId;

  static const _conditionLabels = <ListingCondition, String>{
    ListingCondition.new_: 'New',
    ListingCondition.likeNew: 'Like new',
    ListingCondition.good: 'Good',
    ListingCondition.fair: 'Fair',
    ListingCondition.poor: 'Poor',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(listingDetailProvider(listingId));
    return Scaffold(
      appBar: AppBar(title: const Text('Listing')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyState(
          icon: Icons.cloud_off,
          title: 'Could not load this listing',
          message: 'It may have been removed, or you are offline.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(listingDetailProvider(listingId)),
        ),
        data: (listing) {
          final scheme = Theme.of(context).colorScheme;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    listingCategoryIcons[listing.category] ?? Icons.category,
                    size: 64,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                listing.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                formatPrice(listing.priceCents),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  Chip(
                    label: Text(
                      _conditionLabels[listing.condition] ?? 'Unknown',
                    ),
                  ),
                  if (listing.status != ListingStatus.active)
                    Chip(
                      label: Text(listing.status.name.toUpperCase()),
                      backgroundColor: scheme.errorContainer,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                listing.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              _SellerCard(seller: listing.seller),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Messaging arrives with the M5 UI.'),
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Message seller'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SellerCard extends StatelessWidget {
  const _SellerCard({required this.seller});

  final UserPublicResponse seller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(
                seller.displayName.isEmpty
                    ? '?'
                    : seller.displayName[0].toUpperCase(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${seller.reputationScore.toStringAsFixed(1)}'
                        ' (${seller.ratingCount})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
