
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../themes_colors/colors.dart';

class CurrentOpeningCard extends StatelessWidget {
  final String title;
  final String position;
  final String status;
  final int number;
  final String mail;
  final DateTime submittedDate;
  final Color? boxColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool? isCancelShow;
  final VoidCallback? onCancelTap;

  const CurrentOpeningCard({
    required this.title,
    required this.position,
    required this.status,
    required this.number,
    required this.mail,
    required this.submittedDate,
    super.key,
    this.boxColor,
    this.borderRadius,
    this.borderColor,
    this.isCancelShow,
    this.onCancelTap,
  });
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        // color: boxColor ?? AppColors.secondPrimary,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        border: Border.all(color: borderColor ?? AppColors.borderColor),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  position,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Content
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              // borderRadius: BorderRadius.circular((borderRadius ?? 8) - 1.0),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(borderRadius ?? 8),
                bottom: Radius.circular((borderRadius ?? 8) - 1.0),
              ),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, -4),
                  color: Colors.black12,
                  blurRadius: 4,
                  // spreadRadius: 2,
                ),
                BoxShadow(
                  offset: Offset(4, 0),
                  color: Colors.black12,
                  blurRadius: 4,
                  // spreadRadius: 2,
                ),
                BoxShadow(
                  offset: Offset(-4, 0),
                  color: Colors.black12,
                  blurRadius: 4,
                  // spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      rowData(
                        image: 'assets/call-calling.png',
                        text: '$number',
                        statusData: status,
                      ),
                      const SizedBox(height: 6),
                      rowData(image: 'assets/message.png', text: mail),
                    ],
                  ),
                ),
                const Divider(color: AppColors.borderColor),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${timeFormat.format(submittedDate)},  ${dateFormat.format(submittedDate)}',
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                      ),
                      if (isCancelShow == true)
                        GestureDetector(
                          onTap: onCancelTap,
                          child: const Text(
                            'CANCEL REFERRAL',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                              height: 2,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.error,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Gilroy',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget rowData({
    required String image,
    required String text,
    String? statusData,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Image.asset(image, height: 22),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Gilroy-SemiBold',
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        if (statusData != null) const SizedBox(width: 10),
        if (statusData != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.GPSMediumColor),
            ),
            child: Center(
              child: Text(
                statusData,
                style: const TextStyle(
                  color: AppColors.GPSMediumColor,
                  fontSize: 12,
                  fontFamily: 'Gilroy-SemiBold',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
