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

final AutoDisposeFutureProviderFamily<ListingResponse,
        String> listingDetailProvider =
    FutureProvider.autoDispose
        .family<ListingResponse, String>(
  (ref, id) => ref
      .watch(listingsRepositoryProvider)
      .fetchListing(id),
);

/// Listing detail (spec S6.4): image carousel, seller
/// card with reputation, "Message seller" CTA, owner
/// actions (mark sold, edit, delete).
class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({
    required this.listingId,
    super.key,
  });

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e))),
        );
      }
    }
  }

  Future<void> _markSold(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      await ref
          .read(listingsRepositoryProvider)
          .markSold(listingId);
      ref.invalidate(listingDetailProvider(listingId));
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
          SnackBar(content: Text(apiErrorMessage(e))),
        );
      }
    }
  }

  Future<void> _deleteListing(
    BuildContext context,
    WidgetRef ref,
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
          .deleteListing(listingId);
      await ref
          .read(browseControllerProvider.notifier)
          .refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing removed.'),
          ),
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

  static const _conditionLabels =
      <ListingCondition, String>{
    ListingCondition.new_: 'New',
    ListingCondition.likeNew: 'Like new',
    ListingCondition.good: 'Good',
    ListingCondition.fair: 'Fair',
    ListingCondition.poor: 'Poor',
  };

  static const _conditionIcons =
      <ListingCondition, IconData>{
    ListingCondition.new_: Icons.fiber_new_rounded,
    ListingCondition.likeNew: Icons.auto_awesome,
    ListingCondition.good: Icons.thumb_up_alt_outlined,
    ListingCondition.fair: Icons.thumbs_up_down_outlined,
    ListingCondition.poor: Icons.warning_amber_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(
      listingDetailProvider(listingId),
    );
    final loaded = detail.valueOrNull;
    final currentUserId =
        ref.watch(authControllerProvider).user?.id;
    final isOwner =
        loaded != null && loaded.seller.id == currentUserId;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surface
                  .withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        actions: isOwner
            ? [
                Padding(
                  padding: const EdgeInsets.all(
                    AppSpacing.sm,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (action) async {
                        switch (action) {
                          case 'sold':
                            await _markSold(
                              context,
                              ref,
                            );
                          case 'edit':
                            context.go(
                              '/market/listing'
                              '/$listingId/edit',
                            );
                          case 'delete':
                            await _deleteListing(
                              context,
                              ref,
                            );
                        }
                      },
                      itemBuilder: (_) => [
                        if (loaded.status ==
                            ListingStatus.active)
                          const PopupMenuItem(
                            value: 'sold',
                            child: ListTile(
                              leading: Icon(
                                Icons
                                    .check_circle_outline,
                              ),
                              title: Text(
                                'Mark as sold',
                              ),
                              dense: true,
                              contentPadding:
                                  EdgeInsets.zero,
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(
                              Icons.edit_outlined,
                            ),
                            title: Text('Edit'),
                            dense: true,
                            contentPadding:
                                EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            title: Text(
                              'Remove',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            dense: true,
                            contentPadding:
                                EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  onMessage: () => _messageSeller(
                    context,
                    ref,
                    loaded,
                  ),
                ),
      body: detail.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, _) => EmptyState(
          icon: Icons.cloud_off,
          title: 'Could not load this listing',
          message:
              'It may have been removed, or you are offline.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(
            listingDetailProvider(listingId),
          ),
        ),
        data: (listing) => _DetailBody(
          listing: listing,
          conditionLabels: _conditionLabels,
          conditionIcons: _conditionIcons,
        ),
      ),
    );
  }
}

// -- Detail body (extracted for readability) ----------
class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.listing,
    required this.conditionLabels,
    required this.conditionIcons,
  });

  final ListingResponse listing;
  final Map<ListingCondition, String> conditionLabels;
  final Map<ListingCondition, IconData> conditionIcons;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // -- Hero image carousel --------------------
        _ImageCarousel(listing: listing),

        // -- Content below image --------------------
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                listing.title,
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Chips row: condition + status
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _StyledChip(
                    icon: conditionIcons[
                            listing.condition] ??
                        Icons.info_outline,
                    label: conditionLabels[
                            listing.condition] ??
                        'Unknown',
                    backgroundColor:
                        scheme.surfaceContainerHigh,
                    foregroundColor:
                        scheme.onSurface,
                  ),
                  if (listing.status !=
                      ListingStatus.active)
                    _StyledChip(
                      icon: listing.status ==
                              ListingStatus.sold
                          ? Icons.check_circle
                          : Icons.block,
                      label: listing.status.name
                          .toUpperCase(),
                      backgroundColor:
                          listing.status ==
                                  ListingStatus.sold
                              ? scheme
                                  .tertiaryContainer
                              : scheme.errorContainer,
                      foregroundColor:
                          listing.status ==
                                  ListingStatus.sold
                              ? scheme
                                  .onTertiaryContainer
                              : scheme
                                  .onErrorContainer,
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Description section
              Text(
                'Description',
                style: tt.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                listing.description,
                style: tt.bodyLarge?.copyWith(
                  height: 1.6,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Seller section header
              Text(
                'Seller',
                style: tt.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Seller card
              _SellerCard(seller: listing.seller),

              // Bottom padding for sticky bar
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ],
    );
  }
}

// -- Styled chip with icon for condition/status -------
class _StyledChip extends StatelessWidget {
  const _StyledChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          AppRadius.pill,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Image carousel with page indicator dots and taller
/// aspect ratio for premium feel.
class _ImageCarousel extends StatefulWidget {
  const _ImageCarousel({required this.listing});

  final ListingResponse listing;

  @override
  State<_ImageCarousel> createState() =>
      _ImageCarouselState();
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
    final tt = Theme.of(context).textTheme;
    final images = widget.listing.images;
    final count = images.isEmpty ? 1 : images.length;
    final topPad = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Main image area - taller for premium feel
        Hero(
          tag: 'listing-image-${widget.listing.id}',
          child: SizedBox(
            height: 380 + topPad,
            width: double.infinity,
            child: images.isEmpty
                ? Container(
                    decoration: BoxDecoration(
                      color: scheme
                          .surfaceContainerHighest,
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        SizedBox(height: topPad),
                        Icon(
                          listingCategoryIcons[
                                  widget.listing
                                      .category] ??
                              Icons.category,
                          size: 80,
                          color: scheme.onSurfaceVariant
                              .withValues(alpha: 0.35),
                        ),
                      ],
                    ),
                  )
                : PageView.builder(
                    controller: _controller,
                    itemCount: count,
                    onPageChanged: (i) =>
                        setState(() => _current = i),
                    itemBuilder: (_, i) {
                      final img = images[i];
                      return ColoredBox(
                        color: scheme
                            .surfaceContainerHighest,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Icon(
                              listingCategoryIcons[
                                      widget.listing
                                          .category] ??
                                  Icons.category,
                              size: 80,
                              color: scheme
                                  .onSurfaceVariant
                                  .withValues(
                                alpha: 0.35,
                              ),
                            ),
                            if (img.moderationStatus !=
                                ModerationStatus
                                    .approved)
                              Positioned(
                                top: topPad +
                                    AppSpacing.xxxl,
                                left: AppSpacing.lg,
                                child: Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal:
                                        AppSpacing.md,
                                    vertical:
                                        AppSpacing.sm,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: scheme
                                        .tertiaryContainer,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      AppRadius.pill,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize
                                            .min,
                                    children: [
                                      Icon(
                                        Icons
                                            .hourglass_top,
                                        size: 14,
                                        color: scheme
                                            .onTertiaryContainer,
                                      ),
                                      const SizedBox(
                                        width:
                                            AppSpacing
                                                .xs,
                                      ),
                                      Text(
                                        'Pending review',
                                        style: tt
                                            .labelSmall
                                            ?.copyWith(
                                          color: scheme
                                              .onTertiaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),

        // Bottom gradient overlay
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 60,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    scheme.surface
                        .withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Page dots
        if (count > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSpacing.lg,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: List.generate(
                count,
                (i) => AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 250,
                  ),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  width: _current == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(4),
                    color: _current == i
                        ? scheme.primary
                        : scheme.onSurface
                            .withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),

        // Photo counter badge
        if (count > 1)
          Positioned(
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs + 1,
              ),
              decoration: BoxDecoration(
                color: scheme.surface
                    .withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(
                  AppRadius.pill,
                ),
                border: Border.all(
                  color: scheme.outlineVariant,
                ),
              ),
              child: Text(
                '${_current + 1} / $count',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Sticky bottom CTA for non-owners with premium
/// styling.
class _StickyCtaBar extends StatelessWidget {
  const _StickyCtaBar({
    required this.listing,
    required this.onMessage,
  });

  final ListingResponse listing;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow
                .withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: tt.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.xs,
                    ),
                    Text(
                      formatPrice(
                        listing.priceCents,
                      ),
                      style: tt.titleLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              FilledButton.icon(
                onPressed: onMessage,
                icon: const Icon(
                  Icons.chat_bubble_outline,
                ),
                label: const Text('Message seller'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                ),
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
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow
                .withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your listing',
                      style: tt.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.xs,
                    ),
                    Text(
                      formatPrice(
                        listing.priceCents,
                      ),
                      style: tt.titleLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: listing.status ==
                          ListingStatus.sold
                      ? scheme.tertiaryContainer
                      : scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(
                    AppRadius.pill,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      listing.status ==
                              ListingStatus.sold
                          ? Icons.check_circle
                          : Icons.storefront,
                      size: 18,
                      color: listing.status ==
                              ListingStatus.sold
                          ? scheme.onTertiaryContainer
                          : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Text(
                      listing.status ==
                              ListingStatus.sold
                          ? 'Sold'
                          : 'Active',
                      style: tt.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: listing.status ==
                                ListingStatus.sold
                            ? scheme
                                .onTertiaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -- Seller card with larger avatar and better layout -
class _SellerCard extends StatelessWidget {
  const _SellerCard({required this.seller});

  final UserPublicResponse seller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          // Larger avatar with gradient ring
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  scheme.primary,
                  scheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: scheme.surface,
              child: Text(
                seller.displayName.isEmpty
                    ? '?'
                    : seller.displayName[0]
                        .toUpperCase(),
                style: tt.titleLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Seller info
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  seller.displayName,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.xs,
                ),
                Row(
                  children: [
                    // Star rating
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i <
                                seller.reputationScore
                                    .round()
                            ? Icons.star_rounded
                            : Icons
                                .star_outline_rounded,
                        size: 16,
                        color:
                            const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Text(
                      seller.reputationScore
                          .toStringAsFixed(1),
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      width: AppSpacing.xs,
                    ),
                    Text(
                      '(${seller.ratingCount})',
                      style: tt.bodySmall?.copyWith(
                        color:
                            scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chevron
          Icon(
            Icons.chevron_right_rounded,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
