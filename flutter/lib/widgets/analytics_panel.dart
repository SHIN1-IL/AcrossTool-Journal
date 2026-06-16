import 'package:flutter/material.dart';

import '../utils/category_theme.dart';

/// 통계·분석 전용 뷰 (실시간/월간 통계, 시간 합산 시뮬레이션 기본 구조).
class AnalyticsPanel extends StatelessWidget {
  const AnalyticsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CategoryTheme.analyticsBackground,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: const [
          _SectionCard(
            title: '실시간 통계',
            description: '오늘 완료율, 진행 중인 일정, 카테고리별 달성 현황을 표시합니다.',
            icon: Icons.insights_outlined,
          ),
          SizedBox(height: 16),
          _SectionCard(
            title: '매월 통계 / 분석',
            description: '월별 완료 추이, 카테고리 비중, 주간 패턴을 분석합니다.',
            icon: Icons.calendar_month_outlined,
          ),
          SizedBox(height: 16),
          _SectionCard(
            title: '시간 합산 시뮬레이션',
            description: '카테고리별 시간 배분 시나리오를 시뮬레이션합니다.',
            icon: Icons.schedule_outlined,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF303134),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: CategoryTheme.analyticsAccent, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
