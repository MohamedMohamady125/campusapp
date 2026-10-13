import 'dart:async' show unawaited;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_colors.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';

/// Food-spot hero photo with a graceful monogram fallback.
///
/// Spots carry an `image_url` from the catalog; when it's missing (or the
/// image fails to load) we fall back to the branded gradient monogram tile
/// so the layout never shows a broken-image glyph. Used by the feed cards,
/// the hero card backdrop and the run-detail header.
class SpotImage extends StatelessWidget {
  const SpotImage({
    required this.name,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.monogramFontSize = 28,
    this.decodeWidth = 800,
    super.key,
  });

  final String name;
  final String? imageUrl;
  final BoxFit fit;
  final double monogramFontSize;

  /// Logical-pixel decode target. Catalog photos can be huge; decoding
  /// them at display size (not full resolution) is what keeps fast
  /// scrolling smooth — a full-res decode per card stalls the raster
  /// thread and makes images pop in late.
  final double decodeWidth;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _Monogram(name: name, fontSize: monogramFontSize);
    }
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final physicalWidth = (decodeWidth * dpr).round();
    return CachedNetworkImage(
      imageUrl: sizedSpotImageUrl(url, physicalWidth),
      fit: fit,
      memCacheWidth: physicalWidth,
      fadeInDuration: const Duration(milliseconds: 120),
      // Quiet brand-tinted placeholder while the photo streams in — never a
      // spinner on a card (spec §6.3: zero-jank images, blur-up feel).
      placeholder: (_, _) => const ColoredBox(color: AppColors.primaryBg),
      errorWidget: (_, _, _) =>
          _Monogram(name: name, fontSize: monogramFontSize),
    );
  }
}

/// Rewrites a CDN image URL to request no more pixels than [physicalWidth].
///
/// The catalog ships Unsplash URLs at w=1000 — fetching that for a 44px
/// thumbnail wastes ~10× the bytes and makes fast scrolling feel slow on
/// cellular. Only shrinks (never upscales), keeps the crop aspect by scaling
/// `h` proportionally, and leaves non-Unsplash URLs untouched.
String sizedSpotImageUrl(String url, int physicalWidth) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host != 'images.unsplash.com') return url;
  final params = Map<String, String>.from(uri.queryParameters);
  final w = int.tryParse(params['w'] ?? '');
  if (w == null || w <= physicalWidth) return url;
  params['w'] = '$physicalWidth';
  final h = int.tryParse(params['h'] ?? '');
  if (h != null) params['h'] = '${(h * physicalWidth / w).round()}';
  return uri.replace(queryParameters: params).toString();
}

/// Warm the image cache for a spot photo before its card scrolls into view.
/// Fire-and-forget; errors are swallowed (the card's monogram fallback
/// handles genuinely broken URLs).
void precacheSpotImage(
  BuildContext context,
  String? url, {
  double decodeWidth = 800,
}) {
  if (url == null || url.isEmpty) return;
  final physicalWidth = (decodeWidth * MediaQuery.devicePixelRatioOf(context))
      .round();
  unawaited(
    precacheImage(
      CachedNetworkImageProvider(sizedSpotImageUrl(url, physicalWidth)),
      context,
      onError: (_, _) {},
    ),
  );
}

/// Branded gradient tile with the spot's initial — the pre-imagery look,
/// kept as the no-photo fallback.
class _Monogram extends StatelessWidget {
  const _Monogram({required this.name, required this.fontSize});

  final String name;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBg, AppColors.primaryMuted],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.avatarLetter.copyWith(fontSize: fontSize),
        ),
      ),
    );
  }
}
