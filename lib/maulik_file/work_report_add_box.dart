import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../karan_file/new_myco_button.dart';
import '../themes_colors/colors.dart';
class WorkReportAdd extends StatelessWidget {
  final String title;
  final VoidCallback onNextTap;
  final String forTitle;
  final VoidCallback? onAddTap;
  final Color? boxColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool? isRequired;
  final bool? isAddButtonShow;

  const WorkReportAdd({
    required this.title,
    required this.onNextTap,
    required this.forTitle,
    super.key,
    this.onAddTap,
    this.boxColor,
    this.borderRadius,
    this.borderColor,
    this.isRequired,
    this.isAddButtonShow,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        // color: boxColor ?? AppColors.secondPrimary,
        border: Border.all(color: borderColor ?? AppColors.borderColor),
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        boxShadow: [
          BoxShadow(
            color:
                boxColor?.withAlpha(200) ??
                AppColors.secondPrimary.withAlpha(200),
          ),
          BoxShadow(
            color: boxColor ?? AppColors.secondPrimary,
            spreadRadius: -6.0,
            blurRadius: 8.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Date Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isRequired == true)
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                if (isRequired == true)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: MyCoButton(
                      onTap: () {},
                      title: 'Required',
                      width: 80,
                      height: 24,
                      boarderRadius: 50,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        color: AppColors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(borderRadius ?? 8),
                bottom: Radius.circular((borderRadius ?? 8) - 1.0),
              ),
              // borderRadius: BorderRadius.circular((borderRadius ?? 8) - 1.0),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, -4),
                  color: Colors.black12,
                  blurRadius: 4,
                ),
                BoxShadow(
                  offset: Offset(4, 0),
                  color: Colors.black12,
                  blurRadius: 4,
                ),
                BoxShadow(
                  offset: Offset(-4, 0),
                  color: Colors.black12,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'For : $forTitle',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isAddButtonShow == true)
                      GestureDetector(
                        onTap: onAddTap,
                        child: const Icon(
                          CupertinoIcons.add_circled,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onNextTap,
                      child: const Icon(
                        CupertinoIcons.chevron_right_circle,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
