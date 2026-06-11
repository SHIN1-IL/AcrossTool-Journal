import { describe, expect, it } from "vitest";
import {
  addUserCategory,
  buildFilterOptions,
  normalizeCategoryName,
  removeUserCategory,
  sanitizeSelectedFilter,
} from "./categoryStore";

describe("categoryStore", () => {
  it("builds filter options with built-in and custom categories", () => {
    expect(buildFilterOptions(["취미", "운동"])).toEqual([
      "전체",
      "운동",
      "학습",
      "업무",
      "루틴",
      "취미",
    ]);
  });

  it("adds a unique custom category", () => {
    const result = addUserCategory([], "취미");
    expect(result).toEqual({ categories: ["취미"], added: "취미" });
  });

  it("rejects duplicate or built-in category names", () => {
    expect(addUserCategory([], "운동")).toBeNull();
    expect(addUserCategory(["취미"], "취미")).toBeNull();
    expect(addUserCategory([], "  ")).toBeNull();
  });

  it("normalizes category names", () => {
    expect(normalizeCategoryName("  취미  ")).toBe("취미");
    expect(normalizeCategoryName("전체")).toBeNull();
  });

  it("removes custom categories and resets invalid filters", () => {
    expect(removeUserCategory(["취미", "여행"], "취미")).toEqual(["여행"]);
    expect(sanitizeSelectedFilter("삭제됨", ["전체", "운동"])).toBe("전체");
  });
});
