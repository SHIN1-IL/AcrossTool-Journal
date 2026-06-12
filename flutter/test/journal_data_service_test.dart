import 'dart:io';

import 'package:acrosstool_journal/repositories/preferences_repository.dart';
import 'package:acrosstool_journal/repositories/task_repository.dart';
import 'package:acrosstool_journal/services/journal_data_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late TaskRepository taskRepository;
  late PreferencesRepository preferencesRepository;
  late JournalDataService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_journal_data_test');
    Hive.init(tempDir.path);
    taskRepository = await TaskRepository.createForTest(tempDir.path);
    preferencesRepository = await PreferencesRepository.open();
    service = JournalDataService(
      taskRepository: taskRepository,
      preferencesRepository: preferencesRepository,
    );
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('exportJson includes task store and preferences', () async {
    await preferencesRepository.saveUserCategories(['취미']);
    await preferencesRepository.saveSelectedFilter('운동');

    final json = service.exportJson();
    expect(json, contains('"version": 1'));
    expect(json, contains('취미'));
    expect(json, contains('아침 스트레칭'));
  });

  test('importJson replaces hive data', () async {
    const payload = '''
{
  "version": 1,
  "taskStore": {
    "2026-01-15": [
      {"id": 1, "label": "새 일과", "completed": true, "category": "취미"},
      {"id": 2, "label": "", "completed": false},
      {"id": 3, "label": "", "completed": false},
      {"id": 4, "label": "", "completed": false},
      {"id": 5, "label": "", "completed": false}
    ]
  },
  "userCategories": ["취미"],
  "selectedFilter": "취미"
}
''';

    final success = await service.importJson(payload);
    expect(success, isTrue);
    expect(preferencesRepository.loadUserCategories(), ['취미']);
    expect(preferencesRepository.loadSelectedFilter(), '취미');
    expect(
      taskRepository.getTasksForDate(DateTime(2026, 1, 15)).first.label,
      '새 일과',
    );
  });

  test('importJson returns false for invalid payload', () async {
    expect(await service.importJson('not-json'), isFalse);
  });
}
