import 'package:flutter/material.dart';

import '../models/category_tab_store.dart';
import '../models/completion_rate.dart';
import '../models/journal_category_tab.dart';
import '../repositories/task_repository.dart';
import '../utils/calendar_date_utils.dart';
import '../utils/date_key.dart';
import 'calendar_day_cell.dart';

/// 6×7 날짜 그리드.
class CalendarDateGrid extends StatelessWidget {
  const CalendarDateGrid({
    super.key,
    required this.gridKey,
    required this.month,
    required this.selectedDay,
    required this.activeTab,
    required this.completionRates,
    required this.taskStore,
    required this.onDaySelected,
    required this.onMonthEndReport,
  });

  final Key? gridKey;
  final DateTime month;
  final DateTime selectedDay;
  final JournalCategoryTab activeTab;
  final CompletionRateMap completionRates;
  final TaskStoreData taskStore;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthEndReport;

  @override
  Widget build(BuildContext context) {
    final days = CalendarDateUtils.visibleDaysForMonth(month);

    return Column(
      key: gridKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var week = 0; week < CalendarDateUtils.weekRows; week++)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var dayIndex = 0; dayIndex < 7; dayIndex++)
                  Expanded(
                    child: _buildGridCell(
                      context,
                      days[week * 7 + dayIndex],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildGridCell(BuildContext context, DateTime day) {
    if (day.month != month.month) {
      return SizedBox.expand(
        child: ColoredBox(
          color: Colors.white.withValues(alpha: 0.04),
        ),
      );
    }

    final isSelected = CalendarDateUtils.isSameDay(selectedDay, day);
    final isToday = CalendarDateUtils.isSameDay(DateTime.now(), day);
    final tasks = taskStore[dateKey(day)] ?? [];
    final visibleTasks = CategoryTabStore.filterTasksForTab(tasks, activeTab);

    return SizedBox.expand(
      child: GestureDetector(
        onTap: () => onDaySelected(day),
        child: CalendarDayCell(
          day: day,
          isSelected: isSelected,
          isToday: isToday,
          activeTab: activeTab,
          completionEntry: getCompletionEntryForDate(completionRates, day),
          visibleTasks: visibleTasks,
          onMonthEndReport: onMonthEndReport,
        ),
      ),
    );
  }
}
