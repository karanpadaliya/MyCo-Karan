import 'package:flutter/material.dart';
import 'package:myco_karan/themes_colors/colors.dart';

enum StepStatus { pending, approved, completed, denied, authorized }

class StepData {
  final String title;
  final StepStatus status;
  final List<Map<String, String>>? details;
  final Color? statusColor;
  final Color? titleColor;

  StepData({
    required this.title,
    required this.status,
    this.details,
    this.statusColor,
    this.titleColor,
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
      case StepStatus.approved:
      case StepStatus.completed:
        color = Colors.green;
        icon = Icons.check;
        break;
      case StepStatus.denied:
        color = Colors.red;
        icon = Icons.close;
        break;
      case StepStatus.authorized:
        color = Colors.grey;
        icon = Icons.lock_outline;
        break;
      default:
        color = Colors.orange;
        icon = Icons.hourglass_top;
    }

    color = customColor ?? color;

    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
            boxShadow: const [
              BoxShadow(color: Colors.black26),
              BoxShadow(
                color: Colors.white,
                blurRadius: 5,
                offset: Offset(3, 3),
              ),
            ],
          ),
        ),
        Positioned(
          top: 6,
          left: 6,
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Center(
              child: Icon(icon, color: AppColors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool isActive) {
    return Container(
      width: isHorizontal ? 60 : 3,
      height: 30,
      color: isActive ? Colors.green : const Color(0xffA9A3A3),
    );
  }

  Widget _buildStep(BuildContext context, StepData step, int index) {
    final isLast = index == steps.length - 1;

    if (isHorizontal) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCircle(step.status, customColor: step.statusColor),
          if (!isLast) _buildLine(true),
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildCircle(step.status, customColor: step.statusColor),
              if (!isLast && !isHorizontal)
                Expanded(child: _buildLine(true)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Gilroy-SemiBold',
                      color: step.titleColor ??
                          (step.status == StepStatus.authorized
                              ? Colors.grey
                              : Colors.black),
                    ),
                  ),
                  if (step.details != null && step.details!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xffFAFAFF),
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: step.details!.map((item) {
                          final title = item['title'] ?? '';
                          final description = item['description'] ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Gilroy-SemiBold',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Text(
                                  ' : ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Gilroy-Medium',
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Gilroy-Medium',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isHorizontal
        ? SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          steps.length,
              (index) => _buildStep(context, steps[index], index),
        ),
      ),
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        steps.length,
            (index) => _buildStep(context, steps[index], index),
      ),
    );
  }
}