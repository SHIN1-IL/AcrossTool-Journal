import 'package:acrosstool_journal/main.dart';
import 'package:acrosstool_journal/screens/acrosstool_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AcrossToolMainScreen renders app bar title', (tester) async {
    await tester.pumpWidget(const AcrossToolJournalApp());

    expect(find.text('AcrossTool Journal'), findsOneWidget);
    expect(find.byType(AcrossToolMainScreen), findsOneWidget);
  });

  testWidgets('Wide layout shows calendar and timeline panels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(900, 600)),
          child: AcrossToolMainScreen(),
        ),
      ),
    );

    expect(find.text('오늘 일과 5줄'), findsOneWidget);
    expect(find.byType(VerticalDivider), findsOneWidget);
  });
}
