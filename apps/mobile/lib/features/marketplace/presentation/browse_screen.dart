import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/components/content_width.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/fade_slide_in.dart';
import 'package:campusconnect/design_system/components/filter_chip_row.dart';
import 'package:campusconnect/design_system/components/listing_card.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
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
      body: ContentWidth(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Computed grid (whole.md §4.3) — never guess aspect ratios.
              const gutter = 12.0;
              const target = 200.0;
              final gridWidth = constraints.maxWidth - tokens.space4 * 2;
              final columns = (gridWidth / target).floor().clamp(2, 5);
              final colWidth = (gridWidth - gutter * (columns - 1)) / columns;
              final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: gutter,
                mainAxisSpacing: gutter,
                mainAxisExtent: colWidth * 0.75 + kListingCardContentHeight,
              );
              return CustomScrollView(
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
                            Text('Market', style: AppTextStyles.heading),
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
                            // Ambient trust line (whole.md §5.1) — stated once
                            // per surface, not once per card.
                            Row(
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                                SizedBox(width: tokens.space1),
                                Text(
                                  'Everyone here is a verified student',
                                  style: context.text.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: _CategoryChips(state: state)),
                  if (state.loading)
                    _SkeletonGrid(gridDelegate: gridDelegate)
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
                                  'Try a wider price range or a '
                                  'different category.',
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
                      // 96dp bottom padding so the FAB never covers a card
                      // (whole.md §5.1).
                      padding: EdgeInsets.fromLTRB(
                        tokens.space4,
                        0,
                        tokens.space4,
                        96,
                      ),
                      sliver: SliverGrid.builder(
                        gridDelegate: gridDelegate,
                        itemCount: state.items.length,
                        itemBuilder: (context, i) => FadeSlideIn(
                          index: i,
                          child: _BrowseListingCard(listing: state.items[i]),
                        ),
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
              );
            },
          ),
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

// -- Category chips (whole.md §4.6 — one scroll row, All first) ------------
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
    final priceActive = state.minPrice != null || state.maxPrice != null;
    return FilterChipRow<ListingCategory>(
      options: [
        for (final entry in _labels.entries)
          FilterChipOption(label: entry.value, value: entry.key),
      ],
      selected: state.category,
      onSelected: (category) => controller.setCategory(category).ignore(),
      // Value filters live behind a trailing chip + sheet, never in the
      // row itself (whole.md §4.6).
      trailing: FilterChip(
        label: Text(priceActive ? 'Filters (1)' : 'Filters'),
        selected: priceActive,
        showCheckmark: false,
        onSelected: (_) => _showPriceSheet(context, ref),
      ),
    );
  }

  Future<void> _showPriceSheet(BuildContext context, WidgetRef ref) {
    final controller = ref.read(browseControllerProvider.notifier);
    var range = RangeValues(
      (state.minPrice ?? 0) / 100,
      (state.maxPrice ?? 50000) / 100,
    );
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final tokens = sheetContext.tokens;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space4,
              0,
              tokens.space4,
              tokens.space6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price range', style: sheetContext.text.titleMedium),
                SizedBox(height: tokens.space2),
                RangeSlider(
                  values: range,
                  max: 500,
                  divisions: 50,
                  labels: RangeLabels(
                    '\$${range.start.round()}',
                    '\$${range.end.round()}',
                  ),
                  onChanged: (v) => setSheetState(() => range = v),
                ),
                SizedBox(height: tokens.space2),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.setPriceRange(null, null).ignore();
                          Navigator.of(sheetContext).pop();
                        },
                        child: const Text('Clear'),
                      ),
                    ),
                    SizedBox(width: tokens.space3),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          controller
                              .setPriceRange(
                                range.start.round() * 100,
                                range.end.round() * 100,
                              )
                              .ignore();
                          Navigator.of(sheetContext).pop();
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Formats price cents as whole dollars where possible ("\$45", "\$12.50").
String formatPrice(int cents) => cents % 100 == 0
    ? '\$${cents ~/ 100}'
    : '\$${(cents / 100).toStringAsFixed(2)}';

/// Short relative timestamp, e.g. `2h` — never `2h ago`; `ago` is
/// redundant when every card has one (whole.md §7 voice).
String relativeTime(DateTime time) {
  final delta = DateTime.now().difference(time);
  if (delta.inMinutes < 1) return 'Just now';
  if (delta.inMinutes < 60) return '${delta.inMinutes}m';
  if (delta.inHours < 24) return '${delta.inHours}h';
  if (delta.inDays < 7) return '${delta.inDays}d';
  return '${delta.inDays ~/ 7}w';
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
  const _SkeletonGrid({required this.gridDelegate});

  final SliverGridDelegate gridDelegate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(tokens.space4, 0, tokens.space4, 96),
      sliver: SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemCount: 6,
        itemBuilder: (_, _) => const ListingCardSkeleton(),
      ),
    );
  }
}
