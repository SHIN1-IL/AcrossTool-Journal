import '../models/category_store.dart';
import '../models/journal_data.dart';
import '../repositories/preferences_repository.dart';
import '../repositories/task_repository.dart';

/// 웹 MVP `journalData.ts` 대응 — Hive 저장소 ↔ 공유 JSON 변환.
class JournalDataService {
  JournalDataService({
    required this.taskRepository,
    required this.preferencesRepository,
  });

  final TaskRepository taskRepository;
  final PreferencesRepository preferencesRepository;

  JournalData exportData() {
    return JournalData.fromExport(
      taskStore: taskRepository.loadStore(),
      userCategories: preferencesRepository.loadUserCategories(),
      selectedFilter: preferencesRepository.loadSelectedFilter(),
    );
  }

  String exportJson() => exportData().toJsonString();

  Future<void> importData(JournalData data) async {
    final options = CategoryStore.buildFilterOptions(data.userCategories);
    final filter = CategoryStore.sanitizeSelectedFilter(
      data.selectedFilter,
      options,
    );

    await taskRepository.saveStore(data.taskStore);
    await preferencesRepository.saveUserCategories(data.userCategories);
    await preferencesRepository.saveSelectedFilter(filter);
  }

  Future<bool> importJson(String raw) async {
    final parsed = JournalData.tryParse(raw);
    if (parsed == null) {
      return false;
    }
    await importData(parsed);
    return true;
  }
}
