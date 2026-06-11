type CategorySelectProps = {
  value?: string;
  categories: string[];
  onChange: (category: string | undefined) => void;
  ariaLabel: string;
};

export function CategorySelect({
  value,
  categories,
  onChange,
  ariaLabel,
}: CategorySelectProps) {
  return (
    <select
      value={value ?? ""}
      onChange={(event) =>
        onChange(event.target.value === "" ? undefined : event.target.value)
      }
      aria-label={ariaLabel}
      className="w-20 shrink-0 rounded border border-gray-200 bg-white px-1.5 py-1 text-xs text-gray-700 focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
    >
      <option value="">없음</option>
      {categories.map((category) => (
        <option key={category} value={category}>
          {category}
        </option>
      ))}
    </select>
  );
}
