import { beforeEach, describe, expect, it } from "vitest";
import { STORAGE_KEY } from "../models/taskStore";
import {
  clearTaskStoreFromIndexedDB,
  loadPersistedTaskStore,
  readTaskStoreFromIndexedDB,
  savePersistedTaskStore,
} from "./taskStorage";

describe("taskStorage", () => {
  beforeEach(async () => {
    localStorage.clear();
    await clearTaskStoreFromIndexedDB();
  });

  it("saves and reads task store from IndexedDB", async () => {
    const store = {
      "2026-06-11": [
        { id: 1, label: "운동", completed: true, category: "운동" },
        { id: 2, label: "", completed: false },
        { id: 3, label: "", completed: false },
        { id: 4, label: "", completed: false },
        { id: 5, label: "", completed: false },
      ],
    };

    await savePersistedTaskStore(store);
    expect(await readTaskStoreFromIndexedDB()).toEqual(store);
  });

  it("migrates legacy localStorage data into IndexedDB", async () => {
    const legacyStore = {
      "2026-06-12": [
        { id: 1, label: "회의", completed: false, category: "업무" },
        { id: 2, label: "", completed: false },
        { id: 3, label: "", completed: false },
        { id: 4, label: "", completed: false },
        { id: 5, label: "", completed: false },
      ],
    };

    localStorage.setItem(STORAGE_KEY, JSON.stringify(legacyStore));

    expect(await loadPersistedTaskStore()).toEqual(legacyStore);
    expect(await readTaskStoreFromIndexedDB()).toEqual(legacyStore);
    expect(localStorage.getItem(STORAGE_KEY)).toBeNull();
  });

  it("returns null when no persisted data exists", async () => {
    expect(await loadPersistedTaskStore()).toBeNull();
  });
});
