import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/category_theme.dart';

/// 달력 상단 월 네비게이션 헤더.
class CalendarMonthHeader extends StatelessWidget {
  const CalendarMonthHeader({
    super.key,
    required this.focusedMonth,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime focusedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final title = DateFormat.yMMMM('ko_KR').format(focusedMonth);

    return SizedBox(
      height: 36,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: CategoryTheme.calendarMonthTitleText,
              size: 22,
            ),
            tooltip: '이전 달',
            visualDensity: VisualDensity.compact,
            onPressed: onPrevious,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: CategoryTheme.calendarMonthTitleText,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: CategoryTheme.calendarMonthTitleText,
              size: 22,
            ),
            tooltip: '다음 달',
            visualDensity: VisualDensity.compact,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
