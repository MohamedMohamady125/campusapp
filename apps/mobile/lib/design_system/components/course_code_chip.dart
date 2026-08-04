import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Course code chip, e.g. `CS250` (spec §10.9).
///
/// Rectangular (radiusSm), not stadium — course codes are identifiers and
/// rectangular reads as "data", not "tag". Tapping opens tutor search.
class CourseCodeChip extends StatelessWidget {
  const CourseCodeChip({required this.code, super.key, this.onTap});

  final String code;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;

    return Material(
      color: colors.secondaryContainer,
      borderRadius: tokens.brSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: tokens.brSm,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space3,
            vertical: tokens.space2,
          ),
          child: Text(
            code,
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: colors.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
