import 'dart:io';

import 'package:acrosstool_journal/repositories/preferences_repository.dart';
import 'package:acrosstool_journal/repositories/task_repository.dart';
import 'package:acrosstool_journal/screens/acrosstool_main_screen.dart';
import 'package:acrosstool_journal/widgets/category_tab_bar.dart';
import 'package:acrosstool_journal/widgets/journal_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late Directory tempDir;
  late TaskRepository taskRepository;
  late PreferencesRepository preferencesRepository;

  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_widget_test');
    taskRepository = await TaskRepository.createForTest(tempDir.path);
    preferencesRepository = await PreferencesRepository.open();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget buildApp(Widget home) {
    return MaterialApp(
      locale: const Locale('ko', 'KR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      home: home,
    );
  }

  AcrossToolMainScreen buildScreen() {
    return AcrossToolMainScreen(
      taskRepository: taskRepository,
      preferencesRepository: preferencesRepository,
    );
  }

  testWidgets('AcrossToolMainScreen renders data sync control', (tester) async {
    await tester.pumpWidget(buildApp(buildScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.sync_alt), findsOneWidget);
    expect(find.byType(AcrossToolMainScreen), findsOneWidget);
  });

  testWidgets('Layout shows category tabs and full-width calendar', (tester) async {
    await tester.pumpWidget(
      buildApp(
        MediaQuery(
          data: const MediaQueryData(size: Size(900, 900)),
          child: buildScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CategoryTabBar), findsOneWidget);
    expect(find.byKey(const Key('journal-calendar-grid')), findsOneWidget);
    expect(find.text('기본'), findsOneWidget);
    expect(find.textContaining('1.'), findsWidgets);
    expect(find.byType(VerticalDivider), findsNothing);
    expect(find.text('오늘 일과 5줄'), findsNothing);
  });

  testWidgets('Calendar grid fills viewport to bottom edge', (tester) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      buildApp(
        MediaQuery(
          data: const MediaQueryData(size: Size(900, 900)),
          child: buildScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);

    final calendarBox =
        tester.renderObject<RenderBox>(find.byType(JournalCalendar));
    final gridBox = tester.renderObject<RenderBox>(
      find.byKey(const Key('journal-calendar-grid')),
    );
    final scaffoldBox =
        tester.renderObject<RenderBox>(find.byType(Scaffold));

    final gridBottom =
        gridBox.localToGlobal(Offset(0, gridBox.size.height)).dy;
    final screenBottom =
        scaffoldBox.localToGlobal(Offset(0, scaffoldBox.size.height)).dy;

    expect(screenBottom - gridBottom, closeTo(0, 4));
    expect(
      calendarBox.size.height,
      closeTo(900, 5),
    );
    expect(
      gridBox.size.height,
      greaterThan(calendarBox.size.height * 0.88),
    );
  });

  testWidgets('Data transfer button opens import export dialog', (tester) async {
    await tester.pumpWidget(
      buildApp(
        MediaQuery(
          data: const MediaQueryData(size: Size(900, 900)),
          child: buildScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.sync_alt));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('데이터 가져오기 /보내기'), findsOneWidget);
    expect(find.text('클립보드 복사'), findsOneWidget);
  });

  testWidgets('Analytics tab shows analytics panel', (tester) async {
    await tester.pumpWidget(
      buildApp(
        MediaQuery(
          data: const MediaQueryData(size: Size(900, 900)),
          child: buildScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('category-analytics-tab')), findsOneWidget);

    await tester.tap(find.byKey(const Key('category-analytics-tab')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('analytics-panel-view')), findsOneWidget);
    expect(find.text('실시간 통계'), findsOneWidget);
    expect(find.text('매월 통계 / 분석'), findsOneWidget);
  });

  testWidgets('Batch add button adds numbered categories', (tester) async {
    await tester.pumpWidget(
      buildApp(
        MediaQuery(
          data: const MediaQueryData(size: Size(900, 900)),
          child: buildScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final batchAddButton = find.byKey(const Key('category-batch-add'));

    // 1. 위젯이 화면에 완벽히 보일 때까지 스크롤 및 정렬 강제 수행
    await tester.ensureVisible(batchAddButton);
    await tester.pumpAndSettle(); // 렌더링 안정화

    final batchAddIcon = find.descendant(
      of: batchAddButton,
      matching: find.byIcon(Icons.add_rounded),
    );
    await tester.tap(batchAddIcon);
    await tester.pumpAndSettle();

    final tabList = find.descendant(
      of: find.byType(CategoryTabBar),
      matching: find.byType(ListView),
    );
    await tester.drag(tabList, const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.textContaining('6.'), findsWidgets);
  });

  testWidgets('Editable category tabs show edit control and numbered labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        MediaQuery(
          data: const MediaQueryData(size: Size(900, 900)),
          child: buildScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('기본'), findsOneWidget);
    expect(find.text('1. 1'), findsOneWidget);
    expect(
      find.byKey(const Key('category-edit-cat-default-1')),
      findsOneWidget,
    );
  });
}
