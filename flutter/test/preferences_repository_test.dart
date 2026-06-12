import 'dart:io';

import 'package:acrosstool_journal/models/category_store.dart';
import 'package:acrosstool_journal/repositories/preferences_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late PreferencesRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_prefs_test');
    Hive.init(tempDir.path);
    repository = await PreferencesRepository.open();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('loads defaults when empty', () {
    expect(repository.loadUserCategories(), isEmpty);
    expect(repository.loadSelectedFilter(), CategoryStore.filterAll);
  });

  test('persists user categories and selected filter', () async {
    await repository.saveUserCategories(['취미']);
    await repository.saveSelectedFilter('운동');

    expect(repository.loadUserCategories(), ['취미']);
    expect(repository.loadSelectedFilter(), '운동');
  });
}
