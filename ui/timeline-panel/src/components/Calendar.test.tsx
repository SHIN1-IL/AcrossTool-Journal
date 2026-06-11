import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { Calendar } from "./Calendar";

describe("Calendar", () => {
  it("renders completion markers only for dates with labeled tasks", () => {
    render(
      <Calendar
        selectedDate={new Date(2026, 5, 11)}
        completionRates={{
          "2026-06-11": { rate: 20 },
          "2026-06-12": { rate: 80 },
        }}
        onSelectDate={() => undefined}
      />,
    );

    expect(
      screen.getByRole("button", {
        name: "6월 11일 선택, 완료율 20% (낮음)",
      }),
    ).toBeInTheDocument();
    expect(
      screen.getByRole("button", {
        name: "6월 12일 선택, 완료율 80% (높음)",
      }),
    ).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: "6월 10일 선택, 라벨 있는 일과 없음" }),
    ).toBeInTheDocument();
    expect(screen.getAllByLabelText(/완료율/)).toHaveLength(2);
  });

  it("renders a zero-tier marker and aria label for 0% completion", () => {
    render(
      <Calendar
        selectedDate={new Date(2026, 5, 13)}
        completionRates={{
          "2026-06-13": { rate: 0 },
        }}
        onSelectDate={() => undefined}
      />,
    );

    const dayButton = screen.getByRole("button", {
      name: "6월 13일 선택, 완료율 0% (미완료)",
    });
    expect(dayButton).toBeInTheDocument();
    expect(dayButton.querySelector("[data-tier='zero']")).toBeInTheDocument();
  });

  it("keeps date selection working with markers present", () => {
    const onSelectDate = vi.fn();

    render(
      <Calendar
        selectedDate={new Date(2026, 5, 11)}
        completionRates={{ "2026-06-15": { rate: 40 } }}
        onSelectDate={onSelectDate}
      />,
    );

    fireEvent.click(
      screen.getByRole("button", {
        name: "6월 15일 선택, 완료율 40% (보통)",
      }),
    );
    expect(onSelectDate).toHaveBeenCalledWith(new Date(2026, 5, 15));
  });

  it("updates visible month and marker labels when navigating months", () => {
    render(
      <Calendar
        selectedDate={new Date(2026, 5, 11)}
        completionRates={{
          "2026-06-11": { rate: 20 },
          "2026-07-04": { rate: 100 },
        }}
        onSelectDate={() => undefined}
      />,
    );

    expect(screen.getByText("2026년 6월")).toBeInTheDocument();
    expect(
      screen.getByRole("button", {
        name: "6월 11일 선택, 완료율 20% (낮음)",
      }),
    ).toBeInTheDocument();

    fireEvent.click(screen.getByRole("button", { name: "다음 달" }));

    expect(screen.getByText("2026년 7월")).toBeInTheDocument();
    expect(
      screen.queryByRole("button", {
        name: "6월 11일 선택, 완료율 20% (낮음)",
      }),
    ).not.toBeInTheDocument();
    expect(
      screen.getByRole("button", {
        name: "7월 4일 선택, 완료율 100% (높음)",
      }),
    ).toBeInTheDocument();
  });
});
