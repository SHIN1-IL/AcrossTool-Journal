import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { TimelinePanel } from "./TimelinePanel";

const sampleTasks = [
  { id: 1, label: "아침 스트레칭", completed: true },
  { id: 2, label: "영어 단어", completed: false },
  { id: 3, label: "", completed: false },
  { id: 4, label: "", completed: false },
  { id: 5, label: "", completed: false },
];

describe("TimelinePanel", () => {
  it("renders 5 task rows for the selected date", () => {
    render(
      <TimelinePanel
        selectedDate={new Date(2026, 5, 11)}
        tasks={sampleTasks}
        onToggle={() => undefined}
        onLabelChange={() => undefined}
      />,
    );

    expect(screen.getByText("오늘 일과 5줄")).toBeInTheDocument();
    expect(screen.getAllByRole("checkbox")).toHaveLength(5);
    expect(screen.getByDisplayValue("아침 스트레칭")).toBeInTheDocument();
  });

  it("calls onToggle when a checkbox is clicked", () => {
    const onToggle = vi.fn();

    render(
      <TimelinePanel
        selectedDate={new Date(2026, 5, 11)}
        tasks={sampleTasks}
        onToggle={onToggle}
        onLabelChange={() => undefined}
      />,
    );

    fireEvent.click(screen.getByLabelText("2번째 일과 완료"));
    expect(onToggle).toHaveBeenCalledWith(2);
  });
});
