import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/marketplace/data/listings_repository.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_controller.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_screen.dart';
import 'package:campusconnect/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final AutoDisposeFutureProvider<List<ListingResponse>>
    myListingsProvider =
    FutureProvider.autoDispose<List<ListingResponse>>((ref) {
  final userId = ref.watch(authControllerProvider).user?.id;
  if (userId == null) return [];
  return ref.watch(listingsRepositoryProvider).fetchMyListings(userId);
});

/// Shows the current user's listings with quick actions.
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
          const SnackBar(content: Text('Marked as sold!')),
        );
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e))),
        );
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
        title: const Text('Remove listing?'),
        content: const Text(
          'This listing will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Remove'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(myListingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/market/sell'),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Sell'),
      ),
      body: listings.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyState(
          icon: Icons.cloud_off,
          title: 'Could not load your listings',
          message: 'Check your connection and try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(myListingsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.storefront_outlined,
              title: 'No listings yet',
              message: 'Post something to sell!',
              actionLabel: 'Sell something',
              onAction: () => context.go('/market/sell'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(myListingsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final listing = items[i];
                final scheme = Theme.of(context).colorScheme;
                return Card(
                  child: InkWell(
                    onTap: () => context.go(
                      '/market/listing/${listing.id}',
                    ),
                    borderRadius: BorderRadius.circular(
                      AppRadius.md,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color:
                                  scheme.surfaceContainerHighest,
                              borderRadius:
                                  BorderRadius.circular(
                                AppRadius.sm,
                              ),
                            ),
                            child: Icon(
                              listingCategoryIcons[
                                      listing.category] ??
                                  Icons.category,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  listing.title,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                                const SizedBox(
                                  height: AppSpacing.xs,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      formatPrice(
                                        listing.priceCents,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color:
                                                scheme.primary,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(
                                      width: AppSpacing.sm,
                                    ),
                                    if (listing.status ==
                                        ListingStatus.sold)
                                      Chip(
                                        label: const Text(
                                          'SOLD',
                                        ),
                                        labelStyle:
                                            Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                        backgroundColor: scheme
                                            .tertiaryContainer,
                                        padding:
                                            EdgeInsets.zero,
                                        visualDensity:
                                            VisualDensity
                                                .compact,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (listing.status ==
                              ListingStatus.active)
                            PopupMenuButton<String>(
                              onSelected: (action) async {
                                switch (action) {
                                  case 'sold':
                                    await _markSold(
                                      context,
                                      ref,
                                      listing.id,
                                    );
                                  case 'edit':
                                    context.go(
                                      '/market/listing/'
                                      '${listing.id}',
                                    );
                                  case 'delete':
                                    await _deleteListing(
                                      context,
                                      ref,
                                      listing.id,
                                    );
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'sold',
                                  child: Text('Mark sold'),
                                ),
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
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
              },
            ),
          );
        },
      ),
    );
  }
}
