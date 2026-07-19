import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/marketplace/data/listings_repository.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_controller.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_screen.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:campusconnect/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final AutoDisposeFutureProviderFamily<ListingResponse, String>
listingDetailProvider = FutureProvider.autoDispose
    .family<ListingResponse, String>(
      (ref, id) => ref.watch(listingsRepositoryProvider).fetchListing(id),
    );

/// Listing detail (spec §6.4): image carousel, seller card with
/// reputation, "Message seller" CTA, owner actions (mark sold, edit, delete).
class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({required this.listingId, super.key});

  final String listingId;

  Future<void> _messageSeller(
    BuildContext context,
    WidgetRef ref,
    ListingResponse listing,
  ) async {
    try {
      final convo = await ref
          .read(conversationsRepositoryProvider)
          .openConversation(
            recipientId: listing.seller.id,
            contextType: ConversationContext.listing,
            contextId: listing.id,
          );
      if (context.mounted) {
        context.go(
          '/chats/conversation/${convo.id}',
          extra: listing.seller.displayName,
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

  Future<void> _markSold(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(listingsRepositoryProvider).markSold(listingId);
      ref.invalidate(listingDetailProvider(listingId));
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

  Future<void> _deleteListing(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove listing?'),
        content: const Text('This listing will be permanently removed.'),
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
      await ref.read(listingsRepositoryProvider).deleteListing(listingId);
      await ref.read(browseControllerProvider.notifier).refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing removed.')),
        );
        context.go('/market');
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e))),
        );
      }
    }
  }

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
    final loaded = detail.valueOrNull;
    final currentUserId = ref.watch(authControllerProvider).user?.id;
    final isOwner = loaded != null && loaded.seller.id == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing'),
        actions: isOwner
            ? [
                PopupMenuButton<String>(
                  onSelected: (action) async {
                    switch (action) {
                      case 'sold':
                        await _markSold(context, ref);
                      case 'edit':
                        context.go(
                          '/market/listing/$listingId/edit',
                        );
                      case 'delete':
                        await _deleteListing(context, ref);
                    }
                  },
                  itemBuilder: (_) => [
                    if (loaded.status == ListingStatus.active)
                      const PopupMenuItem(
                        value: 'sold',
                        child: ListTile(
                          leading: Icon(Icons.check_circle_outline),
                          title: Text('Mark as sold'),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: Colors.red),
                        title: Text(
                          'Remove',
                          style: TextStyle(color: Colors.red),
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      bottomNavigationBar: loaded == null
          ? null
          : isOwner
              ? _OwnerCtaBar(listing: loaded)
              : _StickyCtaBar(
                  listing: loaded,
                  onMessage: () => _messageSeller(context, ref, loaded),
                ),
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
              // Image carousel
              _ImageCarousel(listing: listing),
              const SizedBox(height: AppSpacing.lg),
              Text(
                listing.title,
                style: Theme.of(context).textTheme.headlineSmall,
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
                      backgroundColor: listing.status == ListingStatus.sold
                          ? scheme.tertiaryContainer
                          : scheme.errorContainer,
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
            ],
          );
        },
      ),
    );
  }
}

/// Image carousel with page indicator dots.
class _ImageCarousel extends StatefulWidget {
  const _ImageCarousel({required this.listing});

  final ListingResponse listing;

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final images = widget.listing.images;
    final count = images.isEmpty ? 1 : images.length;

    return Column(
      children: [
        Hero(
          tag: 'listing-image-${widget.listing.id}',
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: images.isEmpty
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                      ),
                      child: Icon(
                        listingCategoryIcons[widget.listing.category] ??
                            Icons.category,
                        size: 64,
                        color: scheme.onSurfaceVariant,
                      ),
                    )
                  : PageView.builder(
                      controller: _controller,
                      itemCount: count,
                      onPageChanged: (i) => setState(() => _current = i),
                      itemBuilder: (_, i) {
                        final img = images[i];
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Icon(
                                listingCategoryIcons[
                                        widget.listing.category] ??
                                    Icons.category,
                                size: 64,
                                color: scheme.onSurfaceVariant,
                              ),
                              Positioned(
                                bottom: AppSpacing.sm,
                                right: AppSpacing.sm,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color:
                                        scheme.surface.withValues(alpha: 0.85),
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                    child: Text(
                                      'Photo ${i + 1}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                  ),
                                ),
                              ),
                              if (img.moderationStatus !=
                                  ModerationStatus.approved)
                                Positioned(
                                  top: AppSpacing.sm,
                                  left: AppSpacing.sm,
                                  child: Chip(
                                    avatar: const Icon(
                                      Icons.hourglass_top,
                                      size: 16,
                                    ),
                                    label: const Text('Pending review'),
                                    backgroundColor:
                                        scheme.tertiaryContainer,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
        if (count > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              count,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _current == i ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _current == i
                      ? scheme.primary
                      : scheme.outlineVariant,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Sticky bottom CTA for non-owners.
class _StickyCtaBar extends StatelessWidget {
  const _StickyCtaBar({required this.listing, required this.onMessage});

  final ListingResponse listing;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  formatPrice(listing.priceCents),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              FilledButton.icon(
                onPressed: onMessage,
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Message seller'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sticky bottom bar for listing owners showing status.
class _OwnerCtaBar extends StatelessWidget {
  const _OwnerCtaBar({required this.listing});

  final ListingResponse listing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  formatPrice(listing.priceCents),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Chip(
                avatar: Icon(
                  listing.status == ListingStatus.sold
                      ? Icons.check_circle
                      : Icons.storefront,
                  size: 18,
                ),
                label: Text(
                  listing.status == ListingStatus.sold
                      ? 'Sold'
                      : 'Your listing',
                ),
              ),
            ],
          ),
        ),
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
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Color(0xFFF59E0B),
                      ),
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
