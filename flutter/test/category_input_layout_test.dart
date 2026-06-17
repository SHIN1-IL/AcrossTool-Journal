import 'package:acrosstool_journal/utils/category_input_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('auto uses bottom sheet on phone and inline on desktop',
      (tester) async {
    Future<bool> resolve(Size size) async {
      var result = false;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                result = CategoryInputLayout.useBottomSheet(
                  context: context,
                  preference: CategoryInputLayoutPreference.auto,
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      return result;
    }

    expect(await resolve(const Size(390, 844)), isTrue);
    expect(await resolve(const Size(900, 900)), isFalse);
  });

  testWidgets('settings override bottom sheet on tablet width', (tester) async {
    var result = false;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(768, 1024)),
          child: Builder(
            builder: (context) {
              result = CategoryInputLayout.useBottomSheet(
                context: context,
                preference: CategoryInputLayoutPreference.bottomSheet,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(result, isTrue);
  });
}
