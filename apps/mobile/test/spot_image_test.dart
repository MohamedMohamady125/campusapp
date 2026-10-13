import 'package:campusconnect/features/food_runs/presentation/spot_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sizedSpotImageUrl', () {
    const base =
        'https://images.unsplash.com/photo-123?auto=format&fit=crop&w=1000&h=500&q=70';

    test('shrinks w and scales h proportionally', () {
      final url = Uri.parse(sizedSpotImageUrl(base, 400));
      expect(url.queryParameters['w'], '400');
      expect(url.queryParameters['h'], '200');
      expect(url.queryParameters['q'], '70');
      expect(url.host, 'images.unsplash.com');
    });

    test('never upscales', () {
      expect(sizedSpotImageUrl(base, 1000), base);
      expect(sizedSpotImageUrl(base, 2400), base);
    });

    test('leaves non-Unsplash and malformed URLs untouched', () {
      const api = 'https://api.example.com/images/abc?w=9999';
      expect(sizedSpotImageUrl(api, 100), api);
      expect(sizedSpotImageUrl('not a url', 100), 'not a url');
    });

    test('handles missing w/h params', () {
      const bare = 'https://images.unsplash.com/photo-123?auto=format';
      expect(sizedSpotImageUrl(bare, 100), bare);
    });
  });
}
