import 'package:flutter/material.dart';

import '../utils/calendar_date_utils.dart';
import '../utils/category_theme.dart';
import 'calendar_month_header.dart';

/// 달력 크롬(월 헤더·요일) 레이아웃 치수.
abstract final class CalendarChromeMetrics {
  static const double monthHeaderHeight = 36;
  static const double weekdayRowHeight = 18;
  static const double overlayHeight = monthHeaderHeight + weekdayRowHeight;
}

/// 월 헤더·요일 행 — 날짜 그리드 바로 위에 배치.
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
      decoration: const BoxDecoration(
        color: CategoryTheme.appBackground,
        border: Border(
          bottom: BorderSide(color: CategoryTheme.appBorder),
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
      height: CalendarChromeMetrics.weekdayRowHeight,
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
