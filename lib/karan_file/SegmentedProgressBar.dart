import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ColorRange {
  final double startMinutes;
  final double endMinutes;
  final Color color;

  ColorRange(this.startMinutes, this.endMinutes, this.color);
}

class SegmentedProgressBar extends StatefulWidget {
  final double? maxMinutes;
  final double minutesPerSegment;
  final double strokeWidth;
  final double sectionGap;
  final Color backgroundColor;
  final Color primaryColor;
  final List<ColorRange> colorRanges;

  const SegmentedProgressBar({
    Key? key,
    this.maxMinutes,
    this.minutesPerSegment = 60,
    this.strokeWidth = 20,
    this.sectionGap = 2,
    this.backgroundColor = Colors.grey,
    this.primaryColor = Colors.teal,
    this.colorRanges = const [],
  }) : super(key: key);

  @override
  State<SegmentedProgressBar> createState() => _SegmentedProgressBarState();
}

class _SegmentedProgressBarState extends State<SegmentedProgressBar> {
  late Timer _timer;
  late double currentMinutes;

  double get maxMinutes => widget.maxMinutes ?? 60;

  @override
  void initState() {
    super.initState();
    currentMinutes = _getCurrentMinutes();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        currentMinutes = _getCurrentMinutes();
      });
    });
  }

  double _getCurrentMinutes() {
    final now = DateTime.now();
    return (now.minute % maxMinutes) + now.second / 60;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeText =
        "${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    final clampedMinutes = currentMinutes.clamp(0, maxMinutes).toDouble();

    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(250),
            painter: _SegmentedProgressBarPainter(
              maxMinutes: maxMinutes,
              currentMinutes: clampedMinutes,
              minutesPerSegment: widget.minutesPerSegment,
              strokeWidth: widget.strokeWidth,
              sectionGap: widget.sectionGap,
              backgroundColor: widget.backgroundColor,
              primaryColor: widget.primaryColor,
              colorRanges: widget.colorRanges,
            ),
          ),
          Text(
            timeText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          )
        ],
      ),
    );
  }
}

class _SegmentedProgressBarPainter extends CustomPainter {
  final double maxMinutes;
  final double currentMinutes;
  final double minutesPerSegment;
  final double strokeWidth;
  final double sectionGap;
  final Color backgroundColor;
  final Color primaryColor;
  final List<ColorRange> colorRanges;

  _SegmentedProgressBarPainter({
    required this.maxMinutes,
    required this.currentMinutes,
    required this.minutesPerSegment,
    required this.strokeWidth,
    required this.sectionGap,
    required this.backgroundColor,
    required this.primaryColor,
    required this.colorRanges,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (min(size.width, size.height) / 2) - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final totalSegments = (maxMinutes / minutesPerSegment).ceil();
    final totalGapAngle = totalSegments * sectionGap;
    final totalAvailableAngle = 360.0 - totalGapAngle;
    final anglePerMinute = totalAvailableAngle / maxMinutes;

    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = backgroundColor;

    final colorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double globalStartAngle = -90;

    for (int i = 0; i < totalSegments; i++) {
      final segmentStartMinutes = i * minutesPerSegment;
      final segmentDuration =
      min(minutesPerSegment, maxMinutes - segmentStartMinutes);
      final segmentAngle = segmentDuration * anglePerMinute;

      // Draw background segment
      canvas.drawArc(
        rect,
        _degToRad(globalStartAngle),
        _degToRad(segmentAngle),
        false,
        backgroundPaint,
      );

      // Draw colored progress for segment
      double localStartAngle = globalStartAngle;

      for (double m = segmentStartMinutes;
      m < segmentStartMinutes + segmentDuration;
      m++) {
        if (m >= currentMinutes) break;

        final minuteAngle = anglePerMinute;
        final color = _findColorForMinute(m) ?? primaryColor;

        colorPaint.color = color;

        canvas.drawArc(
          rect,
          _degToRad(localStartAngle),
          _degToRad(minuteAngle),
          false,
          colorPaint,
        );

        localStartAngle += minuteAngle;
      }

      globalStartAngle += segmentAngle + sectionGap;
    }
  }

  Color? _findColorForMinute(double minute) {
    for (var range in colorRanges) {
      if (minute >= range.startMinutes && minute < range.endMinutes) {
        return range.color;
      }
    }
    return null;
  }

  double _degToRad(double degrees) => degrees * pi / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
