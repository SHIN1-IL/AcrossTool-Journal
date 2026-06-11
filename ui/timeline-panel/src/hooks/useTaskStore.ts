import { useCallback, useEffect, useState } from "react";
import {
  createInitialTaskStore,
  ensureTasksForDate,
  getTasksForDate,
  loadTaskStore,
  saveTaskStore,
  toggleTask,
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

  return {
    taskStore,
    tasks,
    isHydrated,
    ensureDate,
    handleToggle,
    handleLabelChange,
  };
}
