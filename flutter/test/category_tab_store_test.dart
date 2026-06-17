import 'package:acrosstool_journal/models/category_tab_store.dart';
import 'package:acrosstool_journal/models/journal_category_tab.dart';
import 'package:acrosstool_journal/models/task_slot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default tabs include overview and 5 numbered tabs', () {
    final tabs = CategoryTabStore.defaultTabs();
    expect(tabs, hasLength(6));
    expect(tabs.first.isOverview, isTrue);
    expect(tabs.first.title, JournalCategoryTab.overviewTitle);
    expect(CategoryTabStore.editableTabs(tabs), hasLength(5));
    expect(CategoryTabStore.displayLabel(tabs[1], tabs), '1. 1');
  });

  test('addBatchTabs adds one tab at a time until max 11', () {
    var tabs = CategoryTabStore.defaultTabs();
    expect(tabs, hasLength(6));

    tabs = CategoryTabStore.addBatchTabs(tabs)!;
    expect(tabs, hasLength(7));

    while (tabs.length < JournalCategoryTab.maxTabs) {
      tabs = CategoryTabStore.addBatchTabs(tabs)!;
    }
    expect(tabs, hasLength(11));
    expect(CategoryTabStore.addBatchTabs(tabs), isNull);
  });

  test('renameTab updates editable tab title', () {
    final tabs = CategoryTabStore.defaultTabs();
    final target = tabs[1];
    final renamed = CategoryTabStore.renameTab(tabs, target.id, '운동');
    expect(renamed, isNotNull);
    expect(renamed!.firstWhere((tab) => tab.id == target.id).title, '운동');
  });

  test('addTab enforces max 11 and reserved titles', () {
    expect(CategoryTabStore.addTab(CategoryTabStore.defaultTabs(), ''), isNull);
    expect(
      CategoryTabStore.addTab(CategoryTabStore.defaultTabs(), '기본'),
      isNull,
    );
  });

  test('removeTab keeps overview tab', () {
    final tabs = CategoryTabStore.defaultTabs();
    final removed = CategoryTabStore.removeTab(tabs, tabs[1].id);
    expect(removed.first.isOverview, isTrue);
    expect(removed, hasLength(5));
  });

  test('findById resolves analytics virtual tab', () {
    final tab = CategoryTabStore.findById(
      CategoryTabStore.defaultTabs(),
      JournalCategoryTab.analyticsId,
    );
    expect(tab?.isAnalytics, isTrue);
  });

  test('filterTasksForTab applies overview and category rules', () {
    const overview = JournalCategoryTab(
      id: JournalCategoryTab.overviewId,
      title: JournalCategoryTab.overviewTitle,
      colorValue: 0xFFFFFFFF,
      isOverview: true,
    );
    const categoryTab = JournalCategoryTab(
      id: 'cat-1',
      title: '운동',
      colorValue: 0xFFEC407A,
    );
    const tasks = [
      TaskSlot(id: 1, label: '런닝', completed: false, category: '운동', time: '09:00'),
      TaskSlot(id: 2, label: '', completed: false, category: '운동', time: '10:00'),
      TaskSlot(id: 3, label: '독서', completed: false, category: '학습', time: '08:00'),
    ];

    expect(
      CategoryTabStore.filterTasksForTab(tasks, overview).map((t) => t.id),
      [1, 3],
    );
    expect(
      CategoryTabStore.filterTasksForTab(tasks, categoryTab).map((t) => t.id),
      [1],
    );
    expect(
      CategoryTabStore.filterTasksForTab(
        tasks,
        categoryTab,
        includeEmptyLabels: true,
      ).map((t) => t.id),
      [1, 2],
    );
    expect(
      CategoryTabStore.filterTasksForTab(
        tasks,
        categoryTab,
        sortByTime: true,
      ).map((t) => t.id),
      [1],
    );
    expect(
      CategoryTabStore.filterTasksForTab(
        tasks,
        JournalCategoryTab.analytics(),
      ),
      isEmpty,
    );
  });
}
