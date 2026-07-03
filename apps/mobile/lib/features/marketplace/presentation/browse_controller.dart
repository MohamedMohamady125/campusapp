import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/marketplace/data/listings_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Browse state: accumulated pages + filters (infinite scroll, §6.2
/// PaginatedListView behavior).
@immutable
class BrowseState {
  const BrowseState({
    this.items = const [],
    this.nextCursor,
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.query = '',
    this.category,
  });

  final List<ListingResponse> items;
  final String? nextCursor;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final String query;
  final ListingCategory? category;

  bool get hasMore => nextCursor != null;
}

class BrowseController extends Notifier<BrowseState> {
  @override
  BrowseState build() {
    Future.microtask(refresh).ignore();
    return const BrowseState(loading: true);
  }

  ListingsRepository get _repo => ref.read(listingsRepositoryProvider);

  Future<void> refresh() async {
    state = BrowseState(
      loading: true,
      query: state.query,
      category: state.category,
    );
    try {
      final page = await _repo.fetchPage(
        query: state.query,
        category: state.category,
      );
      state = BrowseState(
        items: page.items,
        nextCursor: page.nextCursor,
        query: state.query,
        category: state.category,
      );
    } on Object catch (e) {
      state = BrowseState(
        error: e.toString(),
        query: state.query,
        category: state.category,
      );
    }
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loadingMore || state.loading) return;
    state = BrowseState(
      items: state.items,
      nextCursor: cursor,
      loadingMore: true,
      query: state.query,
      category: state.category,
    );
    try {
      final page = await _repo.fetchPage(
        query: state.query,
        category: state.category,
        cursor: cursor,
      );
      state = BrowseState(
        items: [...state.items, ...page.items],
        nextCursor: page.nextCursor,
        query: state.query,
        category: state.category,
      );
    } on Object {
      // Keep what we have; next scroll retriggers loadMore.
      state = BrowseState(
        items: state.items,
        nextCursor: cursor,
        query: state.query,
        category: state.category,
      );
    }
  }

  Future<void> setQuery(String query) {
    state = BrowseState(
      loading: true,
      query: query,
      category: state.category,
    );
    return refresh();
  }

  Future<void> setCategory(ListingCategory? category) {
    state = BrowseState(loading: true, query: state.query, category: category);
    return refresh();
  }
}

final browseControllerProvider =
    NotifierProvider<BrowseController, BrowseState>(
      BrowseController.new,
    );
