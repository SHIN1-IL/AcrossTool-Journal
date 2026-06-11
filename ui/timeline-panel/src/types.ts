export type TaskSlot = {
  id: number;
  label: string;
  completed: boolean;
  category?: string;
};

export const MAX_TASK_SLOTS = 5;
