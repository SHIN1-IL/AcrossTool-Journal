import 'package:flutter/material.dart';

import '../models/completion_rate.dart';
import '../utils/category_theme.dart';

/// 웹 MVP `CompletionMarker.tsx` 대응 — 티어별 원형 마커.
class CompletionMarker extends StatelessWidget {
  const CompletionMarker({
    super.key,
    required this.rate,
    this.selected = false,
  });

  final int rate;
  final bool selected;

  static Color tierColor(CompletionTier tier) {
    switch (tier) {
      case CompletionTier.zero:
        return Colors.grey.shade400;
      case CompletionTier.low:
        return Colors.red.shade500;
      case CompletionTier.medium:
        return Colors.orange.shade400;
      case CompletionTier.high:
        return Colors.green.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tier = getCompletionTier(rate);

    return Semantics(
      label: '완료율 $rate% (${getCompletionTierLabel(rate)})',
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: tierColor(tier),
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: CategoryTheme.appText.withValues(alpha: 0.35))
              : null,
        ),
      ),
    );
  }
}
