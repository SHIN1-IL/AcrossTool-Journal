# Flutter 마이그레이션 준비 문서

웹 MVP(`ui/timeline-panel`)에서 PRD 목표인 Flutter `AcrossToolMainScreen`으로 전환하기 위한 분석 및 준비 가이드입니다.

## 1. 현재 상태

| 항목 | 웹 MVP (`main`) | Flutter (`flutter/`) |
|------|-----------------|----------------------|
| 메인 화면 | `App.tsx` | `AcrossToolMainScreen` (스켈레톤) |
| 반응형 분기 | `matchMedia(600px)` | `LayoutBuilder` (600px) |
| 일과 저장 | IndexedDB (`idb-keyval`) | 미구현 (Hive 권장) |
| 카테고리 | 사용자 정의 + 기본 4종 | 미구현 |
| 완료율 마커 | `completionRate.ts` | 미구현 |
| CI | GitHub Actions (npm) | 미포함 (SDK 필요) |

## 2. 기능 매핑표

| 웹 (React) | Flutter (목표) | PRD 참조 |
|------------|----------------|----------|
| `App.tsx` | `lib/screens/acrosstool_main_screen.dart` | §3.1 |
| `Calendar.tsx` | `lib/widgets/journal_calendar.dart` | §3.2 |
| `TimelinePanel.tsx` | `lib/widgets/timeline_panel.dart` | §3.3 |
| `MobileBottomSheet.tsx` | `showModalBottomSheet` | §3.2.2 |
| `CategoryFilterMenu.tsx` | `PopupMenuButton` / `showModalBottomSheet` | §3.4 |
| `CategorySelect.tsx` | `DropdownButton` | §3.4 |
| `CompletionMarker.tsx` | `Calendar` 셀 하위 `Container` (원형) | §6.2-6 |
| `useTaskStore` | `TaskRepository` + `ChangeNotifier`/`Riverpod` | §3.3 |
| `useCategories` | `PreferencesRepository` | §3.4 |
| `taskStorage.ts` | `Hive` box `taskStore` | §6.2-1 |
| `preferencesStorage.ts` | `Hive` box `preferences` | §3.4 |
| `completionRate.ts` | `lib/models/completion_rate.dart` | §6.2-6 |

## 3. 데이터 모델 이전

### 3.1 공유 스키마

단일 JSON 스키마로 웹·Flutter 간 계약을 정의합니다.

- **파일:** [`docs/schemas/journal-data.schema.json`](./schemas/journal-data.schema.json)
- **버전:** `version: 1`

```json
{
  "version": 1,
  "taskStore": {
    "2026-06-11": [
      { "id": 1, "label": "아침 스트레칭", "completed": true, "category": "운동" }
    ]
  },
  "userCategories": ["취미"],
  "selectedFilter": "전체"
}
```

### 3.2 저장소 매핑

| 웹 (IndexedDB key) | Flutter (Hive box/key) | 내용 |
|--------------------|------------------------|------|
| `acrosstool-journal-tasks` | `taskStore` box → `data` | `Record<dateKey, TaskSlot[]>` |
| `acrosstool-journal-user-categories` | `preferences` box → `userCategories` | `List<String>` |
| `acrosstool-journal-selected-filter` | `preferences` box → `selectedFilter` | `String` |

### 3.3 마이그레이션 전략

1. **웹 → Flutter:** JSON export/import UI (추후) 또는 동일 스키마로 수동 복사
2. **Flutter 내부:** `version` 필드 기반 `MigrationService` — 스키마 변경 시 box 마이그레이션
3. **레거시:** 웹 `localStorage` → IndexedDB 마이그레이션 로직은 이미 구현됨 (`taskStorage.ts`)

## 4. 권장 Flutter 패키지

| 용도 | 패키지 | 비고 |
|------|--------|------|
| 로컬 DB | `hive` + `hive_flutter` | IndexedDB 대체, 경량 |
| 달력 | `table_calendar` | 월별 그리드 + 마커 커스터마이즈 |
| 상태 관리 | `flutter_riverpod` | `useTaskStore`/`useCategories` 대체 |
| 국제화 | `intl` | 날짜 포맷 (한국어) |
| 테스트 | `flutter_test` | 위젯·단위 테스트 |

## 5. 권장 프로젝트 구조

```
flutter/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   └── acrosstool_main_screen.dart   # PRD 진입점
│   ├── widgets/
│   │   ├── journal_calendar.dart
│   │   ├── timeline_panel.dart
│   │   ├── completion_marker.dart
│   │   └── category_filter_menu.dart
│   ├── models/
│   │   ├── task_slot.dart
│   │   ├── journal_preferences.dart
│   │   └── completion_rate.dart
│   ├── repositories/
│   │   ├── task_repository.dart
│   │   └── preferences_repository.dart
│   └── services/
│       └── migration_service.dart
├── test/
│   └── widget_test.dart
└── pubspec.yaml
```

## 6. 구현 우선순위 (Flutter)

1. `AcrossToolMainScreen` 반응형 레이아웃 (600px) — **스켈레톤 완료**
2. Hive 기반 `TaskRepository` + 5슬롯 CRUD
3. `table_calendar` + 날짜 선택 연동
4. `TimelinePanel` 체크박스·텍스트 편집
5. 모바일 `showModalBottomSheet`
6. 카테고리 필터 + 사용자 정의 카테고리
7. 완료율 마커 (0/zero, low, medium, high 티어)
8. 웹↔Flutter 데이터 import/export

## 7. 환경 요구사항

```bash
# Flutter SDK 설치 후
cd flutter
flutter pub get
flutter run          # iOS/Android/Desktop
flutter test
flutter analyze
```

> 현재 CI 워크플로는 `ui/timeline-panel`만 대상입니다. Flutter CI 추가 시 별도 job(`flutter analyze`, `flutter test`)이 필요하며, runner에 Flutter SDK 설치 단계가 포함되어야 합니다.

## 8. 리스크 및 완화

| 리스크 | 완화 |
|--------|------|
| IndexedDB ↔ Hive 직접 호환 불가 | 공유 JSON 스키마 + export/import |
| Flutter SDK 미설치 환경 | 웹 MVP로 기능 검증 유지, Flutter는 병행 개발 |
| UI 패리티 | PRD 와이어프레임·웹 구현을 시각적 기준으로 삼음 |
