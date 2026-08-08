import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';

/// Four L-shaped corner brackets used in Face ID framing.
class FaceScanBrackets extends StatelessWidget {
  const FaceScanBrackets({
    super.key,
    this.color = AppColors.black,
    this.size = 220,
    this.strokeWidth = 3,
    this.cornerLength = 36,
    this.showGuideLine = false,
    this.guideColor,
  });

  final Color color;
  final double size;
  final double strokeWidth;
  final double cornerLength;
  final bool showGuideLine;
  final Color? guideColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BracketsPainter(
          color: color,
          strokeWidth: strokeWidth,
          cornerLength: cornerLength,
          showGuideLine: showGuideLine,
          guideColor: guideColor ?? color,
        ),
      ),
    );
  }
}

class _BracketsPainter extends CustomPainter {
  _BracketsPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
    required this.showGuideLine,
    required this.guideColor,
  });

  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final bool showGuideLine;
  final Color guideColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void corner(Offset origin, double dx, double dy) {
      final path = Path()
        ..moveTo(origin.dx + dx * cornerLength, origin.dy)
        ..lineTo(origin.dx, origin.dy)
        ..lineTo(origin.dx, origin.dy + dy * cornerLength);
      canvas.drawPath(path, paint);
    }

    corner(const Offset(0, 0), 1, 1);
    corner(Offset(size.width, 0), -1, 1);
    corner(Offset(0, size.height), 1, -1);
    corner(Offset(size.width, size.height), -1, -1);

    if (showGuideLine) {
      final midY = size.height * 0.42;
      canvas.drawLine(
        Offset(size.width * 0.22, midY),
        Offset(size.width * 0.78, midY),
        Paint()
          ..color = guideColor
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BracketsPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.showGuideLine != showGuideLine ||
      oldDelegate.guideColor != guideColor;
}
