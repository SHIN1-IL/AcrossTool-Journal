import 'package:flutter/material.dart';

import '../models/task_importance.dart';
import '../models/task_slot.dart';
import '../utils/calendar_layout_metrics.dart';
import '../utils/category_theme.dart';
import 'calendar_day_progress_bar.dart';
import 'task_entry_controls.dart';

/// 항목 카테고리 — 바텀 시트 모드용 달력 셀 미리보기 (탭하여 편집).
class CategoryDayPreviewCell extends StatelessWidget {
  const CategoryDayPreviewCell({
    super.key,
    required this.day,
    required this.task,
    required this.accentColor,
    required this.taskFontPt,
    required this.onDaySelected,
    this.onMonthEndReport,
  });

  final DateTime day;
  final TaskSlot? task;
  final Color accentColor;
  final int taskFontPt;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime>? onMonthEndReport;

  @override
  Widget build(BuildContext context) {
    final fontSize = taskFontPt.toDouble().clamp(6.0, 12.0);
    final barHeight = CalendarDayProgressBar.overviewBarHeight();
    final isLastDay = day.day == DateTime(day.year, day.month + 1, 0).day;
    final previewText = _previewText(task);
    final completed = task?.completed ?? false;
    final importance = task?.importance ?? TaskImportance.defaultValue;
    final usageHours = task?.usageHours ?? 0;
    final contentInset = CalendarLayoutMetrics.dateColumnWidth + fontSize * 0.2;

    return GestureDetector(
      onTap: () => onDaySelected(day),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: CalendarLayoutMetrics.dateColumnWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: CalendarLayoutMetrics.dateFontSize,
                        height: 1.0,
                        fontWeight: FontWeight.w600,
                        color: CategoryTheme.calendarDateText,
                      ),
                    ),
                    if (isLastDay && onMonthEndReport != null)
                      GestureDetector(
                        onTap: () =>
                            onMonthEndReport!(DateTime(day.year, day.month, 1)),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.assessment_outlined,
                            size: 9,
                            color: CategoryTheme.calendarDateText
                                .withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: fontSize * 0.2),
              Expanded(
                child: Text(
                  previewText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSize,
                    height: 1.15,
                    fontWeight:
                        previewText == '탭하여 입력' ? FontWeight.w400 : FontWeight.w600,
                    color: previewText == '탭하여 입력'
                        ? CategoryTheme.calendarDateText.withValues(alpha: 0.35)
                        : CategoryTheme.calendarDateText.withValues(
                            alpha: completed ? 0.45 : 0.92,
                          ),
                    decoration:
                        completed ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: fontSize * 0.3),
          Padding(
            padding: EdgeInsets.only(left: contentInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IgnorePointer(
                  child: ImportancePastelBar(
                    value: importance,
                    height: barHeight,
                    onChanged: (_) {},
                  ),
                ),
                SizedBox(height: fontSize * 0.18),
                IgnorePointer(
                  child: CompactFillDragBar(
                    value: usageHours.toDouble(),
                    min: 0,
                    max: TaskSlot.maxUsageHours.toDouble(),
                    height: barHeight,
                    trackColor: const Color(0xFFDCE6EF),
                    fillColor: const Color(0xFF4A90C2),
                    labelColor: const Color(0xFF2E5678).withValues(alpha: 0.9),
                    centerLabelForValue: (v) => '${v.round()}h',
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _previewText(TaskSlot? task) {
    if (task == null) {
      return '탭하여 입력';
    }
    if (task.header.trim().isNotEmpty) {
      return task.header.trim();
    }
    if (task.label.trim().isNotEmpty) {
      return task.label.trim();
    }
    return '탭하여 입력';
  }
}
