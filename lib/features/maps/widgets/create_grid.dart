import 'package:flutter/material.dart';

class CreateMapGrid extends CustomPainter {
  final Color lineColor;
  const CreateMapGrid({required this.lineColor});

  // draws a grid on the canvas
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.6)
      ..strokeWidth = 1;

    // draw vertical and horizontal lines every 28 pixels
    const step = 28.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CreateMapGrid oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}
