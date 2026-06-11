import { del, get, set } from "idb-keyval";
import type { TaskSlot } from "../types";

export const STORAGE_KEY = "acrosstool-journal-tasks";

export type TaskStoreData = Record<string, TaskSlot[]>;

function isValidTaskStore(value: unknown): value is TaskStoreData {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function readLegacyLocalStorage(): TaskStoreData | null {
  if (typeof window === "undefined") {
    return null;
  }

  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) {
      return null;
    }

    const parsed: unknown = JSON.parse(raw);
    return isValidTaskStore(parsed) ? parsed : null;
  } catch {
    return null;
  }
}

function clearLegacyLocalStorage(): void {
  if (typeof window === "undefined") {
    return;
  }

  window.localStorage.removeItem(STORAGE_KEY);
}

export async function readTaskStoreFromIndexedDB(): Promise<TaskStoreData | null> {
  const value = await get<TaskStoreData>(STORAGE_KEY);
  return isValidTaskStore(value) ? value : null;
}

export async function writeTaskStoreToIndexedDB(
  store: TaskStoreData,
): Promise<void> {
  await set(STORAGE_KEY, store);
}

export async function clearTaskStoreFromIndexedDB(): Promise<void> {
  await del(STORAGE_KEY);
}

export async function loadPersistedTaskStore(): Promise<TaskStoreData | null> {
  const indexedDbStore = await readTaskStoreFromIndexedDB();
  if (indexedDbStore) {
    return indexedDbStore;
  }

  const legacyStore = readLegacyLocalStorage();
  if (!legacyStore) {
    return null;
  }

  await writeTaskStoreToIndexedDB(legacyStore);
  clearLegacyLocalStorage();
  return legacyStore;
}

export async function savePersistedTaskStore(store: TaskStoreData): Promise<void> {
  await writeTaskStoreToIndexedDB(store);
}
