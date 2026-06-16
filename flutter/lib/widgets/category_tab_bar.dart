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

  static const double barHeight = CategoryTheme.headerBarHeight;

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
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CategoryTheme.headerOverlayBorder),
        ),
      ),
      child: SizedBox(
        height: CategoryTabBar.barHeight,
        child: Row(
          children: [
            Expanded(
              child: _ScrollableTabStrip(
                tabs: widget.tabs,
                selectedTabId: widget.selectedTabId,
                editingTabId: _editingTabId,
                editController: _editController,
                editFocusNode: _editFocusNode,
                onTabSelected: widget.onTabSelected,
                onEditRequested: _startEditing,
                onEditSubmitted: _commitEdit,
                onTabRemoved: widget.onTabRemoved,
              ),
            ),
            const _HeaderToolbarDivider(),
            _AddBatchButton(
              key: const Key('category-batch-add'),
              enabled: _canAddBatch,
              onTap: widget.onBatchTabsAdded,
            ),
            const SizedBox(width: 4),
            _AnalyticsChip(
              key: const Key('category-analytics-tab'),
              isSelected: _isAnalyticsSelected,
              onTap: widget.onAnalyticsSelected,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _ScrollableTabStrip extends StatelessWidget {
  const _ScrollableTabStrip({
    required this.tabs,
    required this.selectedTabId,
    required this.editingTabId,
    required this.editController,
    required this.editFocusNode,
    required this.onTabSelected,
    required this.onEditRequested,
    required this.onEditSubmitted,
    required this.onTabRemoved,
  });

  final List<JournalCategoryTab> tabs;
  final String selectedTabId;
  final String? editingTabId;
  final TextEditingController editController;
  final FocusNode editFocusNode;
  final ValueChanged<JournalCategoryTab> onTabSelected;
  final ValueChanged<JournalCategoryTab> onEditRequested;
  final VoidCallback onEditSubmitted;
  final ValueChanged<JournalCategoryTab> onTabRemoved;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 9, 28, 9),
          itemCount: tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final tab = tabs[index];
            final isSelected = tab.id == selectedTabId;
            final isEditing = editingTabId == tab.id;

            return _CategoryChip(
              tab: tab,
              label: CategoryTabStore.displayLabel(tab, tabs),
              isSelected: isSelected,
              isEditing: isEditing,
              canEdit: !tab.isOverview,
              editButtonKey: Key('category-edit-${tab.id}'),
              editController: editController,
              editFocusNode: editFocusNode,
              onTap: () {
                if (isEditing) {
                  return;
                }
                onTabSelected(tab);
              },
              onEditRequested: () => onEditRequested(tab),
              onEditSubmitted: onEditSubmitted,
              onRemove: tab.isOverview ? null : () => onTabRemoved(tab),
            );
          },
        ),
        const Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 28,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0x00000000),
                    Color(0x33000000),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.tab,
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

  final JournalCategoryTab tab;
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
    final accent = tab.accentColor;

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(
          minWidth: CategoryTheme.chipMinWidth,
          minHeight: CategoryTheme.chipHeight,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? CategoryTheme.tabSelectedFill
              : CategoryTheme.tabUnselectedFill,
          borderRadius: BorderRadius.circular(CategoryTheme.tabPillRadius),
          border: Border.all(
            color: isSelected
                ? CategoryTheme.tabSelectedBorder
                : CategoryTheme.tabUnselectedBorder,
            width: isSelected ? 1.2 : 1,
          ),
          boxShadow: isSelected ? CategoryTheme.tabSelectedShadow(accent) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onTap,
              onDoubleTap: canEdit ? onEditRequested : null,
              borderRadius:
                  BorderRadius.circular(CategoryTheme.tabPillRadius),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  canEdit && !isEditing ? 10 : 12,
                  7,
                  canEdit && !isEditing ? 2 : 12,
                  7,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TabLeadingIcon(tab: tab, isSelected: isSelected),
                    const SizedBox(width: 6),
                    if (isEditing)
                      SizedBox(
                        width: 68,
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
                            color: CategoryTheme.tabSelectedText,
                            fontSize: CategoryTheme.chipFontSize,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
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
                    else
                      Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? CategoryTheme.tabSelectedText
                              : CategoryTheme.tabUnselectedText,
                          fontSize: CategoryTheme.chipFontSize,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : CategoryTheme.chipFontWeight,
                          letterSpacing: -0.1,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (canEdit && !isEditing) ...[
              _ChipIconButton(
                buttonKey: editButtonKey,
                icon: Icons.edit_rounded,
                onPressed: onEditRequested,
                tooltip: '이름 편집',
                isSelected: isSelected,
              ),
              if (onRemove != null)
                _ChipIconButton(
                  icon: Icons.close_rounded,
                  onPressed: onRemove!,
                  tooltip: '카테고리 삭제',
                  isDestructive: true,
                  isSelected: isSelected,
                ),
            ],
            if (canEdit && !isEditing) const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _TabLeadingIcon extends StatelessWidget {
  const _TabLeadingIcon({
    required this.tab,
    required this.isSelected,
  });

  final JournalCategoryTab tab;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (tab.isOverview) {
      return Icon(
        Icons.grid_view_rounded,
        size: CategoryTheme.tabIconSize,
        color: isSelected
            ? CategoryTheme.tabSelectedText
            : CategoryTheme.tabUnselectedText,
      );
    }

    return Container(
      width: CategoryTheme.tabColorDotSize,
      height: CategoryTheme.tabColorDotSize,
      decoration: BoxDecoration(
        color: tab.accentColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: tab.accentColor.withValues(alpha: 0.55),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _ChipIconButton extends StatelessWidget {
  const _ChipIconButton({
    this.buttonKey,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isDestructive = false,
    this.isSelected = true,
  });

  final Key? buttonKey;
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isDestructive;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    if (isDestructive) {
      iconColor = isSelected
          ? const Color(0xFFEF4444).withValues(alpha: 0.75)
          : const Color(0xFFFCA5A5).withValues(alpha: 0.85);
    } else {
      iconColor = isSelected
          ? CategoryTheme.tabSelectedText.withValues(alpha: 0.45)
          : Colors.white.withValues(alpha: 0.55);
    }

    return Tooltip(
      message: tooltip,
      child: IconButton(
        key: buttonKey,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
        icon: Icon(
          icon,
          size: 13,
          color: iconColor,
        ),
      ),
    );
  }
}

class _HeaderToolbarDivider extends StatelessWidget {
  const _HeaderToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: CategoryTheme.toolbarDivider,
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
    return Tooltip(
      message: enabled ? '카테고리 5개 추가' : '최대 11개까지 추가 가능',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(CategoryTheme.tabPillRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: enabled
                  ? CategoryTheme.analyticsAccent.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: enabled
                    ? CategoryTheme.analyticsAccent.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1.2,
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              size: 18,
              color: enabled
                  ? CategoryTheme.analyticsAccent
                  : CategoryTheme.toolbarIconMuted.withValues(alpha: 0.5),
            ),
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
    final accent = CategoryTheme.analyticsAccent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CategoryTheme.tabPillRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: CategoryTheme.chipHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(CategoryTheme.tabPillRadius),
            border: Border.all(
              color: isSelected
                  ? accent.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.1),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insights_rounded,
                size: CategoryTheme.tabIconSize,
                color: isSelected ? accent : CategoryTheme.toolbarIconMuted,
              ),
              const SizedBox(width: 5),
              Text(
                JournalCategoryTab.analyticsTitle,
                style: TextStyle(
                  color: isSelected
                      ? accent
                      : CategoryTheme.toolbarIconActive,
                  fontSize: CategoryTheme.chipFontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
