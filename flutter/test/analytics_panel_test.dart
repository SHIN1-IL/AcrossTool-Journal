import 'package:acrosstool_journal/widgets/analytics_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AnalyticsPanel renders sections', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnalyticsPanel(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('실시간 통계'), findsOneWidget);
  });

  testWidgets('AnalyticsPanel in column expanded stack', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 900,
          width: 900,
          child: Column(
            children: [
              Container(height: 48, color: Colors.grey),
              const Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: AnalyticsPanel()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('실시간 통계'), findsOneWidget);
  });
}
