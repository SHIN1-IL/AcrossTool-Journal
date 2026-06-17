import 'package:flutter/material.dart';

import '../models/task_importance.dart';
import '../models/task_slot.dart';
import '../utils/calendar_layout_metrics.dart';
import '../utils/category_theme.dart';

/// 중요 / 긴급 / 일반 3단계 슬라이더형 선택 UI.
class TaskImportanceSlider extends StatelessWidget {
  const TaskImportanceSlider({
    super.key,
    required this.value,
    required this.accentColor,
    required this.onChanged,
    this.enabled = true,
  });

  final TaskImportance value;
  final Color accentColor;
  final ValueChanged<TaskImportance> onChanged;
  final bool enabled;

  static const _options = TaskImportance.values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '중요도',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: CategoryTheme.appTextMuted,
          ),
        ),
        const SizedBox(height: 4),
        DecoratedBox(
          decoration: BoxDecoration(
            color: CategoryTheme.appBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CategoryTheme.appBorder),
          ),
          child: Row(
            children: [
              for (var i = 0; i < _options.length; i++)
                Expanded(
                  child: _ImportanceSegment(
                    label: _options[i].label,
                    shortLabel: _options[i].shortLabel,
                    selected: value == _options[i],
                    accentColor: accentColor,
                    enabled: enabled,
                    isFirst: i == 0,
                    isLast: i == _options.length - 1,
                    onTap: enabled ? () => onChanged(_options[i]) : null,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImportanceSegment extends StatelessWidget {
  const _ImportanceSegment({
    required this.label,
    required this.shortLabel,
    required this.selected,
    required this.accentColor,
    required this.enabled,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final String label;
  final String shortLabel;
  final bool selected;
  final Color accentColor;
  final bool enabled;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? accentColor.withValues(alpha: 0.14)
        : Colors.transparent;

    return Material(
      color: background,
      borderRadius: BorderRadius.horizontal(
        left: isFirst ? const Radius.circular(7) : Radius.zero,
        right: isLast ? const Radius.circular(7) : Radius.zero,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.horizontal(
          left: isFirst ? const Radius.circular(7) : Radius.zero,
          right: isLast ? const Radius.circular(7) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Text(
                shortLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? accentColor : CategoryTheme.appTextMuted,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: selected
                      ? CategoryTheme.appText
                      : CategoryTheme.appTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 0~12시간, 1시간 단위 슬라이더.
class TaskUsageHoursSlider extends StatelessWidget {
  const TaskUsageHoursSlider({
    super.key,
    required this.value,
    required this.accentColor,
    required this.onChanged,
    this.enabled = true,
  });

  final int value;
  final Color accentColor;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '사용 시간',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: CategoryTheme.appTextMuted,
              ),
            ),
            const Spacer(),
            Text(
              '$value시간',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: accentColor,
            inactiveTrackColor: accentColor.withValues(alpha: 0.15),
            thumbColor: accentColor,
            overlayColor: accentColor.withValues(alpha: 0.12),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: TaskSlot.maxUsageHours.toDouble(),
            divisions: TaskSlot.maxUsageHours,
            label: '$value시간',
            onChanged: enabled ? (next) => onChanged(next.round()) : null,
          ),
        ),
      ],
    );
  }
}

/// 달력 셀용 초소형 중요도 슬라이더 (0=일반, 1=중요, 2=긴급).
class CompactTaskImportanceSlider extends StatelessWidget {
  const CompactTaskImportanceSlider({
    super.key,
    required this.value,
    required this.accentColor,
    required this.onChanged,
    this.fontSize = 8,
  });

  final TaskImportance value;
  final Color accentColor;
  final ValueChanged<TaskImportance> onChanged;
  final double fontSize;

  int get _index => TaskImportance.values.indexOf(value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: fontSize * 2.8,
          child: Text(
            '중요',
            style: TextStyle(
              fontSize: fontSize,
              color: CategoryTheme.appTextMuted,
              height: 1.0,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accentColor,
              inactiveTrackColor: accentColor.withValues(alpha: 0.12),
              thumbColor: accentColor,
              overlayColor: accentColor.withValues(alpha: 0.08),
              trackHeight: 1.5,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: fontSize * 0.55,
              ),
              overlayShape: RoundSliderOverlayShape(overlayRadius: fontSize),
            ),
            child: Slider(
              value: _index.toDouble(),
              min: 0,
              max: 2,
              divisions: 2,
              onChanged: (next) =>
                  onChanged(TaskImportance.values[next.round()]),
            ),
          ),
        ),
        SizedBox(
          width: fontSize * 1.4,
          child: Text(
            value.shortLabel,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: accentColor,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

/// 달력 셀용 초소형 사용 시간 슬라이더.
class CompactTaskUsageHoursSlider extends StatelessWidget {
  const CompactTaskUsageHoursSlider({
    super.key,
    required this.value,
    required this.accentColor,
    required this.onChanged,
    this.fontSize = 8,
  });

  final int value;
  final Color accentColor;
  final ValueChanged<int> onChanged;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: fontSize * 2.8,
          child: Text(
            '시간',
            style: TextStyle(
              fontSize: fontSize,
              color: CategoryTheme.appTextMuted,
              height: 1.0,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accentColor,
              inactiveTrackColor: accentColor.withValues(alpha: 0.12),
              thumbColor: accentColor,
              overlayColor: accentColor.withValues(alpha: 0.08),
              trackHeight: 1.5,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: fontSize * 0.55,
              ),
              overlayShape: RoundSliderOverlayShape(overlayRadius: fontSize),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: TaskSlot.maxUsageHours.toDouble(),
              divisions: TaskSlot.maxUsageHours,
              onChanged: (next) => onChanged(next.round()),
            ),
          ),
        ),
        SizedBox(
          width: fontSize * 1.4,
          child: Text(
            '${value}h',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: CategoryTheme.appTextMuted,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

/// 드래그는 유지하고 썸(동그란 점)은 숨깁니다.
SliderThemeData compactColorOnlySliderTheme(
  BuildContext context, {
  required double trackHeight,
}) {
  return SliderTheme.of(context).copyWith(
    trackHeight: trackHeight,
    activeTrackColor: Colors.transparent,
    inactiveTrackColor: Colors.transparent,
    thumbColor: Colors.transparent,
    overlayColor: Colors.transparent,
    thumbShape: const RoundSliderThumbShape(
      enabledThumbRadius: 0,
      disabledThumbRadius: 0,
      elevation: 0,
      pressedElevation: 0,
    ),
    overlayShape: SliderComponentShape.noOverlay,
  );
}

/// Material Slider 기본 터치 영역(48px)을 막대 높이 안으로 클리핑합니다.
class _ClippedCompactSlider extends StatelessWidget {
  const _ClippedCompactSlider({
    required this.height,
    required this.slider,
  });

  final double height;
  final Widget slider;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: 48,
            child: slider,
          ),
        ),
      ),
    );
  }
}

/// 드래그 가능한 단색 채움 막대 — 시간·중요도 등 공통 UI.
class CompactFillDragBar extends StatefulWidget {
  const CompactFillDragBar({
    super.key,
    required this.value,
    required this.max,
    required this.height,
    required this.trackColor,
    required this.fillColor,
    required this.onChanged,
    this.min = 0,
    this.divisions,
    this.centerLabel,
    this.centerLabelForValue,
    this.labelColor,
    this.semanticsLabel,
  });

  final double value;
  final double min;
  final double max;
  final double height;
  final Color trackColor;
  final Color fillColor;
  final ValueChanged<double> onChanged;
  final int? divisions;
  final String? centerLabel;
  final String Function(double value)? centerLabelForValue;
  final Color? labelColor;
  final String? semanticsLabel;

  @override
  State<CompactFillDragBar> createState() => _CompactFillDragBarState();
}

class _CompactFillDragBarState extends State<CompactFillDragBar> {
  double? _dragValue;

  double get _displayValue => _dragValue ?? widget.value;

  @override
  void didUpdateWidget(CompactFillDragBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_dragValue != null && widget.value == _dragValue) {
      _dragValue = null;
    }
  }

  double _fillFactor() {
    final range = widget.max - widget.min;
    if (range <= 0) {
      return 0;
    }
    return ((_displayValue - widget.min) / range).clamp(0.0, 1.0);
  }

  void _handleChanged(double next) {
    setState(() => _dragValue = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final fillFactor = _fillFactor();
    final labelSize = (widget.height * 0.82).clamp(6.0, 10.0);

    return Semantics(
      label: widget.semanticsLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.height / 2),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fillWidth = constraints.maxWidth * fillFactor;

              return Stack(
                clipBehavior: Clip.hardEdge,
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: widget.trackColor),
                  if (fillWidth > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: fillWidth,
                        height: widget.height,
                        child: ColoredBox(color: widget.fillColor),
                      ),
                    ),
                  _ClippedCompactSlider(
                    height: widget.height,
                    slider: SliderTheme(
                      data: compactColorOnlySliderTheme(
                        context,
                        trackHeight: widget.height,
                      ),
                      child: Slider(
                        value: _displayValue.clamp(widget.min, widget.max),
                        min: widget.min,
                        max: widget.max,
                        divisions: widget.divisions,
                        onChanged: _handleChanged,
                      ),
                    ),
                  ),
                  if (widget.centerLabel != null ||
                      widget.centerLabelForValue != null)
                    IgnorePointer(
                      child: Text(
                        widget.centerLabelForValue?.call(_displayValue) ??
                            widget.centerLabel!,
                        style: TextStyle(
                          fontSize: labelSize,
                          height: 1.0,
                          fontWeight: FontWeight.w600,
                          color: widget.labelColor ??
                              CategoryTheme.calendarDateText
                                  .withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 중요도 — 연한 녹색 트랙 + 드래그 위치만큼 진한 녹색 채움.
class ImportancePastelBar extends StatelessWidget {
  const ImportancePastelBar({
    super.key,
    required this.value,
    required this.onChanged,
    this.height,
  });

  static const _trackColor = Color(0xFFE0F2E4);
  static const _fillColor = Color(0xFF43A047);
  static const _labelColor = Color(0xFF2E6B32);

  final TaskImportance value;
  final ValueChanged<TaskImportance> onChanged;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final barHeight = height ?? CalendarLayoutMetrics.dateFontSize * 0.85;

    return CompactFillDragBar(
      value: value.sliderIndex.toDouble(),
      min: 0,
      max: 2,
      divisions: 2,
      height: barHeight,
      trackColor: _trackColor,
      fillColor: _fillColor,
      labelColor: _labelColor.withValues(alpha: 0.9),
      centerLabelForValue: (v) =>
          TaskImportance.fromSliderIndex(v.round()).label,
      semanticsLabel: '중요도 ${value.label}',
      onChanged: (next) =>
          onChanged(TaskImportance.fromSliderIndex(next.round())),
    );
  }
}
