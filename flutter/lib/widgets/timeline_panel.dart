import 'package:flutter/material.dart';

import '../models/journal_category_tab.dart';
import '../models/task_slot.dart';
import '../utils/time_format.dart';

/// 선택한 날짜의 시간대별 일과 패널.
class TimelinePanel extends StatelessWidget {
  const TimelinePanel({
    super.key,
    required this.selectedDay,
    required this.tasks,
    required this.activeTab,
    required this.categoryColors,
    required this.isLoading,
    required this.readOnly,
    this.onToggle,
    this.onLabelChanged,
    this.onTimeChanged,
    this.onAdd,
    this.onRemove,
  });

  final DateTime selectedDay;
  final List<TaskSlot> tasks;
  final JournalCategoryTab activeTab;
  final Map<String, Color> categoryColors;
  final bool isLoading;
  final bool readOnly;
  final ValueChanged<int>? onToggle;
  final void Function(int taskId, String label)? onLabelChanged;
  final void Function(int taskId, String time)? onTimeChanged;
  final VoidCallback? onAdd;
  final ValueChanged<int>? onRemove;

  List<TaskSlot> get _sortedTasks {
    final copy = List<TaskSlot>.from(tasks);
    copy.sort((a, b) => compareTimeStrings(a.time, b.time));
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    final accent = activeTab.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '${selectedDay.month}월 ${selectedDay.day}일',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            if (!readOnly)
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('일정 추가'),
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          readOnly ? '전체 카테고리 일과' : '${activeTab.title} · 시간대별 일정',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : _sortedTasks.isEmpty
                  ? Center(
                      child: Text(
                        readOnly
                            ? '등록된 일과가 없습니다.'
                            : '일정을 추가해 보세요.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _sortedTasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final task = _sortedTasks[index];
                        if (readOnly) {
                          return _ReadOnlyScheduleRow(
                            task: task,
                            color: categoryColors[task.category ?? ''] ??
                                Colors.grey,
                          );
                        }
                        return _ScheduleEntryRow(
                          key: ValueKey(task.id),
                          task: task,
                          accent: accent,
                          onToggle: onToggle!,
                          onLabelChanged: onLabelChanged!,
                          onTimeChanged: onTimeChanged!,
                          onRemove: onRemove!,
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _ReadOnlyScheduleRow extends StatelessWidget {
  const _ReadOnlyScheduleRow({
    required this.task,
    required this.color,
  });

  final TaskSlot task;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              task.time ?? '--:--',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              task.category ?? '기타',
              style: TextStyle(fontSize: 10, color: color),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            task.completed ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.label,
              style: TextStyle(
                fontSize: 13,
                decoration:
                    task.completed ? TextDecoration.lineThrough : null,
                color: task.completed ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleEntryRow extends StatefulWidget {
  const _ScheduleEntryRow({
    super.key,
    required this.task,
    required this.accent,
    required this.onToggle,
    required this.onLabelChanged,
    required this.onTimeChanged,
    required this.onRemove,
  });

  final TaskSlot task;
  final Color accent;
  final ValueChanged<int> onToggle;
  final void Function(int taskId, String label) onLabelChanged;
  final void Function(int taskId, String time) onTimeChanged;
  final ValueChanged<int> onRemove;

  @override
  State<_ScheduleEntryRow> createState() => _ScheduleEntryRowState();
}

class _ScheduleEntryRowState extends State<_ScheduleEntryRow> {
  late final TextEditingController _labelController;
  late final TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.task.label);
    _timeController = TextEditingController(text: widget.task.time ?? '09:00');
  }

  @override
  void didUpdateWidget(_ScheduleEntryRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.label != _labelController.text) {
      _labelController.text = widget.task.label;
    }
    if (widget.task.time != _timeController.text) {
      _timeController.text = widget.task.time ?? '09:00';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _commitLabel() {
    if (_labelController.text != widget.task.label) {
      widget.onLabelChanged(widget.task.id, _labelController.text);
    }
  }

  Future<void> _pickTime() async {
    final parts = (_timeController.text).split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 9,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: widget.accent),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) {
      return;
    }
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    _timeController.text = formatted;
    widget.onTimeChanged(widget.task.id, formatted);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: _pickTime,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: widget.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                _timeController.text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                hintText: '일정 내용',
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              style: widget.task.completed
                  ? TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey.shade500,
                    )
                  : const TextStyle(fontSize: 14),
              onSubmitted: (_) => _commitLabel(),
              onEditingComplete: _commitLabel,
              onTapOutside: (_) => _commitLabel(),
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: widget.task.completed,
              activeColor: widget.accent,
              onChanged: (_) => widget.onToggle(widget.task.id),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => widget.onRemove(widget.task.id),
          ),
        ],
      ),
    );
  }
}
