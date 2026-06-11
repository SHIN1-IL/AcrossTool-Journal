import type { TaskSlot } from "../types";
import { CategorySelect } from "./CategorySelect";

type TimelinePanelProps = {
  selectedDate: Date;
  tasks: TaskSlot[];
  categories: string[];
  filterLabel?: string;
  onToggle: (id: number) => void;
  onLabelChange: (id: number, label: string) => void;
  onCategoryChange: (id: number, category: string | undefined) => void;
};

function formatSelectedDate(date: Date): string {
  return new Intl.DateTimeFormat("ko-KR", {
    year: "numeric",
    month: "long",
    day: "numeric",
    weekday: "long",
  }).format(date);
}

export function TimelinePanel({
  selectedDate,
  tasks,
  categories,
  filterLabel,
  onToggle,
  onLabelChange,
  onCategoryChange,
}: TimelinePanelProps) {
  const subtitle = filterLabel
    ? `${filterLabel} 일과 ${tasks.length}줄`
    : "오늘 일과 5줄";

  return (
    <section
      className="flex h-full min-h-0 flex-col bg-gray-50 p-5"
      aria-label={`${formatSelectedDate(selectedDate)} 일과 타임라인`}
    >
      <header className="mb-4 shrink-0">
        <p className="text-xs font-medium uppercase tracking-wide text-gray-500">
          선택된 날짜
        </p>
        <h2 className="text-lg font-semibold text-gray-900">
          {formatSelectedDate(selectedDate)}
        </h2>
        <p className="mt-1 text-sm text-gray-600">{subtitle}</p>
      </header>

      {tasks.length === 0 ? (
        <p className="flex flex-1 items-center justify-center text-sm text-gray-500">
          선택한 카테고리에 해당하는 일과가 없습니다.
        </p>
      ) : (
        <ol
          className={`flex flex-1 flex-col gap-2 ${filterLabel ? "" : "justify-between"}`}
          role="list"
        >
          {tasks.map((task, index) => (
            <li
              key={task.id}
              className="flex min-h-[3rem] items-center gap-2 rounded-lg border border-gray-200 bg-white px-3 py-2 shadow-sm"
            >
              <input
                id={`task-${task.id}`}
                type="checkbox"
                checked={task.completed}
                onChange={() => onToggle(task.id)}
                aria-label={`${index + 1}번째 일과 완료`}
                className="h-5 w-5 shrink-0 cursor-pointer rounded border-gray-300 text-blue-600 focus:ring-2 focus:ring-blue-500"
              />
              <label htmlFor={`task-${task.id}`} className="sr-only">
                {index + 1}번째 일과
              </label>
              <CategorySelect
                value={task.category}
                categories={categories}
                onChange={(category) => onCategoryChange(task.id, category)}
                ariaLabel={`${index + 1}번째 일과 카테고리`}
              />
              <input
                type="text"
                value={task.label}
                onChange={(event) => onLabelChange(task.id, event.target.value)}
                aria-label={`${index + 1}번째 일과 내용`}
                placeholder={`일과 ${index + 1}`}
                className={`min-w-0 flex-1 border-0 bg-transparent text-sm outline-none focus:ring-0 ${
                  task.completed
                    ? "text-gray-400 line-through"
                    : "text-gray-900"
                }`}
              />
            </li>
          ))}
        </ol>
      )}
    </section>
  );
}
