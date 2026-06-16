import 'package:flutter/material.dart';

import '../utils/calendar_date_utils.dart';
import '../utils/category_theme.dart';
import 'calendar_month_header.dart';

/// 월 헤더·요일 행을 날짜 그리드 위에 띄우는 오버레이.
class CalendarChromeOverlay extends StatelessWidget {
  const CalendarChromeOverlay({
    super.key,
    required this.focusedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime focusedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.38),
            Colors.black.withValues(alpha: 0.18),
            Colors.transparent,
          ],
          stops: const [0.0, 0.72, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CalendarMonthHeader(
            focusedMonth: focusedMonth,
            onPrevious: onPreviousMonth,
            onNext: onNextMonth,
          ),
          const _DaysOfWeekRow(),
        ],
      ),
    );
  }
}

class _DaysOfWeekRow extends StatelessWidget {
  const _DaysOfWeekRow();

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: CategoryTheme.calendarWeekdayText,
    );

    return SizedBox(
      height: 18,
      child: Row(
        children: [
          for (final label in CalendarDateUtils.weekdayLabels)
            Expanded(
              child: Center(
                child: Text(label, style: labelStyle),
              ),
            ),
        ],
      ),
    );
  }
}
