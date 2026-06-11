import type { TaskSlot } from "../types";

type MobileBottomSheetProps = {
  selectedDate: Date;
  tasks: TaskSlot[];
  onToggle: (id: number) => void;
  onClose: () => void;
};

export function MobileBottomSheet({
  selectedDate,
  tasks,
  onToggle,
  onClose,
}: MobileBottomSheetProps) {
  const dateLabel = new Intl.DateTimeFormat("ko-KR", {
    month: "long",
    day: "numeric",
    weekday: "short",
  }).format(selectedDate);

  return (
    <div
      className="fixed inset-0 z-50 flex items-end bg-black/40"
      onClick={onClose}
      role="presentation"
    >
      <div
        className="h-[300px] w-full rounded-t-[20px] bg-white p-5"
        onClick={(event) => event.stopPropagation()}
        role="dialog"
        aria-modal="true"
        aria-label={`${dateLabel} 일과`}
      >
        <div className="mx-auto mb-4 h-1 w-10 rounded-full bg-gray-300" />
        <h2 className="mb-4 text-base font-semibold text-gray-900">
          {dateLabel} 일과
        </h2>
        <ul className="space-y-3">
          {tasks.map((task, index) => (
            <li key={task.id} className="flex items-center gap-3">
              <input
                id={`mobile-task-${task.id}`}
                type="checkbox"
                checked={task.completed}
                onChange={() => onToggle(task.id)}
                aria-label={`${index + 1}번째 일과 완료`}
                className="h-5 w-5 shrink-0 cursor-pointer rounded border-gray-300 text-blue-600"
              />
              <label
                htmlFor={`mobile-task-${task.id}`}
                className={`text-sm ${
                  task.completed
                    ? "text-gray-400 line-through"
                    : "text-gray-900"
                }`}
              >
                {task.label || `일과 ${index + 1}`}
              </label>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
