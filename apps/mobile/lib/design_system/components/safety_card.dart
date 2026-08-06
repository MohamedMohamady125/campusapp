import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// Non-blocking informational card injected into chat threads (spec §10.6).
///
/// Guidance, not an alarm: informational surface, never error/warning
/// colours, dismissible once per thread and never returns.
class SafetyCard extends StatelessWidget {
  const SafetyCard({
    required this.onDismiss,
    super.key,
    this.title = 'Meeting up?',
    this.body =
        'Campus spots like the library lobby or student center are '
        'good places to trade. Meet during the day and bring a friend if '
        "you're carrying cash.",
  });

  final String title;
  final String body;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;

    // Flat white card with hairline border (Fifty Free §1) — guidance,
    // never an alarm surface.
    return Container(
      padding: EdgeInsets.all(tokens.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: tokens.brMd,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 20, color: colors.primary),
          SizedBox(width: tokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.titleSmall?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: tokens.space1),
                Text(
                  body,
                  style: context.text.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            tooltip: 'Dismiss',
            iconSize: 18,
            color: colors.onSurfaceVariant,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
