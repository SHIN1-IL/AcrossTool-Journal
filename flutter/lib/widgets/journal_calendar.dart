import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/completion_rate.dart';
import '../models/journal_category_tab.dart';
import '../models/task_slot.dart';
import '../repositories/task_repository.dart';
import '../utils/date_key.dart';
import '../utils/category_theme.dart';
import '../utils/layout_units.dart';
import 'completion_marker.dart';

/// 웹 MVP `CalendarPage` 레이아웃 대응.
///
/// ```text
/// Column (h-full)
/// ├─ header (flex-shrink-0) — 월 네비게이션
/// └─ main   (flex-1)        — 요일 + 날짜 그리드
///    ├─ weekday row (flex-shrink-0)
///    └─ date grid   (flex-1, grid-rows-6)
/// ```
class JournalCalendar extends StatefulWidget {
  const JournalCalendar({
    super.key,
    required this.selectedDay,
    required this.completionRates,
    required this.taskStore,
    required this.activeTab,
    required this.categoryColors,
    required this.backgroundColor,
    required this.onDaySelected,
    required this.onMonthEndReport,
  });

  final DateTime selectedDay;
  final CompletionRateMap completionRates;
  final TaskStoreData taskStore;
  final JournalCategoryTab activeTab;
  final Map<String, Color> categoryColors;
  final Color backgroundColor;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthEndReport;

  @override
  State<JournalCalendar> createState() => _JournalCalendarState();
}

class _JournalCalendarState extends State<JournalCalendar> {
  late DateTime _focusedDay;
  late final PageController _pageController;

  static final DateTime _firstDay = DateTime(2020, 1, 1);
  static final DateTime _lastDay = DateTime(2035, 12, 31);
  static const int _weekRows = 6;
  static const Duration _pageAnimationDuration =
      Duration(milliseconds: 300);
  static const List<String> _weekdayLabels = [
    '일',
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
  ];

  @override
  void initState() {
    super.initState();
    _focusedDay = _dateOnly(widget.selectedDay);
    _pageController = PageController(initialPage: _monthPageIndex(_focusedDay));
  }

  @override
  void didUpdateWidget(JournalCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(oldWidget.selectedDay, widget.selectedDay)) {
      _focusedDay = _dateOnly(widget.selectedDay);
      final page = _monthPageIndex(_focusedDay);
      if (_pageController.hasClients && _pageController.page?.round() != page) {
        _pageController.jumpToPage(page);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime day) => DateTime(day.year, day.month, day.day);

  int _monthPageIndex(DateTime month) {
    return (month.year - _firstDay.year) * 12 + month.month - _firstDay.month;
  }

  int get _monthPageCount => _monthPageIndex(_lastDay) + 1;

  DateTime _monthForPageIndex(int index) {
    return DateTime(_firstDay.year, _firstDay.month + index);
  }

  List<DateTime> _visibleDaysForMonth(DateTime month) {
    final first = DateTime(month.year, month.month);
    final daysBefore = first.weekday % 7;
    final firstToDisplay = first.subtract(Duration(days: daysBefore));
    return List.generate(
      _weekRows * 7,
      (index) => DateTime(
        firstToDisplay.year,
        firstToDisplay.month,
        firstToDisplay.day + index,
      ),
    );
  }

  bool _isLastDayOfMonth(DateTime day) {
    final last = DateTime(day.year, day.month + 1, 0).day;
    return day.day == last;
  }

  List<TaskSlot> _tasksForDay(DateTime day) {
    return widget.taskStore[dateKey(day)] ?? [];
  }

  List<TaskSlot> _visibleTasksForDay(DateTime day) {
    final tasks = _tasksForDay(day);
    if (widget.activeTab.isOverview) {
      return tasks.where((task) => task.label.trim().isNotEmpty).toList();
    }
    return tasks
        .where(
          (task) =>
              task.category == widget.activeTab.title &&
              task.label.trim().isNotEmpty,
        )
        .toList();
  }

  void _handleDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(widget.selectedDay, selectedDay)) {
      widget.onDaySelected(_dateOnly(selectedDay));
    }
    setState(() => _focusedDay = _dateOnly(focusedDay));
  }

  void _goToPreviousMonth() {
    _pageController.previousPage(
      duration: _pageAnimationDuration,
      curve: Curves.easeOut,
    );
  }

  void _goToNextMonth() {
    _pageController.nextPage(
      duration: _pageAnimationDuration,
      curve: Curves.easeOut,
    );
  }

  Widget _buildMonthHeader() {
    final title = DateFormat.yMMMM('ko_KR').format(_focusedDay);

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: CategoryTheme.calendarMonthTitleText),
          tooltip: '이전 달',
          onPressed: _goToPreviousMonth,
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: CategoryTheme.calendarMonthTitleText,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: CategoryTheme.calendarMonthTitleText),
          tooltip: '다음 달',
          onPressed: _goToNextMonth,
        ),
      ],
    );
  }

  Widget _buildDaysOfWeekRow() {
    const labelStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: CategoryTheme.calendarWeekdayText,
    );

    return Row(
      children: [
        for (final label in _weekdayLabels)
          Expanded(
            child: Center(
              child: Text(label, style: labelStyle),
            ),
          ),
      ],
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
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: borderColor, width: borderWidth),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day, {
    required bool isSelected,
    required bool isToday,
  }) {
    final entry = getCompletionEntryForDate(widget.completionRates, day);
    final visibleTasks = _visibleTasksForDay(day);
    final isLastDay = _isLastDayOfMonth(day);

    final textStyle = TextStyle(
      color: CategoryTheme.calendarDateText.withValues(
        alpha: isSelected || isToday ? 1 : 0.92,
      ),
      fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.w400,
      fontSize: 13,
    );

    return Semantics(
      label: buildCalendarDateAriaLabel(day, entry),
      selected: isSelected,
      button: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox.expand(
          child: Container(
            margin: const EdgeInsets.fromLTRB(0.5, 0.5, 0.5, 0),
            decoration: _cellDecoration(
              isSelected: isSelected,
              isToday: isToday,
            ),
            padding: const EdgeInsets.all(8),
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
                        onTap: () => widget.onMonthEndReport(
                          DateTime(day.year, day.month, 1),
                        ),
                        child: Icon(
                          Icons.assessment_outlined,
                          size: 11,
                          color: CategoryTheme.calendarDateText.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ],
                ),
                if (widget.activeTab.isOverview)
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
                            color: CategoryTheme.calendarDateText.withValues(alpha: 0.88),
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                    ],
                  )
                else if (entry != null)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: CompletionMarker(
                      rate: entry.rate,
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

  Widget _buildGridCell(DateTime day, DateTime monthPage) {
    final isOutside = day.month != monthPage.month;
    if (isOutside) {
      return SizedBox.expand(
        child: ColoredBox(
          color: Colors.white.withValues(alpha: 0.04),
        ),
      );
    }

    final isSelected = isSameDay(widget.selectedDay, day);
    final isToday = isSameDay(DateTime.now(), day);

    return SizedBox.expand(
      child: GestureDetector(
        onTap: () => _handleDaySelected(day, monthPage),
        child: _buildDayCell(
          context,
          day,
          isSelected: isSelected,
          isToday: isToday,
        ),
      ),
    );
  }

  Widget _buildDateGrid(DateTime month, {Key? key}) {
    final days = _visibleDaysForMonth(month);

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var week = 0; week < _weekRows; week++)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var day = 0; day < 7; day++)
                  Expanded(
                    child: _buildGridCell(days[week * 7 + day], month),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kCalendarBottomMarginPx),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMonthHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _buildDaysOfWeekRow(),
                  ),
                  Expanded(
                    child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(
                            () => _focusedDay =
                                _dateOnly(_monthForPageIndex(index)),
                          );
                        },
                        itemCount: _monthPageCount,
                        itemBuilder: (context, index) {
                          final month = _monthForPageIndex(index);
                          final isFocusedPage =
                              index == _monthPageIndex(_focusedDay);

                          return _buildDateGrid(
                            month,
                            key: isFocusedPage
                                ? const Key('journal-calendar-grid')
                                : null,
                          );
                        },
                      ),
                    ),
                ],
              ),
          );
        },
      ),
    );
  }
}
