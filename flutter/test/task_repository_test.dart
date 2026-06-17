import 'dart:io';

import 'package:acrosstool_journal/models/task_importance.dart';
import 'package:acrosstool_journal/models/task_slot.dart';
import 'package:acrosstool_journal/repositories/task_repository.dart';
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

  test('loadStore returns empty store on first run', () {
    expect(repository.loadStore(), isEmpty);
  });

  test('ensureTasksForDate creates empty list for new date', () async {
    final newDate = DateTime(2026, 1, 15);
    final tasks = await repository.ensureTasksForDate(newDate);

    expect(tasks, isEmpty);

    final reloaded = repository.getTasksForDate(newDate);
    expect(reloaded, isEmpty);
  });

  test('addTask appends time-based entry for category', () async {
    final date = DateTime(2026, 3, 1);
    await repository.ensureTasksForDate(date);

    final tasks = await repository.addTask(
      date,
      category: '운동',
      label: '런닝',
    );

    expect(tasks, hasLength(1));
    expect(tasks.first.label, '런닝');
    expect(tasks.first.category, '운동');
    expect(tasks.first.time, isNotNull);
  });

  test('removeTask deletes entry by id', () async {
    final date = DateTime(2026, 3, 2);
    final added = await repository.addTask(date, category: '학습');
    final taskId = added.first.id;

    final updated = await repository.removeTask(date, taskId);
    expect(updated, isEmpty);
  });

  test('clearAllTasks removes every saved entry', () async {
    final date = DateTime(2026, 5, 1);
    await repository.addTask(date, category: '운동', label: '연습');

    await repository.clearAllTasks();

    expect(repository.loadStore(), isEmpty);
  });

  test('ensureSingleCategoryTask creates one task per category per day', () async {
    final date = DateTime(2026, 4, 1);
    final id = await repository.ensureSingleCategoryTask(date, '운동');

    final tasks = repository.getTasksForDate(date);
    expect(tasks, hasLength(1));
    expect(tasks.first.id, id);
    expect(tasks.first.category, '운동');

    final sameId = await repository.ensureSingleCategoryTask(date, '운동');
    expect(sameId, id);
    expect(repository.getTasksForDate(date), hasLength(1));
  });

  test('toggleTask flips completed flag and persists', () async {
    final date = DateTime(2026, 3, 3);
    final added = await repository.addTask(date, category: '운동', label: '런닝');
    final taskId = added.first.id;

    final updated = await repository.toggleTask(date, taskId);

    expect(updated.first.completed, isTrue);
    expect(repository.getTasksForDate(date).first.completed, isTrue);
  });

  test('updateTaskLabel saves label and persists', () async {
    final date = DateTime(2026, 3, 4);
    await repository.addTask(date, category: '학습', label: '기존');
    await repository.addTask(date, category: '학습', label: '변경 대상');
    final taskId = repository.getTasksForDate(date)[1].id;

    final updated = await repository.updateTaskLabel(date, taskId, '새 일과');
    expect(updated[1].label, '새 일과');
    expect(repository.getTasksForDate(date)[1].label, '새 일과');
  });

  test('clearCategoryFromAllTasks removes category from every date', () async {
    final date = DateTime(2026, 3, 5);
    await repository.addTask(date, category: '운동', label: '런닝');
    await repository.addTask(date, category: '학습', label: '독서');

    await repository.clearCategoryFromAllTasks('운동');

    final tasks = repository.getTasksForDate(date);
    expect(tasks.where((task) => task.category == '운동'), isEmpty);
    expect(
      tasks.firstWhere((task) => task.label == '독서').category,
      '학습',
    );
  });

  test('updateTaskCategory saves category', () async {
    final date = DateTime(2026, 3, 6);
    await repository.addTask(date, category: '업무', label: '회의');
    await repository.addTask(date, category: '업무', label: '메일');
    await repository.addTask(date, category: '업무', label: '변경 대상');
    final taskId = repository.getTasksForDate(date)[2].id;

    final updated = await repository.updateTaskCategory(date, taskId, '취미');
    expect(updated[2].category, '취미');
    expect(repository.getTasksForDate(date)[2].category, '취미');
  });

  test('addTask respects max slots per category', () async {
    final date = DateTime(2026, 3, 7);
    for (var i = 0; i < TaskSlot.maxSlots; i++) {
      await repository.addTask(date, category: '운동', label: 'task $i');
    }

    final beforeCount = repository.getTasksForDate(date).length;
    await repository.addTask(date, category: '운동', label: 'overflow');
    final afterCount = repository.getTasksForDate(date).length;

    expect(beforeCount, TaskSlot.maxSlots);
    expect(afterCount, TaskSlot.maxSlots);
  });

  test('persists extended task fields', () async {
    final date = DateTime(2026, 3, 8);
    final added = await repository.addTask(date, category: '학습', label: '수학');
    final taskId = added.first.id;

    await repository.updateTaskHeader(date, taskId, '오늘 목표');
    await repository.updateTaskImportance(
      date,
      taskId,
      TaskImportance.urgent,
    );
    await repository.updateTaskUsageHours(date, taskId, 3);
    await repository.updateTaskNotes(date, taskId, '3단원 복습');

    final task = repository.getTasksForDate(date).first;
    expect(task.header, '오늘 목표');
    expect(task.importance, TaskImportance.urgent);
    expect(task.usageHours, 3);
    expect(task.notes, '3단원 복습');
  });
}
