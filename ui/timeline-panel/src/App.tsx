import { useEffect, useMemo, useState } from "react";
import { Calendar } from "./components/Calendar";
import { CategoryFilterMenu } from "./components/CategoryFilterMenu";
import { MobileBottomSheet } from "./components/MobileBottomSheet";
import { TimelinePanel } from "./components/TimelinePanel";
import { useTaskStore } from "./hooks/useTaskStore";
import { buildCompletionRateMap } from "./models/completionRate";
import {
  filterTasksByCategory,
  type CategoryFilter,
} from "./models/taskStore";

const WIDE_LAYOUT_QUERY = "(min-width: 600px)";

function AppBar({
  onFilterClick,
}: {
  onFilterClick: () => void;
}) {
  return (
    <header className="flex shrink-0 items-center justify-between border-b border-gray-200 bg-white px-4 py-3">
      <h1 className="text-base font-semibold text-gray-900 sm:text-lg">
        AcrossTool Journal
      </h1>
      <button
        type="button"
        onClick={onFilterClick}
        aria-label="카테고리 필터"
        title="카테고리 필터"
        className="inline-flex h-10 w-10 items-center justify-center rounded-full text-gray-600 transition hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
      >
        <span
          className="material-symbols-outlined text-[22px]"
          aria-hidden="true"
        >
          filter_list_alt
        </span>
      </button>
    </header>
  );
}

export default function App() {
  const [selectedDate, setSelectedDate] = useState(() => new Date());
  const [selectedCategory, setSelectedCategory] =
    useState<CategoryFilter>("전체");
  const [isFilterOpen, setIsFilterOpen] = useState(false);
  const [isMobileSheetOpen, setIsMobileSheetOpen] = useState(false);
  const [isWideLayout, setIsWideLayout] = useState(
    () => window.matchMedia(WIDE_LAYOUT_QUERY).matches,
  );

  const { taskStore, tasks, ensureDate, handleToggle, handleLabelChange } =
    useTaskStore(selectedDate);

  const completionRates = useMemo(
    () => buildCompletionRateMap(taskStore, selectedCategory),
    [taskStore, selectedCategory],
  );

  const filteredTasks = useMemo(
    () => filterTasksByCategory(tasks, selectedCategory),
    [tasks, selectedCategory],
  );

  const displayTasks = useMemo(() => {
    if (selectedCategory === "전체") {
      return tasks;
    }

    const visible = filteredTasks;
    const padded = [...visible];
    while (padded.length < 5) {
      padded.push({
        id: padded.length + 1,
        label: "",
        completed: false,
      });
    }

    return padded.slice(0, 5);
  }, [tasks, filteredTasks, selectedCategory]);

  useEffect(() => {
    const media = window.matchMedia(WIDE_LAYOUT_QUERY);
    const handler = (event: MediaQueryListEvent) => {
      setIsWideLayout(event.matches);
      if (event.matches) {
        setIsMobileSheetOpen(false);
      }
    };

    media.addEventListener("change", handler);
    return () => media.removeEventListener("change", handler);
  }, []);

  const handleSelectDate = (date: Date) => {
    ensureDate(date);
    setSelectedDate(date);
    if (!isWideLayout) {
      setIsMobileSheetOpen(true);
    }
  };

  return (
    <>
      <link
        rel="stylesheet"
        href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0"
      />
      <div className="flex h-dvh flex-col bg-white text-gray-900">
        <AppBar onFilterClick={() => setIsFilterOpen(true)} />

        {isWideLayout ? (
          <div className="flex min-h-0 flex-1">
            <div className="min-w-0 flex-[6]">
              <Calendar
                selectedDate={selectedDate}
                completionRates={completionRates}
                onSelectDate={handleSelectDate}
              />
            </div>
            <div
              className="w-px shrink-0 bg-gray-200"
              role="separator"
              aria-orientation="vertical"
            />
            <div className="min-w-0 flex-[4]">
              <TimelinePanel
                selectedDate={selectedDate}
                tasks={displayTasks}
                onToggle={handleToggle}
                onLabelChange={handleLabelChange}
              />
            </div>
          </div>
        ) : (
          <div className="min-h-0 flex-1">
            <Calendar
              selectedDate={selectedDate}
              completionRates={completionRates}
              onSelectDate={handleSelectDate}
            />
          </div>
        )}

        {isFilterOpen && (
          <CategoryFilterMenu
            selectedCategory={selectedCategory}
            onSelect={setSelectedCategory}
            onClose={() => setIsFilterOpen(false)}
          />
        )}

        {!isWideLayout && isMobileSheetOpen && (
          <MobileBottomSheet
            selectedDate={selectedDate}
            tasks={displayTasks}
            onToggle={handleToggle}
            onClose={() => setIsMobileSheetOpen(false)}
          />
        )}
      </div>
    </>
  );
}
