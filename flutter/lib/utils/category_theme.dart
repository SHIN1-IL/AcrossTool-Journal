import 'package:flutter/material.dart';

import '../models/journal_category_tab.dart';

/// 카테고리·달력 UI 스타일 상수 (Flutter Theme/CSS 변수 대응).
abstract final class CategoryTheme {
  static const double chipMinWidth = 72;
  static const double chipHeight = 38;
  static const FontWeight chipFontWeight = FontWeight.w400;
  static const double chipFontSize = 13;

  static const Color headerBackground = Color(0xFF5F6368);
  static const Color headerSelectedChipFill = Color(0xFF3C4043);
  static const Color headerChipText = Color(0xFFF1F3F4);
  static const Color headerChipTextMuted = Color(0xFFBDC1C6);

  static const Color calendarDateText = Colors.white;
  static const Color calendarWeekdayText = Color(0xE6FFFFFF);
  static const Color calendarMonthTitleText = Colors.white;
  static const Color calendarCellFill = Color(0x33FFFFFF);
  static const Color calendarCellBorder = Color(0x4DFFFFFF);
  static const Color calendarSelectedCellFill = Color(0x66FFFFFF);

  static const Color analyticsAccent = Color(0xFF8AB4F8);
  static const Color analyticsBackground = Color(0xFF202124);

  static LinearGradient calendarGradientFor(JournalCategoryTab tab) {
    final base = tab.isAnalytics
        ? analyticsBackground
        : tab.isOverview
            ? const Color(0xFF7A8699)
            : tab.accentColor;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        base.withValues(alpha: 0.28),
        base.withValues(alpha: 0.12),
        const Color(0xFFF8FAFC),
      ],
      stops: const [0.0, 0.45, 1.0],
    );
  }
}
