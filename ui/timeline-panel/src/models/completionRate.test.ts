import { describe, expect, it } from "vitest";
import {
  buildCalendarDateAriaLabel,
  buildCompletionRateMap,
  calculateCompletionRate,
  getCompletionEntryForDate,
  getCompletionTier,
  getCompletionTierLabel,
  hasCompletionMarker,
} from "./completionRate";

describe("completionRate", () => {
  it("returns null when no labeled tasks exist", () => {
    expect(
      calculateCompletionRate([
        { id: 1, label: "", completed: false },
        { id: 2, label: "  ", completed: true },
      ]),
    ).toBeNull();
  });

  it("returns 0 when labeled tasks exist but none are completed", () => {
    expect(
      calculateCompletionRate([
        { id: 1, label: "운동", completed: false },
        { id: 2, label: "공부", completed: false },
      ]),
    ).toBe(0);
  });

  it("calculates completion rate from labeled tasks only", () => {
    expect(
      calculateCompletionRate([
        { id: 1, label: "운동", completed: true },
        { id: 2, label: "공부", completed: false },
        { id: 3, label: "", completed: true },
        { id: 4, label: "메일", completed: true },
        { id: 5, label: "일기", completed: false },
      ]),
    ).toBe(50);
  });

  it("maps completion rate to color tiers with a distinct zero tier", () => {
    expect(getCompletionTier(0)).toBe("zero");
    expect(getCompletionTier(20)).toBe("low");
    expect(getCompletionTier(30)).toBe("low");
    expect(getCompletionTier(31)).toBe("medium");
    expect(getCompletionTier(70)).toBe("medium");
    expect(getCompletionTier(71)).toBe("high");
    expect(getCompletionTier(100)).toBe("high");
  });

  it("provides human-readable tier labels for aria descriptions", () => {
    expect(getCompletionTierLabel(0)).toBe("미완료");
    expect(getCompletionTierLabel(20)).toBe("낮음");
    expect(getCompletionTierLabel(50)).toBe("보통");
    expect(getCompletionTierLabel(90)).toBe("높음");
  });

  it("builds a date-keyed map only for dates with labeled tasks", () => {
    const rates = buildCompletionRateMap({
      "2026-06-10": [
        { id: 1, label: "", completed: false },
        { id: 2, label: "", completed: false },
        { id: 3, label: "", completed: false },
        { id: 4, label: "", completed: false },
        { id: 5, label: "", completed: false },
      ],
      "2026-06-11": [
        { id: 1, label: "운동", completed: true, category: "운동" },
        { id: 2, label: "공부", completed: false, category: "학습" },
        { id: 3, label: "", completed: false },
        { id: 4, label: "", completed: false },
        { id: 5, label: "", completed: false },
      ],
      "2026-06-12": [
        { id: 1, label: "회의", completed: true, category: "업무" },
        { id: 2, label: "보고", completed: true, category: "업무" },
        { id: 3, label: "", completed: false },
        { id: 4, label: "", completed: false },
        { id: 5, label: "", completed: false },
      ],
      "2026-06-13": [
        { id: 1, label: "독서", completed: false, category: "학습" },
        { id: 2, label: "정리", completed: false, category: "루틴" },
        { id: 3, label: "", completed: false },
        { id: 4, label: "", completed: false },
        { id: 5, label: "", completed: false },
      ],
    });

    expect(rates["2026-06-10"]).toBeUndefined();
    expect(rates["2026-06-11"]?.rate).toBe(50);
    expect(rates["2026-06-12"]?.rate).toBe(100);
    expect(rates["2026-06-13"]?.rate).toBe(0);
    expect(hasCompletionMarker(rates, new Date(2026, 5, 10))).toBe(false);
    expect(hasCompletionMarker(rates, new Date(2026, 5, 13))).toBe(true);
    expect(
      getCompletionEntryForDate(rates, new Date(2026, 5, 12))?.rate,
    ).toBe(100);
  });

  it("respects category filter when building completion rates", () => {
    const rates = buildCompletionRateMap(
      {
        "2026-06-11": [
          { id: 1, label: "운동", completed: true, category: "운동" },
          { id: 2, label: "공부", completed: false, category: "학습" },
          { id: 3, label: "", completed: false },
          { id: 4, label: "", completed: false },
          { id: 5, label: "", completed: false },
        ],
      },
      "운동",
    );

    expect(rates["2026-06-11"]?.rate).toBe(100);
  });

  it("builds descriptive aria labels for calendar date cells", () => {
    expect(buildCalendarDateAriaLabel(5, 11, undefined)).toBe(
      "6월 11일 선택, 라벨 있는 일과 없음",
    );
    expect(buildCalendarDateAriaLabel(5, 11, { rate: 0 })).toBe(
      "6월 11일 선택, 완료율 0% (미완료)",
    );
    expect(buildCalendarDateAriaLabel(5, 11, { rate: 20 })).toBe(
      "6월 11일 선택, 완료율 20% (낮음)",
    );
    expect(buildCalendarDateAriaLabel(5, 11, { rate: 80 })).toBe(
      "6월 11일 선택, 완료율 80% (높음)",
    );
  });
});
