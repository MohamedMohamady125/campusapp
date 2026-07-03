import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/marketplace/data/listings_repository.dart';
import 'package:campusconnect/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_auth.dart';

ListingResponse _listing(String id, String title, int cents) => ListingResponse(
  (b) => b
    ..id = id
    ..title = title
    ..description = 'desc'
    ..priceCents = cents
    ..category = ListingCategory.textbooks
    ..condition = ListingCondition.good
    ..status = ListingStatus.active
    ..createdAt = DateTime.utc(2026)
    ..expiresAt = DateTime.utc(2026, 4)
    ..seller.replace(
      UserPublicResponse(
        (s) => s
          ..id = 'u-2'
          ..displayName = 'Sara Seller'
          ..ratingCount = 12
          ..reputationScore = 4.6
          ..createdAt = DateTime.utc(2026),
      ),
    ),
);

class _FakeListingsRepository implements ListingsRepository {
  _FakeListingsRepository(this.pages);

  final List<ListingsPage> pages;
  int calls = 0;
  ListingCategory? lastCategory;
  String? lastQuery;

  @override
  Future<ListingsPage> fetchPage({
    String? query,
    ListingCategory? category,
    String? cursor,
  }) async {
    lastQuery = query;
    lastCategory = category;
    final page = pages[calls.clamp(0, pages.length - 1)];
    calls++;
    return page;
  }

  @override
  Future<ListingResponse> fetchListing(String id) async =>
      _listing(id, 'Calc Textbook', 2500);
}

Widget _app(_FakeListingsRepository repo) => ProviderScope(
  overrides: [
    authControllerProvider.overrideWith(
      () => FakeAuthController(authedState()),
    ),
    listingsRepositoryProvider.overrideWithValue(repo),
  ],
  child: const CampusConnectApp(),
);

void main() {
  testWidgets('browse renders listings with prices', (tester) async {
    final repo = _FakeListingsRepository([
      ListingsPage(
        items: [
          _listing('l1', 'Calc Textbook', 2500),
          _listing('l2', 'Desk Lamp', 900),
        ],
      ),
    ]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(find.text('Calc Textbook'), findsOneWidget);
    expect(find.text(r'$25.00'), findsOneWidget);
    expect(find.text('Desk Lamp'), findsOneWidget);
    expect(find.text(r'$9.00'), findsOneWidget);
  });

  testWidgets('empty feed shows actionable empty state', (tester) async {
    final repo = _FakeListingsRepository([const ListingsPage(items: [])]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(find.text('No listings yet'), findsOneWidget);
    expect(find.text('Sell something'), findsOneWidget);
  });

  testWidgets('category chip filters trigger a refetch', (tester) async {
    final repo = _FakeListingsRepository([const ListingsPage(items: [])]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Furniture'));
    await tester.pumpAndSettle();

    expect(repo.lastCategory, ListingCategory.furniture);
    expect(repo.calls, 2);
  });

  testWidgets('tapping a listing opens detail with seller reputation', (
    tester,
  ) async {
    final repo = _FakeListingsRepository([
      ListingsPage(items: [_listing('l1', 'Calc Textbook', 2500)]),
    ]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calc Textbook'));
    await tester.pumpAndSettle();

    // Seller card sits below the fold in the lazy ListView — scroll to it.
    await tester.scrollUntilVisible(find.text('Sara Seller'), 200);
    expect(find.text('Sara Seller'), findsOneWidget);
    expect(find.text('4.6 (12)'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Message seller'), 200);
    expect(find.text('Message seller'), findsOneWidget);
  });
}
