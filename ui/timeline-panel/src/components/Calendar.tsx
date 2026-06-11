import { useEffect, useState } from "react";
import type { CompletionRateMap } from "../models/completionRate";
import {
  buildCalendarDateAriaLabel,
  getCompletionEntryForDate,
} from "../models/completionRate";
import { dateKey } from "../models/taskStore";
import { CompletionMarker } from "./CompletionMarker";

type CalendarProps = {
  selectedDate: Date;
  completionRates: CompletionRateMap;
  onSelectDate: (date: Date) => void;
};

export function Calendar({
  selectedDate,
  completionRates,
  onSelectDate,
}: CalendarProps) {
  const today = new Date();
  const [viewMonth, setViewMonth] = useState(
    () => new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1),
  );

  useEffect(() => {
    setViewMonth(
      new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1),
    );
  }, [selectedDate]);

  const year = viewMonth.getFullYear();
  const month = viewMonth.getMonth();
  const firstDay = new Date(year, month, 1).getDay();
  const daysInMonth = new Date(year, month + 1, 0).getDate();

  const days: (number | null)[] = [
    ...Array.from({ length: firstDay }, () => null),
    ...Array.from({ length: daysInMonth }, (_, index) => index + 1),
  ];

  const monthLabel = new Intl.DateTimeFormat("ko-KR", {
    year: "numeric",
    month: "long",
  }).format(viewMonth);

  const goToPreviousMonth = () => {
    setViewMonth(new Date(year, month - 1, 1));
  };

  const goToNextMonth = () => {
    setViewMonth(new Date(year, month + 1, 1));
  };

  return (
    <div className="flex h-full flex-col bg-white p-4 sm:p-6">
      <div className="mb-4 flex items-center justify-between gap-2">
        <button
          type="button"
          onClick={goToPreviousMonth}
          aria-label="이전 달"
          className="inline-flex h-9 w-9 items-center justify-center rounded-full text-gray-600 transition hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <span className="material-symbols-outlined text-[20px]" aria-hidden="true">
            chevron_left
          </span>
        </button>
        <p className="text-center text-lg font-semibold text-gray-900">
          {monthLabel}
        </p>
        <button
          type="button"
          onClick={goToNextMonth}
          aria-label="다음 달"
          className="inline-flex h-9 w-9 items-center justify-center rounded-full text-gray-600 transition hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <span className="material-symbols-outlined text-[20px]" aria-hidden="true">
            chevron_right
          </span>
        </button>
      </div>
      <div className="grid grid-cols-7 gap-1 text-center text-xs font-medium text-gray-500">
        {["일", "월", "화", "수", "목", "금", "토"].map((day) => (
          <span key={day}>{day}</span>
        ))}
      </div>
      <div className="mt-2 grid flex-1 grid-cols-7 gap-1">
        {days.map((day, index) => {
          if (day === null) {
            return <span key={`empty-${index}`} />;
          }

          const cellDate = new Date(year, month, day);
          const isSelected =
            cellDate.toDateString() === selectedDate.toDateString();
          const isToday = cellDate.toDateString() === today.toDateString();
          const entry = getCompletionEntryForDate(completionRates, cellDate);

          return (
            <button
              key={dateKey(cellDate)}
              type="button"
              onClick={() => onSelectDate(cellDate)}
              aria-label={buildCalendarDateAriaLabel(month, day, entry)}
              aria-pressed={isSelected}
              className={`flex aspect-square flex-col items-center justify-center gap-0.5 rounded-full text-sm transition ${
                isSelected
                  ? "bg-blue-600 font-semibold text-white"
                  : isToday
                    ? "font-semibold text-blue-600 ring-1 ring-blue-200"
                    : "text-gray-700 hover:bg-gray-100"
              }`}
            >
              <span>{day}</span>
              {entry && (
                <CompletionMarker rate={entry.rate} selected={isSelected} />
              )}
            </button>
          );
        })}
      </div>
    </div>
  );
}
