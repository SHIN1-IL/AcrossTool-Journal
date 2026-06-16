import 'package:acrosstool_journal/utils/time_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compareTimeStrings sorts chronologically', () {
    expect(compareTimeStrings('09:00', '10:30'), lessThan(0));
    expect(compareTimeStrings('10:30', '09:00'), greaterThan(0));
  });

  test('suggestNextTime increments from latest entry', () {
    expect(
      suggestNextTime(const ['09:00', '11:30']),
      '12:30',
    );
  });

  test('isValidTimeString validates HH:mm', () {
    expect(isValidTimeString('09:30'), isTrue);
    expect(isValidTimeString('25:00'), isFalse);
    expect(isValidTimeString('abc'), isFalse);
  });
}
