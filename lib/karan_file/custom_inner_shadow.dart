import 'dart:ui';
import 'package:flutter/material.dart';

class InnerShadowContainer extends StatelessWidget {
  final double? height;
  final double? width;
  final double borderRadius;
  final Color backgroundColor;
  final bool isShadowTopLeft;
  final bool isShadowTopRight;
  final bool isShadowBottomRight;
  final bool isShadowBottomLeft;
  final Widget? child;
  final AlignmentGeometry alignment;

  const InnerShadowContainer({
    super.key,
    this.height,
    this.width,
    this.borderRadius = 12,
    this.backgroundColor = Colors.white,
    this.isShadowTopLeft = false,
    this.isShadowTopRight = false,
    this.isShadowBottomRight = false,
    this.isShadowBottomLeft = false,
    this.child,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          width: width,
          alignment: alignment,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
        if (isShadowTopLeft ||
            isShadowTopRight ||
            isShadowBottomRight ||
            isShadowBottomLeft)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: CustomPaint(
                painter: InnerShadowPainter(
                  shadowColor: const Color(0x1A2FBBA4),
                  blur: 1.4,
                  offset: const Offset(0, 1),
                  borderRadius: borderRadius,
                  isShadowTopLeft: isShadowTopLeft,
                  isShadowTopRight: isShadowTopRight,
                  isShadowBottomRight: isShadowBottomRight,
                  isShadowBottomLeft: isShadowBottomLeft,
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: CustomPaint(
              painter: InnerShadowPainter(
                shadowColor: Colors.black38,
                blur: 4,
                offset: const Offset(4, -3),
                borderRadius: borderRadius,
                isShadowTopLeft: isShadowTopLeft,
                isShadowTopRight: isShadowTopRight,
                isShadowBottomRight: isShadowBottomRight,
                isShadowBottomLeft: isShadowBottomLeft,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class InnerShadowPainter extends CustomPainter {
  final Color shadowColor;
  final double blur;
  final Offset offset;
  final double borderRadius;
  final bool isShadowTopLeft;
  final bool isShadowTopRight;
  final bool isShadowBottomRight;
  final bool isShadowBottomLeft;

  InnerShadowPainter({
    required this.shadowColor,
    required this.blur,
    required this.offset,
    required this.borderRadius,
    this.isShadowTopLeft = false,
    this.isShadowTopRight = false,
    this.isShadowBottomRight = false,
    this.isShadowBottomLeft = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = shadowColor
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    final Rect rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );
    final Path outer =
        Path()..addRect(
          Rect.fromLTRB(
            -size.width,
            -size.height,
            size.width * 2,
            size.height * 2,
          ),
        );
    final Path inner =
        Path()
          ..addRRect(rrect)
          ..fillType = PathFillType.evenOdd;

    canvas.saveLayer(rect, Paint());

    if (isShadowBottomRight) {
      canvas.save();
      canvas.translate(-offset.dx.abs(), -offset.dy.abs());
      canvas.drawPath(
        Path.combine(PathOperation.difference, outer, inner),
        paint,
      );
      canvas.restore();
    }
    if (isShadowBottomLeft) {
      canvas.save();
      canvas.translate(offset.dx.abs(), -offset.dy.abs());
      canvas.drawPath(
        Path.combine(PathOperation.difference, outer, inner),
        paint,
      );
      canvas.restore();
    }
    if (isShadowTopLeft) {
      canvas.save();
      canvas.translate(offset.dx.abs(), offset.dy.abs());
      canvas.drawPath(
        Path.combine(PathOperation.difference, outer, inner),
        paint,
      );
      canvas.restore();
    }
    if (isShadowTopRight) {
      canvas.save();
      canvas.translate(-offset.dx.abs(), offset.dy.abs());
      canvas.drawPath(
        Path.combine(PathOperation.difference, outer, inner),
        paint,
      );
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
