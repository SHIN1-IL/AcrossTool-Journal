import 'category_store.dart';
import 'task_slot.dart';
import '../repositories/task_repository.dart';
import '../utils/date_key.dart';

enum CompletionTier { zero, low, medium, high }

class CompletionDayEntry {
  const CompletionDayEntry({required this.rate});

  final int rate;
}

typedef CompletionRateMap = Map<String, CompletionDayEntry>;

/// 웹 MVP `completionRate.ts`와 동일한 완료율 계산·티어 로직.
int? calculateCompletionRate(List<TaskSlot> tasks) {
  final activeTasks =
      tasks.where((task) => task.label.trim().isNotEmpty).toList();
  if (activeTasks.isEmpty) {
    return null;
  }

  final completedCount =
      activeTasks.where((task) => task.completed).length;
  return ((completedCount / activeTasks.length) * 100).round();
}

CompletionTier getCompletionTier(int rate) {
  if (rate == 0) {
    return CompletionTier.zero;
  }
  if (rate <= 30) {
    return CompletionTier.low;
  }
  if (rate <= 70) {
    return CompletionTier.medium;
  }
  return CompletionTier.high;
}

String getCompletionTierLabel(int rate) {
  switch (getCompletionTier(rate)) {
    case CompletionTier.zero:
      return '미완료';
    case CompletionTier.low:
      return '낮음';
    case CompletionTier.medium:
      return '보통';
    case CompletionTier.high:
      return '높음';
  }
}

CompletionRateMap buildCompletionRateMap(
  TaskStoreData store, [
  String category = CategoryStore.filterAll,
]) {
  final rates = <String, CompletionDayEntry>{};

  for (final entry in store.entries) {
    final scopedTasks = category == CategoryStore.filterAll
        ? entry.value
        : CategoryStore.filterTasksByCategory(entry.value, category);
    final rate = calculateCompletionRate(scopedTasks);
    if (rate != null) {
      rates[entry.key] = CompletionDayEntry(rate: rate);
    }
  }

  return rates;
}

CompletionDayEntry? getCompletionEntryForDate(
  CompletionRateMap rates,
  DateTime date,
) {
  return rates[dateKey(date)];
}

bool hasCompletionMarker(CompletionRateMap rates, DateTime date) {
  return rates.containsKey(dateKey(date));
}

String buildCalendarDateAriaLabel(
  DateTime date,
  CompletionDayEntry? entry,
) {
  final base = '${date.month}월 ${date.day}일 선택';

  if (entry == null) {
    return '$base, 라벨 있는 일과 없음';
  }

  final tierLabel = getCompletionTierLabel(entry.rate);
  return '$base, 완료율 ${entry.rate}% ($tierLabel)';
}
