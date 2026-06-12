import 'package:acrosstool_journal/models/completion_rate.dart';
import 'package:acrosstool_journal/models/task_slot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculateCompletionRate returns null when no labeled tasks exist', () {
    expect(
      calculateCompletionRate(const [
        TaskSlot(id: 1, label: '', completed: false),
        TaskSlot(id: 2, label: '  ', completed: true),
      ]),
      isNull,
    );
  });

  test('calculateCompletionRate returns 0 when none completed', () {
    expect(
      calculateCompletionRate(const [
        TaskSlot(id: 1, label: '운동', completed: false),
        TaskSlot(id: 2, label: '공부', completed: false),
      ]),
      0,
    );
  });

  test('calculateCompletionRate uses labeled tasks only', () {
    expect(
      calculateCompletionRate(const [
        TaskSlot(id: 1, label: '운동', completed: true),
        TaskSlot(id: 2, label: '공부', completed: false),
        TaskSlot(id: 3, label: '', completed: true),
        TaskSlot(id: 4, label: '메일', completed: true),
        TaskSlot(id: 5, label: '일기', completed: false),
      ]),
      50,
    );
  });

  test('getCompletionTier maps rate bands', () {
    expect(getCompletionTier(0), CompletionTier.zero);
    expect(getCompletionTier(20), CompletionTier.low);
    expect(getCompletionTier(30), CompletionTier.low);
    expect(getCompletionTier(31), CompletionTier.medium);
    expect(getCompletionTier(70), CompletionTier.medium);
    expect(getCompletionTier(71), CompletionTier.high);
    expect(getCompletionTier(100), CompletionTier.high);
  });

  test('getCompletionTierLabel returns Korean labels', () {
    expect(getCompletionTierLabel(0), '미완료');
    expect(getCompletionTierLabel(20), '낮음');
    expect(getCompletionTierLabel(50), '보통');
    expect(getCompletionTierLabel(90), '높음');
  });

  test('buildCompletionRateMap includes only dates with labeled tasks', () {
    final rates = buildCompletionRateMap({
      '2026-06-10': TaskSlot.emptySlots(),
      '2026-06-11': const [
        TaskSlot(id: 1, label: '운동', completed: true, category: '운동'),
        TaskSlot(id: 2, label: '공부', completed: false, category: '학습'),
        TaskSlot(id: 3, label: '', completed: false),
        TaskSlot(id: 4, label: '', completed: false),
        TaskSlot(id: 5, label: '', completed: false),
      ],
      '2026-06-12': const [
        TaskSlot(id: 1, label: '회의', completed: true, category: '업무'),
        TaskSlot(id: 2, label: '보고', completed: true, category: '업무'),
        TaskSlot(id: 3, label: '', completed: false),
        TaskSlot(id: 4, label: '', completed: false),
        TaskSlot(id: 5, label: '', completed: false),
      ],
      '2026-06-13': const [
        TaskSlot(id: 1, label: '독서', completed: false, category: '학습'),
        TaskSlot(id: 2, label: '정리', completed: false, category: '루틴'),
        TaskSlot(id: 3, label: '', completed: false),
        TaskSlot(id: 4, label: '', completed: false),
        TaskSlot(id: 5, label: '', completed: false),
      ],
    });

    expect(rates['2026-06-10'], isNull);
    expect(rates['2026-06-11']?.rate, 50);
    expect(rates['2026-06-12']?.rate, 100);
    expect(rates['2026-06-13']?.rate, 0);
    expect(hasCompletionMarker(rates, DateTime(2026, 6, 10)), isFalse);
    expect(hasCompletionMarker(rates, DateTime(2026, 6, 13)), isTrue);
    expect(
      getCompletionEntryForDate(rates, DateTime(2026, 6, 12))?.rate,
      100,
    );
  });

  test('buildCompletionRateMap respects category filter', () {
    final rates = buildCompletionRateMap(
      {
        '2026-06-11': const [
          TaskSlot(id: 1, label: '운동', completed: true, category: '운동'),
          TaskSlot(id: 2, label: '공부', completed: false, category: '학습'),
          TaskSlot(id: 3, label: '', completed: false),
          TaskSlot(id: 4, label: '', completed: false),
          TaskSlot(id: 5, label: '', completed: false),
        ],
      },
      '운동',
    );

    expect(rates['2026-06-11']?.rate, 100);
  });

  test('buildCalendarDateAriaLabel describes completion state', () {
    expect(
      buildCalendarDateAriaLabel(DateTime(2026, 6, 11), null),
      '6월 11일 선택, 라벨 있는 일과 없음',
    );
    expect(
      buildCalendarDateAriaLabel(
        DateTime(2026, 6, 11),
        const CompletionDayEntry(rate: 0),
      ),
      '6월 11일 선택, 완료율 0% (미완료)',
    );
    expect(
      buildCalendarDateAriaLabel(
        DateTime(2026, 6, 11),
        const CompletionDayEntry(rate: 80),
      ),
      '6월 11일 선택, 완료율 80% (높음)',
    );
  });
}
