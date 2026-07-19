import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/network/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One page of listings plus the cursor for the next (spec §2.4:
/// every list endpoint is cursor-paginated).
class ListingsPage {
  const ListingsPage({required this.items, this.nextCursor});

  final List<ListingResponse> items;
  final String? nextCursor;
}

/// Marketplace reads/writes via the generated client (spec §4.1 listings).
class ListingsRepository {
  ListingsRepository(this._api);

  final CampusApi _api;

  ListingsApi get _listings => _api.getListingsApi();

  Future<ListingsPage> fetchPage({
    String? query,
    ListingCategory? category,
    int? minPrice,
    int? maxPrice,
    String? cursor,
  }) async {
    final res = await _listings.listListingsApiV1ListingsGet(
      q: (query == null || query.isEmpty) ? null : query,
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      cursor: cursor,
    );
    final page = res.data!;
    return ListingsPage(
      items: page.items.toList(),
      nextCursor: page.nextCursor,
    );
  }

  Future<ListingResponse> fetchListing(String id) async {
    final res = await _listings.getListingApiV1ListingsListingIdGet(
      listingId: id,
    );
    return res.data!;
  }

  Future<ListingResponse> createListing({
    required String title,
    required String description,
    required int priceCents,
    required ListingCategory category,
    required ListingCondition condition,
  }) async {
    final res = await _listings.createListingApiV1ListingsPost(
      listingCreateRequest: ListingCreateRequest(
        (b) => b
          ..title = title
          ..description = description
          ..priceCents = priceCents
          ..category = category
          ..condition = condition,
      ),
    );
    return res.data!;
  }

  Future<ListingResponse> markSold(String id) async {
    final res = await _listings.markSoldApiV1ListingsListingIdMarkSoldPost(
      listingId: id,
    );
    return res.data!;
  }

  Future<void> deleteListing(String id) async {
    await _listings.deleteListingApiV1ListingsListingIdDelete(listingId: id);
  }

  Future<ListingResponse> updateListing({
    required String id,
    String? title,
    String? description,
    int? priceCents,
    ListingCategory? category,
    ListingCondition? condition,
  }) async {
    final res = await _listings.updateListingApiV1ListingsListingIdPatch(
      listingId: id,
      listingUpdateRequest: ListingUpdateRequest(
        (b) => b
          ..title = title
          ..description = description
          ..priceCents = priceCents
          ..category = category
          ..condition = condition,
      ),
    );
    return res.data!;
  }

  /// Fetch all listings, then filter client-side to the current user's.
  /// Good enough for demo; a server-side filter would be better at scale.
  Future<List<ListingResponse>> fetchMyListings(String userId) async {
    final allItems = <ListingResponse>[];
    String? cursor;
    // Fetch up to 3 pages (60 items) to find the user's listings.
    for (var i = 0; i < 3; i++) {
      final res = await _listings.listListingsApiV1ListingsGet(cursor: cursor);
      final page = res.data!;
      allItems.addAll(page.items);
      cursor = page.nextCursor;
      if (cursor == null) break;
    }
    return allItems.where((l) => l.seller.id == userId).toList();
  }
}

final listingsRepositoryProvider = Provider<ListingsRepository>(
  (ref) => ListingsRepository(ref.watch(campusApiProvider)),
);
