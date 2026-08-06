import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Avatar sizes (spec §10.1).
enum AvatarSize {
  xs(18),
  sm(24),
  md(40),
  lg(56),
  xl(96);

  const AvatarSize(this.dp);
  final double dp;
}

/// Circular avatar with the verification emblem (spec §10.1).
///
/// - Emblem shown at [AvatarSize.md] and above only; below that it is noise.
/// - Fallback is initials on `secondaryContainer` — never a generic grey
///   person icon, which reads as "no real person here".
/// - An optional online dot replaces the emblem position (chat list only).
class VerifiedAvatar extends StatelessWidget {
  const VerifiedAvatar({
    required this.name,
    super.key,
    this.imageUrl,
    this.size = AvatarSize.md,
    this.showEmblem = true,
    this.online = false,
  });

  final String name;
  final String? imageUrl;
  final AvatarSize size;
  final bool showEmblem;
  final bool online;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    final dp = size.dp;
    final emblemVisible = showEmblem && !online && size.dp >= AvatarSize.md.dp;
    final emblemSize = dp >= AvatarSize.lg.dp ? 16.0 : 12.0;

    final circle = ClipOval(
      child: SizedBox(
        width: dp,
        height: dp,
        child: imageUrl == null || imageUrl!.isEmpty
            // Fifty Free avatar: primaryBg circle, Manrope w800 letter in
            // primaryDark (mapped to primaryContainer/onPrimaryContainer).
            ? ColoredBox(
                color: colors.primaryContainer,
                child: Center(
                  child: Text(
                    _initials,
                    style: AppTextStyles.avatarLetter.copyWith(
                      fontSize: dp * 0.36,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    ColoredBox(color: colors.surfaceContainerHighest),
                errorWidget: (_, _, _) => ColoredBox(
                  color: colors.primaryContainer,
                  child: Center(
                    child: Text(
                      _initials,
                      style: AppTextStyles.avatarLetter.copyWith(
                        fontSize: dp * 0.36,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );

    return Semantics(
      label: '$name, verified student',
      image: imageUrl != null,
      child: ExcludeSemantics(
        child: SizedBox(
          width: dp,
          height: dp,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              circle,
              if (emblemVisible)
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: emblemSize,
                    height: emblemSize,
                    decoration: BoxDecoration(
                      color: tokens.verified,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 2),
                    ),
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(1),
                        child: Icon(
                          Icons.check,
                          color: tokens.onVerified,
                        ),
                      ),
                    ),
                  ),
                ),
              if (online)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: tokens.online,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
