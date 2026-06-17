import 'package:flutter/material.dart';

import '../models/journal_category_tab.dart';

/// 카테고리·달력 UI 스타일 상수 (Flutter Theme/CSS 변수 대응).
abstract final class CategoryTheme {
  // ── App-wide colors ──
  static const Color appBackground = Color(0xFFFFFFFF);
  static const Color appText = Color(0xFF000000);
  static const Color appTextMuted = Color(0xFF666666);
  static const Color appBorder = Color(0xFFE5E7EB);
  static const String appName = 'AcrossTool Journal';

  static const double chipMinWidth = 56;
  static const double chipHeight = 28;
  static const double chipHeightUnselected = 24;
  static const FontWeight chipFontWeight = FontWeight.w500;
  static const double chipFontSize = 11.5;

  // ── Diary-style category tab tokens ──
  static const double headerBarHeight = 33;
  static const double headerTotalHeight = headerBarHeight;
  /// 우측 툴바(구분선·통계·설정·여백) 열 너비.
  static const double headerToolbarWidth = 85;
  static const double tabTopRadius = 7;
  static const double tabColorDotSize = 6;
  static const double tabIconSize = 12;
  static const double tabCalendarBridgeHeight = 4;

  static BorderRadius get diaryTabRadius => const BorderRadius.only(
        topLeft: Radius.circular(tabTopRadius),
        topRight: Radius.circular(tabTopRadius),
      );

  static const Color headerBackground = appBackground;
  static const Color headerOverlayBorder = appBorder;
  static const Color tabSelectedFill = appBackground;
  static const Color tabUnselectedFill = appBackground;
  static const Color tabSelectedBorder = Color(0xFFD1D5DB);
  static const Color tabUnselectedBorder = appBorder;
  static const double tabSelectedBorderWidth = 1.2;
  static const double tabUnselectedBorderWidth = 1;
  static const Color tabSelectedText = appText;
  static const Color tabUnselectedText = appTextMuted;
  static const Color toolbarDivider = appBorder;
  static const Color toolbarIconMuted = Color(0xFF6B7280);
  static const Color toolbarIconActive = Color(0xFF374151);
  static const Color appBrandingText = Color(0xFF6B7280);

  static List<BoxShadow> tabSelectedShadow(Color accent) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 2,
          offset: const Offset(0, -1),
        ),
      ];

  static const Color calendarDateText = appText;
  static const Color calendarWeekdayText = appTextMuted;
  static const Color calendarMonthTitleText = appText;
  static const Color calendarCellFill = appBackground;
  static const Color calendarCellBorder = appBorder;
  static const Color calendarSelectedCellFill = appBackground;
  static const Color calendarOutsideCellFill = appBackground;

  static const Color analyticsAccent = Color(0xFF2563EB);
  static const Color analyticsBackground = appBackground;

  static LinearGradient calendarGradientFor(JournalCategoryTab tab) {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [appBackground, appBackground],
    );
  }

  static Color calendarBackgroundFor(JournalCategoryTab tab) => appBackground;
}
