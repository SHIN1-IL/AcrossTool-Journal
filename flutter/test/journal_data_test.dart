import 'package:acrosstool_journal/models/journal_data.dart';
import 'package:acrosstool_journal/models/task_slot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sample = JournalData.fromExport(
    taskStore: {
      '2026-06-11': const [
        TaskSlot(id: 1, label: '운동', completed: true, category: '운동'),
        TaskSlot(id: 2, label: '', completed: false),
        TaskSlot(id: 3, label: '', completed: false),
        TaskSlot(id: 4, label: '', completed: false),
        TaskSlot(id: 5, label: '', completed: false),
      ],
    },
    userCategories: ['취미'],
    selectedFilter: '운동',
  );

  test('serializes schema version 1 payload', () {
    expect(sample.version, JournalData.currentVersion);
    expect(sample.userCategories, ['취미']);
    expect(sample.selectedFilter, '운동');
  });

  test('round-trips through JSON string', () {
    final parsed = JournalData.tryParse(sample.toJsonString());
    expect(parsed?.version, sample.version);
    expect(parsed?.userCategories, sample.userCategories);
    expect(parsed?.selectedFilter, sample.selectedFilter);
    expect(parsed?.taskStore.keys, sample.taskStore.keys);
  });

  test('rejects invalid payloads', () {
    expect(JournalData.tryParse('{'), isNull);
    expect(
      JournalData.isValid({
        'version': 2,
        'taskStore': {},
        'userCategories': [],
        'selectedFilter': '전체',
      }),
      isFalse,
    );
    expect(
      JournalData.isValid({
        'version': 1,
        'taskStore': {'2026-06-11': []},
        'userCategories': [],
        'selectedFilter': '전체',
      }),
      isTrue,
    );
  });
}
