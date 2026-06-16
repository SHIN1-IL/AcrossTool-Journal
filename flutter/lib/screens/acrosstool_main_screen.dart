import 'package:flutter/material.dart';

import '../models/category_store.dart';
import '../models/category_tab_store.dart';
import '../models/completion_rate.dart';
import '../models/journal_category_tab.dart';
import '../models/task_slot.dart';
import '../repositories/preferences_repository.dart';
import '../repositories/task_repository.dart';
import '../services/journal_data_service.dart';
import '../utils/category_theme.dart';
import '../utils/layout_units.dart';
import '../utils/time_format.dart';
import '../widgets/analytics_panel.dart';
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
  List<TaskSlot> _tasks = [];
  List<JournalCategoryTab> _categoryTabs = CategoryTabStore.defaultTabs();
  String _selectedTabId = JournalCategoryTab.overviewId;
  String _calendarTabId = JournalCategoryTab.overviewId;
  bool _isLoading = true;
  int _loadGeneration = 0;
  late final JournalDataService _journalDataService;

  JournalCategoryTab get _activeTab =>
      CategoryTabStore.findById(_categoryTabs, _selectedTabId) ??
      JournalCategoryTab.overview();

  JournalCategoryTab get _calendarTab =>
      CategoryTabStore.findById(_categoryTabs, _calendarTabId) ??
      JournalCategoryTab.overview();

  bool get _isAnalyticsMode =>
      _selectedTabId == JournalCategoryTab.analyticsId;

  bool get _isOverviewMode => _activeTab.isOverview && !_isAnalyticsMode;

  Map<String, Color> get _categoryColors {
    return {
      for (final tab in _categoryTabs.where((tab) => !tab.isOverview))
        tab.title: tab.accentColor,
      for (final name in CategoryStore.builtinCategories)
        name: Colors.blueGrey,
    };
  }

  Color get _pageBackgroundColor => _activeTab.backgroundColor;

  CompletionRateMap get _calendarCompletionRates {
    final filter = _calendarTab.isOverview
        ? CategoryStore.filterAll
        : _calendarTab.title;
    return buildCompletionRateMap(
      widget.taskRepository.loadStore(),
      filter,
    );
  }

  List<TaskSlot> get _displayTasks {
    if (_isOverviewMode) {
      return _tasks.where((task) => task.label.trim().isNotEmpty).toList();
    }
    return _tasks
        .where((task) => task.category == _activeTab.title)
        .toList()
      ..sort((a, b) => compareTimeStrings(a.time, b.time));
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
    _loadTasksForSelectedDay();
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
    });
  }

  Future<void> _loadTasksForSelectedDay() async {
    final generation = ++_loadGeneration;
    final tasks = await widget.taskRepository.ensureTasksForDate(_selectedDay);
    if (!mounted || generation != _loadGeneration) {
      return;
    }
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _onDaySelected(DateTime day) async {
    setState(() {
      _selectedDay = day;
      _isLoading = true;
    });
    _loadGeneration++;
    await _loadTasksForSelectedDay();

    if (!mounted) {
      return;
    }

    _showDayBottomSheet();
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
    await _loadTasksForSelectedDay();
  }

  Future<void> _onToggleTask(int taskId) async {
    _loadGeneration++;
    final tasks = await widget.taskRepository.toggleTask(_selectedDay, taskId);
    if (!mounted) {
      return;
    }
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _onLabelChanged(int taskId, String label) async {
    _loadGeneration++;
    final tasks = await widget.taskRepository.updateTaskLabel(
      _selectedDay,
      taskId,
      label,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _onTimeChanged(int taskId, String time) async {
    _loadGeneration++;
    final tasks = await widget.taskRepository.updateTaskTime(
      _selectedDay,
      taskId,
      time,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _onAddTask() async {
    _loadGeneration++;
    final tasks = await widget.taskRepository.addTask(
      _selectedDay,
      category: _activeTab.title,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _onRemoveTask(int taskId) async {
    _loadGeneration++;
    final tasks = await widget.taskRepository.removeTask(_selectedDay, taskId);
    if (!mounted) {
      return;
    }
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  void _showDataTransferDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return JournalDataDialog(
          service: _journalDataService,
          onImported: () async {
            _loadPreferences();
            _loadGeneration++;
            await _loadTasksForSelectedDay();
          },
        );
      },
    );
  }

  void _showDayBottomSheet() {
    final sheetHeight = MediaQuery.of(context).size.height * 0.58;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SizedBox(
            height: sheetHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: TimelinePanel(
                selectedDay: _selectedDay,
                tasks: _displayTasks,
                activeTab: _activeTab,
                categoryColors: _categoryColors,
                isLoading: _isLoading,
                readOnly: _isOverviewMode,
                onToggle: _isOverviewMode ? null : _onToggleTask,
                onLabelChanged: _isOverviewMode ? null : _onLabelChanged,
                onTimeChanged: _isOverviewMode ? null : _onTimeChanged,
                onAdd: _isOverviewMode ? null : _onAddTask,
                onRemove: _isOverviewMode ? null : _onRemoveTask,
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
    final viewportHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: _pageBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: viewportHeight,
        width: double.infinity,
        child: ColoredBox(
          color: _pageBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CategoryTabBar(
                tabs: _categoryTabs,
                selectedTabId: _selectedTabId,
                onTabSelected: _onTabSelected,
                onTabRenamed: _onTabRenamed,
                onBatchTabsAdded: _onBatchTabsAdded,
                onTabRemoved: _onTabRemoved,
                onAnalyticsSelected: _onAnalyticsSelected,
              ),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: CategoryTheme.calendarGradientFor(
                            _calendarTab,
                          ),
                        ),
                        child: JournalCalendar(
                          selectedDay: _selectedDay,
                          completionRates: _calendarCompletionRates,
                          taskStore: widget.taskRepository.loadStore(),
                          activeTab: _calendarTab,
                          categoryColors: _categoryColors,
                          backgroundColor: Colors.transparent,
                          onDaySelected: _onDaySelected,
                          onMonthEndReport: _showMonthlyReport,
                        ),
                      ),
                    ),
                    if (!_isAnalyticsMode) ...[
                      Positioned(
                        top: 4,
                        right: 48,
                        child: Text(
                          'AcrossTool Journal',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color:
                                kBrandingLineColor.withValues(alpha: 0.9),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 0,
                        child: IconButton(
                          icon: Icon(
                            Icons.sync_alt,
                            size: 20,
                            color:
                                _calendarTab.accentColor.withValues(alpha: 0.7),
                          ),
                          tooltip: '데이터 가져오기 /보내기',
                          onPressed: _showDataTransferDialog,
                        ),
                      ),
                    ],
                    if (_isAnalyticsMode)
                      const Positioned.fill(
                        child: AnalyticsPanel(
                          key: Key('analytics-panel-view'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
