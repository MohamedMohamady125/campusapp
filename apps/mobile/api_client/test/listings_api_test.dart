import 'package:test/test.dart';
import 'package:campus_api/campus_api.dart';


/// tests for ListingsApi
void main() {
  final instance = CampusApi().getListingsApi();

  group(ListingsApi, () {
    // Create Listing
    //
    //Future<ListingResponse> createListingApiV1ListingsPost(ListingCreateRequest listingCreateRequest) async
    test('test createListingApiV1ListingsPost', () async {
      // TODO
    });

    // Delete Listing
    //
    //Future deleteListingApiV1ListingsListingIdDelete(String listingId) async
    test('test deleteListingApiV1ListingsListingIdDelete', () async {
      // TODO
    });

    // Get Listing
    //
    //Future<ListingResponse> getListingApiV1ListingsListingIdGet(String listingId) async
    test('test getListingApiV1ListingsListingIdGet', () async {
      // TODO
    });

    // Image Upload Url
    //
    //Future<ImageUploadUrlResponse> imageUploadUrlApiV1ListingsListingIdImageUploadUrlPost(String listingId, ImageUploadUrlRequest imageUploadUrlRequest) async
    test('test imageUploadUrlApiV1ListingsListingIdImageUploadUrlPost', () async {
      // TODO
    });

    // List Listings
    //
    //Future<ListingPageResponse> listListingsApiV1ListingsGet({ String q, ListingCategory category, ListingCondition condition, int minPrice, int maxPrice, String cursor, int limit }) async
    test('test listListingsApiV1ListingsGet', () async {
      // TODO
    });

    // Mark Sold
    //
    //Future<ListingResponse> markSoldApiV1ListingsListingIdMarkSoldPost(String listingId) async
    test('test markSoldApiV1ListingsListingIdMarkSoldPost', () async {
      // TODO
    });

    // Promote Listing
    //
    // Promoted listings rail (spec §13.1) — 403 FEATURE_DISABLED while the flag is off.
    //
    //Future<ListingResponse> promoteListingApiV1ListingsListingIdPromotePost(String listingId) async
    test('test promoteListingApiV1ListingsListingIdPromotePost', () async {
      // TODO
    });

    // Update Listing
    //
    //Future<ListingResponse> updateListingApiV1ListingsListingIdPatch(String listingId, ListingUpdateRequest listingUpdateRequest) async
    test('test updateListingApiV1ListingsListingIdPatch', () async {
      // TODO
    });

  });
}
