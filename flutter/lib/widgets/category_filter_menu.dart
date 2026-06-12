import 'package:flutter/material.dart';

import '../models/category_store.dart';

/// 웹 MVP `CategoryFilterMenu.tsx` 대응.
class CategoryFilterMenu extends StatefulWidget {
  const CategoryFilterMenu({
    super.key,
    required this.filterOptions,
    required this.selectedCategory,
    required this.onSelect,
    required this.onAddCategory,
    required this.onRemoveCategory,
  });

  final List<String> filterOptions;
  final String selectedCategory;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onAddCategory;
  final ValueChanged<String> onRemoveCategory;

  @override
  State<CategoryFilterMenu> createState() => _CategoryFilterMenuState();
}

class _CategoryFilterMenuState extends State<CategoryFilterMenu> {
  final _newCategoryController = TextEditingController();

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _handleAddCategory() {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty) {
      return;
    }
    widget.onAddCategory(name);
    _newCategoryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 224,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final category in widget.filterOptions)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        widget.onSelect(category);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        color: widget.selectedCategory == category
                            ? Colors.blue.shade50
                            : null,
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: widget.selectedCategory == category
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: widget.selectedCategory == category
                                ? Colors.blue.shade700
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (category != CategoryStore.filterAll &&
                      !CategoryStore.isBuiltinCategory(category))
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: '$category 카테고리 삭제',
                      onPressed: () => widget.onRemoveCategory(category),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '카테고리 추가',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newCategoryController,
                          decoration: const InputDecoration(
                            hintText: '새 카테고리',
                            isDense: true,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                          style: const TextStyle(fontSize: 14),
                          onSubmitted: (_) => _handleAddCategory(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      FilledButton(
                        onPressed: _handleAddCategory,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('추가', style: TextStyle(fontSize: 12)),
                      ),
                    ],
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
