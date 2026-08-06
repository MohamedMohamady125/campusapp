import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/pressable.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/marketplace/data/listings_repository.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_controller.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final AutoDisposeFutureProvider<List<ListingResponse>> myListingsProvider =
    FutureProvider.autoDispose<List<ListingResponse>>((ref) {
      final userId = ref.watch(authControllerProvider).user?.id;
      if (userId == null) return [];
      return ref.watch(listingsRepositoryProvider).fetchMyListings(userId);
    });

/// The current user's listings with manage actions (spec §12.7).
class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  Future<void> _markSold(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    try {
      await ref.read(listingsRepositoryProvider).markSold(id);
      ref.invalidate(myListingsProvider);
      await ref.read(browseControllerProvider.notifier).refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked as sold.')),
        );
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
      }
    }
  }

  Future<void> _deleteListing(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove this listing?'),
        content: const Text(
          'It will disappear from the market. '
          "This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Remove listing'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(listingsRepositoryProvider).deleteListing(id);
      ref.invalidate(myListingsProvider);
      await ref.read(browseControllerProvider.notifier).refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing removed.')),
        );
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(myListingsProvider);
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('My listings')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/market/sell'),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Sell'),
      ),
      body: listings.when(
        loading: () => ListView(
          children: const [
            ListRowSkeleton(height: 104),
            ListRowSkeleton(height: 104),
            ListRowSkeleton(height: 104),
          ],
        ),
        error: (_, _) => EmptyState(
          icon: Icons.cloud_off,
          title: "Couldn't load your listings",
          body: 'Check your connection and try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(myListingsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            // Empty-state copy per spec §13.2.
            return EmptyState(
              icon: Icons.storefront_outlined,
              title: "You haven't listed anything",
              body: 'That textbook on your shelf? Someone needs it.',
              actionLabel: 'Post a listing',
              onAction: () => context.go('/market/sell'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myListingsProvider),
            child: ListView.separated(
              padding: EdgeInsets.all(tokens.space4),
              itemCount: items.length,
              separatorBuilder: (_, _) => SizedBox(height: tokens.space2),
              itemBuilder: (context, i) {
                final listing = items[i];
                return _MyListingRow(
                  listing: listing,
                  onTap: () => context.go('/market/listing/${listing.id}'),
                  onMarkSold: () => _markSold(context, ref, listing.id),
                  onEdit: () =>
                      context.go('/market/listing/${listing.id}/edit'),
                  onDelete: () => _deleteListing(context, ref, listing.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MyListingRow extends StatelessWidget {
  const _MyListingRow({
    required this.listing,
    required this.onTap,
    required this.onMarkSold,
    required this.onEdit,
    required this.onDelete,
  });

  final ListingResponse listing;
  final VoidCallback onTap;
  final VoidCallback onMarkSold;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final isSold = listing.status == ListingStatus.sold;

    return Pressable(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(tokens.space3),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: tokens.brSm,
                ),
                child: Icon(
                  listingCategoryIcons[listing.category] ?? Icons.category,
                  color: colors.onSurfaceVariant,
                ),
              ),
              SizedBox(width: tokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall,
                    ),
                    SizedBox(height: tokens.space1),
                    Text(
                      formatPrice(listing.priceCents),
                      // Inter w700 tabular, onSurface — never blue.
                      style: AppTextStyles.statSmall.copyWith(
                        color: isSold
                            ? colors.onSurfaceVariant
                            : colors.onSurface,
                        decoration: isSold ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    SizedBox(height: tokens.space1),
                    Text(
                      isSold
                          ? 'Sold'
                          : 'Active · '
                                'posted ${relativeTime(listing.createdAt)}',
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSold)
                PopupMenuButton<String>(
                  tooltip: 'Manage listing',
                  onSelected: (action) {
                    switch (action) {
                      case 'sold':
                        onMarkSold();
                      case 'edit':
                        onEdit();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'sold',
                      child: Text('Mark as sold'),
                    ),
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Remove'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
