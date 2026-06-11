import type { CategoryFilter } from "./categoryStore";
import { FILTER_ALL } from "./categoryStore";
import {
  loadPersistedTaskStore,
  savePersistedTaskStore,
  STORAGE_KEY,
} from "../storage/taskStorage";
import { MAX_TASK_SLOTS, type TaskSlot } from "../types";

export { STORAGE_KEY, FILTER_ALL };
export type { CategoryFilter };

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

export async function loadTaskStore(): Promise<Record<string, TaskSlot[]>> {
  if (typeof window === "undefined") {
    return createInitialTaskStore();
  }

  const persisted = await loadPersistedTaskStore();
  return persisted ?? createInitialTaskStore();
}

export async function saveTaskStore(
  store: Record<string, TaskSlot[]>,
): Promise<void> {
  if (typeof window === "undefined") {
    return;
  }

  await savePersistedTaskStore(store);
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

export function updateTaskCategory(
  store: Record<string, TaskSlot[]>,
  date: Date,
  taskId: number,
  category: string | undefined,
): Record<string, TaskSlot[]> {
  const key = dateKey(date);
  const tasks = store[key] ?? createEmptyTasks();

  return {
    ...store,
    [key]: tasks.map((task) =>
      task.id === taskId ? { ...task, category } : task,
    ),
  };
}

export function clearCategoryFromAllTasks(
  store: Record<string, TaskSlot[]>,
  category: string,
): Record<string, TaskSlot[]> {
  return Object.fromEntries(
    Object.entries(store).map(([key, tasks]) => [
      key,
      tasks.map((task) =>
        task.category === category ? { ...task, category: undefined } : task,
      ),
    ]),
  );
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
  if (category === FILTER_ALL) {
    return tasks;
  }

  return tasks.filter(
    (task) => task.category === category && task.label.trim() !== "",
  );
}
