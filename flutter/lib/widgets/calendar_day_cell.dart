import 'package:flutter/material.dart';

import '../models/completion_rate.dart';
import '../models/journal_category_tab.dart';
import '../models/task_slot.dart';
import '../utils/calendar_date_utils.dart';
import '../utils/category_theme.dart';
import 'completion_marker.dart';

/// 달력 날짜 셀 1칸.
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.activeTab,
    required this.completionEntry,
    required this.visibleTasks,
    required this.onMonthEndReport,
  });

  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final JournalCategoryTab activeTab;
  final CompletionDayEntry? completionEntry;
  final List<TaskSlot> visibleTasks;
  final ValueChanged<DateTime> onMonthEndReport;

  @override
  Widget build(BuildContext context) {
    final isLastDay = CalendarDateUtils.isLastDayOfMonth(day);
    final textStyle = TextStyle(
      color: CategoryTheme.calendarDateText.withValues(
        alpha: isSelected || isToday ? 1 : 0.92,
      ),
      fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.w400,
      fontSize: 13,
    );

    return Semantics(
      label: buildCalendarDateAriaLabel(day, completionEntry),
      selected: isSelected,
      button: true,
      child: SizedBox.expand(
        child: DecoratedBox(
          decoration: _cellDecoration(
            isSelected: isSelected,
            isToday: isToday,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${day.day}', style: textStyle),
                    if (isLastDay) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: () => onMonthEndReport(
                          DateTime(day.year, day.month, 1),
                        ),
                        child: Icon(
                          Icons.assessment_outlined,
                          size: 11,
                          color: CategoryTheme.calendarDateText
                              .withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ],
                ),
                if (activeTab.isOverview)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final task in visibleTasks.take(3))
                        Text(
                          task.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            color: CategoryTheme.calendarDateText
                                .withValues(alpha: 0.88),
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                    ],
                  )
                else if (completionEntry != null)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: CompletionMarker(
                      rate: completionEntry!.rate,
                      selected: isSelected,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cellDecoration({
    required bool isSelected,
    required bool isToday,
  }) {
    Color background = CategoryTheme.calendarCellFill;
    Color borderColor = CategoryTheme.calendarCellBorder;
    var borderWidth = 0.5;

    if (isSelected) {
      background = CategoryTheme.calendarSelectedCellFill;
      borderColor = Colors.white54;
      borderWidth = 1;
    } else if (isToday) {
      background = Colors.white30;
      borderColor = Colors.white54;
      borderWidth = 0.8;
    }

    return BoxDecoration(
      color: background,
      border: Border.all(color: borderColor, width: borderWidth),
    );
  }
}
