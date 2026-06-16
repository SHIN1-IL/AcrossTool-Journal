import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/completion_rate.dart';
import '../repositories/task_repository.dart';
/// 월말 보고서 — 해당 월 완료율·일과 수 요약.
class MonthlyReportDialog extends StatelessWidget {
  const MonthlyReportDialog({
    super.key,
    required this.month,
    required this.taskStore,
  });

  final DateTime month;
  final TaskStoreData taskStore;

  static Future<void> show(
    BuildContext context, {
    required DateTime month,
    required TaskStoreData taskStore,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => MonthlyReportDialog(
        month: month,
        taskStore: taskStore,
      ),
    );
  }

  Map<String, _MonthStats> _buildStats() {
    final prefix = '${month.year}-${month.month.toString().padLeft(2, '0')}-';
    final stats = <String, _MonthStats>{};

    for (final entry in taskStore.entries) {
      if (!entry.key.startsWith(prefix)) {
        continue;
      }

      for (final task in entry.value) {
        if (task.label.trim().isEmpty) {
          continue;
        }

        final key = task.category ?? '미분류';
        final current = stats.putIfAbsent(key, _MonthStats.new);
        current.total += 1;
        if (task.completed) {
          current.completed += 1;
        }
      }
    }

    return stats;
  }

  @override
  Widget build(BuildContext context) {
    final stats = _buildStats();
    final monthLabel = DateFormat.yMMMM('ko_KR').format(month);
    final totalTasks = stats.values.fold<int>(0, (sum, item) => sum + item.total);
    final totalCompleted =
        stats.values.fold<int>(0, (sum, item) => sum + item.completed);
    final overallRate = totalTasks == 0
        ? null
        : ((totalCompleted / totalTasks) * 100).round();

    return AlertDialog(
      title: Text('$monthLabel 월말 보고서'),
      content: SizedBox(
        width: 360,
        child: stats.isEmpty
            ? const Text('이번 달 기록된 일과가 없습니다.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (overallRate != null)
                    Text(
                      '전체 완료율: $overallRate% ($totalCompleted/$totalTasks)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  const SizedBox(height: 12),
                  ...stats.entries.map((entry) {
                    final rate = entry.value.total == 0
                        ? 0
                        : ((entry.value.completed / entry.value.total) * 100)
                            .round();
                    final tier = getCompletionTierLabel(rate);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text(entry.key)),
                          Text('$rate% ($tier)'),
                          const SizedBox(width: 8),
                          Text('${entry.value.completed}/${entry.value.total}'),
                        ],
                      ),
                    );
                  }),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}

class _MonthStats {
  int total = 0;
  int completed = 0;
}
