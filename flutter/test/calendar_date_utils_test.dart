import 'package:acrosstool_journal/utils/calendar_date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('visibleDaysForMonth returns 42 days starting on Sunday column', () {
    final days = CalendarDateUtils.visibleDaysForMonth(DateTime(2026, 6, 1));

    expect(days, hasLength(42));
    expect(days.first.weekday, DateTime.sunday);
    expect(days.any((day) => day.day == 11 && day.month == 6), isTrue);
  });

  test('monthPageIndex round-trips with monthForPageIndex', () {
    final month = DateTime(2026, 6, 1);
    final index = CalendarDateUtils.monthPageIndex(month);
    final restored = CalendarDateUtils.monthForPageIndex(index);

    expect(restored.year, 2026);
    expect(restored.month, 6);
  });

  test('isSameDay compares calendar dates only', () {
    expect(
      CalendarDateUtils.isSameDay(
        DateTime(2026, 6, 11, 8, 30),
        DateTime(2026, 6, 11, 22, 0),
      ),
      isTrue,
    );
    expect(
      CalendarDateUtils.isSameDay(
        DateTime(2026, 6, 11),
        DateTime(2026, 6, 12),
      ),
      isFalse,
    );
  });
}
