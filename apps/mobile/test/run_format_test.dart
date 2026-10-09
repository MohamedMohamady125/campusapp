import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/food_runs/presentation/run_format.dart';
import 'package:flutter_test/flutter_test.dart';

RunResponse _run({required int taken, required int max, bool mine = false}) =>
    RunResponse(
      (b) => b
        ..id = 'run-1'
        ..feeCents = 0
        ..prepayRequired = false
        ..spotsMax = max
        ..acceptedCount = taken
        ..pendingCount = 0
        ..isMine = mine
        ..leavingAt = DateTime.utc(2026)
        ..createdAt = DateTime.utc(2026)
        ..status = RunStatus.open
        ..runner.replace(
          RunUserSummary(
            (u) => u
              ..id = 'u-1'
              ..displayName = 'Runner'
              ..reputationScore = 5
              ..ratingCount = 1,
          ),
        )
        ..foodSpot.replace(
          FoodSpotResponse(
            (s) => s
              ..id = 'spot-1'
              ..name = 'Spot'
              ..category = FoodSpotCategory.campus,
          ),
        ),
    );

void main() {
  group('spotsLabel', () {
    test('requesters see scarcity framing, never "taken" counts', () {
      expect(spotsLabel(_run(taken: 0, max: 3)), '3 spots left');
      expect(spotsLabel(_run(taken: 2, max: 3)), '1 spot left');
      expect(spotsLabel(_run(taken: 3, max: 3)), 'Run is full');
    });

    test('the runner keeps the taken/total fraction', () {
      expect(
        spotsLabel(_run(taken: 1, max: 3, mine: true)),
        '1/3 spots filled',
      );
      expect(
        spotsLabel(_run(taken: 3, max: 3, mine: true)),
        '3/3 spots filled',
      );
    });
  });
}
