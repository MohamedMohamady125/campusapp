import 'package:campusconnect/design_system/components/swipe_action.dart';
import 'package:campusconnect/design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] in the real app theme so `context.tokens`/`colors` resolve
/// when the reveal panel builds mid-drag.
Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 300, child: child)),
  ),
);

void main() {
  group('SwipeAction', () {
    testWidgets('committed right swipe fires onSwipeRight only', (
      tester,
    ) async {
      var right = 0;
      var left = 0;
      await tester.pumpWidget(
        _host(
          SwipeAction(
            onSwipeRight: () => right++,
            onSwipeLeft: () => left++,
            child: const SizedBox(height: 80, child: Text('order')),
          ),
        ),
      );

      // Drag well past the 32% (of 300px = 96px) commit threshold.
      await tester.drag(find.text('order'), const Offset(160, 0));
      await tester.pumpAndSettle();

      expect(right, 1);
      expect(left, 0);
    });

    testWidgets('committed left swipe fires onSwipeLeft only', (tester) async {
      var right = 0;
      var left = 0;
      await tester.pumpWidget(
        _host(
          SwipeAction(
            onSwipeRight: () => right++,
            onSwipeLeft: () => left++,
            child: const SizedBox(height: 80, child: Text('order')),
          ),
        ),
      );

      await tester.drag(find.text('order'), const Offset(-160, 0));
      await tester.pumpAndSettle();

      expect(left, 1);
      expect(right, 0);
    });

    testWidgets('short swipe under threshold fires nothing', (tester) async {
      var fired = 0;
      await tester.pumpWidget(
        _host(
          SwipeAction(
            onSwipeRight: () => fired++,
            onSwipeLeft: () => fired++,
            child: const SizedBox(height: 80, child: Text('order')),
          ),
        ),
      );

      // 40px is below the 96px threshold.
      await tester.drag(find.text('order'), const Offset(40, 0));
      await tester.pumpAndSettle();

      expect(fired, 0);
    });

    testWidgets('a direction with no callback never fires', (tester) async {
      var right = 0;
      await tester.pumpWidget(
        _host(
          SwipeAction(
            onSwipeRight: () => right++,
            // no onSwipeLeft
            child: const SizedBox(height: 80, child: Text('order')),
          ),
        ),
      );

      // Drag left hard — there is no left action, so nothing should fire.
      await tester.drag(find.text('order'), const Offset(-200, 0));
      await tester.pumpAndSettle();

      expect(right, 0);
    });
  });
}
