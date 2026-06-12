import 'package:flutter/material.dart';

/// 웹 MVP `CategorySelect.tsx` 대응.
class CategorySelect extends StatelessWidget {
  const CategorySelect({
    super.key,
    required this.value,
    required this.categories,
    required this.onChanged,
    required this.semanticLabel,
  });

  final String? value;
  final List<String> categories;
  final ValueChanged<String?> onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isDense: true,
          value: value,
          hint: const Text('없음', style: TextStyle(fontSize: 12)),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('없음', style: TextStyle(fontSize: 12)),
            ),
            ...categories.map(
              (category) => DropdownMenuItem<String?>(
                value: category,
                child: Text(category, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
