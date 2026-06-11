import { MAX_TASK_SLOTS, type TaskSlot } from "../types";

export const STORAGE_KEY = "acrosstool-journal-tasks";

export const DEFAULT_CATEGORIES = ["전체", "운동", "학습", "업무", "루틴"] as const;

export type CategoryFilter = (typeof DEFAULT_CATEGORIES)[number];

const SAMPLE_TASKS: TaskSlot[] = [
  { id: 1, label: "아침 스트레칭", completed: true, category: "운동" },
  { id: 2, label: "영어 단어 30개", completed: false, category: "학습" },
  { id: 3, label: "이메일 확인", completed: false, category: "업무" },
  { id: 4, label: "저녁 산책", completed: false, category: "운동" },
  { id: 5, label: "일기 작성", completed: false, category: "루틴" },
];

export function dateKey(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

export function createEmptyTasks(): TaskSlot[] {
  return Array.from({ length: MAX_TASK_SLOTS }, (_, index) => ({
    id: index + 1,
    label: "",
    completed: false,
  }));
}

export function createInitialTaskStore(): Record<string, TaskSlot[]> {
  return {
    [dateKey(new Date())]: SAMPLE_TASKS.map((task) => ({ ...task })),
  };
}

export function loadTaskStore(): Record<string, TaskSlot[]> {
  if (typeof window === "undefined") {
    return createInitialTaskStore();
  }

  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) {
      return createInitialTaskStore();
    }

    const parsed = JSON.parse(raw) as Record<string, TaskSlot[]>;
    if (typeof parsed !== "object" || parsed === null) {
      return createInitialTaskStore();
    }

    return parsed;
  } catch {
    return createInitialTaskStore();
  }
}

export function saveTaskStore(store: Record<string, TaskSlot[]>): void {
  if (typeof window === "undefined") {
    return;
  }

  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(store));
}

export function ensureTasksForDate(
  store: Record<string, TaskSlot[]>,
  date: Date,
): Record<string, TaskSlot[]> {
  const key = dateKey(date);
  if (store[key]) {
    return store;
  }

  return { ...store, [key]: createEmptyTasks() };
}

export function toggleTask(
  store: Record<string, TaskSlot[]>,
  date: Date,
  taskId: number,
): Record<string, TaskSlot[]> {
  const key = dateKey(date);
  const tasks = store[key] ?? createEmptyTasks();

  return {
    ...store,
    [key]: tasks.map((task) =>
      task.id === taskId ? { ...task, completed: !task.completed } : task,
    ),
  };
}

export function updateTaskLabel(
  store: Record<string, TaskSlot[]>,
  date: Date,
  taskId: number,
  label: string,
): Record<string, TaskSlot[]> {
  const key = dateKey(date);
  const tasks = store[key] ?? createEmptyTasks();

  return {
    ...store,
    [key]: tasks.map((task) => (task.id === taskId ? { ...task, label } : task)),
  };
}

export function getTasksForDate(
  store: Record<string, TaskSlot[]>,
  date: Date,
): TaskSlot[] {
  return store[dateKey(date)] ?? createEmptyTasks();
}

export function filterTasksByCategory(
  tasks: TaskSlot[],
  category: CategoryFilter,
): TaskSlot[] {
  if (category === "전체") {
    return tasks;
  }

  return tasks.filter((task) => task.category === category);
}
