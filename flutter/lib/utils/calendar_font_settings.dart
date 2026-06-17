/// 달력 할일 글자 크기 — 모든 OS에서 동일한 6단계 pt.
abstract final class CalendarFontSettings {
  static const List<int> availablePtSizes = [4, 6, 8, 10, 12, 14];
  static const int defaultPtSize = 8;

  static int sanitize(int? value) {
    if (value != null && availablePtSizes.contains(value)) {
      return value;
    }
    return defaultPtSize;
  }

  static String label(int pt) => '${pt}pt';
}
