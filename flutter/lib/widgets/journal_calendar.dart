import 'package:flutter/material.dart';

import '../models/completion_rate.dart';
import '../models/journal_category_tab.dart';
import '../repositories/task_repository.dart';
import '../utils/calendar_date_utils.dart';
import 'calendar_chrome_overlay.dart';
import 'calendar_date_grid.dart';

/// 전체 화면 달력 — 월 페이징과 날짜 그리드를 조합합니다.
class JournalCalendar extends StatefulWidget {
  const JournalCalendar({
    super.key,
    required this.selectedDay,
    required this.completionRates,
    required this.taskStore,
    required this.activeTab,
    required this.onDaySelected,
    required this.onMonthEndReport,
    this.topContentInset = 0,
  });

  final DateTime selectedDay;
  final CompletionRateMap completionRates;
  final TaskStoreData taskStore;
  final JournalCategoryTab activeTab;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthEndReport;
  /// 카테고리 헤더 오버레이 아래로 그리드 영역을 내릴 때 사용.
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
    if (!CalendarDateUtils.isSameDay(widget.selectedDay, day)) {
      widget.onDaySelected(CalendarDateUtils.dateOnly(day));
    }
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.topContentInset > 0)
                SizedBox(height: widget.topContentInset),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
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
                        final month =
                            CalendarDateUtils.monthForPageIndex(index);
                        final isFocusedPage =
                            index == CalendarDateUtils.monthPageIndex(_focusedDay);

                        return CalendarDateGrid(
                          gridKey: isFocusedPage
                              ? const Key('journal-calendar-grid')
                              : null,
                          month: month,
                          selectedDay: widget.selectedDay,
                          activeTab: widget.activeTab,
                          completionRates: widget.completionRates,
                          taskStore: widget.taskStore,
                          onDaySelected: _handleDaySelected,
                          onMonthEndReport: widget.onMonthEndReport,
                        );
                      },
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: CalendarChromeOverlay(
                        focusedMonth: _focusedDay,
                        onPreviousMonth: _goToPreviousMonth,
                        onNextMonth: _goToNextMonth,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
