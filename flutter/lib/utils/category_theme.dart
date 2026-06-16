import 'package:flutter/material.dart';

import '../models/journal_category_tab.dart';

/// 카테고리·달력 UI 스타일 상수 (Flutter Theme/CSS 변수 대응).
abstract final class CategoryTheme {
  static const double chipMinWidth = 64;
  static const double chipHeight = 34;
  static const FontWeight chipFontWeight = FontWeight.w500;
  static const double chipFontSize = 12.5;

  // ── Modern category bar tokens ──
  static const double headerBarHeight = 52;
  static const double tabPillRadius = 18;
  static const double tabColorDotSize = 7;
  static const double tabIconSize = 14;

  static const Color headerOverlayBorder = Color(0x1FFFFFFF);
  static const Color tabSelectedFill = Color(0xFFF8FAFC);
  static const Color tabUnselectedFill = Color(0x14FFFFFF);
  static const Color tabSelectedBorder = Color(0x33FFFFFF);
  static const Color tabUnselectedBorder = Color(0x1AFFFFFF);
  static const Color tabSelectedText = Color(0xFF0F172A);
  static const Color tabUnselectedText = Color(0xFFE2E8F0);
  static const Color toolbarDivider = Color(0x24FFFFFF);
  static const Color toolbarIconMuted = Color(0xFF94A3B8);
  static const Color toolbarIconActive = Color(0xFFE2E8F0);

  static List<BoxShadow> tabSelectedShadow(Color accent) => [
        BoxShadow(
          color: accent.withValues(alpha: 0.28),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static const Color calendarDateText = Colors.white;
  static const Color calendarWeekdayText = Color(0xE6FFFFFF);
  static const Color calendarMonthTitleText = Colors.white;
  static const Color calendarCellFill = Color(0x33FFFFFF);
  static const Color calendarCellBorder = Color(0x4DFFFFFF);
  static const Color calendarSelectedCellFill = Color(0x66FFFFFF);

  static const Color analyticsAccent = Color(0xFF60A5FA);
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
        base.withValues(alpha: 0.42),
        base.withValues(alpha: 0.28),
        base.withValues(alpha: 0.18),
      ],
    );
  }
}
