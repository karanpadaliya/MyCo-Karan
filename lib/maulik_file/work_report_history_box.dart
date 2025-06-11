import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../themes_colors/colors.dart';

class WorkReportHistory extends StatelessWidget {
  final DateTime reportDate;
  final String title;
  final DateTime submittedOn;
  final VoidCallback onDownloadTap;
  final VoidCallback onNextTap;
  final Color? boxColor;
  final Color? borderColor;
  final double? borderRadius;

  const WorkReportHistory({
    required this.reportDate,
    required this.title,
    required this.submittedOn,
    required this.onDownloadTap,
    required this.onNextTap,
    super.key,
    this.boxColor,
    this.borderRadius,
    this.borderColor,
  });
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        // color: boxColor ?? AppColors.primary,
        border: Border.all(color: borderColor ?? AppColors.borderColor),
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        boxShadow: [
          BoxShadow(
            color: boxColor?.withAlpha(200) ?? AppColors.primary.withAlpha(200),
          ),
          BoxShadow(
            color: boxColor ?? AppColors.primary,
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
                const Icon(Icons.calendar_month, color: Colors.white),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Text(
                    dateFormat.format(reportDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w700,
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
              // BorderRadius.circular((borderRadius ?? 8) - 1.0),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, -4),
                  color: Colors.black26,
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
                // Title and Download
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onDownloadTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 3,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(50),
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.download_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Download',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Submission info and arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Submitted On :  ${dateFormat.format(submittedOn)} , ${timeFormat.format(submittedOn)}',
                        style: const TextStyle(
                          color: AppColors.borderColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
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
