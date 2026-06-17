import 'package:flutter/material.dart';

import '../models/task_importance.dart';
import '../models/task_slot.dart';
import '../utils/calendar_layout_metrics.dart';
import '../utils/category_theme.dart';
import 'calendar_day_progress_bar.dart';
import 'calendar_task_line.dart';
import 'task_entry_controls.dart';

typedef CategoryDayTaskEnsure = Future<int> Function();
typedef CategoryDayTaskFieldCommit = Future<void> Function(int taskId);

/// 항목 카테고리 달력 셀 — 날짜당 1개 할일을 셀 안에서 직접 편집합니다.
class CategoryDayInlineEntry extends StatefulWidget {
  const CategoryDayInlineEntry({
    super.key,
    required this.day,
    required this.task,
    required this.accentColor,
    required this.taskFontPt,
    required this.onEnsureTask,
    required this.onToggle,
    required this.onHeaderCommit,
    required this.onLabelCommit,
    required this.onNotesCommit,
    required this.onImportanceChanged,
    required this.onUsageHoursChanged,
    this.onMonthEndReport,
  });

  final DateTime day;
  final TaskSlot? task;
  final Color accentColor;
  final int taskFontPt;
  final CategoryDayTaskEnsure onEnsureTask;
  final CategoryDayTaskFieldCommit onToggle;
  final Future<void> Function(int taskId, String value) onHeaderCommit;
  final Future<void> Function(int taskId, String value) onLabelCommit;
  final Future<void> Function(int taskId, String value) onNotesCommit;
  final Future<void> Function(int taskId, TaskImportance value)
      onImportanceChanged;
  final Future<void> Function(int taskId, int value) onUsageHoursChanged;
  final ValueChanged<DateTime>? onMonthEndReport;

  @override
  State<CategoryDayInlineEntry> createState() => _CategoryDayInlineEntryState();
}

class _CategoryDayInlineEntryState extends State<CategoryDayInlineEntry> {
  late final TextEditingController _headerController;
  late final TextEditingController _labelController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _headerController = TextEditingController(text: widget.task?.header ?? '');
    _labelController = TextEditingController(text: widget.task?.label ?? '');
    _notesController = TextEditingController(text: widget.task?.notes ?? '');
  }

  @override
  void didUpdateWidget(CategoryDayInlineEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task?.id != widget.task?.id) {
      _headerController.text = widget.task?.header ?? '';
      _labelController.text = widget.task?.label ?? '';
      _notesController.text = widget.task?.notes ?? '';
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _labelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<int> _taskId() async {
    final existing = widget.task?.id;
    if (existing != null) {
      return existing;
    }
    return widget.onEnsureTask();
  }

  Future<void> _commitHeader() async {
    final id = await _taskId();
    await widget.onHeaderCommit(id, _headerController.text);
  }

  Future<void> _commitLabel() async {
    final id = await _taskId();
    await widget.onLabelCommit(id, _labelController.text);
  }

  Future<void> _commitNotes() async {
    final id = await _taskId();
    await widget.onNotesCommit(id, _notesController.text);
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.taskFontPt.toDouble().clamp(6.0, 12.0);
    final task = widget.task;
    final isLastDay = widget.day.day ==
        DateTime(widget.day.year, widget.day.month + 1, 0).day;
    final barHeight = CalendarDayProgressBar.overviewBarHeight();
    final usageHours = task?.usageHours ?? 0;
    final contentInset = CalendarLayoutMetrics.dateColumnWidth + fontSize * 0.2;
    final headerLineHeight = CalendarLayoutMetrics.dateFontSize * 1.05;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: headerLineHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: CalendarLayoutMetrics.dateColumnWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${widget.day.day}',
                    style: TextStyle(
                      fontSize: CalendarLayoutMetrics.dateFontSize,
                      height: 1.0,
                      fontWeight: FontWeight.w600,
                      color: CategoryTheme.calendarDateText,
                    ),
                  ),
                ),
              ),
              SizedBox(width: fontSize * 0.2),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _headerController,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                          color: CategoryTheme.calendarDateText,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: '할일:',
                          hintStyle: TextStyle(
                            fontSize: fontSize,
                            color: CategoryTheme.calendarDateText
                                .withValues(alpha: 0.35),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isCollapsed: true,
                        ),
                        maxLines: 1,
                        onSubmitted: (_) => _commitHeader(),
                        onEditingComplete: _commitHeader,
                        onTapOutside: (_) => _commitHeader(),
                      ),
                    ),
                    CalendarMiniCheckbox(
                      size: (fontSize * 0.9).clamp(6.0, 10.0),
                      value: task?.completed ?? false,
                      activeColor: widget.accentColor,
                      onChanged: () async {
                        final id = await _taskId();
                        await widget.onToggle(id);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isLastDay && widget.onMonthEndReport != null)
          Padding(
            padding: EdgeInsets.only(left: contentInset * 0.15, bottom: 1),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => widget.onMonthEndReport!(
                  DateTime(widget.day.year, widget.day.month, 1),
                ),
                child: Icon(
                  Icons.assessment_outlined,
                  size: 9,
                  color: CategoryTheme.calendarDateText.withValues(alpha: 0.85),
                ),
              ),
            ),
          ),
        SizedBox(height: fontSize * 0.35),
        Padding(
          padding: EdgeInsets.only(left: contentInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ImportancePastelBar(
                value: task?.importance ?? TaskImportance.defaultValue,
                height: barHeight,
                onChanged: (value) async {
                  final id = await _taskId();
                  await widget.onImportanceChanged(id, value);
                },
              ),
              SizedBox(height: fontSize * 0.22),
              CompactFillDragBar(
                value: usageHours.toDouble(),
                min: 0,
                max: TaskSlot.maxUsageHours.toDouble(),
                divisions: TaskSlot.maxUsageHours,
                height: barHeight,
                trackColor: const Color(0xFFDCE6EF),
                fillColor: const Color(0xFF4A90C2),
                labelColor: const Color(0xFF2E5678).withValues(alpha: 0.9),
                centerLabelForValue: (v) => '${v.round()}h',
                semanticsLabel: '사용 시간 ${usageHours}시간',
                onChanged: (next) async {
                  final id = await _taskId();
                  await widget.onUsageHoursChanged(id, next.round());
                },
              ),
            ],
          ),
        ),
        SizedBox(height: fontSize * 0.1),
        TextField(
          controller: _labelController,
          style: TextStyle(
            fontSize: fontSize * 0.85,
            height: 1.1,
            color: CategoryTheme.calendarDateText.withValues(alpha: 0.85),
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: '짧은 제목',
            hintStyle: TextStyle(
              fontSize: fontSize * 0.85,
              color: CategoryTheme.calendarDateText.withValues(alpha: 0.3),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isCollapsed: true,
          ),
          maxLines: 1,
          onSubmitted: (_) => _commitLabel(),
          onEditingComplete: _commitLabel,
          onTapOutside: (_) => _commitLabel(),
        ),
        SizedBox(height: fontSize * 0.1),
        Expanded(
          child: TextField(
            controller: _notesController,
            style: TextStyle(
              fontSize: fontSize * 0.85,
              height: 1.15,
              color: CategoryTheme.calendarDateText.withValues(alpha: 0.9),
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: '본문',
              hintStyle: TextStyle(
                fontSize: fontSize * 0.85,
                color: CategoryTheme.calendarDateText.withValues(alpha: 0.3),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isCollapsed: true,
            ),
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            onEditingComplete: _commitNotes,
            onTapOutside: (_) => _commitNotes(),
          ),
        ),
      ],
    );
  }
}
