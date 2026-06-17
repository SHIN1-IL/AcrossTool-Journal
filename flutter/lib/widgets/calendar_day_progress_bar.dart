import 'package:flutter/material.dart';

import '../utils/calendar_layout_metrics.dart';
import '../utils/category_theme.dart';

/// 달력 날짜 셀 달성률 막대 (읽기 전용).
class CalendarDayProgressBar extends StatelessWidget {
  const CalendarDayProgressBar({
    super.key,
    required this.rate,
    this.height = CalendarLayoutMetrics.dayProgressBarHeight,
    this.showPercentLabel = false,
    this.centerLabel,
  });

  final int rate;
  final double height;
  final bool showPercentLabel;
  final String? centerLabel;

  static double overviewBarHeight() =>
      CalendarLayoutMetrics.dateFontSize * 0.85;

  @override
  Widget build(BuildContext context) {
    final fill = (rate / 100).clamp(0.0, 1.0);
    final color = switch (rate) {
      >= 80 => CategoryTheme.analyticsAccent,
      >= 40 => const Color(0xFF43A047),
      > 0 => const Color(0xFFFF9800),
      _ => CategoryTheme.appTextMuted.withValues(alpha: 0.35),
    };
    final labelSize = (height * 0.82).clamp(6.0, 10.0);
    final displayLabel = centerLabel ?? '$rate%';

    return Semantics(
      label: '일일 달성률 $rate%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ColoredBox(
                color: CategoryTheme.appBorder.withValues(alpha: 0.85),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: fill > 0 ? fill : 0,
                    child: ColoredBox(color: color),
                  ),
                ),
              ),
              if (showPercentLabel || centerLabel != null)
                Text(
                  displayLabel,
                  style: TextStyle(
                    fontSize: labelSize,
                    height: 1.0,
                    fontWeight: FontWeight.w600,
                    color: rate >= 40
                        ? Colors.white
                        : CategoryTheme.calendarDateText
                            .withValues(alpha: 0.75),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
