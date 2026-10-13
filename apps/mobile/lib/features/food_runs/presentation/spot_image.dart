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
    return CachedNetworkImage(
      // One canonical URL for every consumer (feed banner, hero backdrop,
      // detail header, picker thumb): a spot's photo downloads exactly once
      // per install, then every screen reads the warm disk cache.
      imageUrl: spotImageUrl(url),
      fit: fit,
      // Decode (not fetch) at display size — tiny thumbs stay cheap even
      // though they share the full card-size file.
      memCacheWidth: (decodeWidth * dpr).round(),
      fadeInDuration: const Duration(milliseconds: 120),
      // Quiet brand-tinted placeholder while the photo streams in — never a
      // spinner on a card (spec §6.3: zero-jank images, blur-up feel).
      placeholder: (_, _) => const ColoredBox(color: AppColors.primaryBg),
      errorWidget: (_, _, _) =>
          _Monogram(name: name, fontSize: monogramFontSize),
    );
  }
}

/// Canonical fetch width (physical px) for all spot photos. One shared
/// variant keeps the cache hit-rate at 100% across screens; 800px over the
/// catalog's 2:1 crop is card-sharp at q=70 while costing ~35% fewer bytes
/// than the raw w=1000 source.
const kSpotImagePhysicalWidth = 800;

/// The one URL every spot-photo consumer uses (see [kSpotImagePhysicalWidth]).
String spotImageUrl(String url) =>
    sizedSpotImageUrl(url, kSpotImagePhysicalWidth);

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
/// Uses the canonical variant, so this also covers the detail header, the
/// picker and every other consumer. Fire-and-forget; errors are swallowed
/// (the card's monogram fallback handles genuinely broken URLs).
void precacheSpotImage(BuildContext context, String? url) {
  if (url == null || url.isEmpty) return;
  unawaited(
    precacheImage(
      CachedNetworkImageProvider(spotImageUrl(url)),
      context,
      onError: (_, _) {},
    ),
  );
}

/// Warm a user avatar before its row scrolls into view. Downloads the full
/// file into the shared disk cache but decodes at a bounded width, so a
/// multi-MP selfie never costs a full-res decode during the warmup.
void precacheAvatar(BuildContext context, String? url) {
  if (url == null || url.isEmpty) return;
  unawaited(
    precacheImage(
      ResizeImage(CachedNetworkImageProvider(url), width: 256),
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
