import 'package:hive_flutter/hive_flutter.dart';

import '../models/task_slot.dart';
import '../utils/date_key.dart';

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
    return store[dateKey(date)] ?? TaskSlot.emptySlots();
  }

  Future<List<TaskSlot>> ensureTasksForDate(DateTime date) async {
    final store = loadStore();
    final key = dateKey(date);
    if (store.containsKey(key)) {
      return store[key]!;
    }

    final updated = {...store, key: TaskSlot.emptySlots()};
    await saveStore(updated);
    return updated[key]!;
  }

  Future<List<TaskSlot>> toggleTask(DateTime date, int taskId) async {
    final store = loadStore();
    final key = dateKey(date);
    final tasks = store[key] ?? TaskSlot.emptySlots();

    final updated = {
      ...store,
      key: tasks
          .map(
            (task) => task.id == taskId
                ? task.copyWith(completed: !task.completed)
                : task,
          )
          .toList(),
    };
    await saveStore(updated);
    return updated[key]!;
  }

  Future<List<TaskSlot>> updateTaskLabel(
    DateTime date,
    int taskId,
    String label,
  ) async {
    final store = loadStore();
    final key = dateKey(date);
    final tasks = store[key] ?? TaskSlot.emptySlots();

    final updated = {
      ...store,
      key: tasks
          .map(
            (task) => task.id == taskId ? task.copyWith(label: label) : task,
          )
          .toList(),
    };
    await saveStore(updated);
    return updated[key]!;
  }

  Future<List<TaskSlot>> updateTaskCategory(
    DateTime date,
    int taskId,
    String? category,
  ) async {
    final store = loadStore();
    final key = dateKey(date);
    final tasks = store[key] ?? TaskSlot.emptySlots();

    final updated = {
      ...store,
      key: tasks
          .map(
            (task) => task.id == taskId
                ? task.copyWith(
                    category: category,
                    clearCategory: category == null,
                  )
                : task,
          )
          .toList(),
    };
    await saveStore(updated);
    return updated[key]!;
  }

  static TaskStoreData createInitialTaskStore() {
    return {
      dateKey(DateTime.now()): _sampleTasks(),
    };
  }

  static List<TaskSlot> _sampleTasks() {
    return [
      const TaskSlot(
        id: 1,
        label: '아침 스트레칭',
        completed: true,
        category: '운동',
      ),
      const TaskSlot(
        id: 2,
        label: '영어 단어 30개',
        completed: false,
        category: '학습',
      ),
      const TaskSlot(
        id: 3,
        label: '이메일 확인',
        completed: false,
        category: '업무',
      ),
      const TaskSlot(
        id: 4,
        label: '저녁 산책',
        completed: false,
        category: '운동',
      ),
      const TaskSlot(
        id: 5,
        label: '일기 작성',
        completed: false,
        category: '루틴',
      ),
    ];
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
