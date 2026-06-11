import {
  getCompletionTier,
  type CompletionTier,
} from "../models/completionRate";

type CompletionMarkerProps = {
  rate: number;
  selected?: boolean;
};

const TIER_CLASS: Record<CompletionTier, string> = {
  zero: "bg-gray-400",
  low: "bg-red-500",
  medium: "bg-orange-400",
  high: "bg-green-500",
};

export function CompletionMarker({ rate, selected = false }: CompletionMarkerProps) {
  const tier = getCompletionTier(rate);

  return (
    <span
      className={`block h-1.5 w-1.5 shrink-0 rounded-full ${TIER_CLASS[tier]} ${
        selected ? "ring-1 ring-white/90" : ""
      }`}
      aria-hidden="true"
      data-tier={tier}
      data-rate={rate}
    />
  );
}
