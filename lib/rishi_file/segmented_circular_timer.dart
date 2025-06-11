import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SegmentedCircularTimer extends StatefulWidget {
  const SegmentedCircularTimer({super.key});

  @override
  State<SegmentedCircularTimer> createState() => _SegmentedCircularTimerState();
}

class _SegmentedCircularTimerState extends State<SegmentedCircularTimer> {
  late Timer _timer;
  late DateTime _startTime;
  final int totalSegments = 8;
  final double segmentDuration = 15; // seconds
  double progress = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final elapsed = DateTime.now().difference(_startTime).inSeconds;
      setState(() {
        progress = elapsed.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  List<PieChartSectionData> getAnimatedSections() {
    final List<Color> activeColors = [
      const Color(0xFF3B7C89),
      const Color(0xFF2F648E),
      const Color(0xFF2FBBA4),
      const Color(0xFF2F648E),
      const Color(0xFF2FB3A2),
      const Color(0xFF48C1AC),
      const Color(0xFFFCB015),
      const Color(0xFF48C1AC),
    ];

    final List<PieChartSectionData> sections = [];

    int currentIndex = (progress ~/ segmentDuration).clamp(0, totalSegments - 1);
    double percentInCurrent = (progress % segmentDuration) / segmentDuration;

    for (int i = 0; i < totalSegments; i++) {
      if (i < currentIndex) {
        sections.add(PieChartSectionData(
          value: 1,
          color: activeColors[i],
          radius: 30,
          showTitle: false,
        ));
      } else if (i == currentIndex) {
        sections.add(PieChartSectionData(
          value: percentInCurrent,
          color: activeColors[i],
          radius: 30,
          showTitle: false,
        ));
        sections.add(PieChartSectionData(
          value: 1 - percentInCurrent,
          color: Colors.grey.shade300,
          radius: 30,
          showTitle: false,
        ));
      } else {
        sections.add(PieChartSectionData(
          value: 1,
          color: Colors.grey.shade300,
          radius: 30,
          showTitle: false,
        ));
      }
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final currentTime = DateTime.now();
    final formattedTime =
        "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}:${currentTime.second.toString().padLeft(2, '0')}";

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shadow behind the ring
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.teal[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.8),
                  blurRadius: 30,
                  spreadRadius: -8,
                  offset: Offset(0, 0), // Add offset as a required named argument
                ),
              ],
            ),
          ),
          // Chart Ring
          SizedBox(
            width: 220,
            height: 220,
            child: PieChart(
              PieChartData(
                sections: getAnimatedSections(),
                startDegreeOffset: -90,
                centerSpaceRadius: 80,
                sectionsSpace: 3,
              ),
            ),
          ),
          // Center time
          Container(
            padding: const EdgeInsets.all(54),
            decoration:  BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.6),
                  blurRadius: 30,
                  spreadRadius: -10,
                  offset: Offset(0, 0), // Add offset as a required named argument
                ),
              ],

            ),
            child: Text(
              formattedTime,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
