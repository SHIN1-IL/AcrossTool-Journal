import { DEFAULT_CATEGORIES, type CategoryFilter } from "../models/taskStore";

type CategoryFilterMenuProps = {
  selectedCategory: CategoryFilter;
  onSelect: (category: CategoryFilter) => void;
  onClose: () => void;
};

export function CategoryFilterMenu({
  selectedCategory,
  onSelect,
  onClose,
}: CategoryFilterMenuProps) {
  return (
    <div
      className="fixed inset-0 z-40 flex items-start justify-end bg-black/20 p-4"
      onClick={onClose}
      role="presentation"
    >
      <div
        className="mt-12 w-48 rounded-lg border border-gray-200 bg-white p-2 shadow-lg"
        onClick={(event) => event.stopPropagation()}
        role="menu"
        aria-label="카테고리 필터"
      >
        {DEFAULT_CATEGORIES.map((category) => (
          <button
            key={category}
            type="button"
            role="menuitemradio"
            aria-checked={selectedCategory === category}
            onClick={() => {
              onSelect(category);
              onClose();
            }}
            className={`flex w-full items-center rounded-md px-3 py-2 text-left text-sm transition ${
              selectedCategory === category
                ? "bg-blue-50 font-medium text-blue-700"
                : "text-gray-700 hover:bg-gray-50"
            }`}
          >
            {category}
          </button>
        ))}
      </div>
    </div>
  );
}
