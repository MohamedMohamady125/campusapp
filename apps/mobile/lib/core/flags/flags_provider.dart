import 'dart:async';

import 'package:campusconnect/core/network/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Runs-first launch (food-runs spec): tab visibility is flag-driven so the
/// hidden marketplace/tutoring/chats tabs come back by flipping DB rows.
///
/// Failure default is *food runs only* — a flaky boot must never resurrect
/// tabs that were deliberately hidden for launch.
const kDefaultEnabledTabs = {'tab_food_runs'};

const kTabFoodRuns = 'tab_food_runs';
const kTabMarketplace = 'tab_marketplace';
const kTabTutoring = 'tab_tutoring';
const kTabChats = 'tab_chats';

class FlagsController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    unawaited(_load());
    return kDefaultEnabledTabs;
  }

  Future<void> _load() async {
    try {
      final api = ref.read(campusApiProvider).getMetaApi();
      final res = await api.getFlagsApiV1FlagsGet();
      final enabled = res.data!
          .where((f) => f.enabled)
          .map((f) => f.key)
          .toSet();
      // The hero tab is always reachable even if its row is missing/off —
      // an app with zero tabs is unusable.
      state = {...enabled, kTabFoodRuns};
    } on Object {
      state = kDefaultEnabledTabs; // keep the safe default
    }
  }

  Future<void> refresh() => _load();

  bool isEnabled(String key) => state.contains(key);
}

final flagsProvider = NotifierProvider<FlagsController, Set<String>>(
  FlagsController.new,
);
