import 'dart:convert';

import 'category_store.dart';
import '../repositories/task_repository.dart';
import 'task_slot.dart';

/// 공유 스키마 `docs/schemas/journal-data.schema.json` (version 1).
class JournalData {
  const JournalData({
    required this.version,
    required this.taskStore,
    required this.userCategories,
    required this.selectedFilter,
  });

  static const int currentVersion = 1;
  static final RegExp _dateKeyPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  final int version;
  final TaskStoreData taskStore;
  final List<String> userCategories;
  final String selectedFilter;

  factory JournalData.fromExport({
    required TaskStoreData taskStore,
    required List<String> userCategories,
    required String selectedFilter,
  }) {
    final options = CategoryStore.buildFilterOptions(userCategories);
    return JournalData(
      version: currentVersion,
      taskStore: taskStore,
      userCategories: userCategories,
      selectedFilter: CategoryStore.sanitizeSelectedFilter(
        selectedFilter,
        options,
      ),
    );
  }

  factory JournalData.fromJson(Map<String, dynamic> json) {
    return JournalData(
      version: json['version'] as int,
      taskStore: _parseTaskStore(json['taskStore'] as Map<String, dynamic>? ?? {}),
      userCategories: (json['userCategories'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      selectedFilter: json['selectedFilter'] as String? ?? CategoryStore.filterAll,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'taskStore': taskStore.map(
        (key, tasks) => MapEntry(key, tasks.map((task) => task.toJson()).toList()),
      ),
      'userCategories': userCategories,
      'selectedFilter': selectedFilter,
    };
  }

  String toJsonString({bool pretty = true}) {
    const encoder = JsonEncoder.withIndent('  ');
    return pretty ? encoder.convert(toJson()) : jsonEncode(toJson());
  }

  static JournalData? tryParse(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      final map = Map<String, dynamic>.from(decoded);
      return isValid(map) ? JournalData.fromJson(map) : null;
    } catch (_) {
      return null;
    }
  }

  static bool isValid(Map<String, dynamic> json) {
    if (json['version'] != currentVersion) {
      return false;
    }

    final taskStore = json['taskStore'];
    if (taskStore is! Map) {
      return false;
    }

    for (final entry in taskStore.entries) {
      if (entry.key is! String || !_dateKeyPattern.hasMatch(entry.key as String)) {
        return false;
      }
      if (entry.value is! List) {
        return false;
      }
      for (final slot in entry.value as List) {
        if (slot is! Map || !_isValidTaskSlot(Map<String, dynamic>.from(slot))) {
          return false;
        }
      }
    }

    final userCategories = json['userCategories'];
    if (userCategories is! List ||
        !userCategories.every(
          (category) =>
              category is String &&
              category.trim().isNotEmpty &&
              category.length <= 20,
        )) {
      return false;
    }

    return json['selectedFilter'] is String;
  }

  static bool _isValidTaskSlot(Map<String, dynamic> slot) {
    final id = slot['id'];
    final label = slot['label'];
    final completed = slot['completed'];
    final category = slot['category'];

    final time = slot['time'];

    return id is int &&
        id >= 1 &&
        label is String &&
        completed is bool &&
        (category == null || category is String) &&
        (time == null || time is String);
  }

  static TaskStoreData _parseTaskStore(Map<String, dynamic> raw) {
    final result = <String, List<TaskSlot>>{};
    for (final entry in raw.entries) {
      final value = entry.value;
      if (value is! List) {
        continue;
      }
      result[entry.key] = value
          .whereType<Map>()
          .map((item) => TaskSlot.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return result;
  }
}
