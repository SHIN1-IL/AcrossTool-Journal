import 'task_slot.dart';

/// 웹 MVP `categoryStore.ts`와 동일한 카테고리·필터 로직.
class CategoryStore {
  CategoryStore._();

  static const String filterAll = '전체';
  static const List<String> builtinCategories = ['운동', '학습', '업무', '루틴'];

  static List<String> buildFilterOptions(List<String> userCategories) {
    final custom = userCategories.where(
      (category) =>
          category != filterAll && !builtinCategories.contains(category),
    );
    return [filterAll, ...builtinCategories, ...custom];
  }

  static List<String> buildAssignableCategories(List<String> userCategories) {
    final custom = userCategories.where(
      (category) => !builtinCategories.contains(category),
    );
    return [...builtinCategories, ...custom];
  }

  static String? normalizeCategoryName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == filterAll) {
      return null;
    }
    if (trimmed.length > 20) {
      return null;
    }
    return trimmed;
  }

  static ({List<String> categories, String added})? addUserCategory(
    List<String> userCategories,
    String name,
  ) {
    final normalized = normalizeCategoryName(name);
    if (normalized == null) {
      return null;
    }
    if (builtinCategories.contains(normalized) ||
        userCategories.contains(normalized)) {
      return null;
    }
    return (
      categories: [...userCategories, normalized],
      added: normalized,
    );
  }

  static List<String> removeUserCategory(
    List<String> userCategories,
    String name,
  ) {
    return userCategories.where((category) => category != name).toList();
  }

  static bool isBuiltinCategory(String category) {
    return builtinCategories.contains(category);
  }

  static String sanitizeSelectedFilter(
    String selected,
    List<String> filterOptions,
  ) {
    return filterOptions.contains(selected) ? selected : filterAll;
  }

  static List<TaskSlot> filterTasksByCategory(
    List<TaskSlot> tasks,
    String categoryFilter,
  ) {
    if (categoryFilter == filterAll) {
      return tasks;
    }
    return tasks
        .where(
          (task) =>
              task.category == categoryFilter && task.label.trim().isNotEmpty,
        )
        .toList();
  }
}
