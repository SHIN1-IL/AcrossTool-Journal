import 'package:acrosstool_journal/utils/date_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dateKey formats as YYYY-MM-DD', () {
    expect(dateKey(DateTime(2026, 6, 11)), '2026-06-11');
    expect(dateKey(DateTime(2026, 1, 5)), '2026-01-05');
  });
}
