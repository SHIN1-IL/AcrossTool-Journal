import 'package:flutter/material.dart';

import '../models/completion_rate.dart';
import '../models/journal_category_tab.dart';
import '../models/task_importance.dart';
import '../models/task_slot.dart';
import '../utils/calendar_date_utils.dart';
import '../utils/calendar_layout_metrics.dart';
import '../utils/category_theme.dart';
import '../utils/task_progress.dart';
import '../utils/time_format.dart';
import 'calendar_day_progress_bar.dart';
import 'category_day_inline_entry.dart';
import 'category_day_preview_cell.dart';

typedef CategoryDayTaskEnsure = Future<int> Function(
  DateTime day,
  String category,
);
typedef CategoryDayTaskToggle = Future<void> Function(
  DateTime day,
  int taskId,
);
typedef CategoryDayTaskStringUpdate = Future<void> Function(
  DateTime day,
  int taskId,
  String value,
);
typedef CategoryDayTaskImportanceUpdate = Future<void> Function(
  DateTime day,
  int taskId,
  TaskImportance value,
);
typedef CategoryDayTaskUsageHoursUpdate = Future<void> Function(
  DateTime day,
  int taskId,
  int value,
);

/// 달력 날짜 셀 1칸.
class CalendarDayCell extends StatefulWidget {
  const CalendarDayCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.activeTab,
    required this.completionEntry,
    required this.dayTasks,
    required this.categoryTabs,
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

  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final JournalCategoryTab activeTab;
  final CompletionDayEntry? completionEntry;
  final List<TaskSlot> dayTasks;
  final List<JournalCategoryTab> categoryTabs;
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
  State<CalendarDayCell> createState() => _CalendarDayCellState();
}

class _CalendarDayCellState extends State<CalendarDayCell> {
  List<JournalCategoryTab> get _editableCategories {
    return widget.categoryTabs
        .where((tab) => !tab.isOverview && !tab.isAnalytics)
        .take(CalendarLayoutMetrics.maxCategoryColumns)
        .toList();
  }

  TaskSlot? _singleCategoryTask(String category) {
    final tasks =
        widget.dayTasks.where((task) => task.category == category).toList();
    if (tasks.isEmpty) {
      return null;
    }
    return tasks.first;
  }

  List<TaskSlot> _overviewTasks() {
    final tasks = widget.dayTasks.where((task) => task.hasContent).toList();
    tasks.sort((a, b) {
      final importance =
          TaskImportance.compare(b.importance, a.importance);
      if (importance != 0) {
        return importance;
      }
      return compareTimeStrings(a.time, b.time);
    });
    return tasks.take(CalendarLayoutMetrics.maxTaskRows).toList();
  }

  int get _displayProgressRate {
    final scoped = widget.activeTab.isOverview
        ? widget.dayTasks
        : [
            if (_singleCategoryTask(widget.activeTab.title) case final task?)
              task,
          ];
    final importance = calculateTopTwoImportanceProgress(scoped) ?? 0;
    if (importance > 0) {
      return importance;
    }
    return calculateUsageHoursProgress(scoped) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final isOverview = widget.activeTab.isOverview;
    final useCategoryBottomSheet = !isOverview && !widget.categoryInlineEdit;

    return Semantics(
      label: buildCalendarDateAriaLabel(widget.day, widget.completionEntry),
      selected: widget.isSelected,
      button: isOverview || useCategoryBottomSheet,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final metrics = CalendarLayoutMetrics.of(
            context,
            cellWidth: constraints.maxWidth,
            cellHeight: constraints.maxHeight,
            categoryCount: 1,
            isOverview: false,
            taskFontPt: widget.taskFontPt.toDouble(),
          );
          final progressRate = _displayProgressRate;
          final category = widget.activeTab.title;

          return SizedBox.expand(
            child: DecoratedBox(
              decoration: _cellDecoration(
                isSelected: widget.isSelected,
                isToday: widget.isToday,
              ),
              child: Padding(
                padding: EdgeInsets.all(metrics.cellPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRect(
                        child: isOverview
                            ? _OverviewVerticalList(
                                day: widget.day,
                                metrics: metrics,
                                tasks: _overviewTasks(),
                                categoryTabs: _editableCategories,
                                progressRate: progressRate,
                                onDaySelected: widget.onDaySelected,
                                onMonthEndReport: widget.onMonthEndReport,
                                isSelected: widget.isSelected,
                                isToday: widget.isToday,
                              )
                            : widget.categoryInlineEdit
                                ? CategoryDayInlineEntry(
                                    key: ValueKey(
                                      '${widget.day.toIso8601String()}-$category',
                                    ),
                                    day: widget.day,
                                    task: _singleCategoryTask(category),
                                    accentColor: widget.activeTab.accentColor,
                                    taskFontPt: widget.taskFontPt,
                                    onMonthEndReport: widget.onMonthEndReport,
                                    onEnsureTask: () => widget
                                        .onEnsureCategoryTask!(
                                        widget.day,
                                        category,
                                      ),
                                    onToggle: (taskId) => widget
                                        .onCategoryTaskToggle!(
                                        widget.day,
                                        taskId,
                                      ),
                                    onHeaderCommit: (taskId, value) => widget
                                        .onCategoryTaskHeaderChanged!(
                                        widget.day,
                                        taskId,
                                        value,
                                      ),
                                    onLabelCommit: (taskId, value) => widget
                                        .onCategoryTaskLabelChanged!(
                                        widget.day,
                                        taskId,
                                        value,
                                      ),
                                    onNotesCommit: (taskId, value) => widget
                                        .onCategoryTaskNotesChanged!(
                                        widget.day,
                                        taskId,
                                        value,
                                      ),
                                    onImportanceChanged: (taskId, value) => widget
                                        .onCategoryTaskImportanceChanged!(
                                        widget.day,
                                        taskId,
                                        value,
                                      ),
                                    onUsageHoursChanged: (taskId, value) => widget
                                        .onCategoryTaskUsageHoursChanged!(
                                        widget.day,
                                        taskId,
                                        value,
                                      ),
                                  )
                                : CategoryDayPreviewCell(
                                    key: ValueKey(
                                      '${widget.day.toIso8601String()}-$category-preview',
                                    ),
                                    day: widget.day,
                                    task: _singleCategoryTask(category),
                                    accentColor: widget.activeTab.accentColor,
                                    taskFontPt: widget.taskFontPt,
                                    onDaySelected: widget.onDaySelected,
                                    onMonthEndReport: widget.onMonthEndReport,
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
      borderColor = CategoryTheme.analyticsAccent;
      borderWidth = 1.2;
    } else if (isToday) {
      background = CategoryTheme.calendarSelectedCellFill;
      borderColor = CategoryTheme.appTextMuted;
      borderWidth = 1;
    }

    return BoxDecoration(
      color: background,
      border: Border.all(color: borderColor, width: borderWidth),
    );
  }
}

class _DayNumberColumn extends StatelessWidget {
  const _DayNumberColumn({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.onDaySelected,
    required this.onMonthEndReport,
  });

  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthEndReport;

  @override
  Widget build(BuildContext context) {
    final isLastDay = CalendarDateUtils.isLastDayOfMonth(day);
    final textStyle = TextStyle(
      color: CategoryTheme.calendarDateText.withValues(
        alpha: isSelected || isToday ? 1 : 0.92,
      ),
      fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.w400,
      fontSize: CalendarLayoutMetrics.dateFontSize,
      height: 1.0,
    );

    return SizedBox(
      width: CalendarLayoutMetrics.dateColumnWidth,
      child: GestureDetector(
        onTap: () => onDaySelected(day),
        behavior: HitTestBehavior.opaque,
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${day.day}', style: textStyle),
              if (isLastDay)
                GestureDetector(
                  onTap: () =>
                      onMonthEndReport(DateTime(day.year, day.month, 1)),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.assessment_outlined,
                      size: 10,
                      color: CategoryTheme.calendarDateText
                          .withValues(alpha: 0.85),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewVerticalList extends StatelessWidget {
  const _OverviewVerticalList({
    required this.day,
    required this.metrics,
    required this.tasks,
    required this.categoryTabs,
    required this.progressRate,
    required this.onDaySelected,
    required this.onMonthEndReport,
    required this.isSelected,
    required this.isToday,
  });

  final DateTime day;
  final CalendarLayoutMetrics metrics;
  final List<TaskSlot> tasks;
  final List<JournalCategoryTab> categoryTabs;
  final int progressRate;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthEndReport;
  final bool isSelected;
  final bool isToday;

  Color _colorForTask(TaskSlot task) {
    for (final tab in categoryTabs) {
      if (tab.title == task.category) {
        return tab.accentColor;
      }
    }
    return CategoryTheme.analyticsAccent;
  }

  String _labelForTask(TaskSlot task) {
    final category = task.category;
    if (category == null || category.isEmpty) {
      return '·';
    }
    return category.length <= 3 ? category : category.substring(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final barHeight = CalendarDayProgressBar.overviewBarHeight();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _DayNumberColumn(
              day: day,
              isSelected: isSelected,
              isToday: isToday,
              onDaySelected: onDaySelected,
              onMonthEndReport: onMonthEndReport,
            ),
            SizedBox(width: metrics.rowGap * 0.5),
            Expanded(
              child: CalendarDayProgressBar(
                rate: progressRate,
                height: barHeight,
                showPercentLabel: true,
              ),
            ),
          ],
        ),
        SizedBox(height: metrics.rowGap * 0.5),
        Expanded(
          child: tasks.isEmpty
              ? const SizedBox.shrink()
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: metrics.rowGap),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _OverviewReadOnlyTaskRow(
                      task: task,
                      metrics: metrics,
                      accentColor: _colorForTask(task),
                      categoryLabel: _labelForTask(task),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _OverviewReadOnlyTaskRow extends StatelessWidget {
  const _OverviewReadOnlyTaskRow({
    required this.task,
    required this.metrics,
    required this.accentColor,
    required this.categoryLabel,
  });

  final TaskSlot task;
  final CalendarLayoutMetrics metrics;
  final Color accentColor;
  final String categoryLabel;

  @override
  Widget build(BuildContext context) {
    final completed = task.completed;
    final textColor = CategoryTheme.calendarDateText.withValues(
      alpha: completed ? 0.45 : 0.9,
    );
    final decoration =
        completed ? TextDecoration.lineThrough : TextDecoration.none;

    return SizedBox(
      height: metrics.rowHeight,
      child: Row(
        children: [
          SizedBox(
            width: metrics.taskFontSize * 1.35,
            child: Text(
              categoryLabel,
              maxLines: 1,
              overflow: TextOverflow.clip,
              softWrap: false,
              style: TextStyle(
                fontSize: metrics.taskFontSize * 0.78,
                height: 1.0,
                fontWeight: FontWeight.w700,
                color: accentColor.withValues(alpha: completed ? 0.45 : 1),
                decoration: decoration,
              ),
            ),
          ),
          SizedBox(width: metrics.rowGap * 0.35),
          Expanded(
            child: Text(
              task.displayTitle,
              maxLines: 1,
              overflow: TextOverflow.clip,
              softWrap: false,
              style: TextStyle(
                fontSize: metrics.taskFontSize,
                height: 1.0,
                color: textColor,
                decoration: decoration,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
