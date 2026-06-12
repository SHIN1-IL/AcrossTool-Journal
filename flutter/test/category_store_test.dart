import 'package:acrosstool_journal/models/category_store.dart';
import 'package:acrosstool_journal/models/task_slot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildFilterOptions includes built-in and custom categories', () {
    expect(
      CategoryStore.buildFilterOptions(['취미', '운동']),
      ['전체', '운동', '학습', '업무', '루틴', '취미'],
    );
  });

  test('addUserCategory accepts unique custom names', () {
    final result = CategoryStore.addUserCategory([], '취미');
    expect(result?.categories, ['취미']);
    expect(result?.added, '취미');
  });

  test('addUserCategory rejects duplicates and built-ins', () {
    expect(CategoryStore.addUserCategory([], '운동'), isNull);
    expect(CategoryStore.addUserCategory(['취미'], '취미'), isNull);
    expect(CategoryStore.addUserCategory([], '  '), isNull);
  });

  test('normalizeCategoryName trims and rejects invalid names', () {
    expect(CategoryStore.normalizeCategoryName('  취미  '), '취미');
    expect(CategoryStore.normalizeCategoryName('전체'), isNull);
  });

  test('removeUserCategory and sanitizeSelectedFilter work', () {
    expect(
      CategoryStore.removeUserCategory(['취미', '여행'], '취미'),
      ['여행'],
    );
    expect(
      CategoryStore.sanitizeSelectedFilter('삭제됨', ['전체', '운동']),
      CategoryStore.filterAll,
    );
  });

  test('filterTasksByCategory filters labeled tasks only', () {
    const tasks = [
      TaskSlot(id: 1, label: '운동', completed: false, category: '운동'),
      TaskSlot(id: 2, label: '', completed: false, category: '운동'),
      TaskSlot(id: 3, label: '학습', completed: false, category: '학습'),
    ];

    expect(
      CategoryStore.filterTasksByCategory(tasks, '운동').map((t) => t.id),
      [1],
    );
    expect(
      CategoryStore.filterTasksByCategory(tasks, CategoryStore.filterAll),
      tasks,
    );
  });
}
