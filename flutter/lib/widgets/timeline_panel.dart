import 'package:flutter/material.dart';

import '../models/journal_category_tab.dart';
import '../models/task_importance.dart';
import '../models/task_slot.dart';
import '../utils/time_format.dart';
import 'task_entry_controls.dart';

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
    this.onHeaderChanged,
    this.onLabelChanged,
    this.onTimeChanged,
    this.onImportanceChanged,
    this.onUsageHoursChanged,
    this.onNotesChanged,
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
  final void Function(int taskId, String header)? onHeaderChanged;
  final void Function(int taskId, String label)? onLabelChanged;
  final void Function(int taskId, String time)? onTimeChanged;
  final void Function(int taskId, TaskImportance importance)? onImportanceChanged;
  final void Function(int taskId, int usageHours)? onUsageHoursChanged;
  final void Function(int taskId, String notes)? onNotesChanged;
  final VoidCallback? onAdd;
  final ValueChanged<int>? onRemove;

  List<TaskSlot> get _sortedTasks {
    final copy = List<TaskSlot>.from(tasks);
    copy.sort((a, b) {
      final importance =
          TaskImportance.compare(b.importance, a.importance);
      if (importance != 0) {
        return importance;
      }
      return compareTimeStrings(a.time, b.time);
    });
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
          readOnly ? '기본 · 전체 조회 (읽기 전용)' : '${activeTab.title} · 항목 편집',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : _sortedTasks.isEmpty
                  ? Center(
                      child: readOnly
                          ? Text(
                              '등록된 일과가 없습니다.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            )
                          : TextButton(
                              onPressed: onAdd,
                              child: Text(
                                '일정을 추가해 보세요.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                    )
                  : ListView.separated(
                      itemCount: _sortedTasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                          onHeaderChanged: onHeaderChanged!,
                          onLabelChanged: onLabelChanged!,
                          onTimeChanged: onTimeChanged!,
                          onImportanceChanged: onImportanceChanged!,
                          onUsageHoursChanged: onUsageHoursChanged!,
                          onNotesChanged: onNotesChanged!,
                          onRemove: onRemove,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                task.time ?? '--:--',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
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
              const Spacer(),
              Text(
                task.importance.shortLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          if (task.header.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              task.header,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (task.label.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              task.label,
              style: TextStyle(
                fontSize: 13,
                decoration:
                    task.completed ? TextDecoration.lineThrough : null,
                color: task.completed ? Colors.grey : Colors.black87,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '사용 ${task.usageHours}시간',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          if (task.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              task.notes,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
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
    required this.onHeaderChanged,
    required this.onLabelChanged,
    required this.onTimeChanged,
    required this.onImportanceChanged,
    required this.onUsageHoursChanged,
    required this.onNotesChanged,
    this.onRemove,
  });

  final TaskSlot task;
  final Color accent;
  final ValueChanged<int> onToggle;
  final void Function(int taskId, String header) onHeaderChanged;
  final void Function(int taskId, String label) onLabelChanged;
  final void Function(int taskId, String time) onTimeChanged;
  final void Function(int taskId, TaskImportance importance) onImportanceChanged;
  final void Function(int taskId, int usageHours) onUsageHoursChanged;
  final void Function(int taskId, String notes) onNotesChanged;
  final ValueChanged<int>? onRemove;

  @override
  State<_ScheduleEntryRow> createState() => _ScheduleEntryRowState();
}

class _ScheduleEntryRowState extends State<_ScheduleEntryRow> {
  late final TextEditingController _headerController;
  late final TextEditingController _labelController;
  late final TextEditingController _notesController;
  late final TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _headerController = TextEditingController(text: widget.task.header);
    _labelController = TextEditingController(text: widget.task.label);
    _notesController = TextEditingController(text: widget.task.notes);
    _timeController = TextEditingController(text: widget.task.time ?? '09:00');
  }

  @override
  void didUpdateWidget(_ScheduleEntryRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.header != _headerController.text) {
      _headerController.text = widget.task.header;
    }
    if (widget.task.label != _labelController.text) {
      _labelController.text = widget.task.label;
    }
    if (widget.task.notes != _notesController.text) {
      _notesController.text = widget.task.notes;
    }
    if (widget.task.time != _timeController.text) {
      _timeController.text = widget.task.time ?? '09:00';
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _labelController.dispose();
    _notesController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _commitHeader() {
    if (_headerController.text != widget.task.header) {
      widget.onHeaderChanged(widget.task.id, _headerController.text);
    }
  }

  void _commitLabel() {
    if (_labelController.text != widget.task.label) {
      widget.onLabelChanged(widget.task.id, _labelController.text);
    }
  }

  void _commitNotes() {
    if (_notesController.text != widget.task.notes) {
      widget.onNotesChanged(widget.task.id, _notesController.text);
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
              const Spacer(),
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: widget.task.completed,
                  activeColor: widget.accent,
                  onChanged: (_) => widget.onToggle(widget.task.id),
                ),
              ),
              if (widget.onRemove != null)
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => widget.onRemove!(widget.task.id),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _headerController,
            decoration: const InputDecoration(
              labelText: '할일:',
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            onSubmitted: (_) => _commitHeader(),
            onEditingComplete: _commitHeader,
            onTapOutside: (_) => _commitHeader(),
          ),
          const SizedBox(height: 10),
          TaskImportanceSlider(
            value: widget.task.importance,
            accentColor: widget.accent,
            onChanged: (value) =>
                widget.onImportanceChanged(widget.task.id, value),
          ),
          const SizedBox(height: 10),
          TaskUsageHoursSlider(
            value: widget.task.usageHours,
            accentColor: widget.accent,
            onChanged: (value) =>
                widget.onUsageHoursChanged(widget.task.id, value),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: '짧은 제목 (달력 표시)',
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            onSubmitted: (_) => _commitLabel(),
            onEditingComplete: _commitLabel,
            onTapOutside: (_) => _commitLabel(),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '본문',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(10),
            ),
            onEditingComplete: _commitNotes,
            onTapOutside: (_) => _commitNotes(),
          ),
        ],
      ),
    );
  }
}
