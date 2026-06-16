import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/category_tab_store.dart';
import '../models/journal_category_tab.dart';
import '../utils/category_theme.dart';

/// 상단 카테고리 헤더 — 번호 표시, 인라인 편집, 배치 추가, 통계 탭.
class CategoryTabBar extends StatefulWidget {
  const CategoryTabBar({
    super.key,
    required this.tabs,
    required this.selectedTabId,
    required this.onTabSelected,
    required this.onTabRenamed,
    required this.onBatchTabsAdded,
    required this.onTabRemoved,
    required this.onAnalyticsSelected,
  });

  final List<JournalCategoryTab> tabs;
  final String selectedTabId;
  final ValueChanged<JournalCategoryTab> onTabSelected;
  final void Function(JournalCategoryTab tab, String newTitle) onTabRenamed;
  final VoidCallback onBatchTabsAdded;
  final ValueChanged<JournalCategoryTab> onTabRemoved;
  final VoidCallback onAnalyticsSelected;

  static const double barHeight = 48;

  @override
  State<CategoryTabBar> createState() => _CategoryTabBarState();
}

class _CategoryTabBarState extends State<CategoryTabBar> {
  String? _editingTabId;
  late final TextEditingController _editController;
  late final FocusNode _editFocusNode;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController();
    _editFocusNode = FocusNode();
    _editFocusNode.addListener(_handleEditFocusChange);
  }

  @override
  void dispose() {
    _editFocusNode.removeListener(_handleEditFocusChange);
    _editFocusNode.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _handleEditFocusChange() {
    if (!_editFocusNode.hasFocus && _editingTabId != null) {
      _commitEdit();
    }
  }

  void _startEditing(JournalCategoryTab tab) {
    if (tab.isOverview) {
      return;
    }
    setState(() {
      _editingTabId = tab.id;
      _editController
        ..text = tab.title
        ..selection = TextSelection(
          baseOffset: 0,
          extentOffset: tab.title.length,
        );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _editingTabId != tab.id) {
        return;
      }
      _editFocusNode.requestFocus();
    });
  }

  void _commitEdit() {
    final tabId = _editingTabId;
    if (tabId == null) {
      return;
    }

    final tab = CategoryTabStore.findById(widget.tabs, tabId);
    if (tab != null && _editController.text.trim() != tab.title) {
      widget.onTabRenamed(tab, _editController.text);
    }

    setState(() => _editingTabId = null);
  }

  bool get _canAddBatch =>
      widget.tabs.length < JournalCategoryTab.maxTabs;

  bool get _isAnalyticsSelected =>
      widget.selectedTabId == JournalCategoryTab.analyticsId;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CategoryTheme.headerBackground,
      child: SizedBox(
        height: CategoryTabBar.barHeight,
        child: Row(
            children: [
              Expanded(
                child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
                itemCount: widget.tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final tab = widget.tabs[index];
                  final isSelected = tab.id == widget.selectedTabId;
                  final isEditing = _editingTabId == tab.id;

                  return _CategoryChip(
                    label: CategoryTabStore.displayLabel(tab, widget.tabs),
                    isSelected: isSelected,
                    isEditing: isEditing,
                    canEdit: !tab.isOverview,
                    editButtonKey: Key('category-edit-${tab.id}'),
                    editController: _editController,
                    editFocusNode: _editFocusNode,
                    onTap: () {
                      if (isEditing) {
                        return;
                      }
                      widget.onTabSelected(tab);
                    },
                    onEditRequested: () => _startEditing(tab),
                    onEditSubmitted: _commitEdit,
                    onRemove:
                        tab.isOverview ? null : () => widget.onTabRemoved(tab),
                  );
                },
              ),
            ),
            _AddBatchButton(
              key: const Key('category-batch-add'),
              enabled: _canAddBatch,
              onTap: widget.onBatchTabsAdded,
            ),
            const SizedBox(width: 6),
            _AnalyticsChip(
              key: const Key('category-analytics-tab'),
              isSelected: _isAnalyticsSelected,
              onTap: widget.onAnalyticsSelected,
            ),
            ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.isEditing,
    required this.canEdit,
    this.editButtonKey,
    required this.editController,
    required this.editFocusNode,
    required this.onTap,
    required this.onEditRequested,
    required this.onEditSubmitted,
    this.onRemove,
  });

  final String label;
  final bool isSelected;
  final bool isEditing;
  final bool canEdit;
  final Key? editButtonKey;
  final TextEditingController editController;
  final FocusNode editFocusNode;
  final VoidCallback onTap;
  final VoidCallback onEditRequested;
  final VoidCallback onEditSubmitted;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final background = isSelected
        ? CategoryTheme.headerSelectedChipFill
        : CategoryTheme.headerBackground.withValues(alpha: 0.85);

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: const BoxConstraints(
          minWidth: CategoryTheme.chipMinWidth,
          minHeight: CategoryTheme.chipHeight,
        ),
        padding: const EdgeInsets.only(left: 4, right: 2),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white24 : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onTap,
              onDoubleTap: canEdit ? onEditRequested : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: isEditing
                    ? SizedBox(
                        width: 72,
                        child: TextField(
                          controller: editController,
                          focusNode: editFocusNode,
                          maxLength: JournalCategoryTab.maxTitleLength,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                              JournalCategoryTab.maxTitleLength,
                            ),
                          ],
                          style: const TextStyle(
                            color: CategoryTheme.headerChipText,
                            fontSize: CategoryTheme.chipFontSize,
                            fontWeight: CategoryTheme.chipFontWeight,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => onEditSubmitted(),
                        ),
                      )
                    : Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? CategoryTheme.headerChipText
                              : CategoryTheme.headerChipTextMuted,
                          fontSize: CategoryTheme.chipFontSize,
                          fontWeight: CategoryTheme.chipFontWeight,
                        ),
                      ),
              ),
            ),
            if (canEdit && !isEditing)
              IconButton(
                key: editButtonKey,
                onPressed: onEditRequested,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                icon: Icon(
                  Icons.edit_outlined,
                  size: 13,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            if (onRemove != null && !isEditing)
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddBatchButton extends StatelessWidget {
  const _AddBatchButton({
    super.key,
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: CategoryTheme.chipHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled ? Colors.white24 : Colors.white10,
            ),
          ),
          child: Icon(
            Icons.add,
            size: 18,
            color: enabled ? Colors.white70 : Colors.white30,
          ),
        ),
      ),
    );
  }
}

class _AnalyticsChip extends StatelessWidget {
  const _AnalyticsChip({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: CategoryTabBar.barHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? CategoryTheme.analyticsAccent.withValues(alpha: 0.22)
                : CategoryTheme.headerBackground,
            border: Border(
              left: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 16,
                color: isSelected
                    ? CategoryTheme.analyticsAccent
                    : Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                JournalCategoryTab.analyticsTitle,
                style: TextStyle(
                  color: isSelected
                      ? CategoryTheme.analyticsAccent
                      : CategoryTheme.headerChipTextMuted,
                  fontSize: CategoryTheme.chipFontSize,
                  fontWeight: CategoryTheme.chipFontWeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
