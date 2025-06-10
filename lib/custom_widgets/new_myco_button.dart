import 'package:flutter/material.dart';
import 'package:myco_karan/custom_widgets/responsive.dart';
import 'new_myco_button_theme.dart';

class MyCoButton extends StatelessWidget {
  final void Function()? onTap;
  final String title;
  final BoxDecoration? decoration;
  final double? height;
  final double? width;
  final TextStyle? textStyle;
  final Color? colorBackground;
  final FontWeight? fontWeight;
  final Widget? image;
  final AxisDirection imagePosition;
  final bool enabled;
  final double? spacing;
  final Border? border;
  final Color? borderColor;
  final double? boarderRadius;
  final String? fontFamily;
  final bool isShadow;

  const MyCoButton({
    super.key,
    required this.onTap,
    required this.title,
    this.decoration,
    this.height,
    this.width,
    this.textStyle,
    this.colorBackground,
    this.fontWeight,
    this.image,
    this.imagePosition = AxisDirection.left,
    this.enabled = true,
    this.spacing,
    this.border,
    this.borderColor,
    this.boarderRadius,
    this.fontFamily,
    this.isShadow = true, // default is shadow enabled
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return screenHeight < 1100
        ? _MyCoButtonMobile(
      onTap: enabled ? onTap : null,
      title: title,
      height: height ?? 0.06 * getHeight(context),
      width: width,
      colorBackground: colorBackground,
      decoration: decoration,
      textStyle: textStyle,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      image: image,
      imagePosition: imagePosition,
      enabled: enabled,
      spacing: spacing,
      border: border,
      borderColor: borderColor,
      boarderRadius: boarderRadius,
      isShadow: isShadow,
    )
        : _MyCoButtonMobile(
      onTap: enabled ? onTap : null,
      title: title,
      height: height ?? 0.065 * getHeight(context),
      width: width,
      colorBackground: colorBackground,
      decoration: decoration,
      textStyle: textStyle,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      image: image,
      imagePosition: imagePosition,
      enabled: enabled,
      spacing: spacing,
      border: border,
      borderColor: borderColor,
      boarderRadius: boarderRadius,
      isShadow: isShadow,
    );
  }
}

class _MyCoButtonMobile extends StatelessWidget {
  final void Function()? onTap;
  final String title;
  final double? height;
  final double? width;
  final FontWeight? fontWeight;
  final Color? colorBackground;
  final BoxDecoration? decoration;
  final TextStyle? textStyle;
  final Widget? image;
  final AxisDirection imagePosition;
  final bool enabled;
  final double? spacing;
  final Border? border;
  final Color? borderColor;
  final double? boarderRadius;
  final String? fontFamily;
  final bool isShadow;

  const _MyCoButtonMobile({
    required this.onTap,
    required this.title,
    this.height,
    this.width,
    this.fontWeight,
    this.colorBackground,
    this.decoration,
    this.textStyle,
    this.image,
    required this.imagePosition,
    required this.enabled,
    this.spacing,
    this.border,
    this.borderColor,
    this.boarderRadius,
    this.fontFamily,
    required this.isShadow,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = enabled
        ? (colorBackground ?? MyCoButtonTheme.mobileBackgroundColor)
        : Colors.grey.shade400;

    final TextStyle finalStyle = (textStyle ?? MyCoButtonTheme.getMobileTextStyle(context))
        .copyWith(fontFamily: fontFamily);

    final double radius = boarderRadius ?? MyCoButtonTheme.borderRadius;

    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            height: height ?? 0.04 * getHeight(context),
            width: width ?? 0.94 * getWidth(context),
            decoration: decoration ??
                BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(radius),
                  border: border ?? MyCoButtonTheme.defaultBorder,
                ),
            child: Center(
              child: _ButtonContent(
                title: title,
                style: finalStyle,
                image: image,
                imagePosition: imagePosition,
                spacing: spacing,
              ),
            ),
          ),
          if (isShadow)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: CustomPaint(
                  painter: InnerShadowPainter(
                    shadowColor: const Color(0x1A2FBBA4),
                    blur: 1.4,
                    offset: const Offset(0, 1),
                    borderRadius: radius,
                  ),
                ),
              ),
            ),
          if (isShadow)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: CustomPaint(
                  painter: InnerShadowPainter(
                    shadowColor: const Color(0x40000000),
                    blur: 4,
                    offset: const Offset(4, -3),
                    borderRadius: radius,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String title;
  final TextStyle style;
  final Widget? image;
  final AxisDirection imagePosition;
  final double? spacing;

  const _ButtonContent({
    required this.title,
    required this.style,
    this.image,
    required this.imagePosition,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = image ?? const SizedBox();
    final double gap = spacing ?? 1;

    List<Widget> children;

    if (imagePosition == AxisDirection.left) {
      children = [
        imageWidget,
        SizedBox(width: gap),
        Text(title, style: style, textAlign: TextAlign.center),
      ];
    } else if (imagePosition == AxisDirection.right) {
      children = [
        Text(title, style: style, textAlign: TextAlign.center),
        SizedBox(width: gap),
        imageWidget,
      ];
    } else if (imagePosition == AxisDirection.up) {
      children = [
        imageWidget,
        SizedBox(height: gap),
        Text(title, style: style, textAlign: TextAlign.center),
      ];
    } else {
      children = [
        Text(title, style: style, textAlign: TextAlign.center),
        SizedBox(height: gap),
        imageWidget,
      ];
    }

    return (imagePosition == AxisDirection.left || imagePosition == AxisDirection.right)
        ? Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    )
        : Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

class InnerShadowPainter extends CustomPainter {
  final Color shadowColor;
  final double blur;
  final Offset offset;
  final double borderRadius;

  InnerShadowPainter({
    required this.shadowColor,
    required this.blur,
    required this.offset,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    final RRect innerRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );
    final Path outer = Path()
      ..addRect(Rect.fromLTRB(
        -size.width,
        -size.height,
        size.width * 2,
        size.height * 2,
      ));
    final Path inner = Path()
      ..addRRect(innerRect)
      ..fillType = PathFillType.evenOdd;

    canvas.saveLayer(rect, Paint());
    canvas.translate(offset.dx, offset.dy);
    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, inner),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
