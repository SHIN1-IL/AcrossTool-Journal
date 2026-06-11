import "fake-indexeddb/auto";
import "@testing-library/jest-dom/vitest";
import { del } from "idb-keyval";
import { cleanup } from "@testing-library/react";
import { afterEach } from "vitest";
import {
  SELECTED_FILTER_KEY,
  USER_CATEGORIES_KEY,
} from "../storage/preferencesStorage";
import { clearTaskStoreFromIndexedDB } from "../storage/taskStorage";

afterEach(async () => {
  cleanup();
  localStorage.clear();
  await clearTaskStoreFromIndexedDB();
  await del(USER_CATEGORIES_KEY);
  await del(SELECTED_FILTER_KEY);
});
