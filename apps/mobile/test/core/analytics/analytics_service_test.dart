import 'package:campusconnect/core/analytics/analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeScreen', () {
    test('collapses UUID segments to :id', () {
      expect(
        normalizeScreen('/runs/run/8f14e45f-ceea-467f-a0e6-b5d842ee6ad3'),
        '/runs/run/:id',
      );
      expect(
        normalizeScreen('/messages/123e4567-e89b-12d3-a456-426614174000'),
        '/messages/:id',
      );
    });

    test('collapses numeric segments to :id', () {
      expect(normalizeScreen('/market/listing/42'), '/market/listing/:id');
    });

    test('keeps static routes untouched', () {
      expect(normalizeScreen('/runs'), '/runs');
      expect(
        normalizeScreen('/profile/payment-methods'),
        '/profile/payment-methods',
      );
    });

    test('strips query strings and handles root', () {
      expect(normalizeScreen('/runs?filter=open'), '/runs');
      expect(normalizeScreen('/'), '/');
    });

    test('caps absurdly long paths at 80 chars', () {
      final long = '/${'a' * 200}';
      expect(normalizeScreen(long).length, 80);
    });
  });
}
