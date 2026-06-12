import 'dart:io';

import 'package:acrosstool_journal/models/task_slot.dart';
import 'package:acrosstool_journal/repositories/task_repository.dart';
import 'package:acrosstool_journal/utils/date_key.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late TaskRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_task_test');
    repository = await TaskRepository.createForTest(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('loadStore returns sample tasks for today on first run', () {
    final store = repository.loadStore();
    final todayKey = dateKey(DateTime.now());

    expect(store.containsKey(todayKey), isTrue);
    expect(store[todayKey], hasLength(TaskSlot.maxSlots));
    expect(store[todayKey]!.first.label, '아침 스트레칭');
    expect(store[todayKey]!.first.completed, isTrue);
  });

  test('ensureTasksForDate creates empty slots for new date', () async {
    final newDate = DateTime(2026, 1, 15);
    final tasks = await repository.ensureTasksForDate(newDate);

    expect(tasks, hasLength(TaskSlot.maxSlots));
    expect(tasks.every((task) => task.label.isEmpty), isTrue);

    final reloaded = repository.getTasksForDate(newDate);
    expect(reloaded, hasLength(TaskSlot.maxSlots));
  });

  test('toggleTask flips completed flag and persists', () async {
    final today = DateTime.now();
    await repository.ensureTasksForDate(today);

    final before = repository.getTasksForDate(today).first.completed;
    final updated = await repository.toggleTask(today, 1);

    expect(updated.first.completed, !before);
    expect(repository.getTasksForDate(today).first.completed, !before);
  });

  test('updateTaskLabel saves label and persists', () async {
    final today = DateTime.now();
    await repository.ensureTasksForDate(today);

    final updated = await repository.updateTaskLabel(today, 2, '새 일과');
    expect(updated[1].label, '새 일과');
    expect(repository.getTasksForDate(today)[1].label, '새 일과');
  });

  test('clearCategoryFromAllTasks removes category from every date', () async {
    final today = DateTime.now();
    await repository.ensureTasksForDate(today);

    await repository.clearCategoryFromAllTasks('운동');

    final tasks = repository.getTasksForDate(today);
    expect(tasks.where((task) => task.category == '운동'), isEmpty);
    expect(tasks[0].category, isNull);
  });

  test('updateTaskCategory saves category', () async {
    final today = DateTime.now();
    await repository.ensureTasksForDate(today);

    final updated = await repository.updateTaskCategory(today, 3, '취미');
    expect(updated[2].category, '취미');
    expect(repository.getTasksForDate(today)[2].category, '취미');
  });
}
