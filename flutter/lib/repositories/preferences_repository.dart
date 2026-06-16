import 'package:hive_flutter/hive_flutter.dart';

import '../models/category_store.dart';
import '../models/category_tab_store.dart';
import '../models/journal_category_tab.dart';

/// Hive 기반 사용자 카테고리·필터 설정. 웹 `preferencesStorage.ts` 대응.
class PreferencesRepository {
  PreferencesRepository(this._box);

  static const boxName = 'preferences';
  static const userCategoriesKey = 'userCategories';
  static const selectedFilterKey = 'selectedFilter';
  static const categoryTabsKey = 'categoryTabs';
  static const selectedTabIdKey = 'selectedTabId';

  final Box<dynamic> _box;

  static Future<PreferencesRepository> create() async {
    final box = await Hive.openBox(boxName);
    return PreferencesRepository(box);
  }

  static Future<PreferencesRepository> open() async {
    final box = await Hive.openBox(boxName);
    return PreferencesRepository(box);
  }

  List<String> loadUserCategories() {
    final value = _box.get(userCategoriesKey);
    if (value is! List) {
      return [];
    }
    return value.whereType<String>().toList();
  }

  Future<void> saveUserCategories(List<String> categories) async {
    await _box.put(userCategoriesKey, categories);
  }

  String loadSelectedFilter() {
    final value = _box.get(selectedFilterKey);
    return value is String ? value : CategoryStore.filterAll;
  }

  Future<void> saveSelectedFilter(String filter) async {
    await _box.put(selectedFilterKey, filter);
  }

  List<JournalCategoryTab> loadCategoryTabs() {
    final value = _box.get(categoryTabsKey);
    if (value is! List) {
      return CategoryTabStore.defaultTabs();
    }

    try {
      final tabs = value
          .whereType<Map>()
          .map(
            (item) => JournalCategoryTab.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      return CategoryTabStore.normalizeTabs(tabs);
    } catch (_) {
      return CategoryTabStore.defaultTabs();
    }
  }

  Future<void> saveCategoryTabs(List<JournalCategoryTab> tabs) async {
    await _box.put(
      categoryTabsKey,
      tabs.map((tab) => tab.toJson()).toList(),
    );
    final titles = tabs
        .where((tab) => !tab.isOverview)
        .map((tab) => tab.title)
        .toList();
    await saveUserCategories(titles);
  }

  String loadSelectedTabId() {
    final value = _box.get(selectedTabIdKey);
    return value is String ? value : JournalCategoryTab.overviewId;
  }

  Future<void> saveSelectedTabId(String tabId) async {
    await _box.put(selectedTabIdKey, tabId);
    final tabs = loadCategoryTabs();
    final tab = CategoryTabStore.findById(tabs, tabId);
    if (tab != null && !tab.isOverview && !tab.isAnalytics) {
      await saveSelectedFilter(tab.title);
    } else {
      await saveSelectedFilter(CategoryStore.filterAll);
    }
  }

  Future<void> hydrateDefaults(List<String> filterOptions) async {
    final sanitized = CategoryStore.sanitizeSelectedFilter(
      loadSelectedFilter(),
      filterOptions,
    );
    if (sanitized != loadSelectedFilter()) {
      await saveSelectedFilter(sanitized);
    }
  }
}
