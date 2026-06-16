import 'package:acrosstool_journal/models/completion_rate.dart';
import 'package:acrosstool_journal/models/journal_category_tab.dart';
import 'package:acrosstool_journal/repositories/task_repository.dart';
import 'package:acrosstool_journal/widgets/completion_marker.dart';
import 'package:acrosstool_journal/widgets/journal_calendar.dart';
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
  }) {
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
                    onDaySelected: onDaySelected,
                    onMonthEndReport: onMonthEndReport ?? (_) {},
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

  testWidgets('JournalCalendar shows completion marker for dated entry',
      (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        selectedDay: DateTime(2026, 6, 11),
        activeTab: const JournalCategoryTab(
          id: 'cat-1',
          title: '운동',
          colorValue: 0xFFEC407A,
        ),
        completionRates: {
          '2026-06-11': const CompletionDayEntry(rate: 50),
        },
        onDaySelected: (_) {},
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CompletionMarker), findsWidgets);
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
    expect(gridBox.size.height, greaterThan(700));
  });
}
