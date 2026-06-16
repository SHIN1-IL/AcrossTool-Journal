/// HH:mm 형식 시간 비교·포맷 유틸.
int compareTimeStrings(String? a, String? b) {
  return _toMinutes(a).compareTo(_toMinutes(b));
}

int _toMinutes(String? time) {
  if (time == null || time.isEmpty) {
    return 24 * 60;
  }
  final parts = time.split(':');
  if (parts.length != 2) {
    return 24 * 60;
  }
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;
  return hour * 60 + minute;
}

String formatMinutes(int minutes) {
  final hour = (minutes ~/ 60) % 24;
  final minute = minutes % 60;
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

String suggestNextTime(Iterable<String?> existingTimes) {
  var maxMinutes = 8 * 60;
  for (final time in existingTimes) {
    final minutes = _toMinutes(time);
    if (minutes < 24 * 60 && minutes >= maxMinutes) {
      maxMinutes = minutes + 60;
    }
  }
  if (maxMinutes >= 24 * 60) {
    maxMinutes = 23 * 60 + 59;
  }
  return formatMinutes(maxMinutes);
}

bool isValidTimeString(String value) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
  if (match == null) {
    return false;
  }
  final hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
}
