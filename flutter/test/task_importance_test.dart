import 'package:acrosstool_journal/models/task_importance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('slider maps left to right as normal urgent important', () {
    expect(TaskImportance.normal.sliderIndex, 0);
    expect(TaskImportance.urgent.sliderIndex, 1);
    expect(TaskImportance.important.sliderIndex, 2);

    expect(TaskImportance.fromSliderIndex(0), TaskImportance.normal);
    expect(TaskImportance.fromSliderIndex(1), TaskImportance.urgent);
    expect(TaskImportance.fromSliderIndex(2), TaskImportance.important);
  });

  test('fill factor grows with slider position', () {
    expect(TaskImportance.normal.fillFactor, closeTo(1 / 3, 0.001));
    expect(TaskImportance.urgent.fillFactor, closeTo(2 / 3, 0.001));
    expect(TaskImportance.important.fillFactor, closeTo(1.0, 0.001));
  });
}
