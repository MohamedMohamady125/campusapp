import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_colors.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Course code chip, e.g. `CS250` (spec §10.9, Fifty Free §3).
///
/// Stadium pill with the tinted-blue selected treatment: identifiers get
/// the brand accent so they read as tappable data. Tapping opens tutor
/// search.
class CourseCodeChip extends StatelessWidget {
  const CourseCodeChip({required this.code, super.key, this.onTap});

  final String code;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;

    return Material(
      color: colors.primaryContainer,
      shape: const StadiumBorder(
        side: BorderSide(color: AppColors.primaryBorder),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space3,
            vertical: tokens.space2,
          ),
          child: Text(
            code,
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: colors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
