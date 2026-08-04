import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/listing_card.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Marketplace browse (spec §12.2): search, ambient trust line, filter
/// chips, 2-col infinite-scroll grid, skeletons on first load, FAB to sell.
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
    final tokens = context.tokens;
    final colors = context.colors;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/market/sell'),
        tooltip: 'Post a listing',
        child: const Icon(Icons.add_a_photo_outlined),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    tokens.space4,
                    tokens.space4,
                    tokens.space4,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Market', style: context.text.titleLarge),
                      SizedBox(height: tokens.space3),
                      TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search listings',
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (q) =>
                            controller.setQuery(q.trim()).ignore(),
                      ),
                      SizedBox(height: tokens.space2),
                      // Ambient trust line (spec §4.1) — stated once per
                      // surface, not once per item.
                      Text(
                        'Everyone here is a verified student.',
                        style: context.text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _CategoryChips(state: state)),
            SliverToBoxAdapter(child: _PriceFilter(state: state)),
            if (state.loading)
              const _SkeletonGrid()
            else if (state.error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.cloud_off,
                  title: "Couldn't load listings",
                  body: 'Check your connection and try again.',
                  actionLabel: 'Retry',
                  onAction: () => controller.refresh().ignore(),
                ),
              )
            else if (state.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _hasActiveFilters(state)
                    ? EmptyState(
                        icon: Icons.filter_alt_off_outlined,
                        title: 'No matches',
                        body:
                            'Try a wider price range or a different category.',
                        actionLabel: 'Clear filters',
                        onAction: () => controller.refresh().ignore(),
                      )
                    : EmptyState(
                        icon: Icons.storefront_outlined,
                        title: 'Nothing listed yet',
                        body:
                            'Be the first. Sell that textbook '
                            "you're never opening again.",
                        actionLabel: 'Post a listing',
                        onAction: () => context.go('/market/sell'),
                      ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.all(tokens.space4),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: state.items.length,
                  itemBuilder: (context, i) =>
                      _BrowseListingCard(listing: state.items[i]),
                ),
              ),
            if (state.loadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(tokens.space3),
                  child: const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static bool _hasActiveFilters(BrowseState state) =>
      state.category != null ||
      state.minPrice != null ||
      state.maxPrice != null ||
      state.query.isNotEmpty;
}

/// Adapts an API listing to the shared [ListingCard] (spec §16 — features
/// never define their own card).
class _BrowseListingCard extends StatelessWidget {
  const _BrowseListingCard({required this.listing});

  final ListingResponse listing;

  @override
  Widget build(BuildContext context) {
    return ListingCard(
      title: listing.title,
      priceLabel: formatPrice(listing.priceCents),
      sellerName: listing.seller.displayName,
      rating: listing.seller.ratingCount > 0
          ? listing.seller.reputationScore.toDouble()
          : null,
      ratingCount: listing.seller.ratingCount,
      metaLabel:
          '${relativeTime(listing.createdAt)} · '
          '${conditionLabel(listing.condition)}',
      status: listing.status == ListingStatus.sold
          ? ListingCardStatus.sold
          : ListingCardStatus.none,
      heroTag: 'listing-image-${listing.id}',
      onTap: () => context.go('/market/listing/${listing.id}'),
    );
  }
}

// -- Category chips (spec §3 Hick's law: 6 top-level categories max) -------
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
    final tokens = context.tokens;
    final controller = ref.read(browseControllerProvider.notifier);
    return SizedBox(
      height: 64,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space4,
          vertical: tokens.space2,
        ),
        children: [
          for (final entry in _labels.entries)
            Padding(
              padding: EdgeInsets.only(right: tokens.space2),
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

class _PriceFilter extends ConsumerStatefulWidget {
  const _PriceFilter({required this.state});

  final BrowseState state;

  @override
  ConsumerState<_PriceFilter> createState() => _PriceFilterState();
}

class _PriceFilterState extends ConsumerState<_PriceFilter> {
  RangeValues _range = const RangeValues(0, 500);
  bool _active = false;

  @override
  void initState() {
    super.initState();
    final s = widget.state;
    if (s.minPrice != null || s.maxPrice != null) {
      _active = true;
      _range = RangeValues(
        (s.minPrice ?? 0) / 100,
        (s.maxPrice ?? 50000) / 100,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final controller = ref.read(browseControllerProvider.notifier);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FilterChip(
                label: Text(
                  _active
                      ? '\$${_range.start.round()} \u2013 '
                            '\$${_range.end.round()}'
                      : 'Price',
                ),
                selected: _active,
                onSelected: (on) {
                  setState(() => _active = on);
                  if (!on) controller.setPriceRange(null, null).ignore();
                },
              ),
            ],
          ),
          if (_active)
            RangeSlider(
              values: _range,
              max: 500,
              divisions: 50,
              labels: RangeLabels(
                '\$${_range.start.round()}',
                '\$${_range.end.round()}',
              ),
              onChanged: (v) => setState(() => _range = v),
              onChangeEnd: (v) {
                controller
                    .setPriceRange(v.start.round() * 100, v.end.round() * 100)
                    .ignore();
              },
            ),
        ],
      ),
    );
  }
}

/// Formats price cents as whole dollars where possible ("\$45", "\$12.50").
String formatPrice(int cents) => cents % 100 == 0
    ? '\$${cents ~/ 100}'
    : '\$${(cents / 100).toStringAsFixed(2)}';

/// Short relative timestamp, e.g. `2h ago`.
String relativeTime(DateTime time) {
  final delta = DateTime.now().difference(time);
  if (delta.inMinutes < 1) return 'Just now';
  if (delta.inMinutes < 60) return '${delta.inMinutes}m ago';
  if (delta.inHours < 24) return '${delta.inHours}h ago';
  if (delta.inDays < 7) return '${delta.inDays}d ago';
  return '${delta.inDays ~/ 7}w ago';
}

/// Human label for a listing condition.
String conditionLabel(ListingCondition condition) => switch (condition) {
  ListingCondition.new_ => 'New',
  ListingCondition.likeNew => 'Like new',
  ListingCondition.good => 'Good',
  ListingCondition.fair => 'Fair',
  ListingCondition.poor => 'Poor',
  _ => 'Used',
};

/// Icon per category, reused by detail screen placeholders.
const listingCategoryIcons = <ListingCategory, IconData>{
  ListingCategory.textbooks: Icons.menu_book,
  ListingCategory.furniture: Icons.chair,
  ListingCategory.electronics: Icons.devices,
  ListingCategory.tickets: Icons.confirmation_number,
  ListingCategory.clothing: Icons.checkroom,
  ListingCategory.other: Icons.category,
};

/// Skeleton grid matching the exact card geometry (spec §13.1).
class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SliverPadding(
      padding: EdgeInsets.all(tokens.space4),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => const ListingCardSkeleton(),
      ),
    );
  }
}
