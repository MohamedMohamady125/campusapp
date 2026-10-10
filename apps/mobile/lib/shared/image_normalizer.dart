import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Upload-ready image bytes — always JPEG after normalization, unless the
/// source couldn't be decoded (then the original passes through untouched
/// and the server does its own validation).
class NormalizedImage {
  const NormalizedImage({required this.bytes, required this.contentType});

  final Uint8List bytes;
  final String contentType;
}

/// Normalizes a profile photo from *any* source (12MP camera shots, tall
/// screenshots, transparent PNGs, sideways EXIF-rotated iPhone photos):
/// bakes orientation, flattens transparency onto white, center-crops to a
/// square (avatars render in circles — cover-fit would crop anyway,
/// so we crop once here and upload a fraction of the bytes), downscales to
/// ≤640px and re-encodes as JPEG, well inside the server's 5MB cap.
Future<NormalizedImage> normalizeAvatar(
  Uint8List bytes, {
  String fallbackContentType = 'image/jpeg',
}) => _run(
  _Request(
    bytes: bytes,
    square: true,
    maxDimension: 640,
    fallbackContentType: fallbackContentType,
  ),
);

/// Normalizes a full photo (payment-proof screenshots etc.): bakes EXIF
/// orientation, keeps the aspect ratio, downscales the long side to
/// ≤1600px and re-encodes as JPEG under the server's 5MB cap.
Future<NormalizedImage> normalizePhoto(
  Uint8List bytes, {
  String fallbackContentType = 'image/jpeg',
}) => _run(
  _Request(
    bytes: bytes,
    square: false,
    maxDimension: 1600,
    fallbackContentType: fallbackContentType,
  ),
);

/// Decode + resize off the UI thread (compute is a no-op passthrough on
/// web, where there is only one thread anyway).
Future<NormalizedImage> _run(_Request req) => compute(_normalize, req);

class _Request {
  const _Request({
    required this.bytes,
    required this.square,
    required this.maxDimension,
    required this.fallbackContentType,
  });

  final Uint8List bytes;
  final bool square;
  final int maxDimension;
  final String fallbackContentType;
}

/// The server rejects uploads over 5MB; aim well under it and step the
/// JPEG quality down for pathological inputs (e.g. pure-noise photos).
const int _targetMaxBytes = 4 * 1024 * 1024;

NormalizedImage _normalize(_Request req) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(req.bytes);
  } on Object {
    decoded = null;
  }
  if (decoded == null) {
    // Undecodable (e.g. HEIC on web) — let the server be the judge.
    return NormalizedImage(
      bytes: req.bytes,
      contentType: req.fallbackContentType,
    );
  }

  // Sideways-photo fix: iPhones store landscape pixels + an EXIF rotation
  // flag. Bake the rotation into the pixels so every consumer agrees.
  var image = img.bakeOrientation(decoded);

  // JPEG has no alpha — flatten transparent PNGs onto white, not black.
  if (image.hasAlpha) {
    final flat = img.Image(width: image.width, height: image.height);
    img.fill(flat, color: img.ColorRgb8(255, 255, 255));
    img.compositeImage(flat, image);
    image = flat;
  }

  // Avatars: center-crop to a square before scaling, so a tall portrait
  // keeps the face (center) instead of squishing or padding.
  if (req.square && image.width != image.height) {
    final side = image.width < image.height ? image.width : image.height;
    image = img.copyCrop(
      image,
      x: (image.width - side) ~/ 2,
      y: (image.height - side) ~/ 2,
      width: side,
      height: side,
    );
  }

  // Downscale only — never upscale a small image into blur.
  final longSide = image.width > image.height ? image.width : image.height;
  if (longSide > req.maxDimension) {
    image = img.copyResize(
      image,
      width: image.width >= image.height ? req.maxDimension : null,
      height: image.height > image.width ? req.maxDimension : null,
      interpolation: img.Interpolation.average,
    );
  }

  var quality = 85;
  var encoded = img.encodeJpg(image, quality: quality);
  while (encoded.length > _targetMaxBytes && quality > 40) {
    quality -= 15;
    encoded = img.encodeJpg(image, quality: quality);
  }
  return NormalizedImage(
    bytes: Uint8List.fromList(encoded),
    contentType: 'image/jpeg',
  );
}
