import 'package:acrosstool_journal/models/completion_rate.dart';
import 'package:acrosstool_journal/widgets/completion_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CompletionMarker renders tier color for rate', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CompletionMarker(rate: 80),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, CompletionMarker.tierColor(CompletionTier.high));
  });
}
