import 'journal_category_tab.dart';
import 'task_slot.dart';
import '../utils/time_format.dart';

/// 카테고리 탭 추가·색상·개수 제한 로직.
class CategoryTabStore {
  CategoryTabStore._();

  static List<JournalCategoryTab> defaultTabs() {
    return [
      JournalCategoryTab.overview(),
      ...List.generate(
        JournalCategoryTab.initialEditableCount,
        (index) => _numberedTab(index + 1),
      ),
    ];
  }

  static JournalCategoryTab _numberedTab(int number) {
    final paletteIndex = (number - 1) % JournalCategoryTab.pastelPalette.length;
    return JournalCategoryTab(
      id: 'cat-default-$number',
      title: '$number',
      colorValue:
          JournalCategoryTab.pastelPalette[paletteIndex].toARGB32(),
    );
  }

  static List<JournalCategoryTab> editableTabs(
    List<JournalCategoryTab> tabs,
  ) {
    return tabs
        .where((tab) => !tab.isOverview && !tab.isAnalytics)
        .toList();
  }

  static int displayNumber(JournalCategoryTab tab, List<JournalCategoryTab> tabs) {
    if (tab.isOverview || tab.isAnalytics) {
      return 0;
    }
    final index = editableTabs(tabs).indexWhere((item) => item.id == tab.id);
    return index >= 0 ? index + 1 : 0;
  }

  static String displayLabel(JournalCategoryTab tab, List<JournalCategoryTab> tabs) {
    if (tab.isOverview) {
      return tab.title;
    }
    final number = displayNumber(tab, tabs);
    return '$number. ${tab.title}';
  }

  static List<JournalCategoryTab> normalizeTabs(List<JournalCategoryTab> tabs) {
    if (tabs.isEmpty) {
      return defaultTabs();
    }

    final overview = tabs.firstWhere(
      (tab) => tab.isOverview,
      orElse: () => JournalCategoryTab.overview(),
    );

    final others = tabs
        .where((tab) => !tab.isOverview && !tab.isAnalytics)
        .take(JournalCategoryTab.maxTabs - 1)
        .toList();

    if (others.isEmpty) {
      return defaultTabs();
    }

    return [overview, ...others];
  }

  static String? normalizeTitle(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.length > JournalCategoryTab.maxTitleLength) {
      return trimmed.substring(0, JournalCategoryTab.maxTitleLength);
    }
    if (trimmed == JournalCategoryTab.overviewTitle ||
        trimmed == JournalCategoryTab.analyticsTitle) {
      return null;
    }
    return trimmed;
  }

  static ({List<JournalCategoryTab> tabs, JournalCategoryTab added})? addTab(
    List<JournalCategoryTab> tabs,
    String title,
  ) {
    if (tabs.length >= JournalCategoryTab.maxTabs) {
      return null;
    }

    final normalized = normalizeTitle(title);
    if (normalized == null) {
      return null;
    }

    if (tabs.any((tab) => tab.title == normalized)) {
      return null;
    }

    final newTab = _createTab(tabs, normalized);
    return (tabs: [...tabs, newTab], added: newTab);
  }

  static List<JournalCategoryTab>? addBatchTabs(List<JournalCategoryTab> tabs) {
    if (tabs.length >= JournalCategoryTab.maxTabs) {
      return null;
    }

    final remaining = JournalCategoryTab.maxTabs - tabs.length;
    final count = remaining < JournalCategoryTab.batchAddCount
        ? remaining
        : JournalCategoryTab.batchAddCount;

    final updated = [...tabs];
    final startNumber = editableTabs(updated).length + 1;

    for (var offset = 0; offset < count; offset++) {
      final number = startNumber + offset;
      updated.add(_numberedTab(number));
    }

    return updated;
  }

  static List<JournalCategoryTab>? renameTab(
    List<JournalCategoryTab> tabs,
    String tabId,
    String newTitle,
  ) {
    final tab = findById(tabs, tabId);
    if (tab == null || tab.isOverview || tab.isAnalytics) {
      return null;
    }

    final normalized = normalizeTitle(newTitle);
    if (normalized == null) {
      return null;
    }

    if (tabs.any((item) => item.id != tabId && item.title == normalized)) {
      return null;
    }

    return tabs
        .map(
          (item) => item.id == tabId ? item.copyWith(title: normalized) : item,
        )
        .toList();
  }

  static JournalCategoryTab _createTab(
    List<JournalCategoryTab> tabs,
    String title,
  ) {
    final usedColors = tabs.map((tab) => tab.colorValue).toSet();
    final color = JournalCategoryTab.pastelPalette.firstWhere(
      (candidate) => !usedColors.contains(candidate.toARGB32()),
      orElse: () => JournalCategoryTab.pastelPalette[
          tabs.length % JournalCategoryTab.pastelPalette.length],
    );

    return JournalCategoryTab(
      id: 'cat-${DateTime.now().millisecondsSinceEpoch}-${tabs.length}',
      title: title,
      colorValue: color.toARGB32(),
    );
  }

  static List<JournalCategoryTab> removeTab(
    List<JournalCategoryTab> tabs,
    String tabId,
  ) {
    return tabs.where((tab) => tab.id != tabId || tab.isOverview).toList();
  }

  static JournalCategoryTab? findById(
    List<JournalCategoryTab> tabs,
    String id,
  ) {
    if (id == JournalCategoryTab.analyticsId) {
      return JournalCategoryTab.analytics();
    }

    for (final tab in tabs) {
      if (tab.id == id) {
        return tab;
      }
    }
    return null;
  }

  /// 활성 탭 기준으로 일과 목록을 필터링합니다.
  ///
  /// [includeEmptyLabels] — 카테고리 탭에서 라벨 없는 빈 슬롯 포함 여부.
  /// 타임라인 편집 UI는 `true`, 달력 셀 미리보기는 `false`를 사용합니다.
  static List<TaskSlot> filterTasksForTab(
    List<TaskSlot> tasks,
    JournalCategoryTab tab, {
    bool includeEmptyLabels = false,
    bool sortByTime = false,
  }) {
    if (tab.isAnalytics) {
      return const [];
    }

    final Iterable<TaskSlot> filtered;
    if (tab.isOverview) {
      filtered = tasks.where((task) => task.label.trim().isNotEmpty);
    } else {
      final byCategory =
          tasks.where((task) => task.category == tab.title);
      filtered = includeEmptyLabels
          ? byCategory
          : byCategory.where((task) => task.label.trim().isNotEmpty);
    }

    final result = filtered.toList();
    if (sortByTime) {
      result.sort((a, b) => compareTimeStrings(a.time, b.time));
    }
    return result;
  }
}
