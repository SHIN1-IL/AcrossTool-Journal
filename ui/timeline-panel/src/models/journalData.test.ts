import { describe, expect, it } from "vitest";
import {
  buildJournalData,
  isValidJournalData,
  parseJournalData,
  serializeJournalData,
} from "./journalData";

describe("journalData", () => {
  const sample = buildJournalData(
    {
      "2026-06-11": [
        { id: 1, label: "운동", completed: true, category: "운동" },
        { id: 2, label: "", completed: false },
        { id: 3, label: "", completed: false },
        { id: 4, label: "", completed: false },
        { id: 5, label: "", completed: false },
      ],
    },
    ["취미"],
    "운동",
  );

  it("builds schema version 1 payload", () => {
    expect(sample.version).toBe(1);
    expect(sample.userCategories).toEqual(["취미"]);
    expect(sample.selectedFilter).toBe("운동");
  });

  it("round-trips through JSON", () => {
    const parsed = parseJournalData(serializeJournalData(sample));
    expect(parsed).toEqual(sample);
  });

  it("rejects invalid payloads", () => {
    expect(parseJournalData("{")).toBeNull();
    expect(
      isValidJournalData({
        version: 2,
        taskStore: {},
        userCategories: [],
        selectedFilter: "전체",
      }),
    ).toBe(false);
    expect(
      isValidJournalData({
        version: 1,
        taskStore: { "2026-06-11": [] },
        userCategories: [],
        selectedFilter: "전체",
      }),
    ).toBe(false);
  });
});
