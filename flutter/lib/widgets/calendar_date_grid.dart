import 'package:flutter/material.dart';

import '../models/completion_rate.dart';
import '../models/journal_category_tab.dart';
import '../repositories/task_repository.dart';
import '../utils/calendar_date_utils.dart';
import '../utils/category_theme.dart';
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
    required this.categoryTabs,
    required this.completionRates,
    required this.taskStore,
    required this.taskFontPt,
    required this.onDaySelected,
    required this.onMonthEndReport,
    this.onEnsureCategoryTask,
    this.onCategoryTaskToggle,
    this.onCategoryTaskHeaderChanged,
    this.onCategoryTaskLabelChanged,
    this.onCategoryTaskNotesChanged,
    this.onCategoryTaskImportanceChanged,
    this.onCategoryTaskUsageHoursChanged,
    this.categoryInlineEdit = true,
  });

  final Key? gridKey;
  final DateTime month;
  final DateTime selectedDay;
  final JournalCategoryTab activeTab;
  final List<JournalCategoryTab> categoryTabs;
  final CompletionRateMap completionRates;
  final TaskStoreData taskStore;
  final int taskFontPt;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthEndReport;
  final CategoryDayTaskEnsure? onEnsureCategoryTask;
  final CategoryDayTaskToggle? onCategoryTaskToggle;
  final CategoryDayTaskStringUpdate? onCategoryTaskHeaderChanged;
  final CategoryDayTaskStringUpdate? onCategoryTaskLabelChanged;
  final CategoryDayTaskStringUpdate? onCategoryTaskNotesChanged;
  final CategoryDayTaskImportanceUpdate? onCategoryTaskImportanceChanged;
  final CategoryDayTaskUsageHoursUpdate? onCategoryTaskUsageHoursChanged;
  final bool categoryInlineEdit;

  @override
  Widget build(BuildContext context) {
    final rowCount = CalendarDateUtils.weekRowCountForMonth(month);
    final days = CalendarDateUtils.visibleDaysForMonth(month);

    return Column(
      key: gridKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var week = 0; week < rowCount; week++)
          Expanded(
            flex: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var dayIndex = 0; dayIndex < 7; dayIndex++)
                  Expanded(
                    flex: 1,
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
          color: CategoryTheme.calendarOutsideCellFill,
        ),
      );
    }

    final isSelected = CalendarDateUtils.isSameDay(selectedDay, day);
    final isToday = CalendarDateUtils.isSameDay(DateTime.now(), day);
    final dayTasks = taskStore[dateKey(day)] ?? [];

    return SizedBox.expand(
      child: CalendarDayCell(
        day: day,
        isSelected: isSelected,
        isToday: isToday,
        activeTab: activeTab,
        completionEntry: getCompletionEntryForDate(completionRates, day),
        dayTasks: dayTasks,
        categoryTabs: categoryTabs,
        taskFontPt: taskFontPt,
        onDaySelected: onDaySelected,
        onMonthEndReport: onMonthEndReport,
        onEnsureCategoryTask: onEnsureCategoryTask,
        onCategoryTaskToggle: onCategoryTaskToggle,
        onCategoryTaskHeaderChanged: onCategoryTaskHeaderChanged,
        onCategoryTaskLabelChanged: onCategoryTaskLabelChanged,
        onCategoryTaskNotesChanged: onCategoryTaskNotesChanged,
        onCategoryTaskImportanceChanged: onCategoryTaskImportanceChanged,
        onCategoryTaskUsageHoursChanged: onCategoryTaskUsageHoursChanged,
        categoryInlineEdit: categoryInlineEdit,
      ),
    );
  }
}
