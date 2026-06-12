/// 웹 MVP `taskStore.ts`의 `dateKey`와 동일한 `YYYY-MM-DD` 형식.
String dateKey(DateTime date) {
  final year = date.year;
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
