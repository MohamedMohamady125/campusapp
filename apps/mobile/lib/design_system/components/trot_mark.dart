import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_colors.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';

/// The Trot brand mark — the lowercase "t" stroke with the coral Drop-off
/// dot (docs/brand/logo/trot-mark.svg, logo 1c). Drawn in code so it stays
/// crisp at any size and can follow the surface ink in dark mode.
class TrotMark extends StatelessWidget {
  const TrotMark({this.size = 48, this.ink, super.key});

  final double size;

  /// Stroke color for the "t". Defaults to charcoal ink in light mode and
  /// the surface ink in dark so the mark never disappears.
  final Color? ink;

  @override
  Widget build(BuildContext context) {
    final stroke =
        ink ??
        (Theme.of(context).brightness == Brightness.dark
            ? context.colors.onSurface
            : AppColors.ink);
    return CustomPaint(
      size: Size(size * (104 / 112), size),
      painter: _TrotMarkPainter(stroke: stroke),
    );
  }
}

class _TrotMarkPainter extends CustomPainter {
  const _TrotMarkPainter({required this.stroke});

  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    // SVG viewBox is `4 1 104 112` — normalize to the widget box.
    final s = size.height / 112;
    canvas
      ..scale(s)
      ..translate(-4, -1);

    final paint = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // The "t": vertical stem curving into a tail, plus the crossbar.
    final path = Path()
      ..moveTo(36, 20)
      ..lineTo(36, 76)
      ..arcToPoint(
        const Offset(54, 94),
        radius: const Radius.circular(18),
        // SVG sweep-flag 0 → counterclockwise.
        clockwise: false,
      )
      ..lineTo(62, 94)
      ..moveTo(22, 48)
      ..lineTo(62, 48);
    canvas
      ..drawPath(path, paint)
      // The Drop-off dot — always coral, the one accent.
      ..drawCircle(const Offset(84, 94), 9, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(_TrotMarkPainter oldDelegate) =>
      oldDelegate.stroke != stroke;
}
