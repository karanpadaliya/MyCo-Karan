import 'package:flutter/material.dart';

enum StepStatus { pending, approved, completed, denied, authorized }

class StepData {
  final String title;
  final StepStatus status;
  final String? date;
  final String? remark;
  final Color? statusColor;

  StepData({
    required this.title,
    required this.status,
    this.date,
    this.remark,
    this.statusColor,
  });
}

class CustomStepper extends StatelessWidget {
  final List<StepData> steps;
  final bool isHorizontal;

  const CustomStepper({
    super.key,
    required this.steps,
    this.isHorizontal = false,
  });

  Widget _buildCircle(StepStatus status, {Color? customColor}) {
    Color color;
    IconData icon;
    switch (status) {
      case StepStatus.pending:
        color = Color(0xffFDB913);
        icon = Icons.check;
        break;
      case StepStatus.approved:
        color = Colors.green;
        icon = Icons.check;
        break;
      case StepStatus.completed:
        color = Color(0xff2FBBA4);
        icon = Icons.check;
        break;
      case StepStatus.authorized:
        color = Colors.grey;
        icon = Icons.circle;
        break;
      case StepStatus.denied:
        color = Colors.red;
        icon = Icons.close;
        break;
      default:
        color = Colors.red;
        icon = Icons.circle;
    }

    color = customColor ?? color;

    return CircleAvatar(
      radius: 14,
      backgroundColor: color,
      child: Icon(icon, size: 16, color: Colors.white),
    );
  }

  Widget _buildLine(bool isActive) {
    return Container(
      height: isHorizontal ? 2 : 40,
      width: isHorizontal ? 40 : 2,
      color: isActive ? Colors.green : Colors.grey.shade300,
    );
  }

  Widget _buildStep(BuildContext context, StepData step, int index) {
    final isLast = index == steps.length - 1;

    final stepWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _buildCircle(step.status),
            if (!isLast && !isHorizontal) _buildLine(true),
          ],
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Gilroy-SemiBold',
                color:
                    step.status == StepStatus.authorized
                        ? Colors.grey
                        : Colors.black,
              ),
            ),
            if (step.date != null || step.remark != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 10),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xffFAFAFF),
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      // BoxShadow(color: Colors.grey),
                      // BoxShadow(color: Colors.white),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (step.date != null)
                        Row(
                          children: [
                            Text(
                              "Date \t:",
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Gilroy-SemiBold',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              step.date!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Gilroy-Medium',
                                // fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      if (step.remark != null)
                        Row(
                          children: [
                            Text(
                              "Remark \t:",
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Gilroy-SemiBold',
                              ),
                            ),
                            Text(
                              step.remark!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Gilroy-Medium',
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );

    if (isHorizontal) {
      return Row(
        children: [_buildCircle(step.status), if (!isLast) _buildLine(true)],
      );
    }

    return stepWidget;
  }

  @override
  Widget build(BuildContext context) {
    return isHorizontal
        ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            steps.length,
            (index) => _buildStep(context, steps[index], index),
          ),
        )
        : Column(
          children: List.generate(
            steps.length,
            (index) => _buildStep(context, steps[index], index),
          ),
        );
  }
}
