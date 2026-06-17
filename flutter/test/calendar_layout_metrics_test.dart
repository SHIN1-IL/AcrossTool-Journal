import 'package:flutter_test/flutter_test.dart';

import 'package:acrosstool_journal/models/task_importance.dart';
import 'package:acrosstool_journal/models/task_slot.dart';
import 'package:acrosstool_journal/utils/calendar_layout_metrics.dart';
import 'package:acrosstool_journal/utils/task_progress.dart';

void main() {
  test('vertical layout metrics fit 10 rows within cell height', () {
    const cellWidth = 110.0;
    const cellHeight = 142.0;

    final metrics = CalendarLayoutMetrics.forCell(
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      taskFontPt: 10,
      categoryCount: 1,
      isOverview: false,
    );

    final padding = metrics.cellPadding;
    final innerHeight = cellHeight - padding * 2;
    final taskBand = innerHeight -
        CalendarLayoutMetrics.dayProgressBarHeight -
        CalendarLayoutMetrics.dayProgressBarGap;

    expect(
      metrics.totalTaskBlockHeight,
      lessThanOrEqualTo(
        taskBand - CalendarLayoutMetrics.layoutSafetyMargin + 0.5,
      ),
    );
  });

  test('top two importance progress returns 80 when both completed', () {
    const tasks = [
      TaskSlot(
        id: 1,
        label: 'A',
        completed: true,
        importance: TaskImportance.urgent,
      ),
      TaskSlot(
        id: 2,
        label: 'B',
        completed: true,
        importance: TaskImportance.important,
      ),
      TaskSlot(
        id: 3,
        label: 'C',
        completed: false,
        importance: TaskImportance.normal,
      ),
    ];

    expect(calculateTopTwoImportanceProgress(tasks), 80);
  });

  test('top two importance progress returns 40 when one completed', () {
    const tasks = [
      TaskSlot(
        id: 1,
        label: 'A',
        completed: true,
        importance: TaskImportance.urgent,
      ),
      TaskSlot(
        id: 2,
        label: 'B',
        completed: false,
        importance: TaskImportance.important,
      ),
    ];

    expect(calculateTopTwoImportanceProgress(tasks), 40);
  });
}
