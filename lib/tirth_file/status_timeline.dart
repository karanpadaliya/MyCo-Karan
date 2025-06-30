import 'package:flutter/material.dart';

class TimelineStep {
  final String label;
  final IconData icon;
  final Color color;
  final bool isActive;

  const TimelineStep({
    required this.label,
    required this.icon,
    required this.color,
    this.isActive = false,
  });
}

class StatusTimeline extends StatelessWidget {
  final List<TimelineStep> steps;
  final double circleSize;

  const StatusTimeline({
    super.key,
    required this.steps,
    required this.circleSize,
  });

  @override
  Widget build(BuildContext context) {
    // Find the last active step index
    final lastActiveIndex = steps.lastIndexWhere((step) => step.isActive);
    final activeColor =
        lastActiveIndex >= 0 ? steps[lastActiveIndex].color : Colors.grey;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circles + Lines
          Row(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                final stepIndex = (index - 1) ~/ 2;
                final isLineActive = stepIndex < lastActiveIndex;

                return Container(
                  width: circleSize,
                  height: circleSize,
                  alignment: Alignment.center,
                  child: Container(
                    height: 2,
                    color: isLineActive ? activeColor : Colors.grey.shade400,
                  ),
                );
              } else {
                final stepIndex = index ~/ 2;
                final isStepActive = stepIndex <= lastActiveIndex;
                final displayColor =
                    isStepActive ? activeColor : Color(0xff929292);

                return Column(
                  children: [
                    // Circle with icon
                    Container(
                      width: circleSize * 1.4,
                      height: circleSize * 1.4,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(color: Colors.black26),
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 5,
                            offset: Offset(3, 3),
                          ),
                        ],
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: displayColor.withOpacity(0.9),
                          border: Border.all(color: displayColor, width: 2),
                        ),
                        child: Icon(
                          steps[stepIndex].icon,
                          color: Colors.white,
                          size: circleSize * 0.5,
                        ),
                      ),
                    ),
                  ],
                );
              }
            }),
          ),

          const SizedBox(height: 6),

          // Text below each circle
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                return SizedBox(width: circleSize);
              } else {
                final stepIndex = index ~/ 2;
                final isLabelActive = stepIndex <= lastActiveIndex;
                final displayColor =
                    isLabelActive ? activeColor : Color(0xff929292);

                return SizedBox(
                  width: circleSize * 1.4,
                  child: Text(
                    steps[stepIndex].label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: displayColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
