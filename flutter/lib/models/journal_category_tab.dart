import 'package:flutter/material.dart';

import '../utils/category_theme.dart';

/// 달력 상단 다이어리 스타일 카테고리 탭.
class JournalCategoryTab {
  const JournalCategoryTab({
    required this.id,
    required this.title,
    required this.colorValue,
    this.isOverview = false,
    this.isAnalytics = false,
  });

  static const String overviewId = '__overview__';
  static const String analyticsId = '__analytics__';
  static const String overviewTitle = '기본';
  static const String analyticsTitle = '통계';

  /// 기본 1 + 초기 5 + 추가 5 = 최대 11.
  static const int maxTabs = 11;
  static const int initialEditableCount = 5;
  static const int batchAddCount = 5;
  static const int maxTitleLength = 5;

  static const List<Color> pastelPalette = [
    Color(0xFFFFF8F9),
    Color(0xFFF8FCFF),
    Color(0xFFF8FCF8),
    Color(0xFFFFFDF8),
    Color(0xFFFBF9FF),
    Color(0xFFF8FFFD),
    Color(0xFFFFF9F7),
    Color(0xFFF9FBFF),
    Color(0xFFFCF9FF),
  ];

  final String id;
  final String title;
  final int colorValue;
  final bool isOverview;
  final bool isAnalytics;

  Color get backgroundColor {
    if (isAnalytics) {
      return CategoryTheme.analyticsBackground;
    }
    return Color(colorValue);
  }

  Color get accentColor {
    if (isAnalytics) {
      return CategoryTheme.analyticsAccent;
    }
    if (isOverview) {
      return const Color(0xFF6B7280);
    }
    final hsl = HSLColor.fromColor(backgroundColor);
    return hsl
        .withSaturation((hsl.saturation + 0.25).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 0.42).clamp(0.25, 0.5))
        .toColor();
  }

  static JournalCategoryTab overview() {
    return const JournalCategoryTab(
      id: overviewId,
      title: overviewTitle,
      colorValue: 0xFFFFFFFF,
      isOverview: true,
    );
  }

  static JournalCategoryTab analytics() {
    return const JournalCategoryTab(
      id: analyticsId,
      title: analyticsTitle,
      colorValue: 0xFF202124,
      isAnalytics: true,
    );
  }

  factory JournalCategoryTab.fromJson(Map<String, dynamic> json) {
    return JournalCategoryTab(
      id: json['id'] as String,
      title: json['title'] as String,
      colorValue: (json['colorValue'] as num).toInt(),
      isOverview: json['isOverview'] as bool? ?? false,
      isAnalytics: json['isAnalytics'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'colorValue': colorValue,
      'isOverview': isOverview,
      'isAnalytics': isAnalytics,
    };
  }

  JournalCategoryTab copyWith({
    String? id,
    String? title,
    int? colorValue,
    bool? isOverview,
    bool? isAnalytics,
  }) {
    return JournalCategoryTab(
      id: id ?? this.id,
      title: title ?? this.title,
      colorValue: colorValue ?? this.colorValue,
      isOverview: isOverview ?? this.isOverview,
      isAnalytics: isAnalytics ?? this.isAnalytics,
    );
  }
}
