import { render } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { CompletionMarker } from "./CompletionMarker";

describe("CompletionMarker", () => {
  it("renders zero-tier marker for 0% completion", () => {
    const { container } = render(<CompletionMarker rate={0} />);
    const marker = container.querySelector("[data-tier='zero']");
    expect(marker).toBeInTheDocument();
    expect(marker).toHaveClass("bg-gray-400");
  });

  it("renders low-tier marker for 1-30% completion", () => {
    const { container } = render(<CompletionMarker rate={20} />);
    const marker = container.querySelector("[data-tier='low']");
    expect(marker).toBeInTheDocument();
    expect(marker).toHaveClass("bg-red-500");
  });

  it("renders medium-tier marker for 31-70% completion", () => {
    const { container } = render(<CompletionMarker rate={50} />);
    const marker = container.querySelector("[data-tier='medium']");
    expect(marker).toBeInTheDocument();
    expect(marker).toHaveClass("bg-orange-400");
  });

  it("renders high-tier marker for 71-100% completion", () => {
    const { container } = render(<CompletionMarker rate={90} />);
    const marker = container.querySelector("[data-tier='high']");
    expect(marker).toBeInTheDocument();
    expect(marker).toHaveClass("bg-green-500");
  });
});
