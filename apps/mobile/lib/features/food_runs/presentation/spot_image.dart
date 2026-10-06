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
    super.key,
  });

  final String name;
  final String? imageUrl;
  final BoxFit fit;
  final double monogramFontSize;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _Monogram(name: name, fontSize: monogramFontSize);
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      // Quiet brand-tinted placeholder while the photo streams in — never a
      // spinner on a card (spec §6.3: zero-jank images, blur-up feel).
      placeholder: (_, _) => const ColoredBox(color: AppColors.primaryBg),
      errorWidget: (_, _, _) =>
          _Monogram(name: name, fontSize: monogramFontSize),
    );
  }
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
