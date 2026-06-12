import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/completion_rate.dart';
import 'completion_marker.dart';

/// 웹 MVP `Calendar.tsx` 대응.
class JournalCalendar extends StatefulWidget {
  const JournalCalendar({
    super.key,
    required this.selectedDay,
    required this.completionRates,
    required this.onDaySelected,
  });

  final DateTime selectedDay;
  final CompletionRateMap completionRates;
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

  Widget _buildDayCell(
    BuildContext context,
    DateTime day, {
    required bool isSelected,
    required bool isToday,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final entry = getCompletionEntryForDate(widget.completionRates, day);

    BoxDecoration? decoration;
    late final TextStyle textStyle;

    if (isSelected) {
      decoration = BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      );
      textStyle = const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      );
    } else if (isToday) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.35),
        ),
      );
      textStyle = TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      );
    } else {
      textStyle = TextStyle(color: Colors.grey.shade800);
    }

    return Semantics(
      label: buildCalendarDateAriaLabel(day, entry),
      selected: isSelected,
      button: true,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: decoration,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.day}', style: textStyle),
            if (entry != null) ...[
              const SizedBox(height: 2),
              CompletionMarker(rate: entry.rate, selected: isSelected),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            cellMargin: EdgeInsets.zero,
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              return _buildDayCell(
                context,
                day,
                isSelected: isSameDay(widget.selectedDay, day),
                isToday: isSameDay(DateTime.now(), day),
              );
            },
            todayBuilder: (context, day, focusedDay) {
              return _buildDayCell(
                context,
                day,
                isSelected: isSameDay(widget.selectedDay, day),
                isToday: true,
              );
            },
            selectedBuilder: (context, day, focusedDay) {
              return _buildDayCell(
                context,
                day,
                isSelected: true,
                isToday: isSameDay(DateTime.now(), day),
              );
            },
          ),
        ),
      ),
    );
  }
}
