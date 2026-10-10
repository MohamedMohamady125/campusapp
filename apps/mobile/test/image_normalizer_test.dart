import 'dart:typed_data';

import 'package:campusconnect/shared/image_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

Uint8List _png(int width, int height, {bool alpha = false}) {
  final im = img.Image(
    width: width,
    height: height,
    numChannels: alpha ? 4 : 3,
  );
  img.fill(
    im,
    color: alpha ? img.ColorRgba8(200, 40, 40, 0) : img.ColorRgb8(200, 40, 40),
  );
  return Uint8List.fromList(img.encodePng(im));
}

void main() {
  group('normalizeAvatar', () {
    test('tall portrait is center-cropped square and capped at 640', () async {
      final out = await normalizeAvatar(_png(900, 2400));
      final decoded = img.decodeImage(out.bytes)!;
      expect(out.contentType, 'image/jpeg');
      expect(decoded.width, decoded.height);
      expect(decoded.width, 640);
    });

    test('wide landscape is center-cropped square', () async {
      final out = await normalizeAvatar(_png(3000, 1000));
      final decoded = img.decodeImage(out.bytes)!;
      expect(decoded.width, decoded.height);
      expect(decoded.width, 640);
    });

    test('small photo is never upscaled', () async {
      final out = await normalizeAvatar(_png(200, 300));
      final decoded = img.decodeImage(out.bytes)!;
      expect(decoded.width, 200);
      expect(decoded.height, 200);
    });

    test('transparent PNG flattens to white, not black', () async {
      final out = await normalizeAvatar(_png(100, 100, alpha: true));
      final decoded = img.decodeImage(out.bytes)!;
      final p = decoded.getPixel(50, 50);
      // Fully transparent source → white background shows through.
      expect(p.r, greaterThan(240));
      expect(p.g, greaterThan(240));
      expect(p.b, greaterThan(240));
    });

    test('undecodable bytes pass through with the fallback type', () async {
      final junk = Uint8List.fromList(List.filled(64, 7));
      final out = await normalizeAvatar(
        junk,
        fallbackContentType: 'image/webp',
      );
      expect(out.bytes, junk);
      expect(out.contentType, 'image/webp');
    });
  });

  group('normalizePhoto', () {
    test('keeps aspect ratio, caps long side at 1600', () async {
      final out = await normalizePhoto(_png(4000, 3000));
      final decoded = img.decodeImage(out.bytes)!;
      expect(decoded.width, 1600);
      expect(decoded.height, 1200);
      expect(out.contentType, 'image/jpeg');
    });

    test('portrait long side is the height', () async {
      final out = await normalizePhoto(_png(1080, 2340));
      final decoded = img.decodeImage(out.bytes)!;
      expect(decoded.height, 1600);
      // 1080/2340 * 1600 ≈ 738 — aspect preserved, no squish.
      expect((decoded.width - 738).abs() <= 1, isTrue);
    });

    test('stays under the 5MB server cap even for large inputs', () async {
      final out = await normalizePhoto(_png(4000, 4000));
      expect(out.bytes.length, lessThan(5 * 1024 * 1024));
    });
  });
}
