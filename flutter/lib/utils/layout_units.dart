import 'package:flutter/material.dart';

/// CSS 96dpi 기준 mm → Flutter logical px 변환.
double logicalMm(double millimeters) => millimeters * 96 / 25.4;

/// 하단 브랜딩(AcrossTool Journal)용 예약 높이 (10mm).
const double kFooterReserveMm = 10.0;

/// 달력 메인 컨테이너 하단 여백.
const double kCalendarBottomMarginPx = 8.0;

/// 브랜딩 텍스트 연한 회색.
const Color kBrandingLineColor = Color(0xFFE0E0E0);

double footerReservePx() => logicalMm(kFooterReserveMm);
