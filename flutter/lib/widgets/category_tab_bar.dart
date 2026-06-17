import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/category_tab_store.dart';
import '../models/journal_category_tab.dart';
import '../utils/category_theme.dart';
import '../utils/calendar_font_settings.dart';
import '../utils/category_input_layout.dart';

/// 상단 카테고리 헤더 — 번호 표시, 인라인 편집, 배치 추가, 통계 탭.
class CategoryTabBar extends StatefulWidget {
  const CategoryTabBar({
    super.key,
    required this.tabs,
    required this.selectedTabId,
    required this.onTabSelected,
    required this.onTabRenamed,
    required this.onBatchTabsAdded,
    required this.onAnalyticsSelected,
    required this.onManageCategories,
    required this.onDataTransfer,
    required this.calendarTaskFontPt,
    required this.onCalendarTaskFontPtChanged,
    required this.categoryInputLayout,
    required this.onCategoryInputLayoutChanged,
  });

  final List<JournalCategoryTab> tabs;
  final String selectedTabId;
  final ValueChanged<JournalCategoryTab> onTabSelected;
  final void Function(JournalCategoryTab tab, String newTitle) onTabRenamed;
  final VoidCallback onBatchTabsAdded;
  final VoidCallback onAnalyticsSelected;
  final VoidCallback onManageCategories;
  final VoidCallback onDataTransfer;
  final int calendarTaskFontPt;
  final ValueChanged<int> onCalendarTaskFontPtChanged;
  final CategoryInputLayoutPreference categoryInputLayout;
  final ValueChanged<CategoryInputLayoutPreference> onCategoryInputLayoutChanged;

  static const double barHeight = CategoryTheme.headerBarHeight;
  static const double totalHeight = CategoryTheme.headerTotalHeight;

  @override
  State<CategoryTabBar> createState() => _CategoryTabBarState();
}

class _CategoryTabBarState extends State<CategoryTabBar> {
  String? _editingTabId;
  late final TextEditingController _editController;
  late final FocusNode _editFocusNode;
  double? _selectedTabGapLeft;
  double? _selectedTabGapRight;

  bool get _showsCategoryTabGap =>
      widget.selectedTabId != JournalCategoryTab.analyticsId;

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
        height: CategoryTheme.headerTotalHeight,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: 0,
              right: CategoryTheme.headerToolbarWidth,
              bottom: 0,
              height: CategoryTabBar.barHeight,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _TabRowBottomRule(
                      gapLeft: _showsCategoryTabGap ? _selectedTabGapLeft : null,
                      gapRight:
                          _showsCategoryTabGap ? _selectedTabGapRight : null,
                    ),
                  ),
                  _ScrollableTabStrip(
                    tabs: widget.tabs,
                    selectedTabId: widget.selectedTabId,
                    editingTabId: _editingTabId,
                    editController: _editController,
                    editFocusNode: _editFocusNode,
                    canAddBatch: _canAddBatch,
                    onBatchTabsAdded: widget.onBatchTabsAdded,
                    onTabSelected: widget.onTabSelected,
                    onEditRequested: _startEditing,
                    onEditSubmitted: _commitEdit,
                    onSelectedTabBoundsChanged: (left, right) {
                      if (_selectedTabGapLeft == left &&
                          _selectedTabGapRight == right) {
                        return;
                      }
                      setState(() {
                        _selectedTabGapLeft = left;
                        _selectedTabGapRight = right;
                      });
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              width: CategoryTheme.headerToolbarWidth,
              height: CategoryTheme.headerTotalHeight,
              child: ColoredBox(
                color: CategoryTheme.headerBackground,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _HeaderRuleLine(),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _HeaderToolbarRow(
                        isAnalyticsSelected: _isAnalyticsSelected,
                        onAnalyticsSelected: widget.onAnalyticsSelected,
                        onDataTransfer: widget.onDataTransfer,
                        onManageCategories: widget.onManageCategories,
                        calendarTaskFontPt: widget.calendarTaskFontPt,
                        onCalendarTaskFontPtChanged:
                            widget.onCalendarTaskFontPtChanged,
                        categoryInputLayout: widget.categoryInputLayout,
                        onCategoryInputLayoutChanged:
                            widget.onCategoryInputLayoutChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderRuleLine extends StatelessWidget {
  const _HeaderRuleLine({
    this.thickness = CategoryTheme.tabUnselectedBorderWidth,
  });

  final double thickness;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CategoryTheme.headerOverlayBorder,
      child: SizedBox(height: thickness, width: double.infinity),
    );
  }
}

class _TabRowBottomRule extends StatelessWidget {
  const _TabRowBottomRule({
    this.gapLeft,
    this.gapRight,
  });

  final double? gapLeft;
  final double? gapRight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final hasGap = gapLeft != null &&
            gapRight != null &&
            gapRight! > gapLeft!;
        final thickness = hasGap
            ? CategoryTheme.tabSelectedBorderWidth
            : CategoryTheme.tabUnselectedBorderWidth;

        return SizedBox(
          height: thickness,
          width: width,
          child: CustomPaint(
            painter: _TabRowBottomRulePainter(
              gapLeft: gapLeft,
              gapRight: gapRight,
              thickness: thickness,
            ),
          ),
        );
      },
    );
  }
}

class _TabRowBottomRulePainter extends CustomPainter {
  _TabRowBottomRulePainter({
    this.gapLeft,
    this.gapRight,
    required this.thickness,
  });

  final double? gapLeft;
  final double? gapRight;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CategoryTheme.headerOverlayBorder
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final width = size.width;
    final y = size.height - thickness / 2;
    final hasGap =
        gapLeft != null && gapRight != null && gapRight! > gapLeft!;

    if (!hasGap) {
      canvas.drawLine(Offset(0, y), Offset(width, y), paint);
      return;
    }

    final left = gapLeft!.clamp(0.0, width);
    final right = gapRight!.clamp(0.0, width);

    if (left > 0) {
      canvas.drawLine(Offset(0, y), Offset(left, y), paint);
    }
    if (right < width) {
      canvas.drawLine(Offset(right, y), Offset(width, y), paint);
    }

    // 선택 탭 좌·우 세로 테두리와 가로 구분선이 모서리에서 맞닿도록 연결
    canvas.drawLine(Offset(left, y - thickness), Offset(left, y), paint);
    canvas.drawLine(Offset(right, y - thickness), Offset(right, y), paint);
  }

  @override
  bool shouldRepaint(covariant _TabRowBottomRulePainter oldDelegate) {
    return oldDelegate.gapLeft != gapLeft ||
        oldDelegate.gapRight != gapRight ||
        oldDelegate.thickness != thickness;
  }
}

class _HeaderToolbarRow extends StatelessWidget {
  const _HeaderToolbarRow({
    required this.isAnalyticsSelected,
    required this.onAnalyticsSelected,
    required this.onDataTransfer,
    required this.onManageCategories,
    required this.calendarTaskFontPt,
    required this.onCalendarTaskFontPtChanged,
    required this.categoryInputLayout,
    required this.onCategoryInputLayoutChanged,
  });

  final bool isAnalyticsSelected;
  final VoidCallback onAnalyticsSelected;
  final VoidCallback onDataTransfer;
  final VoidCallback onManageCategories;
  final int calendarTaskFontPt;
  final ValueChanged<int> onCalendarTaskFontPtChanged;
  final CategoryInputLayoutPreference categoryInputLayout;
  final ValueChanged<CategoryInputLayoutPreference> onCategoryInputLayoutChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const _HeaderToolbarDivider(),
        _AnalyticsChip(
          key: const Key('category-analytics-tab'),
          isSelected: isAnalyticsSelected,
          onTap: onAnalyticsSelected,
        ),
        const SizedBox(width: 4),
        _SettingsMenuButton(
          key: const Key('category-settings-menu'),
          onDataTransfer: onDataTransfer,
          onManageCategories: onManageCategories,
          calendarTaskFontPt: calendarTaskFontPt,
          onCalendarTaskFontPtChanged: onCalendarTaskFontPtChanged,
          categoryInputLayout: categoryInputLayout,
          onCategoryInputLayoutChanged: onCategoryInputLayoutChanged,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _ScrollableTabStrip extends StatefulWidget {
  const _ScrollableTabStrip({
    required this.tabs,
    required this.selectedTabId,
    required this.editingTabId,
    required this.editController,
    required this.editFocusNode,
    required this.canAddBatch,
    required this.onBatchTabsAdded,
    required this.onTabSelected,
    required this.onEditRequested,
    required this.onEditSubmitted,
    required this.onSelectedTabBoundsChanged,
  });

  final List<JournalCategoryTab> tabs;
  final String selectedTabId;
  final String? editingTabId;
  final TextEditingController editController;
  final FocusNode editFocusNode;
  final bool canAddBatch;
  final VoidCallback onBatchTabsAdded;
  final ValueChanged<JournalCategoryTab> onTabSelected;
  final ValueChanged<JournalCategoryTab> onEditRequested;
  final VoidCallback onEditSubmitted;
  final void Function(double? left, double? right) onSelectedTabBoundsChanged;

  @override
  State<_ScrollableTabStrip> createState() => _ScrollableTabStripState();
}

class _ScrollableTabStripState extends State<_ScrollableTabStrip> {
  final GlobalKey _selectedTabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_reportSelectedTabBounds);
  }

  @override
  void didUpdateWidget(covariant _ScrollableTabStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTabId != widget.selectedTabId ||
        oldWidget.tabs != widget.tabs) {
      WidgetsBinding.instance.addPostFrameCallback(_reportSelectedTabBounds);
    }
  }

  void _reportSelectedTabBounds([_]) {
    if (!mounted) {
      return;
    }

    if (widget.selectedTabId == JournalCategoryTab.analyticsId) {
      widget.onSelectedTabBoundsChanged(null, null);
      return;
    }

    final tabContext = _selectedTabKey.currentContext;
    final stripBox = context.findRenderObject() as RenderBox?;
    if (tabContext == null || stripBox == null || !stripBox.hasSize) {
      widget.onSelectedTabBoundsChanged(null, null);
      return;
    }

    final tabBox = tabContext.findRenderObject() as RenderBox?;
    if (tabBox == null || !tabBox.hasSize) {
      widget.onSelectedTabBoundsChanged(null, null);
      return;
    }

    final tabOrigin = tabBox.localToGlobal(Offset.zero, ancestor: stripBox);
    widget.onSelectedTabBoundsChanged(
      tabOrigin.dx.clamp(0.0, stripBox.size.width),
      (tabOrigin.dx + tabBox.size.width).clamp(0.0, stripBox.size.width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        WidgetsBinding.instance
            .addPostFrameCallback(_reportSelectedTabBounds);
        return false;
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var index = 0; index < widget.tabs.length; index++) ...[
              if (index > 0) const SizedBox(width: 3),
              Align(
                alignment: Alignment.bottomCenter,
                child: _CategoryTab(
                  key: widget.tabs[index].id == widget.selectedTabId
                      ? _selectedTabKey
                      : null,
                  tab: widget.tabs[index],
                  label: CategoryTabStore.displayLabel(
                    widget.tabs[index],
                    widget.tabs,
                  ),
                  isSelected: widget.tabs[index].id == widget.selectedTabId,
                  isEditing: widget.editingTabId == widget.tabs[index].id,
                  canEdit: !widget.tabs[index].isOverview,
                  editButtonKey: Key('category-edit-${widget.tabs[index].id}'),
                  editController: widget.editController,
                  editFocusNode: widget.editFocusNode,
                  onTap: () {
                    if (widget.editingTabId == widget.tabs[index].id) {
                      return;
                    }
                    widget.onTabSelected(widget.tabs[index]);
                  },
                  onEditRequested: () =>
                      widget.onEditRequested(widget.tabs[index]),
                  onEditSubmitted: widget.onEditSubmitted,
                ),
              ),
            ],
            const SizedBox(width: 3),
            _AddBatchButton(
              key: const Key('category-batch-add'),
              enabled: widget.canAddBatch,
              onTap: widget.onBatchTabsAdded,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    final tabHeight = isSelected
        ? CategoryTheme.chipHeight
        : CategoryTheme.chipHeightUnselected;
    final borderColor = isSelected
        ? CategoryTheme.tabSelectedBorder
        : CategoryTheme.tabUnselectedBorder;

    final tabBody = Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: tabHeight,
          constraints:
              const BoxConstraints(minWidth: CategoryTheme.chipMinWidth),
          decoration: BoxDecoration(
            color: isSelected
                ? CategoryTheme.tabSelectedFill
                : CategoryTheme.tabUnselectedFill,
            borderRadius: CategoryTheme.diaryTabRadius,
          ),
          child: CustomPaint(
            painter: _DiaryTabOutlinePainter(
              radius: CategoryTheme.tabTopRadius,
              color: borderColor,
              strokeWidth: isSelected
                  ? CategoryTheme.tabSelectedBorderWidth
                  : CategoryTheme.tabUnselectedBorderWidth,
              includeBottom: !isSelected,
            ),
            child: ClipRRect(
              borderRadius: CategoryTheme.diaryTabRadius,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: isSelected ? 2 : 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: onTap,
                          onDoubleTap: canEdit ? onEditRequested : null,
                          borderRadius: CategoryTheme.diaryTabRadius,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              canEdit && !isEditing ? 8 : 10,
                              4,
                              canEdit && !isEditing ? 0 : 8,
                              4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _TabLeadingIcon(
                                  tab: tab,
                                  isSelected: isSelected,
                                ),
                                const SizedBox(width: 5),
                                if (isEditing)
                                  SizedBox(
                                    width: 64,
                                    child: TextField(
                                      controller: editController,
                                      focusNode: editFocusNode,
                                      maxLength:
                                          JournalCategoryTab.maxTitleLength,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(
                                          JournalCategoryTab.maxTitleLength,
                                        ),
                                      ],
                                      style: const TextStyle(
                                        color: CategoryTheme.tabSelectedText,
                                        fontSize: CategoryTheme.chipFontSize,
                                        fontWeight: FontWeight.w600,
                                        height: 1.1,
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
                                      height: 1.1,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (canEdit && !isEditing)
                          _TabIconButton(
                            buttonKey: editButtonKey,
                            icon: Icons.edit_outlined,
                            onPressed: onEditRequested,
                            tooltip: '이름 편집',
                            isSelected: isSelected,
                          ),
                        if (canEdit && !isEditing) const SizedBox(width: 2),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: tab.accentColor,
                          borderRadius: CategoryTheme.diaryTabRadius,
                        ),
                        child: const SizedBox(height: 2),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (isSelected)
          Positioned(
            left: 0,
            right: 0,
            bottom: -CategoryTheme.tabCalendarBridgeHeight,
            child: ColoredBox(
              color: CategoryTheme.tabSelectedFill,
              child: SizedBox(height: CategoryTheme.tabCalendarBridgeHeight),
            ),
          ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: tabBody,
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
        Icons.menu_book_outlined,
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
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _TabIconButton extends StatelessWidget {
  const _TabIconButton({
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
          : CategoryTheme.tabUnselectedText.withValues(alpha: 0.7);
    }

    return Tooltip(
      message: tooltip,
      child: IconButton(
        key: buttonKey,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        icon: Icon(
          icon,
          size: 12,
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
      height: 18,
      margin: const EdgeInsets.fromLTRB(4, 0, 4, 6),
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
      message: enabled ? '카테고리 추가' : '최대 11개까지 추가 가능',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: CategoryTheme.diaryTabRadius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 28,
            height: CategoryTheme.chipHeightUnselected,
            margin: const EdgeInsets.only(bottom: 0),
            decoration: BoxDecoration(
              color: enabled
                  ? CategoryTheme.analyticsAccent.withValues(alpha: 0.1)
                  : CategoryTheme.tabUnselectedFill,
              borderRadius: CategoryTheme.diaryTabRadius,
              border: Border.all(
                color: enabled
                    ? CategoryTheme.analyticsAccent.withValues(alpha: 0.35)
                    : CategoryTheme.tabUnselectedBorder,
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              size: 16,
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
    final tabHeight = isSelected
        ? CategoryTheme.chipHeight
        : CategoryTheme.chipHeightUnselected;

    return Tooltip(
      message: JournalCategoryTab.analyticsTitle,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: CategoryTheme.diaryTabRadius,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                height: tabHeight,
                width: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? CategoryTheme.tabSelectedFill
                      : CategoryTheme.tabUnselectedFill,
                  borderRadius: CategoryTheme.diaryTabRadius,
                ),
                child: CustomPaint(
                  painter: _DiaryTabOutlinePainter(
                    radius: CategoryTheme.tabTopRadius,
                    color: isSelected
                        ? CategoryTheme.tabSelectedBorder
                        : CategoryTheme.tabUnselectedBorder,
                    strokeWidth: isSelected
                        ? CategoryTheme.tabSelectedBorderWidth
                        : CategoryTheme.tabUnselectedBorderWidth,
                    includeBottom: !isSelected,
                  ),
                  child: ClipRRect(
                    borderRadius: CategoryTheme.diaryTabRadius,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart_outlined,
                          size: CategoryTheme.tabIconSize + 2,
                          color: isSelected
                              ? accent
                              : CategoryTheme.toolbarIconMuted,
                        ),
                        if (isSelected)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: CategoryTheme.diaryTabRadius,
                              ),
                              child: const SizedBox(height: 2),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -CategoryTheme.tabCalendarBridgeHeight,
                  child: const ColoredBox(
                    color: CategoryTheme.tabSelectedFill,
                    child: SizedBox(height: CategoryTheme.tabCalendarBridgeHeight),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsMenuButton extends StatelessWidget {
  const _SettingsMenuButton({
    super.key,
    required this.onDataTransfer,
    required this.onManageCategories,
    required this.calendarTaskFontPt,
    required this.onCalendarTaskFontPtChanged,
    required this.categoryInputLayout,
    required this.onCategoryInputLayoutChanged,
  });

  final VoidCallback onDataTransfer;
  final VoidCallback onManageCategories;
  final int calendarTaskFontPt;
  final ValueChanged<int> onCalendarTaskFontPtChanged;
  final CategoryInputLayoutPreference categoryInputLayout;
  final ValueChanged<CategoryInputLayoutPreference> onCategoryInputLayoutChanged;

  static const _dataTransferValue = 'data-transfer';
  static const _manageCategoriesValue = 'manage-categories';

  static String _fontValue(int pt) => 'font-$pt';

  static int? _parseFontValue(String value) {
    if (!value.startsWith('font-')) {
      return null;
    }
    return CalendarFontSettings.sanitize(int.tryParse(value.substring(5)));
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '설정',
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          tooltip: '설정',
          offset: const Offset(0, 4),
          constraints: const BoxConstraints(minWidth: 232),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onSelected: (value) {
            final fontPt = _parseFontValue(value);
            if (fontPt != null) {
              onCalendarTaskFontPtChanged(fontPt);
              return;
            }
            final inputLayout = CategoryInputLayout.parseMenuValue(value);
            if (inputLayout != null) {
              onCategoryInputLayoutChanged(inputLayout);
              return;
            }
            switch (value) {
              case _dataTransferValue:
                onDataTransfer();
              case _manageCategoriesValue:
                onManageCategories();
            }
          },
          itemBuilder: (context) => [
            const _SettingsBrandingHeader(),
            const PopupMenuDivider(height: 1),
            const PopupMenuItem<String>(
              enabled: false,
              child: Text(
                '항목 입력 방식',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CategoryTheme.appTextMuted,
                ),
              ),
            ),
            for (final layout in CategoryInputLayoutPreference.values)
              PopupMenuItem<String>(
                value: CategoryInputLayout.preferenceMenuValue(layout),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      child: layout == categoryInputLayout
                          ? const Icon(Icons.check, size: 16)
                          : null,
                    ),
                    Expanded(
                      child: Text(
                        CategoryInputLayout.preferenceLabel(layout),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            const PopupMenuDivider(height: 1),
            const PopupMenuItem<String>(
              enabled: false,
              child: Text(
                '달력 글자 크기',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CategoryTheme.appTextMuted,
                ),
              ),
            ),
            for (final pt in CalendarFontSettings.availablePtSizes)
              PopupMenuItem<String>(
                value: _fontValue(pt),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      child: pt == calendarTaskFontPt
                          ? const Icon(Icons.check, size: 16)
                          : null,
                    ),
                    Text(CalendarFontSettings.label(pt)),
                  ],
                ),
              ),
            const PopupMenuDivider(height: 1),
            const PopupMenuItem<String>(
              value: _dataTransferValue,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sync_alt, size: 18),
                  SizedBox(width: 10),
                  Text('가져오기'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: _manageCategoriesValue,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, size: 18),
                  SizedBox(width: 10),
                  Text('카테고리 삭제'),
                ],
              ),
            ),
          ],
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 32,
            height: CategoryTheme.chipHeightUnselected,
            decoration: BoxDecoration(
              color: CategoryTheme.tabUnselectedFill,
              borderRadius: CategoryTheme.diaryTabRadius,
              border: Border.all(color: CategoryTheme.tabUnselectedBorder),
            ),
            child: const Icon(
              Icons.settings_outlined,
              size: 16,
              color: CategoryTheme.toolbarIconMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsBrandingHeader extends PopupMenuEntry<String> {
  const _SettingsBrandingHeader();

  @override
  final double height = 52;

  @override
  bool represents(String? value) => false;

  @override
  State<_SettingsBrandingHeader> createState() => _SettingsBrandingHeaderState();
}

class _SettingsBrandingHeaderState extends State<_SettingsBrandingHeader> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: CategoryTheme.analyticsAccent,
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
            child: SizedBox(width: 3, height: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              CategoryTheme.appName,
              key: Key('settings-branding-title'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: CategoryTheme.appText,
                letterSpacing: -0.2,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaryTabOutlinePainter extends CustomPainter {
  const _DiaryTabOutlinePainter({
    required this.radius,
    required this.color,
    required this.strokeWidth,
    required this.includeBottom,
  });

  final double radius;
  final Color color;
  final double strokeWidth;
  final bool includeBottom;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    final inset = strokeWidth / 2;
    final maxRadius = math.min(size.width / 2, size.height / 2) - inset;
    final r = radius.clamp(0.0, maxRadius);
    final w = size.width;
    final h = size.height;

    final path = Path();
    if (includeBottom) {
      path
        ..moveTo(inset, h - inset)
        ..lineTo(inset, r + inset)
        ..arcToPoint(
          Offset(r + inset, inset),
          radius: Radius.circular(r),
        )
        ..lineTo(w - r - inset, inset)
        ..arcToPoint(
          Offset(w - inset, r + inset),
          radius: Radius.circular(r),
        )
        ..lineTo(w - inset, h - inset)
        ..lineTo(inset, h - inset);
    } else {
      path
        ..moveTo(inset, h)
        ..lineTo(inset, r + inset)
        ..arcToPoint(
          Offset(r + inset, inset),
          radius: Radius.circular(r),
        )
        ..lineTo(w - r - inset, inset)
        ..arcToPoint(
          Offset(w - inset, r + inset),
          radius: Radius.circular(r),
        )
        ..lineTo(w - inset, h);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DiaryTabOutlinePainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.includeBottom != includeBottom;
  }
}
