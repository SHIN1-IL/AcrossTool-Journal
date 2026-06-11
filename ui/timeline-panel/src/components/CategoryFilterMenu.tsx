import { useState } from "react";
import {
  FILTER_ALL,
  isBuiltinCategory,
  type CategoryFilter,
} from "../models/categoryStore";

type CategoryFilterMenuProps = {
  filterOptions: string[];
  selectedCategory: CategoryFilter;
  onSelect: (category: CategoryFilter) => void;
  onAddCategory: (name: string) => void;
  onRemoveCategory: (name: string) => void;
  onClose: () => void;
};

export function CategoryFilterMenu({
  filterOptions,
  selectedCategory,
  onSelect,
  onAddCategory,
  onRemoveCategory,
  onClose,
}: CategoryFilterMenuProps) {
  const [newCategoryName, setNewCategoryName] = useState("");

  const handleAddCategory = () => {
    const trimmed = newCategoryName.trim();
    if (!trimmed) {
      return;
    }

    onAddCategory(trimmed);
    setNewCategoryName("");
  };

  return (
    <div
      className="fixed inset-0 z-40 flex items-start justify-end bg-black/20 p-4"
      onClick={onClose}
      role="presentation"
    >
      <div
        className="mt-12 w-56 rounded-lg border border-gray-200 bg-white p-2 shadow-lg"
        onClick={(event) => event.stopPropagation()}
        role="menu"
        aria-label="카테고리 필터"
      >
        {filterOptions.map((category) => (
          <div key={category} className="flex items-center gap-1">
            <button
              type="button"
              role="menuitemradio"
              aria-checked={selectedCategory === category}
              onClick={() => {
                onSelect(category);
                onClose();
              }}
              className={`flex flex-1 items-center rounded-md px-3 py-2 text-left text-sm transition ${
                selectedCategory === category
                  ? "bg-blue-50 font-medium text-blue-700"
                  : "text-gray-700 hover:bg-gray-50"
              }`}
            >
              {category}
            </button>
            {category !== FILTER_ALL && !isBuiltinCategory(category) && (
              <button
                type="button"
                aria-label={`${category} 카테고리 삭제`}
                onClick={() => onRemoveCategory(category)}
                className="inline-flex h-8 w-8 shrink-0 items-center justify-center rounded text-gray-400 transition hover:bg-red-50 hover:text-red-600"
              >
                <span className="material-symbols-outlined text-[18px]" aria-hidden="true">
                  close
                </span>
              </button>
            )}
          </div>
        ))}

        <div className="mt-2 border-t border-gray-100 pt-2">
          <label className="mb-1 block px-1 text-xs font-medium text-gray-500">
            카테고리 추가
          </label>
          <div className="flex gap-1">
            <input
              type="text"
              value={newCategoryName}
              onChange={(event) => setNewCategoryName(event.target.value)}
              onKeyDown={(event) => {
                if (event.key === "Enter") {
                  event.preventDefault();
                  handleAddCategory();
                }
              }}
              placeholder="새 카테고리"
              aria-label="새 카테고리 이름"
              className="min-w-0 flex-1 rounded border border-gray-200 px-2 py-1.5 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
            />
            <button
              type="button"
              onClick={handleAddCategory}
              className="rounded bg-blue-600 px-2.5 py-1.5 text-xs font-medium text-white transition hover:bg-blue-700"
            >
              추가
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
