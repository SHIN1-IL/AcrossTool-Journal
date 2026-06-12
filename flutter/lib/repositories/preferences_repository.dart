import 'package:hive_flutter/hive_flutter.dart';

import '../models/category_store.dart';

/// Hive 기반 사용자 카테고리·필터 설정. 웹 `preferencesStorage.ts` 대응.
class PreferencesRepository {
  PreferencesRepository(this._box);

  static const boxName = 'preferences';
  static const userCategoriesKey = 'userCategories';
  static const selectedFilterKey = 'selectedFilter';

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
