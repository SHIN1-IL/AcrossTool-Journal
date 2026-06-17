/// 할일 중요도 — 긴급(상) > 중요(중) > 일반(하).
enum TaskImportance {
  urgent,
  important,
  normal;

  static const TaskImportance defaultValue = TaskImportance.normal;

  /// 파스텔 막대 — 하(왼쪽).
  static const pastelNormal = 0xFFD6E4F0;
  /// 파스텔 막대 — 중(가운데, 노랑·주황).
  static const pastelImportant = 0xFFFFE082;
  /// 파스텔 막대 — 상(오른쪽, 빨강).
  static const pastelUrgent = 0xFFEF9A9A;

  String get label => switch (this) {
        TaskImportance.urgent => '긴급',
        TaskImportance.important => '중요',
        TaskImportance.normal => '일반',
      };

  /// UI 슬라이더 짧은 라벨 (상/중/하).
  String get shortLabel => switch (this) {
        TaskImportance.urgent => '상',
        TaskImportance.important => '중',
        TaskImportance.normal => '하',
      };

  int get sortWeight => switch (this) {
        TaskImportance.urgent => 3,
        TaskImportance.important => 2,
        TaskImportance.normal => 1,
      };

  static TaskImportance fromJson(dynamic value) {
    if (value is String) {
      return TaskImportance.values.firstWhere(
        (item) => item.name == value,
        orElse: () => defaultValue,
      );
    }
    if (value is int && value >= 0 && value < TaskImportance.values.length) {
      return TaskImportance.values[value];
    }
    return defaultValue;
  }

  String toJson() => name;

  static int compare(TaskImportance a, TaskImportance b) =>
      a.sortWeight.compareTo(b.sortWeight);

  int get sliderIndex => switch (this) {
        TaskImportance.normal => 0,
        TaskImportance.urgent => 1,
        TaskImportance.important => 2,
      };

  /// 슬라이더 왼쪽→오른쪽: 일반 → 긴급 → 중요.
  static TaskImportance fromSliderIndex(int index) => switch (index) {
        0 => TaskImportance.normal,
        1 => TaskImportance.urgent,
        2 => TaskImportance.important,
        _ => TaskImportance.defaultValue,
      };

  /// 연속 막대 채움 비율 (0~1).
  double get fillFactor => (sliderIndex + 1) / 3;
}
