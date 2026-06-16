import 'package:acrosstool_journal/models/category_tab_store.dart';
import 'package:acrosstool_journal/models/journal_category_tab.dart';
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

  test('addBatchTabs adds up to 5 tabs until max 11', () {
    final batch = CategoryTabStore.addBatchTabs(CategoryTabStore.defaultTabs());
    expect(batch, isNotNull);
    expect(batch, hasLength(11));
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
}
