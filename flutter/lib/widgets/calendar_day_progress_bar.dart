import 'package:flutter/material.dart';

import '../utils/calendar_layout_metrics.dart';

/// 달력 날짜 셀 달성률 막대 (읽기 전용).
class CalendarDayProgressBar extends StatelessWidget {
  const CalendarDayProgressBar({
    super.key,
    required this.rate,
    this.height = CalendarLayoutMetrics.dayProgressBarHeight,
    this.showPercentLabel = false,
    this.centerLabel,
  });

  static const _trackColor = Color(0xFFDCE6EF);
  static const _fillColor = Color(0xFF4A90C2);
  static const _labelColor = Color(0xFF2E5678);

  final int rate;
  final double height;
  final bool showPercentLabel;
  final String? centerLabel;

  static double overviewBarHeight() =>
      CalendarLayoutMetrics.dateFontSize * 0.85;

  @override
  Widget build(BuildContext context) {
    final fillFactor = (rate / 100).clamp(0.0, 1.0);
    final labelSize = (height * 0.82).clamp(6.0, 10.0);
    final displayLabel = centerLabel ?? '$rate%';

    return Semantics(
      label: '일일 달성률 $rate%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fillWidth = constraints.maxWidth * fillFactor;

              return Stack(
                clipBehavior: Clip.hardEdge,
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  const ColoredBox(color: _trackColor),
                  if (fillWidth > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: fillWidth,
                        height: height,
                        child: const ColoredBox(color: _fillColor),
                      ),
                    ),
                  if (showPercentLabel || centerLabel != null)
                    Text(
                      displayLabel,
                      style: TextStyle(
                        fontSize: labelSize,
                        height: 1.0,
                        fontWeight: FontWeight.w600,
                        color: rate >= 50
                            ? Colors.white
                            : _labelColor.withValues(alpha: 0.85),
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
