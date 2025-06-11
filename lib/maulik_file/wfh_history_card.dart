import 'package:flutter/material.dart';
import '../jenil_file/app_theme.dart';
import '../jenil_file/dashed_border_container_theme.dart';
import '../themes_colors/colors.dart';

class WFHHistoryCard extends StatelessWidget {
  final DateTime titleDate;
  final DateTime leaveDate;
  final String leaveType;
  final String reason;
  final String location;
  final DateTime createdOn;
  final DateTime? approvedOn;
  final String? approvedBy;
  final DateTime? rejectedOn;
  final String? rejectedBy;
  final String? rejectedReason;
  final Color? color;
  final Color? dividerColor;
  final Icon? suffixIcon;
  final double? borderRadius;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onAttachmentTap;

  const WFHHistoryCard({
    required this.leaveDate,
    required this.leaveType,
    required this.reason,
    required this.location,
    required this.createdOn,
    this.approvedOn,
    this.approvedBy,
    required this.titleDate,
    super.key,
    this.color,
    this.suffixIcon,
    this.borderRadius,
    this.dividerColor,
    this.onDeleteTap,
    this.onAttachmentTap,
    this.rejectedOn,
    this.rejectedBy,
    this.rejectedReason,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(borderRadius ?? 10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header bar
          Container(
            decoration: BoxDecoration(
              // color: color ?? AppColors.secondPrimary,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular((borderRadius ?? 10) - 2.0),
              ),
              boxShadow: [
                const BoxShadow(
                  offset: Offset(0, 3),
                  blurRadius: 5,
                  color: Colors.black26,
                ),
                BoxShadow(
                  color:
                      color?.withAlpha(220) ??
                      AppColors.secondPrimary.withAlpha(200),
                ),
                BoxShadow(
                  color: color ?? AppColors.secondPrimary,
                  spreadRadius: -8.0,
                  blurRadius: 8.0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_formatDate(titleDate)} ($leaveType)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          AppTheme.lightTheme.textTheme.bodyMedium!.fontSize,
                      fontFamily: 'Gilroy-Bold',
                    ),
                  ),
                ),
                suffixIcon ??
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
              ],
            ),
          ),

          // Body content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Reason', reason),
                const SizedBox(height: 8),
                _infoRow('Location', location),
                Divider(
                  height: 20,
                  color: dividerColor ?? color ?? AppColors.borderColor,
                ),

                // Dates and approval
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _dateLabel('Created On', date: createdOn),
                        ),
                        const SizedBox(width: 10),
                        if (onAttachmentTap != null)
                          DashedBorderContainer(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            backgroundColor: AppColors.primary.withAlpha(22),
                            borderRadius: 12,
                            borderColor: AppColors.primary,
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/bookmark-2.png',
                                  height: 22,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'View Attachment',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontFamily: 'Gilroy',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (onAttachmentTap == null)
                          GestureDetector(
                            onTap: onDeleteTap,
                            child: Image.asset('assets/trash.png', height: 22),
                          ),
                      ],
                    ),
                    if (rejectedOn != null || rejectedBy != null)
                      const SizedBox(height: 10),
                    if (rejectedOn != null || rejectedBy != null)
                      Row(
                        children: [
                          if (rejectedOn != null)
                            Expanded(
                              child: _dateLabel(
                                'Rejected On',
                                date: rejectedOn,
                              ),
                            ),
                          const SizedBox(width: 10),
                          if (rejectedBy != null)
                            Expanded(
                              child: _dateLabel(
                                'Rejected By',
                                data: rejectedBy,
                              ),
                            ),
                          GestureDetector(
                            onTap: onDeleteTap,
                            child: Image.asset('assets/trash.png', height: 22),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    if (rejectedReason != null)
                      _infoRow('Reject Reason', rejectedReason!),
                    if (rejectedReason == null ||
                        rejectedOn == null ||
                        rejectedBy == null)
                      Row(
                        children: [
                          if (approvedOn != null)
                            Expanded(
                              child: _dateLabel(
                                'Approved On',
                                date: approvedOn,
                              ),
                            ),
                          const SizedBox(width: 10),
                          if (approvedBy != null)
                            Expanded(
                              child: _dateLabel(
                                'Approved By',
                                cross: CrossAxisAlignment.end,
                                data: approvedBy,
                              ),
                            ),
                        ],
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

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label :', style: const TextStyle(fontFamily: 'Gilroy-Bold')),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Gilroy',
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateLabel(
    String label, {
    CrossAxisAlignment? cross,
    DateTime? date,
    String? data,
  }) {
    return Column(
      crossAxisAlignment: cross ?? CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            fontFamily: 'Gilroy-Bold',
            fontSize: 12,
          ),
        ),
        Text(
          data ?? _formatDateTime(date ?? DateTime.now()),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            fontFamily: 'Gilroy',
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    return '${_weekdayName(date.weekday)}, ${_twoDigits(date.day)} ${_monthName(date.month)} ${date.year}';
  }

  static String _formatDateTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${_twoDigits(dt.day)} ${_monthName(dt.month)} ${dt.year}, '
        '${_twoDigits(hour)}:${_twoDigits(dt.minute)} $period';
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  static String _weekdayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }
}
