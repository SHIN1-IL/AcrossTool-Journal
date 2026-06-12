import 'package:flutter/material.dart';

import '../models/category_store.dart';
import '../models/completion_rate.dart';
import '../models/task_slot.dart';
import '../repositories/preferences_repository.dart';
import '../repositories/task_repository.dart';
import '../services/journal_data_service.dart';
import '../widgets/category_filter_menu.dart';
import '../widgets/category_select.dart';
import '../widgets/journal_calendar.dart';
import '../widgets/journal_data_dialog.dart';

/// PRD 메인 화면 진입점. 600px 브레이크포인트로 PC/모바일 레이아웃을 분기합니다.
class AcrossToolMainScreen extends StatefulWidget {
  const AcrossToolMainScreen({
    super.key,
    required this.taskRepository,
    required this.preferencesRepository,
  });

  final TaskRepository taskRepository;
  final PreferencesRepository preferencesRepository;

  @override
  State<AcrossToolMainScreen> createState() => _AcrossToolMainScreenState();
}

class _AcrossToolMainScreenState extends State<AcrossToolMainScreen> {
  DateTime _selectedDay = DateTime.now();
  List<TaskSlot> _tasks = TaskSlot.emptySlots();
  List<String> _userCategories = [];
  String _selectedFilter = CategoryStore.filterAll;
  bool _isLoading = true;
  int _loadGeneration = 0;
  late final JournalDataService _journalDataService;

  static const double _wideBreakpoint = 600;

  List<String> get _filterOptions =>
      CategoryStore.buildFilterOptions(_userCategories);

  List<String> get _assignableCategories =>
      CategoryStore.buildAssignableCategories(_userCategories);

  List<TaskSlot> get _displayTasks =>
      CategoryStore.filterTasksByCategory(_tasks, _selectedFilter);

  String? get _filterLabel =>
      _selectedFilter == CategoryStore.filterAll ? null : _selectedFilter;

  CompletionRateMap get _completionRates => buildCompletionRateMap(
        widget.taskRepository.loadStore(),
        _selectedFilter,
      );

  @override
  void initState() {
    super.initState();
    _journalDataService = JournalDataService(
      taskRepository: widget.taskRepository,
      preferencesRepository: widget.preferencesRepository,
    );
    _loadPreferences();
    _loadTasksForSelectedDay();
  }

  void _loadPreferences() {
    final userCategories = widget.preferencesRepository.loadUserCategories();
    final filterOptions = CategoryStore.buildFilterOptions(userCategories);
    final selectedFilter = CategoryStore.sanitizeSelectedFilter(
      widget.preferencesRepository.loadSelectedFilter(),
      filterOptions,
    );

    setState(() {
      _userCategories = userCategories;
      _selectedFilter = selectedFilter;
    });
  }

  Future<void> _loadTasksForSelectedDay() async {
    final generation = ++_loadGeneration;
    final tasks = await widget.taskRepository.ensureTasksForDate(_selectedDay);
    if (!mounted || generation != _loadGeneration) {
      return;
    }
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _onDaySelected(DateTime day) async {
    setState(() {
      _selectedDay = day;
      _isLoading = true;
    });
    _loadGeneration++;
    await _loadTasksForSelectedDay();

    if (!mounted) {
      return;
    }

    final width = MediaQuery.sizeOf(context).width;
    if (width < _wideBreakpoint) {
      _showMobileBottomSheet();
    }
  }

  Future<void> _onToggleTask(int taskId) async {
    _loadGeneration++;
    final tasks = await widget.taskRepository.toggleTask(_selectedDay, taskId);
    if (!mounted) {
      return;
    }
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _onLabelChanged(int taskId, String label) async {
    _loadGeneration++;
    final tasks = await widget.taskRepository.updateTaskLabel(
      _selectedDay,
      taskId,
      label,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _onCategoryChanged(int taskId, String? category) async {
    _loadGeneration++;
    final tasks = await widget.taskRepository.updateTaskCategory(
      _selectedDay,
      taskId,
      category,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _onSelectFilter(String category) async {
    setState(() => _selectedFilter = category);
    await widget.preferencesRepository.saveSelectedFilter(category);
  }

  Future<void> _onAddCategory(String name) async {
    final result = CategoryStore.addUserCategory(_userCategories, name);
    if (result == null) {
      return;
    }

    setState(() => _userCategories = result.categories);
    await widget.preferencesRepository.saveUserCategories(result.categories);
  }

  Future<void> _onRemoveCategory(String name) async {
    final updatedCategories =
        CategoryStore.removeUserCategory(_userCategories, name);
    final nextFilter =
        _selectedFilter == name ? CategoryStore.filterAll : _selectedFilter;

    await widget.taskRepository.clearCategoryFromAllTasks(name);
    await widget.preferencesRepository.saveUserCategories(updatedCategories);
    await widget.preferencesRepository.saveSelectedFilter(nextFilter);

    if (!mounted) {
      return;
    }

    setState(() {
      _userCategories = updatedCategories;
      _selectedFilter = nextFilter;
    });
    await _loadTasksForSelectedDay();
  }

  void _showDataTransferDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return JournalDataDialog(
          service: _journalDataService,
          onImported: () async {
            _loadPreferences();
            _loadGeneration++;
            await _loadTasksForSelectedDay();
          },
        );
      },
    );
  }

  void _showCategoryFilterMenu() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black26,
      builder: (dialogContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                behavior: HitTestBehavior.opaque,
              ),
            ),
            Positioned(
              top: kToolbarHeight + 8,
              right: 16,
              child: CategoryFilterMenu(
                filterOptions: _filterOptions,
                selectedCategory: _selectedFilter,
                onSelect: _onSelectFilter,
                onAddCategory: _onAddCategory,
                onRemoveCategory: _onRemoveCategory,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMobileBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _TimelineContent(
              selectedDay: _selectedDay,
              tasks: _displayTasks,
              assignableCategories: _assignableCategories,
              filterLabel: _filterLabel,
              isLoading: _isLoading,
              onToggle: _onToggleTask,
              onLabelChanged: _onLabelChanged,
              onCategoryChanged: _onCategoryChanged,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AcrossTool Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_alt),
            tooltip: '데이터 가져오기 /보내기',
            onPressed: _showDataTransferDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_alt),
            tooltip: '카테고리 필터',
            onPressed: _showCategoryFilterMenu,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _wideBreakpoint;

          if (isWide) {
            return Row(
              children: [
                Expanded(
                  flex: 6,
                  child: JournalCalendar(
                    selectedDay: _selectedDay,
                    completionRates: _completionRates,
                    onDaySelected: _onDaySelected,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 4,
                  child: ColoredBox(
                    color: Colors.grey.shade50,
                    child: _TimelineContent(
                      selectedDay: _selectedDay,
                      tasks: _displayTasks,
                      assignableCategories: _assignableCategories,
                      filterLabel: _filterLabel,
                      isLoading: _isLoading,
                      onToggle: _onToggleTask,
                      onLabelChanged: _onLabelChanged,
                      onCategoryChanged: _onCategoryChanged,
                    ),
                  ),
                ),
              ],
            );
          }

          return JournalCalendar(
            selectedDay: _selectedDay,
            completionRates: _completionRates,
            onDaySelected: _onDaySelected,
          );
        },
      ),
    );
  }
}

class _TimelineContent extends StatelessWidget {
  const _TimelineContent({
    required this.selectedDay,
    required this.tasks,
    required this.assignableCategories,
    required this.filterLabel,
    required this.isLoading,
    required this.onToggle,
    required this.onLabelChanged,
    required this.onCategoryChanged,
  });

  final DateTime selectedDay;
  final List<TaskSlot> tasks;
  final List<String> assignableCategories;
  final String? filterLabel;
  final bool isLoading;
  final ValueChanged<int> onToggle;
  final void Function(int taskId, String label) onLabelChanged;
  final void Function(int taskId, String? category) onCategoryChanged;

  String get _subtitle {
    if (filterLabel != null) {
      return '$filterLabel 일과 ${tasks.length}줄';
    }
    return '오늘 일과 5줄';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${selectedDay.month}월 ${selectedDay.day}일',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(_subtitle),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                    ? Center(
                        child: Text(
                          '선택한 카테고리에 해당하는 일과가 없습니다.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _TaskRow(
                            key: ValueKey(task.id),
                            task: task,
                            assignableCategories: assignableCategories,
                            onToggle: onToggle,
                            onLabelChanged: onLabelChanged,
                            onCategoryChanged: onCategoryChanged,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatefulWidget {
  const _TaskRow({
    super.key,
    required this.task,
    required this.assignableCategories,
    required this.onToggle,
    required this.onLabelChanged,
    required this.onCategoryChanged,
  });

  final TaskSlot task;
  final List<String> assignableCategories;
  final ValueChanged<int> onToggle;
  final void Function(int taskId, String label) onLabelChanged;
  final void Function(int taskId, String? category) onCategoryChanged;

  @override
  State<_TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<_TaskRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.label);
  }

  @override
  void didUpdateWidget(_TaskRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.label != _controller.text) {
      _controller.text = widget.task.label;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commitLabel() {
    if (_controller.text == widget.task.label) {
      return;
    }
    widget.onLabelChanged(widget.task.id, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          key: Key('task_checkbox_${widget.task.id}'),
          value: widget.task.completed,
          onChanged: (_) => widget.onToggle(widget.task.id),
        ),
        CategorySelect(
          value: widget.task.category,
          categories: widget.assignableCategories,
          semanticLabel: '일과 ${widget.task.id} 카테고리',
          onChanged: (category) =>
              widget.onCategoryChanged(widget.task.id, category),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: '일과 ${widget.task.id}',
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            style: widget.task.completed
                ? TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey.shade500,
                  )
                : null,
            onSubmitted: (_) => _commitLabel(),
            onEditingComplete: _commitLabel,
            onTapOutside: (_) {
              _commitLabel();
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
        ),
      ],
    );
  }
}
