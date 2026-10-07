import 'dart:async';

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
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
    this.minPrice,
    this.maxPrice,
  });

  final List<ListingResponse> items;
  final String? nextCursor;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final String query;
  final ListingCategory? category;
  final int? minPrice;
  final int? maxPrice;

  bool get hasMore => nextCursor != null;

  BrowseState _copyWith({
    bool? loading,
    bool? loadingMore,
    List<ListingResponse>? items,
    String? Function()? nextCursor,
    String? Function()? error,
  }) => BrowseState(
    items: items ?? this.items,
    nextCursor: nextCursor != null ? nextCursor() : this.nextCursor,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: error != null ? error() : this.error,
    query: query,
    category: category,
    minPrice: minPrice,
    maxPrice: maxPrice,
  );
}

/// Browse live poll: new listings surface without pull-to-refresh, matching
/// the runs feed (spec §7.4 smart polling).
const kBrowsePollInterval = Duration(seconds: 15);

class BrowseController extends Notifier<BrowseState> {
  Timer? _poll;

  @override
  BrowseState build() {
    ref
      ..listen(authControllerProvider, (prev, next) {
        if (prev?.status != AuthStatus.authenticated &&
            next.status == AuthStatus.authenticated) {
          Future.microtask(refresh).ignore();
        }
      })
      ..onDispose(() => _poll?.cancel());
    _poll = Timer.periodic(kBrowsePollInterval, (_) => _pollTick());
    final auth = ref.read(authControllerProvider);
    if (auth.status == AuthStatus.authenticated) {
      Future.microtask(refresh).ignore();
    }
    return BrowseState(
      loading: auth.status == AuthStatus.authenticated,
    );
  }

  ListingsRepository get _repo => ref.read(listingsRepositoryProvider);

  void _pollTick() {
    if (ref.read(authControllerProvider).status != AuthStatus.authenticated) {
      return;
    }
    // Skip while the user is mid-interaction (first load / paging in).
    if (state.loading || state.loadingMore) return;
    _silentRefresh().ignore();
  }

  /// Poll refresh of page one — never flips the skeletons back on.
  Future<void> _silentRefresh() async {
    try {
      final page = await _repo.fetchPage(
        query: state.query,
        category: state.category,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
      );
      state = state._copyWith(
        items: page.items,
        nextCursor: () => page.nextCursor,
        error: () => null,
      );
    } on Object catch (e) {
      debugPrint('BrowseController.poll ERROR: $e');
    }
  }

  Future<void> refresh() async {
    state = state._copyWith(
      loading: true,
      error: () => null,
    );
    try {
      final page = await _repo.fetchPage(
        query: state.query,
        category: state.category,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
      );
      state = state._copyWith(
        loading: false,
        items: page.items,
        nextCursor: () => page.nextCursor,
      );
    } on Object catch (e) {
      debugPrint('BrowseController.refresh ERROR: $e');
      state = state._copyWith(
        loading: false,
        error: e.toString,
      );
    }
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loadingMore || state.loading) {
      return;
    }
    state = state._copyWith(loadingMore: true);
    try {
      final page = await _repo.fetchPage(
        query: state.query,
        category: state.category,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        cursor: cursor,
      );
      state = state._copyWith(
        loadingMore: false,
        items: [...state.items, ...page.items],
        nextCursor: () => page.nextCursor,
      );
    } on Object catch (e) {
      debugPrint('BrowseController.loadMore ERROR: $e');
      state = state._copyWith(loadingMore: false);
    }
  }

  Future<void> setQuery(String query) {
    state = BrowseState(
      loading: true,
      query: query,
      category: state.category,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
    );
    return refresh();
  }

  Future<void> setCategory(ListingCategory? category) {
    state = BrowseState(
      loading: true,
      query: state.query,
      category: category,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
    );
    return refresh();
  }

  Future<void> setPriceRange(int? min, int? max) {
    state = BrowseState(
      loading: true,
      query: state.query,
      category: state.category,
      minPrice: min,
      maxPrice: max,
    );
    return refresh();
  }
}

final browseControllerProvider =
    NotifierProvider<BrowseController, BrowseState>(
      BrowseController.new,
    );
