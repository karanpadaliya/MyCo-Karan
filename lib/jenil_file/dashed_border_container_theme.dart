import 'package:flutter/material.dart';

class DashedBorderContainerTheme {
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: Colors.deepPurple,
      textTheme: const TextTheme(
        bodySmall: TextStyle(fontSize: 15, color: Colors.black87),
      ),
      iconTheme: const IconThemeData(size: 28, color: Color(0xFF2F648E)),
    );
  }
}

class DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double? height;
  final double? width;

  const DashedBorderContainer({
    super.key,
    required this.child,
    this.borderColor,
    this.borderRadius = 6.0,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(12),
    this.onTap,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = borderColor ?? Theme.of(context).primaryColor;

    return CustomPaint(
      painter: _DashedBorderPainter(
        color: themeColor,
        borderRadius: borderRadius,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: height,
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;

  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(borderRadius),
        ),
      );

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// AttachmentGrid widget now accepts dynamic list of attachments and size
class AttachmentGrid extends StatelessWidget {
  final List<Map<String, dynamic>> attachmentItems;
  final double itemHeight;
  final double itemWidth;

  const AttachmentGrid({
    super.key,
    required this.attachmentItems,
    this.itemHeight = 50,
    this.itemWidth = 160,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: itemWidth / itemHeight,
        children: attachmentItems.map((item) {
          return SizedBox(
            height: itemHeight,
            width: itemWidth,
            child: DashedBorderContainer(
              height: itemHeight,
              width: itemWidth,
              onTap: () {},
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  Icon(
                    item['icon'] as IconData? ?? Icons.help_outline,
                    size: Theme.of(context).iconTheme.size,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      item['label']?.toString() ?? 'No Label',
                      style: Theme.of(context).textTheme.bodySmall,
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
