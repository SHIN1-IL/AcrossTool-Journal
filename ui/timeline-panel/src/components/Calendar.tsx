type CalendarProps = {
  selectedDate: Date;
  onSelectDate: (date: Date) => void;
};

export function Calendar({ selectedDate, onSelectDate }: CalendarProps) {
  const today = new Date();
  const year = selectedDate.getFullYear();
  const month = selectedDate.getMonth();
  const firstDay = new Date(year, month, 1).getDay();
  const daysInMonth = new Date(year, month + 1, 0).getDate();

  const days: (number | null)[] = [
    ...Array.from({ length: firstDay }, () => null),
    ...Array.from({ length: daysInMonth }, (_, index) => index + 1),
  ];

  const monthLabel = new Intl.DateTimeFormat("ko-KR", {
    year: "numeric",
    month: "long",
  }).format(selectedDate);

  return (
    <div className="flex h-full flex-col bg-white p-4 sm:p-6">
      <p className="mb-4 text-center text-lg font-semibold text-gray-900">
        {monthLabel}
      </p>
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

          return (
            <button
              key={day}
              type="button"
              onClick={() => onSelectDate(cellDate)}
              aria-label={`${month + 1}월 ${day}일 선택`}
              aria-pressed={isSelected}
              className={`flex aspect-square items-center justify-center rounded-full text-sm transition ${
                isSelected
                  ? "bg-blue-600 font-semibold text-white"
                  : isToday
                    ? "font-semibold text-blue-600 ring-1 ring-blue-200"
                    : "text-gray-700 hover:bg-gray-100"
              }`}
            >
              {day}
            </button>
          );
        })}
      </div>
    </div>
  );
}
