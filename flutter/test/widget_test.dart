import 'dart:io';

import 'package:acrosstool_journal/repositories/task_repository.dart';
import 'package:acrosstool_journal/screens/acrosstool_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late TaskRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_widget_test');
    repository = await TaskRepository.createForTest(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('AcrossToolMainScreen renders app bar title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AcrossToolMainScreen(taskRepository: repository),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('AcrossTool Journal'), findsOneWidget);
    expect(find.byType(AcrossToolMainScreen), findsOneWidget);
  });

  testWidgets('Wide layout shows calendar and timeline panels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(900, 600)),
          child: AcrossToolMainScreen(taskRepository: repository),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('오늘 일과 5줄'), findsOneWidget);
    expect(find.byType(VerticalDivider), findsOneWidget);
    expect(find.text('아침 스트레칭'), findsOneWidget);
  });

}
