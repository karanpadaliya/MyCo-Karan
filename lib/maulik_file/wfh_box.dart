import 'package:flutter/material.dart';
import '../themes_colors/colors.dart';

class LeaveDetailsCard extends StatelessWidget {
  final DateTime titleDate;
  final DateTime leaveDate;
  final String leaveType;
  final String reason;
  final String location;
  final DateTime createdOn;
  final DateTime approvedOn;
  final String approvedBy;
  final Color? color;
  final Color? dividerColor;
  final Icon? suffixIcon;
  final double? borderRadius;

  const LeaveDetailsCard({
    required this.leaveDate,
    required this.leaveType,
    required this.reason,
    required this.location,
    required this.createdOn,
    required this.approvedOn,
    required this.approvedBy,
    required this.titleDate,
    super.key,
    this.color,
    this.suffixIcon,
    this.borderRadius,
    this.dividerColor,
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
              color: color ?? AppColors.secondPrimary,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular((borderRadius ?? 10) - 2.0),
              ),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 3),
                  blurRadius: 5,
                  color: Colors.black26,
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_formatDate(titleDate)} ($leaveType)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w600,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _dateLabel('Created On', date: createdOn),
                          const SizedBox(height: 10),
                          _dateLabel('Approved On', date: approvedOn),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _dateLabel(
                        'Approved By',
                        cross: CrossAxisAlignment.end,
                        approver: approvedBy,
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

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label :',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Gilroy',
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
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
    String? approver,
  }) {
    return Column(
      crossAxisAlignment: cross ?? CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            fontFamily: 'Gilroy',
          ),
        ),
        Text(
          approver ?? _formatDateTime(date!),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
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
