import 'package:flutter/material.dart';

import '../models/category_store.dart';
import '../models/category_tab_store.dart';
import '../models/completion_rate.dart';
import '../models/journal_category_tab.dart';
import '../models/task_importance.dart';
import '../models/task_slot.dart';
import '../repositories/preferences_repository.dart';
import '../repositories/task_repository.dart';
import '../services/journal_data_service.dart';
import '../utils/category_theme.dart';
import '../utils/calendar_font_settings.dart';
import '../utils/category_input_layout.dart';
import '../widgets/analytics_panel.dart';
import '../widgets/category_manage_dialog.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/journal_calendar.dart';
import '../widgets/journal_data_dialog.dart';
import '../widgets/monthly_report_dialog.dart';
import '../widgets/timeline_panel.dart';

/// PRD 메인 화면 진입점. 카테고리 탭 + 전체 너비 달력 레이아웃.
class AcrossToolMainScreen extends StatefulWidget {
  const AcrossToolMainScreen({
    super.key,
    required this.taskRepository,
    required this.preferencesRepository,
  });

  final TaskRepository taskRepository;
  final PreferencesRepository preferencesRepository;

  @override
  State<AcrossToolMainScreen> createState() => _AcrossToolMainScreenState();
}

class _AcrossToolMainScreenState extends State<AcrossToolMainScreen>
    with WidgetsBindingObserver {
  DateTime _selectedDay = DateTime.now();
  List<JournalCategoryTab> _categoryTabs = CategoryTabStore.defaultTabs();
  String _selectedTabId = JournalCategoryTab.overviewId;
  String _calendarTabId = JournalCategoryTab.overviewId;
  int _calendarTaskFontPt = CalendarFontSettings.defaultPtSize;
  CategoryInputLayoutPreference _categoryInputLayout =
      CategoryInputLayoutPreference.auto;
  late final JournalDataService _journalDataService;

  JournalCategoryTab get _activeTab =>
      CategoryTabStore.findById(_categoryTabs, _selectedTabId) ??
      JournalCategoryTab.overview();

  JournalCategoryTab get _calendarTab =>
      CategoryTabStore.findById(_categoryTabs, _calendarTabId) ??
      JournalCategoryTab.overview();

  bool get _isAnalyticsMode =>
      _selectedTabId == JournalCategoryTab.analyticsId;

  Map<String, Color> get _categoryColors {
    return {
      for (final tab in _categoryTabs.where((tab) => !tab.isOverview))
        tab.title: tab.accentColor,
      for (final name in CategoryStore.builtinCategories)
        name: Colors.blueGrey,
    };
  }

  CompletionRateMap get _calendarCompletionRates {
    final filter = _calendarTab.isOverview
        ? CategoryStore.filterAll
        : _calendarTab.title;
    return buildCompletionRateMap(
      widget.taskRepository.loadStore(),
      filter,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _journalDataService = JournalDataService(
      taskRepository: widget.taskRepository,
      preferencesRepository: widget.preferencesRepository,
    );
    _loadPreferences();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      widget.preferencesRepository.saveSelectedTabId(_selectedTabId);
      widget.preferencesRepository.saveCategoryTabs(_categoryTabs);
    }
  }

  void _loadPreferences() {
    setState(() {
      _categoryTabs = widget.preferencesRepository.loadCategoryTabs();
      _selectedTabId = widget.preferencesRepository.loadSelectedTabId();
      _calendarTabId = _selectedTabId == JournalCategoryTab.analyticsId
          ? JournalCategoryTab.overviewId
          : _selectedTabId;
      _calendarTaskFontPt =
          widget.preferencesRepository.loadCalendarTaskFontPt();
      _categoryInputLayout =
          widget.preferencesRepository.loadCategoryInputLayout();
    });
  }

  Future<void> _onCategoryInputLayoutChanged(
    CategoryInputLayoutPreference layout,
  ) async {
    setState(() => _categoryInputLayout = layout);
    await widget.preferencesRepository.saveCategoryInputLayout(layout);
  }

  bool _categoryUsesBottomSheet(BuildContext context) {
    if (_calendarTab.isOverview || _calendarTab.isAnalytics) {
      return false;
    }
    return CategoryInputLayout.useBottomSheet(
      context: context,
      preference: _categoryInputLayout,
    );
  }

  Future<void> _onCalendarTaskFontPtChanged(int pt) async {
    final sanitized = CalendarFontSettings.sanitize(pt);
    setState(() => _calendarTaskFontPt = sanitized);
    await widget.preferencesRepository.saveCalendarTaskFontPt(sanitized);
  }

  Future<void> _onDaySelected(DateTime day) async {
    setState(() => _selectedDay = day);
    if (!mounted) {
      return;
    }
    if (_calendarTab.isOverview) {
      _showDayBottomSheet();
      return;
    }
    if (_categoryUsesBottomSheet(context)) {
      _showDayBottomSheet();
    }
  }

  Future<void> _onTabSelected(JournalCategoryTab tab) async {
    setState(() {
      _selectedTabId = tab.id;
      _calendarTabId = tab.id;
    });
    await widget.preferencesRepository.saveSelectedTabId(tab.id);
  }

  void _onTabRenamed(JournalCategoryTab tab, String newTitle) {
    final updated = CategoryTabStore.renameTab(_categoryTabs, tab.id, newTitle);
    if (updated == null) {
      return;
    }

    final renamedTitle =
        updated.firstWhere((item) => item.id == tab.id).title;

    setState(() => _categoryTabs = updated);

    widget.taskRepository.renameCategoryInAllTasks(tab.title, renamedTitle);
  }

  void _onBatchTabsAdded() {
    final updated = CategoryTabStore.addBatchTabs(_categoryTabs);
    if (updated == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리는 최대 11개까지 추가할 수 있습니다.')),
      );
      return;
    }

    setState(() => _categoryTabs = updated);
  }

  void _onAnalyticsSelected() {
    setState(() => _selectedTabId = JournalCategoryTab.analyticsId);
  }

  Future<void> _onTabRemoved(JournalCategoryTab tab) async {
    final updated = CategoryTabStore.removeTab(_categoryTabs, tab.id);
    await widget.taskRepository.clearCategoryFromAllTasks(tab.title);
    await widget.preferencesRepository.saveCategoryTabs(updated);

    if (!mounted) {
      return;
    }

    setState(() {
      _categoryTabs = updated;
      if (_selectedTabId == tab.id) {
        _selectedTabId = JournalCategoryTab.overviewId;
      }
    });
    await widget.preferencesRepository.saveSelectedTabId(_selectedTabId);
    setState(() {});
  }

  Future<void> _refreshAfterCalendarMutation(DateTime day) async {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _onCalendarTaskToggle(DateTime day, int taskId) async {
    await widget.taskRepository.toggleTask(day, taskId);
    await _refreshAfterCalendarMutation(day);
  }

  Future<int> _onEnsureCategoryTask(DateTime day, String category) async {
    return widget.taskRepository.ensureSingleCategoryTask(day, category);
  }

  Future<void> _onCategoryTaskHeaderChanged(
    DateTime day,
    int taskId,
    String header,
  ) async {
    await widget.taskRepository.updateTaskHeader(day, taskId, header);
    await _refreshAfterCalendarMutation(day);
  }

  Future<void> _onCategoryTaskLabelChanged(
    DateTime day,
    int taskId,
    String label,
  ) async {
    await widget.taskRepository.updateTaskLabel(day, taskId, label);
    await _refreshAfterCalendarMutation(day);
  }

  Future<void> _onCategoryTaskNotesChanged(
    DateTime day,
    int taskId,
    String notes,
  ) async {
    await widget.taskRepository.updateTaskNotes(day, taskId, notes);
    await _refreshAfterCalendarMutation(day);
  }

  Future<void> _onCategoryTaskImportanceChanged(
    DateTime day,
    int taskId,
    TaskImportance importance,
  ) async {
    await widget.taskRepository.updateTaskImportance(day, taskId, importance);
    await _refreshAfterCalendarMutation(day);
  }

  Future<void> _onCategoryTaskUsageHoursChanged(
    DateTime day,
    int taskId,
    int usageHours,
  ) async {
    await widget.taskRepository.updateTaskUsageHours(day, taskId, usageHours);
    await _refreshAfterCalendarMutation(day);
  }

  void _showCategoryManageDialog() {
    CategoryManageDialog.show(
      context,
      tabs: _categoryTabs,
      onDeleteTab: _onTabRemoved,
    );
  }

  void _showDataTransferDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return JournalDataDialog(
          service: _journalDataService,
          onImported: () {
            _loadPreferences();
            if (mounted) {
              setState(() {});
            }
          },
        );
      },
    );
  }

  void _showDayBottomSheet() {
    if (_calendarTab.isAnalytics) {
      return;
    }

    final sheetHeight = MediaQuery.of(context).size.height * 0.72;
    final activeTab = _calendarTab;
    final readOnly = activeTab.isOverview;
    final singleCategoryTaskMode = !readOnly && !activeTab.isAnalytics;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: SizedBox(
            height: sheetHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: _DayScheduleSheet(
                selectedDay: _selectedDay,
                activeTab: activeTab,
                categoryColors: _categoryColors,
                taskRepository: widget.taskRepository,
                readOnly: readOnly,
                singleCategoryTaskMode: singleCategoryTaskMode,
                onTasksChanged: () {
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMonthlyReport(DateTime month) {
    MonthlyReportDialog.show(
      context,
      month: month,
      taskStore: widget.taskRepository.loadStore(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = CategoryTabBar.totalHeight;

    return Scaffold(
      backgroundColor: CategoryTheme.appBackground,
      resizeToAvoidBottomInset: false,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        SizedBox(height: headerHeight),
                        Expanded(
                          child: JournalCalendar(
                            selectedDay: _selectedDay,
                            completionRates: _calendarCompletionRates,
                            taskStore: widget.taskRepository.loadStore(),
                            activeTab: _calendarTab,
                            categoryTabs: _categoryTabs,
                            taskFontPt: _calendarTaskFontPt,
                            categoryInlineEdit:
                                !_categoryUsesBottomSheet(context),
                            onDaySelected: _onDaySelected,
                            onMonthEndReport: _showMonthlyReport,
                            onEnsureCategoryTask: _onEnsureCategoryTask,
                            onCategoryTaskToggle: _onCalendarTaskToggle,
                            onCategoryTaskHeaderChanged:
                                _onCategoryTaskHeaderChanged,
                            onCategoryTaskLabelChanged:
                                _onCategoryTaskLabelChanged,
                            onCategoryTaskNotesChanged:
                                _onCategoryTaskNotesChanged,
                            onCategoryTaskImportanceChanged:
                                _onCategoryTaskImportanceChanged,
                            onCategoryTaskUsageHoursChanged:
                                _onCategoryTaskUsageHoursChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: CategoryTabBar(
                      tabs: _categoryTabs,
                      selectedTabId: _selectedTabId,
                      onTabSelected: _onTabSelected,
                      onTabRenamed: _onTabRenamed,
                      onBatchTabsAdded: _onBatchTabsAdded,
                      onAnalyticsSelected: _onAnalyticsSelected,
                      onManageCategories: _showCategoryManageDialog,
                      onDataTransfer: _showDataTransferDialog,
                      calendarTaskFontPt: _calendarTaskFontPt,
                      onCalendarTaskFontPtChanged: _onCalendarTaskFontPtChanged,
                      categoryInputLayout: _categoryInputLayout,
                      onCategoryInputLayoutChanged: _onCategoryInputLayoutChanged,
                    ),
                  ),
                  if (_isAnalyticsMode)
                    Positioned(
                      top: headerHeight,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: const AnalyticsPanel(
                        key: Key('analytics-panel-view'),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 날짜별 일정 바텀 시트 — 추가·수정 후 자체 setState로 UI를 즉시 갱신합니다.
class _DayScheduleSheet extends StatefulWidget {
  const _DayScheduleSheet({
    required this.selectedDay,
    required this.activeTab,
    required this.categoryColors,
    required this.taskRepository,
    required this.readOnly,
    required this.singleCategoryTaskMode,
    required this.onTasksChanged,
  });

  final DateTime selectedDay;
  final JournalCategoryTab activeTab;
  final Map<String, Color> categoryColors;
  final TaskRepository taskRepository;
  final bool readOnly;
  final bool singleCategoryTaskMode;
  final VoidCallback onTasksChanged;

  @override
  State<_DayScheduleSheet> createState() => _DayScheduleSheetState();
}

class _DayScheduleSheetState extends State<_DayScheduleSheet> {
  List<TaskSlot> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  List<TaskSlot> get _displayTasks {
    final filtered = CategoryTabStore.filterTasksForTab(
      _tasks,
      widget.activeTab,
      includeEmptyLabels: !widget.readOnly,
      sortByTime: !widget.readOnly && !widget.singleCategoryTaskMode,
    );
    if (!widget.singleCategoryTaskMode) {
      return filtered;
    }
    return filtered.take(1).toList();
  }

  Future<void> _loadTasks() async {
    if (widget.singleCategoryTaskMode) {
      await widget.taskRepository.ensureSingleCategoryTask(
        widget.selectedDay,
        widget.activeTab.title,
      );
    }
    final tasks =
        await widget.taskRepository.ensureTasksForDate(widget.selectedDay);
    if (!mounted) {
      return;
    }
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _mutateTasks(
    Future<List<TaskSlot>> Function() mutation,
  ) async {
    final tasks = await mutation();
    if (!mounted) {
      return;
    }
    setState(() => _tasks = tasks);
    widget.onTasksChanged();
  }

  Future<void> _onAddTask() async {
    await _mutateTasks(
      () => widget.taskRepository.addTask(
        widget.selectedDay,
        category: widget.activeTab.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TimelinePanel(
      selectedDay: widget.selectedDay,
      tasks: _displayTasks,
      activeTab: widget.activeTab,
      categoryColors: widget.categoryColors,
      isLoading: _isLoading,
      readOnly: widget.readOnly,
      onToggle: widget.readOnly
          ? null
          : (taskId) => _mutateTasks(
                () => widget.taskRepository.toggleTask(
                  widget.selectedDay,
                  taskId,
                ),
              ),
      onLabelChanged: widget.readOnly
          ? null
          : (taskId, label) => _mutateTasks(
                () => widget.taskRepository.updateTaskLabel(
                  widget.selectedDay,
                  taskId,
                  label,
                ),
              ),
      onTimeChanged: widget.readOnly
          ? null
          : (taskId, time) => _mutateTasks(
                () => widget.taskRepository.updateTaskTime(
                  widget.selectedDay,
                  taskId,
                  time,
                ),
              ),
      onHeaderChanged: widget.readOnly
          ? null
          : (taskId, header) => _mutateTasks(
                () => widget.taskRepository.updateTaskHeader(
                  widget.selectedDay,
                  taskId,
                  header,
                ),
              ),
      onImportanceChanged: widget.readOnly
          ? null
          : (taskId, importance) => _mutateTasks(
                () => widget.taskRepository.updateTaskImportance(
                  widget.selectedDay,
                  taskId,
                  importance,
                ),
              ),
      onUsageHoursChanged: widget.readOnly
          ? null
          : (taskId, hours) => _mutateTasks(
                () => widget.taskRepository.updateTaskUsageHours(
                  widget.selectedDay,
                  taskId,
                  hours,
                ),
              ),
      onNotesChanged: widget.readOnly
          ? null
          : (taskId, notes) => _mutateTasks(
                () => widget.taskRepository.updateTaskNotes(
                  widget.selectedDay,
                  taskId,
                  notes,
                ),
              ),
      onAdd: widget.readOnly || widget.singleCategoryTaskMode ? null : _onAddTask,
      onRemove: widget.readOnly || widget.singleCategoryTaskMode
          ? null
          : (taskId) => _mutateTasks(
                () => widget.taskRepository.removeTask(
                  widget.selectedDay,
                  taskId,
                ),
              ),
    );
  }
}
