class JournalPreferences {
  const JournalPreferences({
    this.userCategories = const [],
    this.selectedFilter = filterAll,
  });

  static const String filterAll = '전체';
  static const List<String> builtinCategories = ['운동', '학습', '업무', '루틴'];

  final List<String> userCategories;
  final String selectedFilter;

  List<String> get filterOptions => [
        filterAll,
        ...builtinCategories,
        ...userCategories.where((c) => !builtinCategories.contains(c)),
      ];

  factory JournalPreferences.fromJson(Map<String, dynamic> json) {
    return JournalPreferences(
      userCategories: (json['userCategories'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      selectedFilter: json['selectedFilter'] as String? ?? filterAll,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userCategories': userCategories,
      'selectedFilter': selectedFilter,
    };
  }
}
