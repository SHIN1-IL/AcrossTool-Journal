/// 달력 월 페이징·그리드 날짜 계산 유틸.
abstract final class CalendarDateUtils {
  static final DateTime firstDay = DateTime(2020, 1, 1);
  static final DateTime lastDay = DateTime(2035, 12, 31);
  static const int maxWeekRows = 6;

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

  /// 해당 월을 표시하는 데 필요한 주(행) 수 (4~6).
  static int weekRowCountForMonth(DateTime month) {
    final first = DateTime(month.year, month.month);
    final daysBefore = first.weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return ((daysBefore + daysInMonth) + 6) ~/ 7;
  }

  static List<DateTime> visibleDaysForMonth(DateTime month) {
    final rowCount = weekRowCountForMonth(month);
    final first = DateTime(month.year, month.month);
    final daysBefore = first.weekday % 7;
    final firstToDisplay = first.subtract(Duration(days: daysBefore));
    return List.generate(
      rowCount * 7,
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
