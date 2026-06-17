import 'package:flutter/material.dart';

import '../models/category_tab_store.dart';
import '../models/journal_category_tab.dart';
import '../utils/category_theme.dart';

/// 설정에서 카테고리를 삭제할 때 사용하는 다이얼로그.
class CategoryManageDialog extends StatefulWidget {
  const CategoryManageDialog({
    super.key,
    required this.tabs,
    required this.onDeleteTab,
  });

  final List<JournalCategoryTab> tabs;
  final Future<void> Function(JournalCategoryTab tab) onDeleteTab;

  static Future<void> show(
    BuildContext context, {
    required List<JournalCategoryTab> tabs,
    required Future<void> Function(JournalCategoryTab tab) onDeleteTab,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CategoryManageDialog(
          tabs: tabs,
          onDeleteTab: onDeleteTab,
        );
      },
    );
  }

  @override
  State<CategoryManageDialog> createState() => _CategoryManageDialogState();
}

class _CategoryManageDialogState extends State<CategoryManageDialog> {
  late List<JournalCategoryTab> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = List<JournalCategoryTab>.from(widget.tabs);
  }

  List<JournalCategoryTab> get _deletableTabs =>
      _tabs.where((tab) => !tab.isOverview).toList();

  Future<void> _confirmDelete(JournalCategoryTab tab) async {
    final label = CategoryTabStore.displayLabel(tab, _tabs);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (confirmContext) {
        return AlertDialog(
          title: const Text('카테고리 삭제'),
          content: Text('"$label" 카테고리를 삭제할까요?\n연결된 일정의 카테고리도 함께 제거됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(confirmContext).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(confirmContext).pop(true),
              child: const Text(
                '삭제',
                style: TextStyle(color: Color(0xFFDC2626)),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await widget.onDeleteTab(tab);

    if (!mounted) {
      return;
    }

    setState(() {
      _tabs = CategoryTabStore.removeTab(_tabs, tab.id);
    });

    if (_deletableTabs.isEmpty) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deletableTabs = _deletableTabs;

    return AlertDialog(
      title: const Text('카테고리 삭제'),
      content: SizedBox(
        width: double.maxFinite,
        child: deletableTabs.isEmpty
            ? const Text('삭제할 카테고리가 없습니다.')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: deletableTabs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final tab = deletableTabs[index];
                  final label = CategoryTabStore.displayLabel(tab, _tabs);

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: CategoryTheme.tabColorDotSize,
                      height: CategoryTheme.tabColorDotSize,
                      decoration: BoxDecoration(
                        color: tab.accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    title: Text(label),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: const Color(0xFFDC2626),
                      tooltip: '삭제',
                      onPressed: () => _confirmDelete(tab),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}
