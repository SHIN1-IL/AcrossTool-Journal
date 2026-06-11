import { useCallback, useEffect, useState } from "react";
import {
  ensureTasksForDate,
  getTasksForDate,
  loadTaskStore,
  saveTaskStore,
  toggleTask,
  updateTaskLabel,
} from "../models/taskStore";

export function useTaskStore(selectedDate: Date) {
  const [taskStore, setTaskStore] = useState(loadTaskStore);

  useEffect(() => {
    saveTaskStore(taskStore);
  }, [taskStore]);

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
    tasks,
    ensureDate,
    handleToggle,
    handleLabelChange,
  };
}
