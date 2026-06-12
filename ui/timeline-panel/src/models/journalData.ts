import type { CategoryFilter } from "./categoryStore";
import {
  buildFilterOptions,
  sanitizeSelectedFilter,
} from "./categoryStore";
import type { TaskSlot } from "../types";
import { MAX_TASK_SLOTS } from "../types";
import type { TaskStoreData } from "../storage/taskStorage";

export const JOURNAL_DATA_VERSION = 1 as const;

export type JournalData = {
  version: typeof JOURNAL_DATA_VERSION;
  taskStore: TaskStoreData;
  userCategories: string[];
  selectedFilter: CategoryFilter;
};

const DATE_KEY_PATTERN = /^\d{4}-\d{2}-\d{2}$/;

function isValidTaskSlot(value: unknown): value is TaskSlot {
  if (typeof value !== "object" || value === null) {
    return false;
  }

  const slot = value as Record<string, unknown>;
  const id = slot.id;
  const label = slot.label;
  const completed = slot.completed;
  const category = slot.category;

  return (
    typeof id === "number" &&
    Number.isInteger(id) &&
    id >= 1 &&
    id <= MAX_TASK_SLOTS &&
    typeof label === "string" &&
    typeof completed === "boolean" &&
    (category === undefined || typeof category === "string")
  );
}

function isValidTaskStore(value: unknown): value is TaskStoreData {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return false;
  }

  return Object.entries(value).every(([dateKey, tasks]) => {
    if (!DATE_KEY_PATTERN.test(dateKey) || !Array.isArray(tasks)) {
      return false;
    }

    if (tasks.length !== MAX_TASK_SLOTS) {
      return false;
    }

    return tasks.every(isValidTaskSlot);
  });
}

export function isValidJournalData(value: unknown): value is JournalData {
  if (typeof value !== "object" || value === null) {
    return false;
  }

  const data = value as Record<string, unknown>;

  return (
    data.version === JOURNAL_DATA_VERSION &&
    isValidTaskStore(data.taskStore) &&
    Array.isArray(data.userCategories) &&
    data.userCategories.every(
      (category) =>
        typeof category === "string" &&
        category.trim().length > 0 &&
        category.length <= 20,
    ) &&
    typeof data.selectedFilter === "string"
  );
}

export function buildJournalData(
  taskStore: TaskStoreData,
  userCategories: string[],
  selectedFilter: CategoryFilter,
): JournalData {
  const filterOptions = buildFilterOptions(userCategories);

  return {
    version: JOURNAL_DATA_VERSION,
    taskStore,
    userCategories,
    selectedFilter: sanitizeSelectedFilter(selectedFilter, filterOptions),
  };
}

export function serializeJournalData(data: JournalData): string {
  return JSON.stringify(data, null, 2);
}

export function parseJournalData(raw: string): JournalData | null {
  try {
    const parsed: unknown = JSON.parse(raw);
    return isValidJournalData(parsed) ? parsed : null;
  } catch {
    return null;
  }
}

export function downloadJournalData(data: JournalData): void {
  const blob = new Blob([serializeJournalData(data)], {
    type: "application/json",
  });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  const stamp = new Date().toISOString().slice(0, 10);

  anchor.href = url;
  anchor.download = `acrosstool-journal-${stamp}.json`;
  anchor.click();
  URL.revokeObjectURL(url);
}
