import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 달력 셀 타이포·행 높이·카테고리 열 모드를 황금비(φ)로 계산합니다.
class CalendarLayoutMetrics {
  CalendarLayoutMetrics._({
    required this.taskFontSize,
    required this.checkboxSize,
    required this.rowHeight,
    required this.rowGap,
    required this.cellPadding,
    required this.columnMode,
    required this.columnWidth,
    required this.colorSquareSize,
    required this.categoryHeaderHeight,
    required this.taskBlockHeight,
  });

  static const double phi = 1.618033988749;
  static const double invPhi = 0.618033988749;

  static const int maxTaskRows = 10;
  static const int maxCategoryColumns = 10;

  static const double dateFontSize = 13;
  static const double dateColumnWidth = 18;
  static const double dayProgressBarHeight = 6;
  static const double dayProgressBarGap = 3;
  /// 행 사이 추가 간격 — font pt 대비 비율 (작을수록 줄 간격이 좁음).
  static const double lineGapRatio = 0.06;
  static const double minRowGap = 0.08;
  /// 할일 한 줄 박스 높이 — font pt와 동일하게 맞춤.
  static const double rowHeightRatio = 1.0;
  /// 행·헤더 합산과 실제 셀 높이 사이 여유 (서브픽셀·테두리).
  static const double layoutSafetyMargin = 12;

  final double taskFontSize;
  final double checkboxSize;
  final double rowHeight;
  final double rowGap;
  final double cellPadding;
  final OverviewColumnMode columnMode;
  final double columnWidth;
  final double colorSquareSize;
  final double categoryHeaderHeight;
  final double taskBlockHeight;

  /// 10줄 할일 블록 높이 (행 간격 포함).
  double get totalTaskBlockHeight => taskBlockHeight;

  static CalendarLayoutMetrics forCell({
    required double cellWidth,
    required double cellHeight,
    required double taskFontPt,
    required int categoryCount,
    required bool isOverview,
  }) {
    final padding =
        math.max(0.6, math.min(2.0, cellWidth * (1 - invPhi) / 14));
    final innerWidth = math.max(1.0, cellWidth - padding * 2);
    final innerHeight = math.max(1.0, cellHeight - padding * 2);

    final taskBand = math.max(
      1.0,
      innerHeight - dayProgressBarHeight - dayProgressBarGap,
    );

    final columns = isOverview
        ? math.min(categoryCount, maxCategoryColumns).clamp(1, maxCategoryColumns)
        : 1;
    final rawColWidth = innerWidth / columns;

    var columnMode = OverviewColumnMode.full;
    if (isOverview) {
      if (categoryCount > 7 || rawColWidth < 10) {
        columnMode = OverviewColumnMode.colorOnly;
      } else if (categoryCount > 4 || rawColWidth < 18) {
        columnMode = OverviewColumnMode.compact;
      }
    }

    final colWidth = switch (columnMode) {
      OverviewColumnMode.colorOnly =>
        math.max(3.0, rawColWidth).clamp(3.0, innerWidth),
      OverviewColumnMode.compact => rawColWidth,
      OverviewColumnMode.full => rawColWidth,
    };

    final targetPt = taskFontPt;
    final rowGap = math.max(minRowGap, targetPt * lineGapRatio);
    final rowHeightFromFont = targetPt * rowHeightRatio;
    final rowsAtFull =
        maxTaskRows * rowHeightFromFont + (maxTaskRows - 1) * rowGap;
    final headerGapAtFull = isOverview ? rowGap * 0.6 : 0.0;

    final fitScale = _resolveFitScale(
      taskBand: taskBand,
      targetPt: targetPt,
      rowsAtFull: rowsAtFull,
      headerGapAtFull: headerGapAtFull,
      isOverview: isOverview,
      columnMode: columnMode,
      colWidth: colWidth,
    );

    final taskFont = targetPt * fitScale;
    final rowHeight = rowHeightFromFont * fitScale;
    final fittedRowGap = rowGap * fitScale;
    final rowsBlockHeight =
        maxTaskRows * rowHeight + (maxTaskRows - 1) * fittedRowGap;
    final fittedHeaderHeight = isOverview
        ? _overviewHeaderHeight(
            mode: columnMode,
            taskFont: taskFont,
            colWidth: colWidth,
          )
        : 0.0;
    final colorSquare = fittedHeaderHeight;

    final checkbox = (taskFont * invPhi).clamp(3.0, 12.0);

    return CalendarLayoutMetrics._(
      taskFontSize: taskFont,
      checkboxSize: checkbox,
      rowHeight: rowHeight,
      rowGap: fittedRowGap,
      cellPadding: padding,
      columnMode: columnMode,
      columnWidth: colWidth,
      colorSquareSize: colorSquare,
      categoryHeaderHeight: fittedHeaderHeight,
      taskBlockHeight: rowsBlockHeight,
    );
  }

  static double _resolveFitScale({
    required double taskBand,
    required double targetPt,
    required double rowsAtFull,
    required double headerGapAtFull,
    required bool isOverview,
    required OverviewColumnMode columnMode,
    required double colWidth,
  }) {
    final budget = taskBand - layoutSafetyMargin;
    if (budget <= 0) {
      return 0.35;
    }

    if (!isOverview) {
      if (rowsAtFull <= budget) {
        return 1.0;
      }
      return math.max(0.35, budget / rowsAtFull);
    }

    final headerAtFull = _overviewHeaderHeight(
      mode: columnMode,
      taskFont: targetPt,
      colWidth: colWidth,
    );
    final scalableAtFull = rowsAtFull + headerGapAtFull;
    final fixedHeader = _fixedOverviewHeaderHeight(
      mode: columnMode,
      colWidth: colWidth,
      taskFont: targetPt,
    );

    if (fixedHeader > 0) {
      final scalableBudget = budget - fixedHeader;
      if (scalableBudget <= 0) {
        return 0.35;
      }
      if (scalableAtFull <= scalableBudget) {
        return 1.0;
      }
      return math.max(0.35, scalableBudget / scalableAtFull);
    }

    final requiredAtFull = headerAtFull + headerGapAtFull + rowsAtFull;
    if (requiredAtFull <= budget) {
      return 1.0;
    }
    return math.max(0.35, budget / requiredAtFull);
  }

  /// 열 너비에 묶여 fitScale과 무관하게 유지되는 헤더 높이.
  static double _fixedOverviewHeaderHeight({
    required OverviewColumnMode mode,
    required double colWidth,
    required double taskFont,
  }) {
    if (mode == OverviewColumnMode.full) {
      return 0;
    }
    final colCap = math.min(colWidth * invPhi, taskFont * phi).clamp(2.5, 12.0);
    final fontCap = taskFont * phi;
    return colCap <= fontCap ? colCap : 0;
  }

  static double _overviewHeaderHeight({
    required OverviewColumnMode mode,
    required double taskFont,
    required double colWidth,
  }) {
    return switch (mode) {
      OverviewColumnMode.colorOnly ||
      OverviewColumnMode.compact =>
        math.min(colWidth * invPhi, taskFont * phi).clamp(2.5, 12.0),
      OverviewColumnMode.full => taskFont,
    };
  }

  static CalendarLayoutMetrics of(
    BuildContext context, {
    required double cellWidth,
    required double cellHeight,
    required int categoryCount,
    required bool isOverview,
    required double taskFontPt,
  }) {
    return forCell(
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      taskFontPt: taskFontPt,
      categoryCount: categoryCount,
      isOverview: isOverview,
    );
  }
}

enum OverviewColumnMode {
  full,
  compact,
  colorOnly,
}
