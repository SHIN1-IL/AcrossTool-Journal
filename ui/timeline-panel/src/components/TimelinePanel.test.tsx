import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { TimelinePanel } from "./TimelinePanel";

const sampleTasks = [
  { id: 1, label: "아침 스트레칭", completed: true, category: "운동" },
  { id: 2, label: "영어 단어", completed: false, category: "학습" },
  { id: 3, label: "", completed: false },
  { id: 4, label: "", completed: false },
  { id: 5, label: "", completed: false },
];

const categories = ["운동", "학습", "업무", "루틴"];

describe("TimelinePanel", () => {
  it("renders 5 task rows for the selected date", () => {
    render(
      <TimelinePanel
        selectedDate={new Date(2026, 5, 11)}
        tasks={sampleTasks}
        categories={categories}
        onToggle={() => undefined}
        onLabelChange={() => undefined}
        onCategoryChange={() => undefined}
      />,
    );

    expect(screen.getByText("오늘 일과 5줄")).toBeInTheDocument();
    expect(screen.getAllByRole("checkbox")).toHaveLength(5);
    expect(screen.getByDisplayValue("아침 스트레칭")).toBeInTheDocument();
  });

  it("shows filtered empty state with dynamic subtitle", () => {
    render(
      <TimelinePanel
        selectedDate={new Date(2026, 5, 11)}
        tasks={[]}
        categories={categories}
        filterLabel="운동"
        onToggle={() => undefined}
        onLabelChange={() => undefined}
        onCategoryChange={() => undefined}
      />,
    );

    expect(screen.getByText("운동 일과 0줄")).toBeInTheDocument();
    expect(
      screen.getByText("선택한 카테고리에 해당하는 일과가 없습니다."),
    ).toBeInTheDocument();
  });

  it("calls onToggle when a checkbox is clicked", () => {
    const onToggle = vi.fn();

    render(
      <TimelinePanel
        selectedDate={new Date(2026, 5, 11)}
        tasks={sampleTasks}
        categories={categories}
        onToggle={onToggle}
        onLabelChange={() => undefined}
        onCategoryChange={() => undefined}
      />,
    );

    fireEvent.click(screen.getByLabelText("2번째 일과 완료"));
    expect(onToggle).toHaveBeenCalledWith(2);
  });
});
