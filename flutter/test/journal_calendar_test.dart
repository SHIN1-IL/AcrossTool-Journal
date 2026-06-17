import 'package:acrosstool_journal/models/category_tab_store.dart';
import 'package:acrosstool_journal/models/completion_rate.dart';
import 'package:acrosstool_journal/models/journal_category_tab.dart';
import 'package:acrosstool_journal/models/task_importance.dart';
import 'package:acrosstool_journal/models/task_slot.dart';
import 'package:acrosstool_journal/repositories/task_repository.dart';
import 'package:acrosstool_journal/widgets/calendar_chrome_overlay.dart';
import 'package:acrosstool_journal/widgets/calendar_day_progress_bar.dart';
import 'package:acrosstool_journal/widgets/category_day_inline_entry.dart';
import 'package:acrosstool_journal/widgets/category_day_preview_cell.dart';
import 'package:acrosstool_journal/widgets/journal_calendar.dart';
import 'package:acrosstool_journal/widgets/task_entry_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

  Widget buildTestApp({
    required DateTime selectedDay,
    CompletionRateMap completionRates = const {},
    TaskStoreData taskStore = const {},
    JournalCategoryTab activeTab = const JournalCategoryTab(
      id: JournalCategoryTab.overviewId,
      title: JournalCategoryTab.overviewTitle,
      colorValue: 0xFF5C6BC0,
      isOverview: true,
    ),
    required ValueChanged<DateTime> onDaySelected,
    ValueChanged<DateTime>? onMonthEndReport,
    bool categoryInlineEdit = true,
  }) {
    Future<int> ensureCategoryTask(DateTime day, String category) async => 1;
    Future<void> noopDayTask(DateTime day, int taskId) async {}
    Future<void> noopString(
      DateTime day,
      int taskId,
      String value,
    ) async {}
    Future<void> noopImportance(
      DateTime day,
      int taskId,
      TaskImportance value,
    ) async {}
    Future<void> noopHours(DateTime day, int taskId, int value) async {}

    return MaterialApp(
      locale: const Locale('ko', 'KR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      home: MediaQuery(
        data: const MediaQueryData(size: Size(900, 900)),
        child: Scaffold(
          body: SizedBox(
            height: 900,
            child: Column(
              children: [
                Expanded(
                  child: JournalCalendar(
                    selectedDay: selectedDay,
                    completionRates: completionRates,
                    taskStore: taskStore,
                    activeTab: activeTab,
                    categoryTabs: CategoryTabStore.defaultTabs(),
                    onDaySelected: onDaySelected,
                    onMonthEndReport: onMonthEndReport ?? (_) {},
                    onEnsureCategoryTask: ensureCategoryTask,
                    onCategoryTaskToggle: noopDayTask,
                    onCategoryTaskHeaderChanged: noopString,
                    onCategoryTaskLabelChanged: noopString,
                    onCategoryTaskNotesChanged: noopString,
                    onCategoryTaskImportanceChanged: noopImportance,
                    onCategoryTaskUsageHoursChanged: noopHours,
                    categoryInlineEdit: categoryInlineEdit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('JournalCalendar renders grid with Korean weekdays', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        selectedDay: DateTime(2026, 6, 11),
        onDaySelected: (_) {},
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('journal-calendar-grid')), findsOneWidget);
    expect(find.text('일'), findsOneWidget);
    expect(find.text('월'), findsOneWidget);
  });

  testWidgets('category tab shows importance bar below header line', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        selectedDay: DateTime(2026, 6, 11),
        activeTab: const JournalCategoryTab(
          id: 'cat-1',
          title: '운동',
          colorValue: 0xFFEC407A,
        ),
        taskStore: {
          '2026-06-11': const [
            TaskSlot(
              id: 1,
              label: '러닝',
              completed: true,
              category: '운동',
              importance: TaskImportance.urgent,
            ),
          ],
        },
        onDaySelected: (_) {},
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ImportancePastelBar), findsWidgets);

    final dayCell = find.byKey(
      const ValueKey('2026-06-11T00:00:00.000-운동'),
    );
    expect(dayCell, findsOneWidget);

    final headerField = find.descendant(
      of: dayCell,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.hintText == '할일:',
      ),
    );
    final importanceBar = find.descendant(
      of: dayCell,
      matching: find.byType(ImportancePastelBar),
    );

    final headerRect = tester.getRect(headerField);
    final barRect = tester.getRect(importanceBar);

    expect(barRect.top, greaterThan(headerRect.bottom));
  });

  testWidgets('overview tab shows top progress bar with percent label',
      (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        selectedDay: DateTime(2026, 6, 11),
        taskStore: {
          '2026-06-11': const [
            TaskSlot(
              id: 1,
              label: '러닝',
              completed: true,
              category: '운동',
              importance: TaskImportance.urgent,
            ),
            TaskSlot(
              id: 2,
              label: '독서',
              completed: true,
              category: '학습',
              importance: TaskImportance.important,
            ),
          ],
        },
        onDaySelected: (_) {},
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('80%'), findsWidgets);
  });

  testWidgets('overview tab shows strikethrough for completed tasks', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        selectedDay: DateTime(2026, 6, 11),
        taskStore: {
          '2026-06-11': const [
            TaskSlot(
              id: 1,
              label: '완료됨',
              completed: true,
              category: '운동',
              header: '아침 운동',
            ),
          ],
        },
        onDaySelected: (_) {},
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final text = tester.widget<Text>(find.text('아침 운동'));
    expect(text.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('overview tab shows cross-category read-only rows without editors',
      (tester) async {
    DateTime? tappedDay;

    await tester.pumpWidget(
      buildTestApp(
        selectedDay: DateTime(2026, 6, 11),
        taskStore: {
          '2026-06-11': const [
            TaskSlot(
              id: 1,
              label: '러닝',
              completed: true,
              category: '운동',
              importance: TaskImportance.urgent,
            ),
            TaskSlot(
              id: 2,
              label: '독서',
              completed: false,
              category: '학습',
              importance: TaskImportance.important,
            ),
          ],
        },
        onDaySelected: (day) => tappedDay = day,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CategoryDayInlineEntry), findsNothing);
    expect(find.text('러닝'), findsOneWidget);
    expect(find.text('독서'), findsOneWidget);
    expect(find.text('운동'), findsOneWidget);
    expect(find.text('학습'), findsOneWidget);

    await tester.tap(find.text('러닝'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tappedDay, isNull);

    await tester.tap(find.text('11'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tappedDay, DateTime(2026, 6, 11));
  });

  testWidgets('category tab embeds inline entry without bottom sheet tap',
      (tester) async {
    DateTime? tappedDay;

    await tester.pumpWidget(
      buildTestApp(
        selectedDay: DateTime(2026, 6, 11),
        activeTab: const JournalCategoryTab(
          id: 'cat-1',
          title: '운동',
          colorValue: 0xFFEC407A,
        ),
        taskStore: {
          '2026-06-11': const [
            TaskSlot(
              id: 1,
              label: '러닝',
              completed: false,
              category: '운동',
              header: '아침 러닝',
              importance: TaskImportance.urgent,
              usageHours: 2,
            ),
          ],
        },
        onDaySelected: (day) => tappedDay = day,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CategoryDayInlineEntry), findsWidgets);
    expect(find.text('아침 러닝'), findsOneWidget);
    expect(find.text('짧은 제목'), findsWidgets);
    expect(find.text('본문'), findsWidgets);

    await tester.tap(find.text('아침 러닝'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tappedDay, isNull);
  });

  testWidgets('category tab uses preview cell when bottom sheet mode',
      (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        selectedDay: DateTime(2026, 6, 11),
        categoryInlineEdit: false,
        activeTab: const JournalCategoryTab(
          id: 'cat-1',
          title: '운동',
          colorValue: 0xFFEC407A,
        ),
        onDaySelected: (_) {},
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CategoryDayPreviewCell), findsWidgets);
    expect(find.byType(CategoryDayInlineEntry), findsNothing);
    expect(find.text('탭하여 입력'), findsWidgets);
  });

  testWidgets('JournalCalendar calls onDaySelected when another day is tapped',
      (tester) async {
    DateTime? tappedDay;

    await tester.pumpWidget(
      buildTestApp(
        selectedDay: DateTime(2026, 6, 11),
        onDaySelected: (day) => tappedDay = day,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('15'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tappedDay, DateTime(2026, 6, 15));
  });

  testWidgets('JournalCalendar renders month header and fills parent height',
      (tester) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      buildTestApp(
        selectedDay: DateTime(2026, 6, 11),
        onDaySelected: (_) {},
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.text('2026년 6월'), findsOneWidget);

    final calendarBox =
        tester.renderObject<RenderBox>(find.byType(JournalCalendar));
    expect(calendarBox.size.height, 900);

    final gridBox = tester.renderObject<RenderBox>(
      find.byKey(const Key('journal-calendar-grid')),
    );
    expect(
      gridBox.size.height,
      closeTo(900 - CalendarChromeMetrics.overlayHeight, 5),
    );
  });
}
