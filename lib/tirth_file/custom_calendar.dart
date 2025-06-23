import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

enum SelectionMode { multi, range }

class CustomCalendar extends StatefulWidget {
  final Function(DateTime, String)? onLeaveTypeChanged;

  const CustomCalendar({super.key, this.onLeaveTypeChanged});

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime _focusedDay = DateTime.now();

  SelectionMode _selectionMode = SelectionMode.multi;

  final List<DateTime> _selectedDays = [];
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  final Map<DateTime, String> _leaveTypeSelection = {};
  final Map<DateTime, Color> _customDayColors = {};

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;

      if (_selectionMode == SelectionMode.multi) {
        if (_selectedDays.any((d) => isSameDay(d, selectedDay))) {
          _selectedDays.removeWhere((d) => isSameDay(d, selectedDay));
          _leaveTypeSelection.removeWhere(
              (key, _) => isSameDay(key, selectedDay));
        } else {
          _selectedDays.add(selectedDay);
        }

        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      } else {
        if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
          _rangeStart = selectedDay;
          _rangeEnd = null;
          _rangeSelectionMode = RangeSelectionMode.toggledOn;
        } else if (_rangeStart != null && _rangeEnd == null) {
          if (!selectedDay.isBefore(_rangeStart!)) {
            _rangeEnd = selectedDay;
          } else {
            _rangeStart = selectedDay;
          }
        }

        _selectedDays.clear();
        _leaveTypeSelection.removeWhere(
            (key, _) => !_isWithinRange(key, _rangeStart, _rangeEnd));
      }
    });
  }

  bool _isWithinRange(DateTime day, DateTime? start, DateTime? end) {
    if (start == null) return false;
    if (end == null) return isSameDay(day, start);
    return (day.isAtSameMomentAs(start) ||
        day.isAtSameMomentAs(end) ||
        (day.isAfter(start) && day.isBefore(end)));
  }

  void _onLeaveTypeChanged(DateTime day, String type) {
    setState(() {
      _leaveTypeSelection[day] = type;
    });
    widget.onLeaveTypeChanged?.call(day, type);
  }

  List<DateTime> get _currentlySelectedDays {
    if (_selectionMode == SelectionMode.multi) {
      return _selectedDays;
    } else {
      if (_rangeStart != null && _rangeEnd != null) {
        return List.generate(
          _rangeEnd!.difference(_rangeStart!).inDays + 1,
          (index) => _rangeStart!.add(Duration(days: index)),
        );
      } else if (_rangeStart != null) {
        return [_rangeStart!];
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              if (_selectionMode == SelectionMode.multi) {
                return _selectedDays.any((d) => isSameDay(d, day));
              }
              return false;
            },
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            rangeSelectionMode: _rangeSelectionMode,
            onDaySelected: _onDaySelected,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              rangeHighlightColor: Color(0xFF2F648E),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF2F648E),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.arrow_back_ios),
              rightChevronIcon: Icon(Icons.arrow_forward_ios),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final normalizedDay = DateTime.utc(day.year, day.month, day.day);
                final color = _customDayColors[normalizedDay];
                if (color != null) {
                  return Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          if (_currentlySelectedDays.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Icon(
                          Icons.calendar_today,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Text(
                              "Full Day",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff2F648E),
                              ),
                            ),
                            Text(
                              "1st Half",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff2F648E),
                              ),
                            ),
                            Text(
                              "2nd Half",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff2F648E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._currentlySelectedDays.map((day) {
                    String? selectedType = _leaveTypeSelection[day];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 32),
                          Stack(
                            children: [
                              Container(
                                width: 140,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xff2FBBA4),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    "${day.day} ${_monthName(day.month)}, ${day.year}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: LinearGradient(
                                          begin: Alignment.center,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black12,
                                          ],
                                          stops: [0.8, 1.0],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: LinearGradient(
                                          begin: Alignment.center,
                                          end: Alignment.centerLeft,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black12,
                                          ],
                                          stops: [0.7, 1.0],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: LinearGradient(
                                          begin: Alignment.center,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black12,
                                          ],
                                          stops: [0.7, 1.0],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Radio<String>(
                                  value: "Full Day",
                                  groupValue: selectedType,
                                  onChanged: (val) =>
                                      _onLeaveTypeChanged(day, val!),
                                  activeColor: Color(0xFF2F648E),
                                ),
                                Radio<String>(
                                  value: "1st Half",
                                  groupValue: selectedType,
                                  onChanged: (val) =>
                                      _onLeaveTypeChanged(day, val!),
                                  activeColor: Color(0xFF2F648E),
                                ),
                                Radio<String>(
                                  value: "2nd Half",
                                  groupValue: selectedType,
                                  onChanged: (val) =>
                                      _onLeaveTypeChanged(day, val!),
                                  activeColor: Color(0xFF2F648E),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text("Multi-select"),
                selected: _selectionMode == SelectionMode.multi,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectionMode = SelectionMode.multi;
                      _rangeStart = null;
                      _rangeEnd = null;
                      _rangeSelectionMode = RangeSelectionMode.toggledOff;
                    });
                  }
                },
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text("Range-select"),
                selected: _selectionMode == SelectionMode.range,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectionMode = SelectionMode.range;
                      _selectedDays.clear();
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }

  void setCustomDayColor(DateTime date, Color color) {
    setState(() {
      _customDayColors[DateTime.utc(date.year, date.month, date.day)] = color;
    });
  }
}
