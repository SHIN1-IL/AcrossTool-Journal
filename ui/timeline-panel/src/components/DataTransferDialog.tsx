import { useRef, useState } from "react";
import {
  downloadJournalData,
  parseJournalData,
  type JournalData,
} from "../models/journalData";

type DataTransferDialogProps = {
  exportData: JournalData;
  onImport: (data: JournalData) => void;
  onClose: () => void;
};

export function DataTransferDialog({
  exportData,
  onImport,
  onClose,
}: DataTransferDialogProps) {
  const [importText, setImportText] = useState("");
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleImport = () => {
    const parsed = parseJournalData(importText);
    if (!parsed) {
      setError("유효하지 않은 JSON 형식입니다. 스키마 version 1을 확인하세요.");
      return;
    }

    onImport(parsed);
    onClose();
  };

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) {
      return;
    }

    void file.text().then((text) => {
      setImportText(text);
      setError(null);
    });
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/30 p-4"
      onClick={onClose}
      role="presentation"
    >
      <div
        className="w-full max-w-lg rounded-xl border border-gray-200 bg-white p-5 shadow-xl"
        onClick={(event) => event.stopPropagation()}
        role="dialog"
        aria-label="데이터 가져오기 및보내기"
      >
        <h2 className="text-lg font-semibold text-gray-900">
          데이터 가져오기 /보내기
        </h2>
        <p className="mt-1 text-sm text-gray-600">
          웹 MVP와 Flutter 앱 간 JSON 백업 파일을 공유할 수 있습니다.
        </p>

        <div className="mt-4 flex flex-wrap gap-2">
          <button
            type="button"
            onClick={() => downloadJournalData(exportData)}
            className="rounded-lg bg-blue-600 px-3 py-2 text-sm font-medium text-white transition hover:bg-blue-700"
          >
            JSON보내기
          </button>
          <button
            type="button"
            onClick={() => fileInputRef.current?.click()}
            className="rounded-lg border border-gray-200 px-3 py-2 text-sm font-medium text-gray-700 transition hover:bg-gray-50"
          >
            파일 선택
          </button>
          <input
            ref={fileInputRef}
            type="file"
            accept=".json,application/json"
            className="hidden"
            onChange={handleFileChange}
          />
        </div>

        <label className="mt-4 block text-sm font-medium text-gray-700">
          JSON 붙여넣기
        </label>
        <textarea
          value={importText}
          onChange={(event) => {
            setImportText(event.target.value);
            setError(null);
          }}
          rows={8}
          placeholder='{"version":1,"taskStore":{...},"userCategories":[],"selectedFilter":"전체"}'
          className="mt-1 w-full rounded-lg border border-gray-200 px-3 py-2 font-mono text-xs text-gray-800 focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
        />

        {error && (
          <p className="mt-2 text-sm text-red-600" role="alert">
            {error}
          </p>
        )}

        <div className="mt-4 flex justify-end gap-2">
          <button
            type="button"
            onClick={onClose}
            className="rounded-lg px-3 py-2 text-sm font-medium text-gray-600 transition hover:bg-gray-100"
          >
            취소
          </button>
          <button
            type="button"
            onClick={handleImport}
            className="rounded-lg bg-blue-600 px-3 py-2 text-sm font-medium text-white transition hover:bg-blue-700"
          >
            가져오기
          </button>
        </div>
      </div>
    </div>
  );
}
