import 'package:flutter/material.dart';

import '../models/task_slot.dart';
import '../repositories/task_repository.dart';

/// PRD 메인 화면 진입점. 600px 브레이크포인트로 PC/모바일 레이아웃을 분기합니다.
class AcrossToolMainScreen extends StatefulWidget {
  const AcrossToolMainScreen({
    super.key,
    required this.taskRepository,
  });

  final TaskRepository taskRepository;

  @override
  State<AcrossToolMainScreen> createState() => _AcrossToolMainScreenState();
}

class _AcrossToolMainScreenState extends State<AcrossToolMainScreen> {
  DateTime _selectedDay = DateTime.now();
  List<TaskSlot> _tasks = TaskSlot.emptySlots();
  bool _isLoading = true;
  int _loadGeneration = 0;

  static const double _wideBreakpoint = 600;

  @override
  void initState() {
    super.initState();
    _loadTasksForSelectedDay();
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
              tasks: _tasks,
              isLoading: _isLoading,
              onToggle: _onToggleTask,
              onLabelChanged: _onLabelChanged,
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
            icon: const Icon(Icons.filter_list_alt),
            tooltip: '카테고리 필터',
            onPressed: () {
              // TODO: CategoryFilterMenu (단계 6 이후 구현)
            },
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
                  child: _CalendarPlaceholder(
                    selectedDay: _selectedDay,
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
                      tasks: _tasks,
                      isLoading: _isLoading,
                      onToggle: _onToggleTask,
                      onLabelChanged: _onLabelChanged,
                    ),
                  ),
                ),
              ],
            );
          }

          return _CalendarPlaceholder(
            selectedDay: _selectedDay,
            onDaySelected: _onDaySelected,
          );
        },
      ),
    );
  }
}

class _CalendarPlaceholder extends StatelessWidget {
  const _CalendarPlaceholder({
    required this.selectedDay,
    required this.onDaySelected,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${selectedDay.year}년 ${selectedDay.month}월',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          const Text('달력 위젯 (table_calendar 연동 예정)'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => onDaySelected(DateTime.now()),
            child: const Text('오늘 선택'),
          ),
        ],
      ),
    );
  }
}

class _TimelineContent extends StatelessWidget {
  const _TimelineContent({
    required this.selectedDay,
    required this.tasks,
    required this.isLoading,
    required this.onToggle,
    required this.onLabelChanged,
  });

  final DateTime selectedDay;
  final List<TaskSlot> tasks;
  final bool isLoading;
  final ValueChanged<int> onToggle;
  final void Function(int taskId, String label) onLabelChanged;

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
          const Text('오늘 일과 5줄'),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _TaskRow(
                        key: ValueKey(task.id),
                        task: task,
                        onToggle: onToggle,
                        onLabelChanged: onLabelChanged,
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
    required this.onToggle,
    required this.onLabelChanged,
  });

  final TaskSlot task;
  final ValueChanged<int> onToggle;
  final void Function(int taskId, String label) onLabelChanged;

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
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: '일과 ${widget.task.id}',
              isDense: true,
              border: const OutlineInputBorder(),
            ),
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
