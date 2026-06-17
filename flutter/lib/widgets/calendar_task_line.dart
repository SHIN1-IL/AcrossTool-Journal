import 'package:flutter/material.dart';

import '../models/task_importance.dart';
import '../models/task_slot.dart';
import '../utils/calendar_layout_metrics.dart';
import '../utils/category_theme.dart';

typedef CalendarTaskLineCommit = void Function(int? taskId, String label);

/// 달력 셀 안의 할일 1줄 — 체크박스 + 한 줄 텍스트(줄바꿈 없음).
class CalendarTaskLine extends StatefulWidget {
  const CalendarTaskLine({
    super.key,
    required this.task,
    required this.metrics,
    required this.accentColor,
    required this.colorOnly,
    required this.startEditing,
    this.openEditorOnTap = false,
    this.onOpenEditor,
    this.onToggle,
    this.onLabelCommit,
  });

  final TaskSlot? task;
  final CalendarLayoutMetrics metrics;
  final Color accentColor;
  final bool colorOnly;
  final bool startEditing;
  final bool openEditorOnTap;
  final VoidCallback? onOpenEditor;
  final ValueChanged<int>? onToggle;
  final CalendarTaskLineCommit? onLabelCommit;

  @override
  State<CalendarTaskLine> createState() => _CalendarTaskLineState();
}

class _CalendarTaskLineState extends State<CalendarTaskLine> {
  TextEditingController? _controller;
  FocusNode? _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.startEditing) {
      _beginEditing();
    }
  }

  @override
  void didUpdateWidget(CalendarTaskLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startEditing && !_isEditing) {
      _beginEditing();
    } else if (!widget.startEditing && _isEditing) {
      _endEditing(commit: true);
    } else if (_isEditing &&
        widget.task?.label != oldWidget.task?.label &&
        _controller != null &&
        !(_focusNode?.hasFocus ?? false)) {
      _controller!.text = widget.task?.label ?? '';
    }
  }

  @override
  void dispose() {
    _focusNode?.removeListener(_handleFocusChange);
    _controller?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  void _ensureEditor() {
    _controller ??= TextEditingController();
    if (_focusNode == null) {
      _focusNode = FocusNode()..addListener(_handleFocusChange);
    }
  }

  void _handleFocusChange() {
    if (_focusNode?.hasFocus == false && _isEditing) {
      _endEditing(commit: true);
    }
  }

  void _beginEditing() {
    if (widget.openEditorOnTap) {
      widget.onOpenEditor?.call();
      return;
    }
    if (widget.onLabelCommit == null || widget.colorOnly) {
      return;
    }
    _ensureEditor();
    _controller!.text = widget.task?.label ?? '';
    if (!_isEditing) {
      setState(() => _isEditing = true);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isEditing) {
        _focusNode?.requestFocus();
      }
    });
  }

  /// 편집 종료 — 컨트롤러는 [dispose]에서만 해제합니다.
  /// (setState 직후 EditableText가 한 프레임 더 붙어 있을 수 있음)
  void _endEditing({required bool commit}) {
    if (!_isEditing) {
      return;
    }
    if (commit) {
      _commitLabel();
    }
    if (!mounted) {
      return;
    }
    setState(() => _isEditing = false);
  }

  void _commitLabel() {
    if (widget.onLabelCommit == null || _controller == null) {
      return;
    }
    final label = _controller!.text;
    if (widget.task == null && label.trim().isEmpty) {
      return;
    }
    widget.onLabelCommit!(widget.task?.id, label);
  }

  @override
  Widget build(BuildContext context) {
    final metrics = widget.metrics;
    final completed = widget.task?.completed ?? false;
    final textColor = CategoryTheme.calendarDateText.withValues(
      alpha: completed ? 0.45 : 0.9,
    );

    if (widget.colorOnly) {
      return SizedBox(
        height: metrics.rowHeight,
        child: Center(
          child: CalendarTaskDot(
            size: metrics.colorSquareSize,
            color: widget.accentColor,
            completed: completed,
            onTap: widget.task != null && widget.onToggle != null
                ? () => widget.onToggle!(widget.task!.id)
                : null,
          ),
        ),
      );
    }

    return CalendarTaskLineBody(
      metrics: metrics,
      label: widget.task?.displayTitle ?? '',
      completed: completed,
      textColor: textColor,
      accentColor: widget.accentColor,
      isEditing: _isEditing,
      controller: _controller,
      focusNode: _focusNode,
      importanceLabel: widget.task?.importance.shortLabel,
      usageHours: widget.task?.usageHours ?? 0,
      onToggle: widget.task != null && widget.onToggle != null
          ? () => widget.onToggle!(widget.task!.id)
          : null,
      onBeginEditing: _beginEditing,
      onEndEditing: () => _endEditing(commit: true),
    );
  }
}

/// 내용 없는 빈 줄 — 탭하면 편집을 시작합니다.
class CalendarEmptyTaskLine extends StatelessWidget {
  const CalendarEmptyTaskLine({
    super.key,
    required this.metrics,
    required this.accentColor,
    required this.onTap,
  });

  final CalendarLayoutMetrics metrics;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CalendarTaskLineBody(
      metrics: metrics,
      label: '',
      completed: false,
      textColor: CategoryTheme.calendarDateText.withValues(alpha: 0.35),
      accentColor: accentColor,
      isEditing: false,
      onToggle: null,
      onBeginEditing: onTap,
    );
  }
}

class CalendarTaskLineBody extends StatelessWidget {
  const CalendarTaskLineBody({
    super.key,
    required this.metrics,
    required this.label,
    required this.completed,
    required this.textColor,
    required this.accentColor,
    required this.isEditing,
    required this.onBeginEditing,
    this.importanceLabel,
    this.usageHours = 0,
    this.controller,
    this.focusNode,
    this.onToggle,
    this.onEndEditing,
  });

  final CalendarLayoutMetrics metrics;
  final String label;
  final bool completed;
  final Color textColor;
  final Color accentColor;
  final bool isEditing;
  final String? importanceLabel;
  final int usageHours;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onToggle;
  final VoidCallback onBeginEditing;
  final VoidCallback? onEndEditing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final checkboxPart =
            metrics.checkboxSize + metrics.rowGap * 0.65;
        final metaPart = (importanceLabel != null ? metrics.taskFontSize * 1.1 : 0) +
            (usageHours > 0 ? metrics.taskFontSize * 1.4 : 0);
        final textWidth = (constraints.maxWidth - checkboxPart - metaPart)
            .clamp(0.0, double.infinity);

        return SizedBox(
          height: metrics.rowHeight,
          width: constraints.maxWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CalendarMiniCheckbox(
                size: metrics.checkboxSize,
                value: completed,
                activeColor: accentColor,
                onChanged: onToggle,
              ),
              SizedBox(width: metrics.rowGap * 0.65),
              SizedBox(
                width: textWidth,
                child: isEditing && controller != null && focusNode != null
                    ? EditableText(
                        key: ValueKey('edit-${focusNode.hashCode}'),
                        controller: controller!,
                        focusNode: focusNode!,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: metrics.taskFontSize,
                          height: 1.0,
                          color: textColor,
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                        cursorColor: accentColor,
                        backgroundCursorColor:
                            accentColor.withValues(alpha: 0.2),
                        selectionColor: accentColor.withValues(alpha: 0.25),
                        onSubmitted: (_) => onEndEditing?.call(),
                        onEditingComplete: () => onEndEditing?.call(),
                      )
                    : GestureDetector(
                        onTap: onBeginEditing,
                        behavior: HitTestBehavior.opaque,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: metrics.taskFontSize,
                              height: 1.0,
                              color: textColor,
                              decoration: completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
              ),
              if (importanceLabel != null) ...[
                SizedBox(width: metrics.rowGap * 0.35),
                Text(
                  importanceLabel!,
                  style: TextStyle(
                    fontSize: metrics.taskFontSize * 0.85,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ],
              if (usageHours > 0) ...[
                SizedBox(width: metrics.rowGap * 0.35),
                Text(
                  '${usageHours}h',
                  style: TextStyle(
                    fontSize: metrics.taskFontSize * 0.75,
                    color: textColor.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class CalendarMiniCheckbox extends StatelessWidget {
  const CalendarMiniCheckbox({
    super.key,
    required this.size,
    required this.value,
    required this.activeColor,
    this.onChanged,
  });

  final double size;
  final bool value;
  final Color activeColor;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        CategoryTheme.calendarDateText.withValues(alpha: 0.55);

    return GestureDetector(
      onTap: onChanged,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: value ? activeColor : Colors.transparent,
          border: Border.all(
            color: value ? activeColor : borderColor,
            width: size < 4 ? 0.4 : size * 0.12,
          ),
          borderRadius: BorderRadius.circular(size * 0.15),
        ),
        alignment: Alignment.center,
        child: value
            ? Icon(
                Icons.check,
                size: size * 0.72,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}

class CalendarTaskDot extends StatelessWidget {
  const CalendarTaskDot({
    super.key,
    required this.size,
    required this.color,
    required this.completed,
    this.onTap,
  });

  final double size;
  final Color color;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: completed ? color : color.withValues(alpha: 0.35),
          border: Border.all(
            color: color.withValues(alpha: completed ? 1 : 0.7),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(size * 0.15),
        ),
        child: completed
            ? Icon(
                Icons.check,
                size: size * 0.72,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
