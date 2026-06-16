/// 달력 월 페이징·그리드 날짜 계산 유틸.
abstract final class CalendarDateUtils {
  static final DateTime firstDay = DateTime(2020, 1, 1);
  static final DateTime lastDay = DateTime(2035, 12, 31);
  static const int weekRows = 6;

  static const List<String> weekdayLabels = [
    '일',
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
  ];

  static DateTime dateOnly(DateTime day) =>
      DateTime(day.year, day.month, day.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static int monthPageIndex(DateTime month) =>
      (month.year - firstDay.year) * 12 + month.month - firstDay.month;

  static int get monthPageCount => monthPageIndex(lastDay) + 1;

  static DateTime monthForPageIndex(int index) =>
      DateTime(firstDay.year, firstDay.month + index);

  static List<DateTime> visibleDaysForMonth(DateTime month) {
    final first = DateTime(month.year, month.month);
    final daysBefore = first.weekday % 7;
    final firstToDisplay = first.subtract(Duration(days: daysBefore));
    return List.generate(
      weekRows * 7,
      (index) => DateTime(
        firstToDisplay.year,
        firstToDisplay.month,
        firstToDisplay.day + index,
      ),
    );
  }

  static bool isLastDayOfMonth(DateTime day) {
    final last = DateTime(day.year, day.month + 1, 0).day;
    return day.day == last;
  }
}
