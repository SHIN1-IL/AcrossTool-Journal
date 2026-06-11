import { describe, expect, it, beforeEach } from "vitest";
import {
  createEmptyTasks,
  dateKey,
  ensureTasksForDate,
  filterTasksByCategory,
  getTasksForDate,
  STORAGE_KEY,
  toggleTask,
  updateTaskLabel,
} from "./taskStore";

describe("taskStore", () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it("creates exactly 5 empty task slots", () => {
    const tasks = createEmptyTasks();
    expect(tasks).toHaveLength(5);
    expect(tasks.every((task) => task.label === "" && !task.completed)).toBe(
      true,
    );
  });

  it("formats date keys as YYYY-MM-DD", () => {
    expect(dateKey(new Date(2026, 5, 11))).toBe("2026-06-11");
  });

  it("ensures tasks exist for a new date", () => {
    const date = new Date(2026, 0, 15);
    const store = ensureTasksForDate({}, date);

    expect(store[dateKey(date)]).toHaveLength(5);
  });

  it("toggles task completion for the selected date", () => {
    const date = new Date(2026, 0, 15);
    const store = ensureTasksForDate({}, date);
    const updated = toggleTask(store, date, 2);

    expect(updated[dateKey(date)]?.[1]?.completed).toBe(true);
  });

  it("updates task labels", () => {
    const date = new Date(2026, 0, 15);
    const store = ensureTasksForDate({}, date);
    const updated = updateTaskLabel(store, date, 3, "회의 준비");

    expect(updated[dateKey(date)]?.[2]?.label).toBe("회의 준비");
  });

  it("filters tasks by category while keeping 전체 unfiltered", () => {
    const tasks = [
      { id: 1, label: "운동", completed: false, category: "운동" },
      { id: 2, label: "공부", completed: false, category: "학습" },
      { id: 3, label: "메일", completed: false, category: "업무" },
      { id: 4, label: "", completed: false },
      { id: 5, label: "", completed: false },
    ];

    expect(filterTasksByCategory(tasks, "전체")).toHaveLength(5);
    expect(filterTasksByCategory(tasks, "운동")).toHaveLength(1);
    expect(filterTasksByCategory(tasks, "학습")[0]?.label).toBe("공부");
  });

  it("persists task store to localStorage", () => {
    const date = new Date(2026, 0, 15);
    const store = updateTaskLabel(
      ensureTasksForDate({}, date),
      date,
      1,
      "저장 테스트",
    );

    localStorage.setItem(STORAGE_KEY, JSON.stringify(store));

    expect(getTasksForDate(JSON.parse(localStorage.getItem(STORAGE_KEY)!), date)[0]
      ?.label).toBe("저장 테스트");
  });
});
