import 'task_importance.dart';

class TaskSlot {
  const TaskSlot({
    required this.id,
    required this.label,
    required this.completed,
    this.category,
    this.time,
    this.header = '',
    this.importance = TaskImportance.defaultValue,
    this.usageHours = 0,
    this.notes = '',
  });

  final int id;
  final String label;
  final bool completed;
  final String? category;
  final String? time;
  final String header;
  final TaskImportance importance;
  final int usageHours;
  final String notes;

  static const int maxSlots = 10;
  static const int maxUsageHours = 12;

  bool get hasContent =>
      header.trim().isNotEmpty ||
      label.trim().isNotEmpty ||
      notes.trim().isNotEmpty;

  String get displayTitle {
    if (header.trim().isNotEmpty) {
      return header.trim();
    }
    return label.trim();
  }

  factory TaskSlot.fromJson(Map<String, dynamic> json) {
    return TaskSlot(
      id: json['id'] as int,
      label: json['label'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      category: json['category'] as String?,
      time: json['time'] as String?,
      header: json['header'] as String? ?? '',
      importance: TaskImportance.fromJson(json['importance']),
      usageHours: _clampUsageHours(json['usageHours']),
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'completed': completed,
      if (category != null) 'category': category,
      if (time != null) 'time': time,
      if (header.isNotEmpty) 'header': header,
      if (importance != TaskImportance.defaultValue)
        'importance': importance.toJson(),
      if (usageHours != 0) 'usageHours': usageHours,
      if (notes.isNotEmpty) 'notes': notes,
    };
  }

  TaskSlot copyWith({
    int? id,
    String? label,
    bool? completed,
    String? category,
    String? time,
    String? header,
    TaskImportance? importance,
    int? usageHours,
    String? notes,
    bool clearCategory = false,
    bool clearTime = false,
  }) {
    return TaskSlot(
      id: id ?? this.id,
      label: label ?? this.label,
      completed: completed ?? this.completed,
      category: clearCategory ? null : (category ?? this.category),
      time: clearTime ? null : (time ?? this.time),
      header: header ?? this.header,
      importance: importance ?? this.importance,
      usageHours: usageHours ?? this.usageHours,
      notes: notes ?? this.notes,
    );
  }

  static List<TaskSlot> emptySlots() {
    return List.generate(
      maxSlots,
      (index) => TaskSlot(id: index + 1, label: '', completed: false),
    );
  }

  static int _clampUsageHours(dynamic value) {
    if (value is! num) {
      return 0;
    }
    return value.round().clamp(0, maxUsageHours);
  }
}
