import 'package:flutter/material.dart';

import '../models/task_slot.dart';

/// PRD 메인 화면 진입점. 600px 브레이크포인트로 PC/모바일 레이아웃을 분기합니다.
class AcrossToolMainScreen extends StatefulWidget {
  const AcrossToolMainScreen({super.key});

  @override
  State<AcrossToolMainScreen> createState() => _AcrossToolMainScreenState();
}

class _AcrossToolMainScreenState extends State<AcrossToolMainScreen> {
  DateTime _selectedDay = DateTime.now();
  final List<TaskSlot> _tasks = TaskSlot.emptySlots();

  static const double _wideBreakpoint = 600;

  void _onDaySelected(DateTime day) {
    setState(() => _selectedDay = day);

    final width = MediaQuery.sizeOf(context).width;
    if (width < _wideBreakpoint) {
      _showMobileBottomSheet();
    }
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
              // TODO: CategoryFilterMenu (단계 E 이후 구현)
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
  });

  final DateTime selectedDay;
  final List<TaskSlot> tasks;

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
            child: ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Row(
                  children: [
                    Checkbox(
                      value: task.completed,
                      onChanged: null, // TODO: TaskRepository 연동
                    ),
                    Expanded(
                      child: Text(
                        task.label.isEmpty ? '일과 ${task.id}' : task.label,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
