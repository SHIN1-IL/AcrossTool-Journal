import '../models/task_importance.dart';
import '../models/task_slot.dart';

/// 상위 2개 중요 항목 완료 시 80% — 1개 완료 40%, 0개 0%.
int? calculateTopTwoImportanceProgress(List<TaskSlot> tasks) {
  final active = tasks.where((task) => task.hasContent).toList();
  if (active.isEmpty) {
    return null;
  }

  final sorted = List<TaskSlot>.from(active)
    ..sort((a, b) {
      final importance =
          TaskImportance.compare(b.importance, a.importance);
      if (importance != 0) {
        return importance;
      }
      return a.id.compareTo(b.id);
    });

  final topTwo = sorted.take(2).toList();
  final completed = topTwo.where((task) => task.completed).length;
  if (topTwo.length == 1) {
    return completed == 1 ? 80 : 0;
  }
  return ((completed / topTwo.length) * 80).round();
}

/// 해당 날짜 총 사용 시간(0~12h) / 최대 12h 비율 — 보조 시각화용.
int? calculateUsageHoursProgress(List<TaskSlot> tasks) {
  final active = tasks.where((task) => task.hasContent).toList();
  if (active.isEmpty) {
    return null;
  }
  final totalHours = active.fold<int>(0, (sum, task) => sum + task.usageHours);
  return ((totalHours / 12) * 100).clamp(0, 100).round();
}
