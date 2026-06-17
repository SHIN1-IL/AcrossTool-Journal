import 'package:hive_flutter/hive_flutter.dart';

import '../models/task_importance.dart';
import '../models/task_slot.dart';
import '../utils/date_key.dart';
import '../utils/time_format.dart';

typedef TaskStoreData = Map<String, List<TaskSlot>>;

/// Hive 기반 일과 저장소. 웹 MVP `taskStore.ts` + `taskStorage.ts`와 동일한 계약.
class TaskRepository {
  TaskRepository(this._box);

  static const boxName = 'taskStore';
  static const dataKey = 'data';

  final Box<dynamic> _box;

  static Future<TaskRepository> create() async {
    await Hive.initFlutter();
    final box = await Hive.openBox(boxName);
    return _open(box);
  }

  /// 테스트용 — 임시 디렉터리에 Hive 초기화.
  static Future<TaskRepository> createForTest(String path) async {
    Hive.init(path);
    final box = await Hive.openBox(boxName);
    return _open(box);
  }

  static Future<TaskRepository> _open(Box<dynamic> box) async {
    final repository = TaskRepository(box);
    if (!_isValidStore(box.get(dataKey))) {
      await repository.saveStore(createInitialTaskStore());
    }
    return repository;
  }

  TaskStoreData loadStore() {
    final raw = _box.get(dataKey);
    if (!_isValidStore(raw)) {
      return createInitialTaskStore();
    }
    return _deserialize(raw as Map);
  }

  Future<void> saveStore(TaskStoreData store) async {
    await _box.put(dataKey, _serialize(store));
  }

  List<TaskSlot> getTasksForDate(DateTime date) {
    final store = loadStore();
    return store[dateKey(date)] ?? [];
  }

  Future<List<TaskSlot>> ensureTasksForDate(DateTime date) async {
    final store = loadStore();
    final key = dateKey(date);
    if (store.containsKey(key)) {
      return store[key]!;
    }

    final updated = {...store, key: <TaskSlot>[]};
    await saveStore(updated);
    return updated[key]!;
  }

  Future<List<TaskSlot>> toggleTask(DateTime date, int taskId) async {
    return _updateTasksForDate(date, (tasks) {
      return tasks
          .map(
            (task) => task.id == taskId
                ? task.copyWith(completed: !task.completed)
                : task,
          )
          .toList();
    });
  }

  Future<List<TaskSlot>> updateTaskLabel(
    DateTime date,
    int taskId,
    String label,
  ) async {
    return _updateTasksForDate(date, (tasks) {
      return tasks
          .map(
            (task) => task.id == taskId ? task.copyWith(label: label) : task,
          )
          .toList();
    });
  }

  Future<List<TaskSlot>> updateTaskTime(
    DateTime date,
    int taskId,
    String time,
  ) async {
    return _updateTasksForDate(date, (tasks) {
      return tasks
          .map(
            (task) => task.id == taskId ? task.copyWith(time: time) : task,
          )
          .toList();
    });
  }

  Future<List<TaskSlot>> updateTaskHeader(
    DateTime date,
    int taskId,
    String header,
  ) async {
    return _updateTaskForField(date, taskId, (task) => task.copyWith(header: header));
  }

  Future<List<TaskSlot>> updateTaskImportance(
    DateTime date,
    int taskId,
    TaskImportance importance,
  ) async {
    return _updateTaskForField(
      date,
      taskId,
      (task) => task.copyWith(importance: importance),
    );
  }

  Future<List<TaskSlot>> updateTaskUsageHours(
    DateTime date,
    int taskId,
    int usageHours,
  ) async {
    return _updateTaskForField(
      date,
      taskId,
      (task) => task.copyWith(
        usageHours: usageHours.clamp(0, TaskSlot.maxUsageHours),
      ),
    );
  }

  Future<List<TaskSlot>> updateTaskNotes(
    DateTime date,
    int taskId,
    String notes,
  ) async {
    return _updateTaskForField(date, taskId, (task) => task.copyWith(notes: notes));
  }

  Future<List<TaskSlot>> _updateTaskForField(
    DateTime date,
    int taskId,
    TaskSlot Function(TaskSlot task) transform,
  ) async {
    return _updateTasksForDate(date, (tasks) {
      return tasks
          .map((task) => task.id == taskId ? transform(task) : task)
          .toList();
    });
  }

  Future<int> ensureSingleCategoryTask(
    DateTime date,
    String category,
  ) async {
    final tasks = await _updateTasksForDate(date, (tasks) {
      final categoryTasks =
          tasks.where((task) => task.category == category).toList();
      if (categoryTasks.isEmpty) {
        final nextId = _nextTaskId(tasks);
        return [
          ...tasks,
          TaskSlot(
            id: nextId,
            label: '',
            completed: false,
            category: category,
            time: '09:00',
          ),
        ];
      }

      if (categoryTasks.length == 1) {
        return tasks;
      }

      final keepId = categoryTasks.first.id;
      return tasks
          .where(
            (task) => task.category != category || task.id == keepId,
          )
          .toList();
    });

    return tasks.firstWhere((task) => task.category == category).id;
  }

  TaskSlot? getSingleCategoryTask(DateTime date, String category) {
    final tasks = getTasksForDate(date)
        .where((task) => task.category == category)
        .toList();
    if (tasks.isEmpty) {
      return null;
    }
    return tasks.first;
  }

  Future<List<TaskSlot>> addTask(
    DateTime date, {
    required String category,
    String? time,
    String label = '',
  }) async {
    return _updateTasksForDate(date, (tasks) {
      final categoryTasks =
          tasks.where((task) => task.category == category).toList();
      if (categoryTasks.length >= TaskSlot.maxSlots) {
        return tasks;
      }
      final nextTime = time ??
          suggestNextTime(categoryTasks.map((task) => task.time));
      final nextId = _nextTaskId(tasks);

      return [
        ...tasks,
        TaskSlot(
          id: nextId,
          label: label,
          completed: false,
          category: category,
          time: nextTime,
        ),
      ];
    });
  }

  Future<List<TaskSlot>> removeTask(DateTime date, int taskId) async {
    return _updateTasksForDate(date, (tasks) {
      return tasks.where((task) => task.id != taskId).toList();
    });
  }

  Future<void> clearCategoryFromAllTasks(String category) async {
    final store = loadStore();
    final updated = store.map(
      (key, tasks) => MapEntry(
        key,
        tasks
            .map(
              (task) => task.category == category
                  ? task.copyWith(clearCategory: true)
                  : task,
            )
            .toList(),
      ),
    );
    await saveStore(updated);
  }

  Future<void> renameCategoryInAllTasks(String from, String to) async {
    final store = loadStore();
    final updated = store.map(
      (key, tasks) => MapEntry(
        key,
        tasks
            .map(
              (task) => task.category == from
                  ? task.copyWith(category: to)
                  : task,
            )
            .toList(),
      ),
    );
    await saveStore(updated);
  }

  Future<List<TaskSlot>> updateTaskCategory(
    DateTime date,
    int taskId,
    String? category,
  ) async {
    return _updateTasksForDate(date, (tasks) {
      return tasks
          .map(
            (task) => task.id == taskId
                ? task.copyWith(
                    category: category,
                    clearCategory: category == null,
                  )
                : task,
          )
          .toList();
    });
  }

  Future<List<TaskSlot>> _updateTasksForDate(
    DateTime date,
    List<TaskSlot> Function(List<TaskSlot> tasks) transform,
  ) async {
    final store = loadStore();
    final key = dateKey(date);
    final tasks = store[key] ?? [];
    final updatedTasks = transform(List<TaskSlot>.from(tasks));
    final updated = {...store, key: updatedTasks};
    await saveStore(updated);
    return updatedTasks;
  }

  static int _nextTaskId(List<TaskSlot> tasks) {
    if (tasks.isEmpty) {
      return 1;
    }
    return tasks.map((task) => task.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  static TaskStoreData createInitialTaskStore() => {};

  Future<void> clearAllTasks() async {
    await saveStore({});
  }

  static bool _isValidStore(dynamic value) {
    return value is Map;
  }

  static Map<String, dynamic> _serialize(TaskStoreData store) {
    return store.map(
      (key, tasks) => MapEntry(key, tasks.map((task) => task.toJson()).toList()),
    );
  }

  static TaskStoreData _deserialize(Map raw) {
    final result = <String, List<TaskSlot>>{};
    for (final entry in raw.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is! String || value is! List) {
        continue;
      }
      result[key] = value
          .whereType<Map>()
          .map((item) => TaskSlot.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return result;
  }
}
