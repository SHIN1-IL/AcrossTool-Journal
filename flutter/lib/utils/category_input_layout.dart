import 'package:flutter/material.dart';

/// 항목 카테고리 입력 방식 — 설정 또는 기기 크기에 따라 결정.
enum CategoryInputLayoutPreference {
  auto,
  inline,
  bottomSheet,
}

abstract final class CategoryInputLayout {
  static const double phoneMaxShortestSide = 600;
  static const double tabletMaxShortestSide = 900;

  static CategoryInputLayoutPreference parsePreference(String? value) {
    return CategoryInputLayoutPreference.values.firstWhere(
      (item) => item.name == value,
      orElse: () => CategoryInputLayoutPreference.auto,
    );
  }

  static bool isPhone(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide < phoneMaxShortestSide;
  }

  static bool isTablet(BuildContext context) {
    final side = MediaQuery.sizeOf(context).shortestSide;
    return side >= phoneMaxShortestSide && side < tabletMaxShortestSide;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= tabletMaxShortestSide;
  }

  /// `true` → 달력 셀 미리보기 + 바텀 시트 편집.
  static bool useBottomSheet({
    required BuildContext context,
    required CategoryInputLayoutPreference preference,
  }) {
    return switch (preference) {
      CategoryInputLayoutPreference.auto => isPhone(context),
      CategoryInputLayoutPreference.inline => false,
      CategoryInputLayoutPreference.bottomSheet => true,
    };
  }

  static String preferenceLabel(CategoryInputLayoutPreference preference) {
    return switch (preference) {
      CategoryInputLayoutPreference.auto => '자동 (휴대폰: 아래 입력창)',
      CategoryInputLayoutPreference.inline => '셀 안에서 입력 (노트북)',
      CategoryInputLayoutPreference.bottomSheet => '아래 입력창 (휴대폰)',
    };
  }

  static String preferenceMenuValue(CategoryInputLayoutPreference preference) {
    return 'input-layout-${preference.name}';
  }

  static CategoryInputLayoutPreference? parseMenuValue(String value) {
    const prefix = 'input-layout-';
    if (!value.startsWith(prefix)) {
      return null;
    }
    return parsePreference(value.substring(prefix.length));
  }
}
