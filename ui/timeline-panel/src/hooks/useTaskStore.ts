import { useCallback, useEffect, useState } from "react";
import {
  clearCategoryFromAllTasks,
  createInitialTaskStore,
  ensureTasksForDate,
  getTasksForDate,
  loadTaskStore,
  saveTaskStore,
  toggleTask,
  updateTaskCategory,
  updateTaskLabel,
} from "../models/taskStore";

export function useTaskStore(selectedDate: Date) {
  const [taskStore, setTaskStore] = useState(createInitialTaskStore);
  const [isHydrated, setIsHydrated] = useState(false);

  useEffect(() => {
    let cancelled = false;

    loadTaskStore().then((store) => {
      if (!cancelled) {
        setTaskStore(store);
        setIsHydrated(true);
      }
    });

    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    if (!isHydrated) {
      return;
    }

    void saveTaskStore(taskStore);
  }, [taskStore, isHydrated]);

  const tasks = getTasksForDate(taskStore, selectedDate);

  const ensureDate = useCallback((date: Date) => {
    setTaskStore((prev) => ensureTasksForDate(prev, date));
  }, []);

  const handleToggle = useCallback(
    (taskId: number) => {
      setTaskStore((prev) => toggleTask(prev, selectedDate, taskId));
    },
    [selectedDate],
  );

  const handleLabelChange = useCallback(
    (taskId: number, label: string) => {
      setTaskStore((prev) => updateTaskLabel(prev, selectedDate, taskId, label));
    },
    [selectedDate],
  );

  const handleCategoryChange = useCallback(
    (taskId: number, category: string | undefined) => {
      setTaskStore((prev) =>
        updateTaskCategory(prev, selectedDate, taskId, category),
      );
    },
    [selectedDate],
  );

  const clearCategory = useCallback((category: string) => {
    setTaskStore((prev) => clearCategoryFromAllTasks(prev, category));
  }, []);

  return {
    taskStore,
    tasks,
    isHydrated,
    ensureDate,
    handleToggle,
    handleLabelChange,
    handleCategoryChange,
    clearCategory,
  };
}
