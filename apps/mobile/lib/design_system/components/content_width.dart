import 'package:campusconnect/design_system/material.dart';

/// Constrains scroll bodies on wide windows (whole.md §4.7).
///
/// Market, Tutors, Groups, Profile → 1120. Chat threads → 720.
class ContentWidth extends StatelessWidget {
  const ContentWidth({required this.child, super.key, this.max = 1120});

  final Widget child;
  final double max;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: max),
      child: child,
    ),
  );
}
