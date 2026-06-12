import 'package:acrosstool_journal/widgets/journal_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

  Widget buildTestApp({
    required DateTime selectedDay,
    required ValueChanged<DateTime> onDaySelected,
  }) {
    return MaterialApp(
      locale: const Locale('ko', 'KR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      home: Scaffold(
        body: JournalCalendar(
          selectedDay: selectedDay,
          onDaySelected: onDaySelected,
        ),
      ),
    );
  }

  testWidgets('JournalCalendar renders TableCalendar with Korean weekdays',
      (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        selectedDay: DateTime(2026, 6, 11),
        onDaySelected: (_) {},
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(TableCalendar<void>), findsOneWidget);
    expect(find.text('일'), findsOneWidget);
    expect(find.text('월'), findsOneWidget);
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
}
