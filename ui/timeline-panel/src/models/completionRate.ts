import type { TaskSlot } from "../types";
import {
  dateKey,
  filterTasksByCategory,
  type CategoryFilter,
} from "./taskStore";

export type CompletionTier = "zero" | "low" | "medium" | "high";

export type CompletionDayEntry = {
  rate: number;
};

/** Dates with labeled tasks only; absent keys mean no marker. */
export type CompletionRateMap = Record<string, CompletionDayEntry>;

export function calculateCompletionRate(tasks: TaskSlot[]): number | null {
  const activeTasks = tasks.filter((task) => task.label.trim() !== "");
  if (activeTasks.length === 0) {
    return null;
  }

  const completedCount = activeTasks.filter((task) => task.completed).length;
  return Math.round((completedCount / activeTasks.length) * 100);
}

export function getCompletionTier(rate: number): CompletionTier {
  if (rate === 0) {
    return "zero";
  }
  if (rate <= 30) {
    return "low";
  }
  if (rate <= 70) {
    return "medium";
  }
  return "high";
}

export function getCompletionTierLabel(rate: number): string {
  switch (getCompletionTier(rate)) {
    case "zero":
      return "미완료";
    case "low":
      return "낮음";
    case "medium":
      return "보통";
    case "high":
      return "높음";
  }
}

export function buildCompletionRateMap(
  store: Record<string, TaskSlot[]>,
  category: CategoryFilter = "전체",
): CompletionRateMap {
  const rates: CompletionRateMap = {};

  for (const [key, tasks] of Object.entries(store)) {
    const scopedTasks =
      category === "전체" ? tasks : filterTasksByCategory(tasks, category);
    const rate = calculateCompletionRate(scopedTasks);
    if (rate !== null) {
      rates[key] = { rate };
    }
  }

  return rates;
}

export function getCompletionEntryForDate(
  rates: CompletionRateMap,
  date: Date,
): CompletionDayEntry | undefined {
  return rates[dateKey(date)];
}

export function hasCompletionMarker(
  rates: CompletionRateMap,
  date: Date,
): boolean {
  return dateKey(date) in rates;
}

export function buildCalendarDateAriaLabel(
  month: number,
  day: number,
  entry: CompletionDayEntry | undefined,
): string {
  const base = `${month + 1}월 ${day}일 선택`;

  if (!entry) {
    return `${base}, 라벨 있는 일과 없음`;
  }

  const tierLabel = getCompletionTierLabel(entry.rate);
  return `${base}, 완료율 ${entry.rate}% (${tierLabel})`;
}
