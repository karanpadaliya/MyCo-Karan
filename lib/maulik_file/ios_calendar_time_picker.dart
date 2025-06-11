import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../karan_file/new_myco_button.dart';
import '../karan_file/new_myco_button_theme.dart';
import '../themes_colors/colors.dart';

class DialDatePickerWidget extends StatefulWidget {
  final DateTime initialDate;
  final void Function(DateTime selectedDate) onSubmit;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool pickDay;
  final bool timePicker; // NEW
  final Widget? image;
  final double? bottomSheetHeight;
  final double? height;
  final double? width;
  final bool? use24hFormat;

  const DialDatePickerWidget({
    required this.initialDate,
    required this.onSubmit,
    super.key,
    this.minDate,
    this.maxDate,
    this.pickDay = true,
    this.timePicker = false, // NEW
    this.image,
    this.height,
    this.width,
    this.bottomSheetHeight,
    this.use24hFormat,
  });

  @override
  State<DialDatePickerWidget> createState() => _DialDatePickerWidgetState();
}

class _DialDatePickerWidgetState extends State<DialDatePickerWidget> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;

    if (widget.minDate != null && _selectedDate.isBefore(widget.minDate!)) {
      _selectedDate = widget.minDate!;
    }
    if (widget.maxDate != null && _selectedDate.isAfter(widget.maxDate!)) {
      _selectedDate = widget.maxDate!;
    }
  }

  void _showPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => Container(
            height:
                widget.bottomSheetHeight ??
                MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: Column(
              children: [
                Expanded(
                  child:
                      widget.timePicker
                          ? CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            initialDateTime: _selectedDate,
                            use24hFormat: widget.use24hFormat ?? false,
                            onDateTimeChanged: (DateTime newTime) {
                              setState(() {
                                _selectedDate = DateTime(
                                  _selectedDate.year,
                                  _selectedDate.month,
                                  _selectedDate.day,
                                  newTime.hour,
                                  newTime.minute,
                                );
                              });
                            },
                          )
                          : CustomDatePicker(
                            initialDate: _selectedDate,
                            minDate: widget.minDate ?? DateTime(1900, 1, 1),
                            maxDate: widget.maxDate ?? DateTime(2100, 12, 31),
                            pickDay: widget.pickDay,
                            onDateChanged: (date) {
                              setState(() {
                                _selectedDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  _selectedDate.hour,
                                  _selectedDate.minute,
                                );
                              });
                            },
                          ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    borderRadius: BorderRadius.circular(50),
                    color: AppColors.primary,
                    child: Center(
                      child: Text(
                        'Submit',
                        style: MyCoButtonTheme.getMobileTextStyle(context),
                      ),
                    ),
                    onPressed: () {
                      widget.onSubmit(_selectedDate);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  String _formatDate(DateTime date) {
    if (widget.timePicker) {
      return DateFormat('hh:mm a').format(date);
    } else if (widget.pickDay) {
      return '${_monthName(date.month)} ${date.day}, ${date.year}';
    } else {
      return '${_monthName(date.month)} ${date.year}';
    }
  }

  String _monthName(int month) {
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
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) => MyCoButton(
    onTap: () => _showPicker(context),
    title: _formatDate(_selectedDate),
    textStyle: const TextStyle(
      color: AppColors.black,
      fontWeight: FontWeight.w500,
    ),
    image: widget.image,
    width: widget.width,
    height: widget.height,
    backgroundColor: AppColors.white,
    border: Border.all(color: AppColors.borderColor, width: 1.2),
  );
}

// import 'package:flutter/cupertino.dart';
// import 'package:intl/intl.dart';
// import 'package:testing_myco/config/colors.dart';
// import 'package:testing_myco/config/new_myco_button.dart';
// import 'package:testing_myco/config/new_myco_button_theme.dart';

// class DialDatePickerWidget extends StatefulWidget {
//   final DateTime initialDate;
//   final void Function(DateTime selectedDate) onSubmit;
//   final DateTime? minDate;
//   final DateTime? maxDate;
//   final bool pickDay;
//   final Widget? image;
//   final double? bottomSheetHeight;
//   final double? height;
//   final double? width;

//   const DialDatePickerWidget({
//     required this.initialDate,
//     required this.onSubmit,
//     super.key,
//     this.minDate,
//     this.maxDate,
//     this.pickDay = true,
//     this.image,
//     this.height,
//     this.width,
//     this.bottomSheetHeight,
//   });

//   @override
//   State<DialDatePickerWidget> createState() => _DialDatePickerWidgetState();
// }

// class _DialDatePickerWidgetState extends State<DialDatePickerWidget> {
//   late DateTime _selectedDate;

//   @override
//   void initState() {
//     super.initState();
//     _selectedDate = widget.initialDate;

//     if (widget.minDate != null && _selectedDate.isBefore(widget.minDate!)) {
//       _selectedDate = widget.minDate!;
//     }
//     if (widget.maxDate != null && _selectedDate.isAfter(widget.maxDate!)) {
//       _selectedDate = widget.maxDate!;
//     }
//   }

//   void _showPicker(BuildContext context) {
//     showCupertinoModalPopup(
//       context: context,
//       builder:
//           (_) => Container(
//             height:
//                 widget.bottomSheetHeight ??
//                 MediaQuery.of(context).size.height * 0.4,
//             width: double.infinity,
//             color: CupertinoColors.systemBackground.resolveFrom(context),
//             child: Column(
//               children: [
//                 Expanded(
//                   child: CustomDatePicker(
//                     initialDate: DateTime.now(),
//                     minDate: widget.minDate ?? DateTime(1900, 1, 1),
//                     maxDate: widget.maxDate ?? DateTime(2100, 12, 31),
//                     pickDay: widget.pickDay,
//                     onDateChanged: (date) {
//                       setState(() {
//                         _selectedDate = date; // Save selected date
//                       });
//                     },
//                   ),

//                   // child: CupertinoDatePicker(
//                   //   dateOrder: DatePickerDateOrder.dmy,
//                   //   initialDateTime: _selectedDate,
//                   //   mode:
//                   //       widget.pickDay
//                   //           ? CupertinoDatePickerMode.date
//                   //           : CupertinoDatePickerMode.monthYear,
//                   //   minimumDate: widget.minDate,
//                   //   maximumDate: widget.maxDate,
//                   //   onDateTimeChanged: (DateTime newDate) {
//                   //     setState(() => _selectedDate = newDate);
//                   //     widget.onDateChanged(newDate);
//                   //   },
//                   // ),
//                 ),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.only(
//                     left: 16,
//                     right: 16,
//                     bottom: 16,
//                   ),
//                   child: CupertinoButton(
//                     padding: const EdgeInsets.all(0),
//                     borderRadius: BorderRadius.circular(50),
//                     color: AppColors.primary,
//                     child: Center(
//                       child: Text(
//                         'Submit',
//                         style: MyCoButtonTheme.getMobileTextStyle(context),
//                       ),
//                     ),
//                     onPressed: () {
//                       widget.onSubmit(_selectedDate);
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     if (widget.pickDay) {
//       return '${_monthName(date.month)} ${date.day}, ${date.year}';
//     } else {
//       return '${_monthName(date.month)} ${date.year}';
//     }
//   }

//   String _monthName(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];

//     if (month < 1 || month > 12) {
//       return '';
//     }
//     return months[month - 1];
//   }

//   @override
//   Widget build(BuildContext context) => MyCoButton(
//     onTap: () => _showPicker(context),
//     title: _formatDate(_selectedDate),
//     textStyle: const TextStyle(
//       color: AppColors.black,
//       fontWeight: FontWeight.w500,
//     ),
//     image: widget.image,
//     width: widget.width,
//     height: widget.height,
//     colorBackground: AppColors.white,
//     border: Border.all(color: AppColors.borderColor, width: 1.2),
//   );
// }

class CustomDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;
  final ValueChanged<DateTime> onDateChanged;
  final bool pickDay;

  const CustomDatePicker({
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
    required this.onDateChanged,
    super.key,
    this.pickDay = false,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late int selectedDay;
  late int selectedMonth;
  late int selectedYear;

  late List<String> monthNames;
  late List<int> yearList;
  late List<int> dayList;

  @override
  void initState() {
    super.initState();
    selectedDay = widget.initialDate.day;
    selectedMonth = widget.initialDate.month;
    selectedYear = widget.initialDate.year;

    // Month labels
    monthNames = List.generate(
      12,
      (i) => DateFormat.MMM().format(DateTime(0, i + 1)),
    );

    // Year range
    yearList = List.generate(
      widget.maxDate.year - widget.minDate.year + 1,
      (i) => widget.minDate.year + i,
    );

    _generateDayList();
  }

  void _generateDayList() {
    final isMinMonth =
        selectedYear == widget.minDate.year &&
        selectedMonth == widget.minDate.month;
    final isMaxMonth =
        selectedYear == widget.maxDate.year &&
        selectedMonth == widget.maxDate.month;

    final int startDay = isMinMonth ? widget.minDate.day : 1;
    int endDay = DateTime(selectedYear, selectedMonth + 1, 0).day;
    if (isMaxMonth) endDay = widget.maxDate.day.clamp(1, endDay);

    dayList = List.generate(endDay - startDay + 1, (i) => startDay + i);

    if (!dayList.contains(selectedDay)) {
      selectedDay = dayList.last;
    }
  }

  void _notifyChange() {
    final pickedDate = DateTime(
      selectedYear,
      selectedMonth,
      widget.pickDay ? selectedDay : 1,
    );
    widget.onDateChanged(pickedDate);
  }

  Widget _buildPicker({
    required FixedExtentScrollController controller,
    required List<Widget> children,
    required ValueChanged<int> onChanged,
  }) => Expanded(
    child: CupertinoPicker(
      scrollController: controller,
      itemExtent: 32,
      onSelectedItemChanged: onChanged,
      selectionOverlay: Container(
        decoration: const BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 6),
      ),
      children: children,
    ),
  );

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (widget.pickDay)
        _buildPicker(
          controller: FixedExtentScrollController(
            initialItem: dayList.indexOf(selectedDay),
          ),
          children:
              dayList
                  .map(
                    (d) => Center(
                      child: Text(d.toString(), textAlign: TextAlign.center),
                    ),
                  )
                  .toList(),
          onChanged: (index) {
            setState(() {
              selectedDay = dayList[index];
              _notifyChange();
            });
          },
        ),

      _buildPicker(
        controller: FixedExtentScrollController(initialItem: selectedMonth - 1),
        children: monthNames.map((m) => Center(child: Text(m))).toList(),
        onChanged: (index) {
          setState(() {
            selectedMonth = index + 1;
            _generateDayList();
            _notifyChange();
          });
        },
      ),

      _buildPicker(
        controller: FixedExtentScrollController(
          initialItem: selectedYear - widget.minDate.year,
        ),
        children:
            yearList.map((y) => Center(child: Text(y.toString()))).toList(),
        onChanged: (index) {
          setState(() {
            selectedYear = yearList[index];
            _generateDayList();
            _notifyChange();
          });
        },
      ),
    ],
  );
}
