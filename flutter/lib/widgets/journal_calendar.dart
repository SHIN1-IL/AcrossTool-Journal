import 'package:flutter/material.dart';

import '../models/completion_rate.dart';
import '../models/journal_category_tab.dart';
import '../repositories/task_repository.dart';
import '../utils/calendar_date_utils.dart';
import '../utils/calendar_font_settings.dart';
import '../utils/category_theme.dart';
import 'calendar_chrome_overlay.dart';
import 'calendar_date_grid.dart';
import 'calendar_day_cell.dart';

/// 전체 화면 달력 — 월 페이징과 날짜 그리드를 조합합니다.
class JournalCalendar extends StatefulWidget {
  const JournalCalendar({
    super.key,
    required this.selectedDay,
    required this.completionRates,
    required this.taskStore,
    required this.activeTab,
    required this.categoryTabs,
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
    this.taskFontPt = CalendarFontSettings.defaultPtSize,
    this.topContentInset = 0,
  });

  final DateTime selectedDay;
  final CompletionRateMap completionRates;
  final TaskStoreData taskStore;
  final JournalCategoryTab activeTab;
  final List<JournalCategoryTab> categoryTabs;
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
  final int taskFontPt;
  /// 카테고리 탭 바 높이 — 그리드 시작 위치 계산에 사용.
  final double topContentInset;

  @override
  State<JournalCalendar> createState() => _JournalCalendarState();
}

class _JournalCalendarState extends State<JournalCalendar> {
  late DateTime _focusedDay;
  late final PageController _pageController;

  static const Duration _pageAnimationDuration =
      Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _focusedDay = CalendarDateUtils.dateOnly(widget.selectedDay);
    _pageController = PageController(
      initialPage: CalendarDateUtils.monthPageIndex(_focusedDay),
    );
  }

  @override
  void didUpdateWidget(JournalCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!CalendarDateUtils.isSameDay(oldWidget.selectedDay, widget.selectedDay)) {
      _focusedDay = CalendarDateUtils.dateOnly(widget.selectedDay);
      final page = CalendarDateUtils.monthPageIndex(_focusedDay);
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

  void _handleDaySelected(DateTime day) {
    widget.onDaySelected(CalendarDateUtils.dateOnly(day));
    setState(() => _focusedDay = CalendarDateUtils.dateOnly(day));
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

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CategoryTheme.appBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.topContentInset > 0)
                SizedBox(height: widget.topContentInset),
              CalendarChromeOverlay(
                focusedMonth: _focusedDay,
                onPreviousMonth: _goToPreviousMonth,
                onNextMonth: _goToNextMonth,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(
                      () => _focusedDay = CalendarDateUtils.dateOnly(
                        CalendarDateUtils.monthForPageIndex(index),
                      ),
                    );
                  },
                  itemCount: CalendarDateUtils.monthPageCount,
                  itemBuilder: (context, index) {
                    final month = CalendarDateUtils.monthForPageIndex(index);
                    final isFocusedPage =
                        index == CalendarDateUtils.monthPageIndex(_focusedDay);

                    return SizedBox.expand(
                      child: CalendarDateGrid(
                        gridKey: isFocusedPage
                            ? const Key('journal-calendar-grid')
                            : null,
                        month: month,
                        selectedDay: widget.selectedDay,
                        activeTab: widget.activeTab,
                        categoryTabs: widget.categoryTabs,
                        taskFontPt: widget.taskFontPt,
                        completionRates: widget.completionRates,
                        taskStore: widget.taskStore,
                        onDaySelected: _handleDaySelected,
                        onMonthEndReport: widget.onMonthEndReport,
                        onEnsureCategoryTask: widget.onEnsureCategoryTask,
                        onCategoryTaskToggle: widget.onCategoryTaskToggle,
                        onCategoryTaskHeaderChanged:
                            widget.onCategoryTaskHeaderChanged,
                        onCategoryTaskLabelChanged:
                            widget.onCategoryTaskLabelChanged,
                        onCategoryTaskNotesChanged:
                            widget.onCategoryTaskNotesChanged,
                        onCategoryTaskImportanceChanged:
                            widget.onCategoryTaskImportanceChanged,
                        onCategoryTaskUsageHoursChanged:
                            widget.onCategoryTaskUsageHoursChanged,
                        categoryInlineEdit: widget.categoryInlineEdit,
                      ),
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
