import { get, set } from "idb-keyval";
import {
  FILTER_ALL,
  type CategoryFilter,
} from "../models/categoryStore";

export const USER_CATEGORIES_KEY = "acrosstool-journal-user-categories";
export const SELECTED_FILTER_KEY = "acrosstool-journal-selected-filter";

function isStringArray(value: unknown): value is string[] {
  return (
    Array.isArray(value) && value.every((item) => typeof item === "string")
  );
}

export async function loadUserCategories(): Promise<string[]> {
  const value = await get<string[]>(USER_CATEGORIES_KEY);
  return isStringArray(value) ? value : [];
}

export async function saveUserCategories(categories: string[]): Promise<void> {
  await set(USER_CATEGORIES_KEY, categories);
}

export async function loadSelectedFilter(): Promise<CategoryFilter> {
  const value = await get<string>(SELECTED_FILTER_KEY);
  return typeof value === "string" ? value : FILTER_ALL;
}

export async function saveSelectedFilter(
  filter: CategoryFilter,
): Promise<void> {
  await set(SELECTED_FILTER_KEY, filter);
}
