import { useCallback, useEffect, useMemo, useState } from "react";
import {
  addUserCategory,
  buildFilterOptions,
  FILTER_ALL,
  removeUserCategory,
  sanitizeSelectedFilter,
  type CategoryFilter,
} from "../models/categoryStore";
import {
  loadSelectedFilter,
  loadUserCategories,
  saveSelectedFilter,
  saveUserCategories,
} from "../storage/preferencesStorage";

export function useCategories() {
  const [userCategories, setUserCategories] = useState<string[]>([]);
  const [selectedCategory, setSelectedCategory] =
    useState<CategoryFilter>(FILTER_ALL);
  const [isHydrated, setIsHydrated] = useState(false);

  const filterOptions = useMemo(
    () => buildFilterOptions(userCategories),
    [userCategories],
  );

  const assignableCategories = useMemo(
    () => filterOptions.filter((category) => category !== FILTER_ALL),
    [filterOptions],
  );

  useEffect(() => {
    let cancelled = false;

    Promise.all([loadUserCategories(), loadSelectedFilter()]).then(
      ([categories, filter]) => {
        if (cancelled) {
          return;
        }

        const options = buildFilterOptions(categories);
        setUserCategories(categories);
        setSelectedCategory(sanitizeSelectedFilter(filter, options));
        setIsHydrated(true);
      },
    );

    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    if (!isHydrated) {
      return;
    }

    void saveUserCategories(userCategories);
  }, [userCategories, isHydrated]);

  useEffect(() => {
    if (!isHydrated) {
      return;
    }

    void saveSelectedFilter(selectedCategory);
  }, [selectedCategory, isHydrated]);

  const handleSelectCategory = useCallback((category: CategoryFilter) => {
    setSelectedCategory(category);
  }, []);

  const handleAddCategory = useCallback((name: string) => {
    setUserCategories((prev) => {
      const result = addUserCategory(prev, name);
      return result?.categories ?? prev;
    });
  }, []);

  const handleRemoveCategory = useCallback((name: string) => {
    setUserCategories((prev) => removeUserCategory(prev, name));
    setSelectedCategory((prev) => (prev === name ? FILTER_ALL : prev));
  }, []);

  const importPreferences = useCallback(
    (categories: string[], filter: CategoryFilter) => {
      const options = buildFilterOptions(categories);
      setUserCategories(categories);
      setSelectedCategory(sanitizeSelectedFilter(filter, options));
      setIsHydrated(true);
    },
    [],
  );

  return {
    userCategories,
    selectedCategory,
    filterOptions,
    assignableCategories,
    isHydrated,
    setSelectedCategory: handleSelectCategory,
    addCategory: handleAddCategory,
    removeCategory: handleRemoveCategory,
    importPreferences,
  };
}
