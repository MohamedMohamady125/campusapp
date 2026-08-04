import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/report_sheet.dart';
import 'package:campusconnect/design_system/components/reputation_chip.dart';
import 'package:campusconnect/design_system/components/safety_card.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/components/verified_avatar.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/marketplace/data/listings_repository.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_controller.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_screen.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final AutoDisposeFutureProviderFamily<ListingResponse, String>
listingDetailProvider = FutureProvider.autoDispose
    .family<ListingResponse, String>(
      (ref, id) => ref.watch(listingsRepositoryProvider).fetchListing(id),
    );

/// Listing detail (spec §12.3): gallery, price + title, condition chip,
/// seller card with reputation, safety card, report entry, sticky
/// "Message seller" bar. Owner sees manage actions instead.
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

  Future<void> _deleteListing(BuildContext context, WidgetRef ref) async {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
      }
    }
  }

  void _report(BuildContext context, ListingResponse listing) {
    showReportSheet(
      context,
      targetName: listing.seller.displayName,
      onSubmit: (reason, details) async {
        // Report API wiring lands with the moderation milestone; the
        // sheet's confirmation copy handles user expectations (spec §14).
      },
    ).ignore();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(listingDetailProvider(listingId));
    final loaded = detail.valueOrNull;
    final currentUserId = ref.watch(authControllerProvider).user?.id;
    final isOwner = loaded != null && loaded.seller.id == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing'),
        actions: [
          if (loaded != null && isOwner)
            PopupMenuButton<String>(
              tooltip: 'Manage listing',
              onSelected: (action) async {
                switch (action) {
                  case 'sold':
                    await _markSold(context, ref);
                  case 'edit':
                    context.go('/market/listing/$listingId/edit');
                  case 'delete':
                    await _deleteListing(context, ref);
                }
              },
              itemBuilder: (_) => [
                if (loaded.status == ListingStatus.active)
                  const PopupMenuItem(
                    value: 'sold',
                    child: Text('Mark as sold'),
                  ),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Remove')),
              ],
            )
          else if (loaded != null)
            IconButton(
              tooltip: 'Report',
              icon: const Icon(Icons.flag_outlined),
              onPressed: () => _report(context, loaded),
            ),
        ],
      ),
      bottomNavigationBar: loaded == null || isOwner
          ? null
          : _StickyCtaBar(
              listing: loaded,
              onMessage: () => _messageSeller(context, ref, loaded),
            ),
      body: detail.when(
        loading: () => ListView(
          children: const [
            AspectRatio(aspectRatio: 1, child: SkeletonBox()),
            ListRowSkeleton(),
            ListRowSkeleton(),
          ],
        ),
        error: (_, _) => EmptyState(
          icon: Icons.cloud_off,
          title: "Couldn't load this listing",
          body: "It may have been removed, or you're offline.",
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(listingDetailProvider(listingId)),
        ),
        data: (listing) => _DetailBody(listing: listing, isOwner: isOwner),
      ),
    );
  }
}

class _DetailBody extends StatefulWidget {
  const _DetailBody({required this.listing, required this.isOwner});

  final ListingResponse listing;
  final bool isOwner;

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  bool _safetyDismissed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final listing = widget.listing;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _ImageCarousel(listing: listing),
        Padding(
          padding: EdgeInsets.all(tokens.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price first — it's what buyers scan for (spec §12.3).
              Text(
                formatPrice(listing.priceCents),
                style: context.text.headlineSmall?.copyWith(
                  color: tokens.price,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              SizedBox(height: tokens.space1),
              Text(listing.title, style: context.text.titleLarge),
              SizedBox(height: tokens.space2),
              Text(
                '${conditionLabel(listing.condition)} · '
                'Posted ${relativeTime(listing.createdAt)}',
                style: context.text.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              if (listing.status == ListingStatus.sold) ...[
                SizedBox(height: tokens.space2),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.space2,
                    vertical: tokens.space1 / 2,
                  ),
                  decoration: ShapeDecoration(
                    color: colors.surfaceContainerHigh,
                    shape: const StadiumBorder(),
                  ),
                  child: Text('Sold', style: context.text.labelSmall),
                ),
              ],
              SizedBox(height: tokens.space4),
              Text(
                listing.description,
                style: context.text.bodyLarge?.copyWith(height: 1.5),
              ),
              SizedBox(height: tokens.space5),
              _SellerCard(seller: listing.seller),
              if (!widget.isOwner && !_safetyDismissed) ...[
                SizedBox(height: tokens.space4),
                // Meetup safety guidance (spec §10.7) — informative
                // secondary tone, never a warning colour.
                SafetyCard(
                  onDismiss: () => setState(() => _safetyDismissed = true),
                ),
              ],
              SizedBox(height: tokens.space6),
            ],
          ),
        ),
      ],
    );
  }
}

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
    final tokens = context.tokens;
    final colors = context.colors;
    final images = widget.listing.images;
    final count = images.isEmpty ? 1 : images.length;
    final placeholderIcon = Icon(
      listingCategoryIcons[widget.listing.category] ?? Icons.category,
      size: 64,
      color: colors.onSurfaceVariant,
    );

    return Stack(
      children: [
        Hero(
          tag: 'listing-image-${widget.listing.id}',
          child: AspectRatio(
            aspectRatio: 1,
            child: images.isEmpty
                ? ColoredBox(
                    color: colors.surfaceContainerHighest,
                    child: Center(child: placeholderIcon),
                  )
                : PageView.builder(
                    controller: _controller,
                    itemCount: count,
                    onPageChanged: (i) => setState(() => _current = i),
                    itemBuilder: (_, i) => ColoredBox(
                      color: colors.surfaceContainerHighest,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Center(child: placeholderIcon),
                          if (images[i].moderationStatus !=
                              ModerationStatus.approved)
                            Positioned(
                              left: tokens.space3,
                              top: tokens.space3,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: tokens.space2,
                                  vertical: tokens.space1 / 2,
                                ),
                                decoration: ShapeDecoration(
                                  color: colors.surfaceContainerHigh,
                                  shape: const StadiumBorder(),
                                ),
                                child: Text(
                                  'Pending review',
                                  style: context.text.labelSmall,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        if (count > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: tokens.space3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < count; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _current == i ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _current == i
                          ? colors.primary
                          : colors.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Sticky bottom CTA — price restated + one primary action (spec §12.3).
class _StickyCtaBar extends StatelessWidget {
  const _StickyCtaBar({required this.listing, required this.onMessage});

  final ListingResponse listing;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return ColoredBox(
      color: colors.surfaceContainer,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space4,
            vertical: tokens.space3,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  formatPrice(listing.priceCents),
                  style: context.text.titleLarge?.copyWith(
                    color: tokens.price,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              SizedBox(width: tokens.space3),
              FilledButton.icon(
                onPressed: listing.status == ListingStatus.sold
                    ? null
                    : onMessage,
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(
                  listing.status == ListingStatus.sold
                      ? 'Sold'
                      : 'Message seller',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seller card: identity + reputation with count (spec §12.3, §4.2 —
/// never a bare average).
class _SellerCard extends StatelessWidget {
  const _SellerCard({required this.seller});

  final UserPublicResponse seller;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.space3),
        child: Row(
          children: [
            VerifiedAvatar(name: seller.displayName, size: AvatarSize.lg),
            SizedBox(width: tokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(seller.displayName, style: context.text.titleSmall),
                  SizedBox(height: tokens.space1),
                  ReputationChip(
                    rating: seller.ratingCount > 0
                        ? seller.reputationScore.toDouble()
                        : null,
                    ratingCount: seller.ratingCount,
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
