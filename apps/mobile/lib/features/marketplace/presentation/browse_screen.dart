import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/marketplace/presentation/browse_controller.dart';
import 'package:campusconnect/shared/widgets/empty_state.dart';
import 'package:campusconnect/shared/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Marketplace browse (J1 entry + spec S6.4): search,
/// category filters, infinite-scroll grid, skeletons on
/// first load.
class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() =>
      _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >
          _scroll.position.maxScrollExtent - 400) {
        ref
            .read(browseControllerProvider.notifier)
            .loadMore()
            .ignore();
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
    final controller =
        ref.read(browseControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
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
            // -- Premium header with branding ----------
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  scheme.primary,
                                  scheme.tertiary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                AppRadius.sm,
                              ),
                            ),
                            child: Icon(
                              Icons.storefront_rounded,
                              color: scheme.onPrimary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(
                            width: AppSpacing.md,
                          ),
                          Text(
                            'Marketplace',
                            style: tt.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Buy & sell with verified students',
                        style: tt.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // -- Search bar with shadow ----------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      AppRadius.pill,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow
                            .withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                      hintText:
                          'Search textbooks, furniture\u2026',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          AppRadius.pill,
                        ),
                        borderSide: BorderSide(
                          color: scheme.outlineVariant,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          AppRadius.pill,
                        ),
                        borderSide: BorderSide(
                          color: scheme.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          AppRadius.pill,
                        ),
                        borderSide: BorderSide(
                          color: scheme.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.md,
                      ),
                    ),
                    textInputAction:
                        TextInputAction.search,
                    onSubmitted: (q) => controller
                        .setQuery(q.trim())
                        .ignore(),
                  ),
                ),
              ),
            ),

            // -- Category chips with icons -------------
            SliverToBoxAdapter(
              child: _CategoryChips(state: state),
            ),

            // -- Price filter --------------------------
            SliverToBoxAdapter(
              child: _PriceFilter(state: state),
            ),

            // -- Content area --------------------------
            if (state.loading)
              const _SkeletonGrid()
            else if (state.error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.cloud_off,
                  title: 'Could not load listings',
                  message:
                      'Check your connection and try again.',
                  actionLabel: 'Retry',
                  onAction: () =>
                      controller.refresh().ignore(),
                ),
              )
            else if (state.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.storefront_outlined,
                  title: 'No listings yet',
                  message:
                      'Be the first \u2014 post something to sell.',
                  actionLabel: 'Sell something',
                  onAction: () =>
                      context.go('/market/sell'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(
                  AppSpacing.lg,
                ),
                sliver: SliverGrid.builder(
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: AppSpacing.lg,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: state.items.length,
                  itemBuilder: (context, i) =>
                      FadeSlideIn(
                    index: i,
                    child: _ListingCard(
                      listing: state.items[i],
                    ),
                  ),
                ),
              ),

            if (state.loadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// -- Category chips with icons per category -----------
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
    final controller =
        ref.read(browseControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        children: [
          for (final entry in _labels.entries)
            Padding(
              padding: const EdgeInsets.only(
                right: AppSpacing.sm,
              ),
              child: FilterChip(
                avatar: Icon(
                  listingCategoryIcons[entry.key] ??
                      Icons.category,
                  size: 18,
                  color: state.category == entry.key
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
                label: Text(entry.value),
                selected: state.category == entry.key,
                onSelected: (on) => controller
                    .setCategory(
                      on ? entry.key : null,
                    )
                    .ignore(),
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
  ConsumerState<_PriceFilter> createState() =>
      _PriceFilterState();
}

class _PriceFilterState
    extends ConsumerState<_PriceFilter> {
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
    final controller =
        ref.read(browseControllerProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FilterChip(
                label: Text(
                  _active
                      ? '\$${_range.start.round()}'
                          ' \u2013 '
                          '\$${_range.end.round()}'
                      : 'Price range',
                ),
                avatar: const Icon(
                  Icons.attach_money,
                  size: 18,
                ),
                selected: _active,
                onSelected: (on) {
                  setState(() => _active = on);
                  if (!on) {
                    controller
                        .setPriceRange(null, null)
                        .ignore();
                  }
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
              onChanged: (v) =>
                  setState(() => _range = v),
              onChangeEnd: (v) {
                controller
                    .setPriceRange(
                      v.start.round() * 100,
                      v.end.round() * 100,
                    )
                    .ignore();
              },
            ),
        ],
      ),
    );
  }
}

/// Formats price cents as dollars ("\$12.50").
String formatPrice(int cents) =>
    '\$${(cents / 100).toStringAsFixed(2)}';

/// Icon per category, reused by detail screen
/// placeholders.
const listingCategoryIcons =
    <ListingCategory, IconData>{
  ListingCategory.textbooks: Icons.menu_book,
  ListingCategory.furniture: Icons.chair,
  ListingCategory.electronics: Icons.devices,
  ListingCategory.tickets: Icons.confirmation_number,
  ListingCategory.clothing: Icons.checkroom,
  ListingCategory.other: Icons.category,
};

// -- Listing card (Depop/Instagram style) -------------
class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});

  final ListingResponse listing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.outlineVariant),
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => context.go(
          '/market/listing/${listing.id}',
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // -- Image area with price badge ----------
            Expanded(
              flex: 4,
              child: Hero(
                tag: 'listing-image-${listing.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color:
                            scheme.surfaceContainerHighest,
                        borderRadius:
                            const BorderRadius.vertical(
                          top: Radius.circular(
                            AppRadius.lg - 1,
                          ),
                        ),
                      ),
                      child: Icon(
                        listingCategoryIcons[
                                listing.category] ??
                            Icons.category,
                        size: 44,
                        color: scheme.onSurfaceVariant
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    // Gradient overlay at bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black
                                  .withValues(alpha: 0.25),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Price badge
                    Positioned(
                      left: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs + 1,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius:
                              BorderRadius.circular(
                            AppRadius.pill,
                          ),
                        ),
                        child: Text(
                          formatPrice(
                            listing.priceCents,
                          ),
                          style:
                              tt.labelMedium?.copyWith(
                            color:
                                scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // Sold overlay
                    if (listing.status ==
                        ListingStatus.sold)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black
                                .withValues(alpha: 0.45),
                            borderRadius:
                                const BorderRadius
                                    .vertical(
                              top: Radius.circular(
                                AppRadius.lg - 1,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.surface
                                  .withValues(
                                alpha: 0.95,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Text(
                              'SOLD',
                              style: tt.labelLarge
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // -- Info area ----------------------------
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.xs,
                    ),
                    Row(
                      children: [
                        Icon(
                          listingCategoryIcons[
                                  listing.category] ??
                              Icons.category,
                          size: 13,
                          color:
                              scheme.onSurfaceVariant,
                        ),
                        const SizedBox(
                          width: AppSpacing.xs,
                        ),
                        Flexible(
                          child: Text(
                            _categoryLabel(
                              listing.category,
                            ),
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                tt.bodySmall?.copyWith(
                              color: scheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _categoryLabel(ListingCategory cat) {
    switch (cat) {
      case ListingCategory.textbooks:
        return 'Textbooks';
      case ListingCategory.furniture:
        return 'Furniture';
      case ListingCategory.electronics:
        return 'Electronics';
      case ListingCategory.tickets:
        return 'Tickets';
      case ListingCategory.clothing:
        return 'Clothing';
      case ListingCategory.other:
        return 'Other';
    }
    return cat.name;
  }
}

/// Skeleton grid for initial load (spec S6.3: never a
/// bare spinner on a blank screen).
class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: SliverGrid.builder(
        gridDelegate:
            const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: AppSpacing.lg,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.68,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => _SkeletonCard(
          scheme: scheme,
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard({required this.scheme});

  final ColorScheme scheme;

  @override
  State<_SkeletonCard> createState() =>
      _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true).ignore();
    _opacity = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        final color = widget.scheme.surfaceContainerHighest
            .withValues(alpha: _opacity.value);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppRadius.lg,
            ),
            border: Border.all(
              color: widget.scheme.outlineVariant
                  .withValues(alpha: 0.5),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: Container(color: color),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius:
                              BorderRadius.circular(
                            AppRadius.sm,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: AppSpacing.sm,
                      ),
                      Container(
                        height: 10,
                        width: 80,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius:
                              BorderRadius.circular(
                            AppRadius.sm,
                          ),
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
    );
  }
}
