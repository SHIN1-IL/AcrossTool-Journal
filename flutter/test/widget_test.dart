import 'dart:io';

import 'package:acrosstool_journal/repositories/preferences_repository.dart';
import 'package:acrosstool_journal/repositories/task_repository.dart';
import 'package:acrosstool_journal/screens/acrosstool_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

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

  testWidgets('AcrossToolMainScreen renders app bar title', (tester) async {
    await tester.pumpWidget(buildApp(buildScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('AcrossTool Journal'), findsOneWidget);
    expect(find.byType(AcrossToolMainScreen), findsOneWidget);
  });

  testWidgets('Wide layout shows calendar and timeline panels', (tester) async {
    await tester.pumpWidget(
      buildApp(
        MediaQuery(
          data: const MediaQueryData(size: Size(900, 600)),
          child: buildScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(TableCalendar<void>), findsOneWidget);
    expect(find.text('오늘 일과 5줄'), findsOneWidget);
    expect(find.byType(VerticalDivider), findsOneWidget);
    expect(find.text('아침 스트레칭'), findsOneWidget);
  });

  testWidgets('Data transfer button opens import export dialog', (tester) async {
    await tester.pumpWidget(
      buildApp(
        MediaQuery(
          data: const MediaQueryData(size: Size(900, 600)),
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

  testWidgets('Filter button opens category filter menu', (tester) async {
    await tester.pumpWidget(
      buildApp(
        MediaQuery(
          data: const MediaQueryData(size: Size(900, 600)),
          child: buildScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.filter_list_alt));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('카테고리 추가'), findsOneWidget);
    expect(find.text('전체'), findsWidgets);
    expect(find.text('운동'), findsWidgets);
  });
}
