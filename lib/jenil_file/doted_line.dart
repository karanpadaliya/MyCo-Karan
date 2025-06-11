import 'package:flutter/material.dart';

class DotedLine extends CustomPainter {
  final int dotCount;
  final double dotWidth;
  final double dotHeight;
  final double spacing;
  final Color color;
  final bool vertical;

  DotedLine({
    required this.dotCount,
    required this.dotWidth,
    required this.dotHeight,
    required this.spacing,
    required this.color,
    required this.vertical,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    double pos = 0;

    for (int i = 0; i < dotCount; i++) {
      final dx = vertical ? (size.width - dotWidth) / 2 : pos;
      final dy = vertical ? pos : (size.height - dotHeight) / 2;
      final rect = Rect.fromLTWH(dx, dy, dotWidth, dotHeight);
      canvas.drawOval(rect, paint);
      pos += (vertical ? dotHeight : dotWidth) + spacing;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
