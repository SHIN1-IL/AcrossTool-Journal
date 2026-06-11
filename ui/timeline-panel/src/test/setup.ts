import "fake-indexeddb/auto";
import "@testing-library/jest-dom/vitest";
import { cleanup } from "@testing-library/react";
import { afterEach } from "vitest";
import { clearTaskStoreFromIndexedDB } from "../storage/taskStorage";

afterEach(async () => {
  cleanup();
  localStorage.clear();
  await clearTaskStoreFromIndexedDB();
});
