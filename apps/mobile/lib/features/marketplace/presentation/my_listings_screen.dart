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
    FutureProvider.autoDispose<List<ListingResponse>>(
        (ref) {
  final userId =
      ref.watch(authControllerProvider).user?.id;
  if (userId == null) return [];
  return ref
      .watch(listingsRepositoryProvider)
      .fetchMyListings(userId);
});

/// Shows the current user's listings with quick
/// actions.
class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  Future<void> _markSold(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    try {
      await ref
          .read(listingsRepositoryProvider)
          .markSold(id);
      ref.invalidate(myListingsProvider);
      await ref
          .read(browseControllerProvider.notifier)
          .refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marked as sold!'),
          ),
        );
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiErrorMessage(e)),
          ),
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
          'This listing will be permanently'
          ' removed.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor:
                  Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref
          .read(listingsRepositoryProvider)
          .deleteListing(id);
      ref.invalidate(myListingsProvider);
      await ref
          .read(browseControllerProvider.notifier)
          .refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing removed.'),
          ),
        );
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiErrorMessage(e)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(myListingsProvider);
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () => context.go('/market/sell'),
        icon: const Icon(
          Icons.add_a_photo_outlined,
        ),
        label: const Text('Sell'),
      ),
      body: listings.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, _) => EmptyState(
          icon: Icons.cloud_off,
          title: 'Could not load your listings',
          message:
              'Check your connection and try again.',
          actionLabel: 'Retry',
          onAction: () =>
              ref.invalidate(myListingsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.storefront_outlined,
              title: 'No listings yet',
              message: 'Post something to sell!',
              actionLabel: 'Sell something',
              onAction: () =>
                  context.go('/market/sell'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(myListingsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(
                AppSpacing.lg,
              ),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(
                height: AppSpacing.md,
              ),
              itemBuilder: (context, i) {
                final listing = items[i];
                final isSold = listing.status ==
                    ListingStatus.sold;
                return _ListingCard(
                  listing: listing,
                  isSold: isSold,
                  scheme: scheme,
                  tt: tt,
                  onTap: () => context.go(
                    '/market/listing/${listing.id}',
                  ),
                  onMarkSold: () => _markSold(
                    context,
                    ref,
                    listing.id,
                  ),
                  onEdit: () => context.go(
                    '/market/listing/${listing.id}',
                  ),
                  onDelete: () => _deleteListing(
                    context,
                    ref,
                    listing.id,
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

// -- Premium listing card --
class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.listing,
    required this.isSold,
    required this.scheme,
    required this.tt,
    required this.onTap,
    required this.onMarkSold,
    required this.onEdit,
    required this.onDelete,
  });

  final ListingResponse listing;
  final bool isSold;
  final ColorScheme scheme;
  final TextTheme tt;
  final VoidCallback onTap;
  final VoidCallback onMarkSold;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          child: Row(
            children: [
              // Large thumbnail
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isSold
                      ? scheme
                          .surfaceContainerHighest
                          .withAlpha(180)
                      : scheme
                          .surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        listingCategoryIcons[
                                listing.category] ??
                            Icons.category,
                        color: isSold
                            ? scheme
                                .onSurfaceVariant
                                .withAlpha(100)
                            : scheme
                                .onSurfaceVariant,
                        size: 32,
                      ),
                    ),
                    // Sold overlay
                    if (isSold)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black
                                .withAlpha(30),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              AppRadius.md,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            maxLines: 1,
                            overflow: TextOverflow
                                .ellipsis,
                            style: tt.titleSmall
                                ?.copyWith(
                              fontWeight:
                                  FontWeight.w600,
                              color: isSold
                                  ? scheme
                                      .onSurfaceVariant
                                  : null,
                            ),
                          ),
                        ),
                        _StatusBadge(
                          isSold: isSold,
                          scheme: scheme,
                          tt: tt,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: AppSpacing.xs,
                    ),
                    Text(
                      formatPrice(
                        listing.priceCents,
                      ),
                      style:
                          tt.titleMedium?.copyWith(
                        color: isSold
                            ? scheme
                                .onSurfaceVariant
                            : scheme.primary,
                        fontWeight: FontWeight.w700,
                        decoration: isSold
                            ? TextDecoration
                                .lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.sm,
                    ),
                    // Category label
                    Row(
                      children: [
                        Icon(
                          listingCategoryIcons[
                                  listing
                                      .category] ??
                              Icons.category,
                          size: 14,
                          color: scheme
                              .onSurfaceVariant,
                        ),
                        const SizedBox(
                          width: AppSpacing.xs,
                        ),
                        Text(
                          listing.category.name,
                          style: tt.labelSmall
                              ?.copyWith(
                            color: scheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions menu
              if (!isSold)
                PopupMenuButton<String>(
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
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color:
                        scheme.onSurfaceVariant,
                  ),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'sold',
                      child: Row(
                        children: [
                          Icon(
                            Icons
                                .check_circle_outline,
                            size: 18,
                          ),
                          SizedBox(
                            width: AppSpacing.sm,
                          ),
                          Text('Mark sold'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                          ),
                          SizedBox(
                            width: AppSpacing.sm,
                          ),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons
                                .delete_outline_rounded,
                            size: 18,
                          ),
                          SizedBox(
                            width: AppSpacing.sm,
                          ),
                          Text('Remove'),
                        ],
                      ),
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

// -- Status badge --
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isSold,
    required this.scheme,
    required this.tt,
  });

  final bool isSold;
  final ColorScheme scheme;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final color = isSold
        ? const Color(0xFFF59E0B)
        : const Color(0xFF22C55E);
    final label = isSold ? 'SOLD' : 'ACTIVE';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(
          AppRadius.sm,
        ),
        border: Border.all(
          color: color.withAlpha(80),
        ),
      ),
      child: Text(
        label,
        style: tt.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
