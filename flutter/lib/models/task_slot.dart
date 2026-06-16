class TaskSlot {
  const TaskSlot({
    required this.id,
    required this.label,
    required this.completed,
    this.category,
    this.time,
  });

  final int id;
  final String label;
  final bool completed;
  final String? category;
  final String? time;

  static const int maxSlots = 5;

  factory TaskSlot.fromJson(Map<String, dynamic> json) {
    return TaskSlot(
      id: json['id'] as int,
      label: json['label'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      category: json['category'] as String?,
      time: json['time'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'completed': completed,
      if (category != null) 'category': category,
      if (time != null) 'time': time,
    };
  }

  TaskSlot copyWith({
    int? id,
    String? label,
    bool? completed,
    String? category,
    String? time,
    bool clearCategory = false,
    bool clearTime = false,
  }) {
    return TaskSlot(
      id: id ?? this.id,
      label: label ?? this.label,
      completed: completed ?? this.completed,
      category: clearCategory ? null : (category ?? this.category),
      time: clearTime ? null : (time ?? this.time),
    );
  }

  static List<TaskSlot> emptySlots() {
    return List.generate(
      maxSlots,
      (index) => TaskSlot(id: index + 1, label: '', completed: false),
    );
  }
}
