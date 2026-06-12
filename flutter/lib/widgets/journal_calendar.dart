import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

/// 웹 MVP `Calendar.tsx` 대응. 완료율 마커는 추후 `completion_marker.dart`에서 추가합니다.
class JournalCalendar extends StatefulWidget {
  const JournalCalendar({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  @override
  State<JournalCalendar> createState() => _JournalCalendarState();
}

class _JournalCalendarState extends State<JournalCalendar> {
  late DateTime _focusedDay;

  static final DateTime _firstDay = DateTime(2020, 1, 1);
  static final DateTime _lastDay = DateTime(2035, 12, 31);

  @override
  void initState() {
    super.initState();
    _focusedDay = _dateOnly(widget.selectedDay);
  }

  @override
  void didUpdateWidget(JournalCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(oldWidget.selectedDay, widget.selectedDay)) {
      _focusedDay = _dateOnly(widget.selectedDay);
    }
  }

  DateTime _dateOnly(DateTime day) => DateTime(day.year, day.month, day.day);

  void _handleDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(widget.selectedDay, selectedDay)) {
      widget.onDaySelected(_dateOnly(selectedDay));
    }
    setState(() => _focusedDay = _dateOnly(focusedDay));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TableCalendar<void>(
          firstDay: _firstDay,
          lastDay: _lastDay,
          focusedDay: _focusedDay,
          locale: 'ko_KR',
          startingDayOfWeek: StartingDayOfWeek.sunday,
          selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
          onDaySelected: _handleDaySelected,
          onPageChanged: (focusedDay) {
            setState(() => _focusedDay = _dateOnly(focusedDay));
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon: const Icon(Icons.chevron_left),
            rightChevronIcon: const Icon(Icons.chevron_right),
            titleTextFormatter: (date, locale) {
              return DateFormat.yMMMM('ko_KR').format(date);
            },
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            weekendStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            cellMargin: const EdgeInsets.all(4),
            defaultTextStyle: TextStyle(color: Colors.grey.shade800),
            weekendTextStyle: TextStyle(color: Colors.grey.shade800),
            selectedDecoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            todayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35)),
            ),
            todayTextStyle: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
