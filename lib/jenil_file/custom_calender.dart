import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myco_karan/jenil_file/responsive.dart';

class CustomCalendar extends StatefulWidget {
  final bool isRangeSelectionMode;
  final bool disableFutureDates;
  final bool disablePastDates;
  final List<DateTime>? customDatesAsSelected;
  final DateTime? disableDatesBefore;
  final DateTime? disableDatesAfter;
  final int totalPreviousYear;
  final int totalNextYear;
  final List<DateTime>? disableCustomDates;
  final bool isMultipleSelection;
  final Color? selectedDateColor;
  final bool preselectSaturdays;
  final bool preselectSundays;

  const CustomCalendar({
    this.isRangeSelectionMode = false,
    this.disableFutureDates = false,
    this.disablePastDates = false,
    this.disableDatesBefore,
    this.disableDatesAfter,
    this.totalPreviousYear = 1,
    this.totalNextYear = 1,
    this.disableCustomDates,
    this.isMultipleSelection = false,
    this.selectedDateColor,
    this.customDatesAsSelected,
    this.preselectSaturdays = false,
    this.preselectSundays = false,
    super.key,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime _displayedMonth;
  List<DateTime> _selectedDates = [];
  final Set<DateTime> _lockedDates = {};
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  Map<DateTime, String> _dayWiseSelection = {};

  Color get selectionColor =>
      widget.selectedDateColor ?? const Color(0xFF2C5776);

  @override
  void initState() {
    super.initState();

    _displayedMonth =
        (widget.customDatesAsSelected?.isNotEmpty ?? false)
            ? widget.customDatesAsSelected!.first
            : DateTime.now();

    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
      if ((widget.preselectSaturdays && date.weekday == DateTime.saturday) ||
          (widget.preselectSundays && date.weekday == DateTime.sunday)) {
        if (!_isDateDisabled(date)) {
          _selectedDates.add(date);
          _dayWiseSelection[date] = "";
          _lockedDates.add(date);
        }
      }
    }

    if (widget.customDatesAsSelected != null) {
      for (var date in widget.customDatesAsSelected!) {
        if (!_selectedDates.any((d) => _isSameDay(d, date)) &&
            !_isDateDisabled(date)) {
          _selectedDates.add(date);
          _dayWiseSelection[date] = "";
          _lockedDates.add(date);
        }
      }
    }

    if (widget.isRangeSelectionMode &&
        widget.customDatesAsSelected != null &&
        widget.customDatesAsSelected!.length >= 2) {
      _rangeStart = widget.customDatesAsSelected!.first;
      _rangeEnd = widget.customDatesAsSelected!.last;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isDateDisabled(DateTime date) {
    final today = DateTime.now();
    if (widget.disablePastDates &&
        date.isBefore(DateTime(today.year, today.month, today.day))) {
      return true;
    }
    if (widget.disableFutureDates &&
        date.isAfter(DateTime(today.year, today.month, today.day))) {
      return true;
    }
    if (widget.disableDatesBefore != null &&
        date.isBefore(widget.disableDatesBefore!)) {
      return true;
    }
    if (widget.disableDatesAfter != null &&
        date.isAfter(widget.disableDatesAfter!)) {
      return true;
    }
    if (widget.disableCustomDates != null &&
        widget.disableCustomDates!.any((d) => _isSameDay(d, date))) {
      return true;
    }
    final minYear = DateTime.now().year - widget.totalPreviousYear;
    final maxYear = DateTime.now().year + widget.totalNextYear;
    return date.year < minYear || date.year > maxYear;
  }

  void _onDateTap(DateTime date) {
    if (_isDateDisabled(date)) return;

    setState(() {
      if (widget.isRangeSelectionMode) {
        if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
          _rangeStart = date;
          _rangeEnd = null;
        } else if (_rangeStart != null && _rangeEnd == null) {
          if (date.isBefore(_rangeStart!)) {
            _rangeEnd = _rangeStart;
            _rangeStart = date;
          } else {
            _rangeEnd = date;
          }
        }

        _selectedDates.clear();
        if (_rangeStart != null) {
          if (_rangeEnd == null) {
            _selectedDates = [_rangeStart!];
          } else {
            DateTime current = _rangeStart!;
            while (!current.isAfter(_rangeEnd!)) {
              _selectedDates.add(current);
              current = current.add(const Duration(days: 1));
            }
          }
        }
      } else if (widget.isMultipleSelection) {
        if (_selectedDates.any((d) => _isSameDay(d, date))) {
          if (_lockedDates.any((d) => _isSameDay(d, date))) return;
          _selectedDates.removeWhere((d) => _isSameDay(d, date));
          _dayWiseSelection.removeWhere((key, _) => _isSameDay(key, date));
        } else {
          _selectedDates.add(date);
          _dayWiseSelection[date] = "";
        }
      } else {
        if (_selectedDates.any((d) => _isSameDay(d, date))) {
          if (_lockedDates.any((d) => _isSameDay(d, date))) return;
          _selectedDates.clear();
          _dayWiseSelection.clear();
        } else {
          _selectedDates = [date];
          _dayWiseSelection = {date: ""};
        }
      }
    });
  }

  void _setDayType(DateTime date, String type) {
    setState(() => _dayWiseSelection[date] = type);
  }

  List<Widget> _buildDays() {
    final first = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final offset = (first.weekday) % 7;

    return List.generate(offset + daysInMonth, (index) {
      if (index < offset) return const SizedBox();
      final day = index - offset + 1;
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
      final isSelected = _selectedDates.any((d) => _isSameDay(d, date));
      final isDisabled = _isDateDisabled(date);
      final isRangeStart =
          _rangeStart != null && _isSameDay(_rangeStart!, date);
      final isRangeEnd = _rangeEnd != null && _isSameDay(_rangeEnd!, date);
      final inRange =
          _rangeStart != null &&
          _rangeEnd != null &&
          date.isAfter(_rangeStart!) &&
          date.isBefore(_rangeEnd!);

      Color backgroundColor;
      BorderRadius borderRadius = BorderRadius.zero;

      if (isRangeStart && isRangeEnd) {
        backgroundColor = selectionColor;
        borderRadius = BorderRadius.circular(getWidth(context) * 0.05);
      } else if (isRangeStart) {
        backgroundColor = selectionColor;
        borderRadius = BorderRadius.horizontal(
          left: Radius.circular(getWidth(context) * 0.05),
        );
      } else if (isRangeEnd) {
        backgroundColor = selectionColor;
        borderRadius = BorderRadius.horizontal(
          right: Radius.circular(getWidth(context) * 0.05),
        );
      } else if (inRange) {
        backgroundColor = selectionColor.withAlpha(153);
      } else if (isSelected) {
        backgroundColor = selectionColor;
        borderRadius = BorderRadius.circular(getWidth(context) * 0.05);
      } else {
        backgroundColor = Colors.transparent;
      }

      return GestureDetector(
        onTap: isDisabled ? null : () => _onDateTap(date),
        child: Container(
          margin: EdgeInsets.all(getWidth(context) * 0.005),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 12,
              color:
                  isDisabled
                      ? Colors.grey
                      : (isSelected || inRange || isRangeStart || isRangeEnd)
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRadioOnly(
    String? selected,
    VoidCallback onTap, {
    String label = "",
  }) {
    final isSelected =
        selected == label || (label.isEmpty && selected == "Full Day");
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: getWidth(context) * 0.05,
        height: getWidth(context) * 0.05,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: primaryColor, width: 1.5),
        ),
        child:
            isSelected
                ? Center(
                  child: Container(
                    width: getWidth(context) * 0.025,
                    height: getWidth(context) * 0.025,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                : null,
      ),
    );
  }

  Widget _buildDateChipsWithRadios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedDates.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              SizedBox(width: 20),
              Icon(Icons.calendar_month),
              SizedBox(width: 10),
              Text(
                "Full Day",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                "1st Half",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                "2nd Half",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ..._selectedDates.map((date) {
          final label = DateFormat('d MMM, yyyy').format(date);
          final selected = _dayWiseSelection[date];

          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2AB3A6),
                    borderRadius: BorderRadius.circular(
                      getWidth(context) * 0.05,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: getWidth(context) * 0.03,
                    vertical: getHeight(context) * 0.01,
                  ),
                  child: Row(
                    children: [
                      Text(label, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRadioOnly(
                        selected,
                        () => _setDayType(date, "Full Day"),
                      ),
                      _buildRadioOnly(
                        selected,
                        () => _setDayType(date, "1st Half"),
                        label: "1st Half",
                      ),
                      _buildRadioOnly(
                        selected,
                        () => _setDayType(date, "2nd Half"),
                        label: "2nd Half",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final minYear = DateTime.now().year - widget.totalPreviousYear;
    final maxYear = DateTime.now().year + widget.totalNextYear;

    return Container(
      height: getHeight(context) * 0.6,
      width: getWidth(context) * 0.9,
      padding: EdgeInsets.all(getWidth(context) * 0.04),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(getWidth(context) * 0.05),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: getWidth(context) * 0.04,
                ),
                onPressed: () {
                  final prev = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month - 1,
                  );
                  if (prev.year >= minYear) {
                    setState(() => _displayedMonth = prev);
                  }
                },
              ),
              Text(
                DateFormat('d MMMM, yyyy').format(
                  DateTime(_displayedMonth.year, _displayedMonth.month, 15),
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: getWidth(context) * 0.04,
                ),
                onPressed: () {
                  final next = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month + 1,
                  );
                  if (next.year <= maxYear) {
                    setState(() => _displayedMonth = next);
                  }
                },
              ),
            ],
          ),
          SizedBox(height: getHeight(context) * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .map(
                      (e) => Expanded(
                        child: Center(
                          child: Text(
                            e,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          SizedBox(height: getHeight(context) * 0.015),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _buildDays(),
          ),
          Divider(height: getHeight(context) * 0.04),
          Expanded(
            child: SingleChildScrollView(child: _buildDateChipsWithRadios()),
          ),
        ],
      ),
    );
  }
}
