export const FILTER_ALL = "전체" as const;

export const BUILTIN_CATEGORIES = ["운동", "학습", "업무", "루틴"] as const;

export type BuiltinCategory = (typeof BUILTIN_CATEGORIES)[number];

export type CategoryFilter = typeof FILTER_ALL | string;

export type TaskCategory = BuiltinCategory | string;

export function buildFilterOptions(userCategories: string[]): string[] {
  const custom = userCategories.filter(
    (category) =>
      category !== FILTER_ALL &&
      !BUILTIN_CATEGORIES.includes(category as BuiltinCategory),
  );

  return [FILTER_ALL, ...BUILTIN_CATEGORIES, ...custom];
}

export function buildAssignableCategories(userCategories: string[]): string[] {
  const custom = userCategories.filter(
    (category) =>
      !BUILTIN_CATEGORIES.includes(category as BuiltinCategory),
  );

  return [...BUILTIN_CATEGORIES, ...custom];
}

export function normalizeCategoryName(name: string): string | null {
  const trimmed = name.trim();
  if (!trimmed || trimmed === FILTER_ALL) {
    return null;
  }
  if (trimmed.length > 20) {
    return null;
  }
  return trimmed;
}

export function addUserCategory(
  userCategories: string[],
  name: string,
): { categories: string[]; added: string } | null {
  const normalized = normalizeCategoryName(name);
  if (!normalized) {
    return null;
  }

  if (
    BUILTIN_CATEGORIES.includes(normalized as BuiltinCategory) ||
    userCategories.includes(normalized)
  ) {
    return null;
  }

  return {
    categories: [...userCategories, normalized],
    added: normalized,
  };
}

export function removeUserCategory(
  userCategories: string[],
  name: string,
): string[] {
  return userCategories.filter((category) => category !== name);
}

export function isBuiltinCategory(category: string): boolean {
  return BUILTIN_CATEGORIES.includes(category as BuiltinCategory);
}

export function sanitizeSelectedFilter(
  selected: string,
  filterOptions: string[],
): CategoryFilter {
  return filterOptions.includes(selected) ? selected : FILTER_ALL;
}
