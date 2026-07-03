import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_controller.dart';
import 'package:campusconnect/shared/widgets/empty_state.dart';
import 'package:campusconnect/shared/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Marketplace browse (J1 entry + spec §6.4): search, category filters,
/// infinite-scroll grid, skeletons on first load.
class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) {
        ref.read(browseControllerProvider.notifier).loadMore().ignore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(browseControllerProvider);
    final controller = ref.read(browseControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/market/sell'),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Sell'),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  0,
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search textbooks, furniture…',
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (q) => controller.setQuery(q.trim()).ignore(),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _CategoryChips(state: state)),
            if (state.loading)
              const _SkeletonGrid()
            else if (state.error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.cloud_off,
                  title: 'Could not load listings',
                  message: 'Check your connection and try again.',
                  actionLabel: 'Retry',
                  onAction: () => controller.refresh().ignore(),
                ),
              )
            else if (state.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.storefront_outlined,
                  title: 'No listings yet',
                  message: 'Be the first — post something to sell.',
                  actionLabel: 'Sell something',
                  onAction: () => context.go('/market/sell'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: state.items.length,
                  itemBuilder: (context, i) => FadeSlideIn(
                    index: i,
                    child: _ListingCard(listing: state.items[i]),
                  ),
                ),
              ),
            if (state.loadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({required this.state});

  final BrowseState state;

  static const _labels = <ListingCategory, String>{
    ListingCategory.textbooks: 'Textbooks',
    ListingCategory.furniture: 'Furniture',
    ListingCategory.electronics: 'Electronics',
    ListingCategory.tickets: 'Tickets',
    ListingCategory.clothing: 'Clothing',
    ListingCategory.other: 'Other',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(browseControllerProvider.notifier);
    return SizedBox(
      height: 64, // 48px tap target (a11y guideline) + vertical padding
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        children: [
          for (final entry in _labels.entries)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: Text(entry.value),
                selected: state.category == entry.key,
                onSelected: (on) =>
                    controller.setCategory(on ? entry.key : null).ignore(),
              ),
            ),
        ],
      ),
    );
  }
}

/// Formats price cents as dollars ("$12.50").
String formatPrice(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

/// Icon per category, reused by detail screen placeholders.
const listingCategoryIcons = <ListingCategory, IconData>{
  ListingCategory.textbooks: Icons.menu_book,
  ListingCategory.furniture: Icons.chair,
  ListingCategory.electronics: Icons.devices,
  ListingCategory.tickets: Icons.confirmation_number,
  ListingCategory.clothing: Icons.checkroom,
  ListingCategory.other: Icons.category,
};

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});

  final ListingResponse listing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Depop-style card: edge-to-edge image, price overlay chip, terse title.
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/market/listing/${listing.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'listing-image-${listing.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: scheme.surfaceContainerHighest,
                      child: Icon(
                        listingCategoryIcons[listing.category] ??
                            Icons.category,
                        size: 40,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          child: Text(
                            formatPrice(listing.priceCents),
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                listing.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton grid for initial load (spec §6.3: never a bare spinner on a
/// blank screen).
class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.md),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.72,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ColoredBox(color: scheme.surfaceContainerHighest),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: 100,
                      color: scheme.surfaceContainerHighest,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      height: 14,
                      width: 60,
                      color: scheme.surfaceContainerHighest,
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
