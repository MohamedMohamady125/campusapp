import 'package:campusconnect/core/flags/flags_provider.dart';
import 'package:campusconnect/features/food_runs/data/runs_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

/// Flags controller pinned to a fixed set — no network on build.
class FakeFlagsController extends FlagsController {
  FakeFlagsController(this.flags);

  final Set<String> flags;

  @override
  Set<String> build() => flags;
}

/// Every tab visible — the default for pre-existing shell suites.
const Set<String> allTabFlags = {
  kTabFoodRuns,
  kTabMarketplace,
  kTabTutoring,
  kTabChats,
};

class MockRunsRepository extends Mock implements RunsRepository {}

/// Riverpod overrides that make the runs-first shell render deterministically:
/// all tabs enabled and an empty (but successful) runs feed.
List<Override> shellOverrides({Set<String> flags = allTabFlags}) {
  final runs = MockRunsRepository();
  when(
    () => runs.fetchFeed(cursor: any(named: 'cursor')),
  ).thenAnswer((_) async => const RunsPage(items: []));
  when(runs.fetchMyRuns).thenAnswer((_) async => []);
  return [
    flagsProvider.overrideWith(() => FakeFlagsController(flags)),
    runsRepositoryProvider.overrideWithValue(runs),
  ];
}
