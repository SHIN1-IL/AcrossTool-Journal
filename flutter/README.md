# AcrossTool Journal (Flutter)

PRD 목표 플랫폼용 Flutter 앱 스켈레톤입니다. 웹 MVP(`ui/timeline-panel`) 기능을 단계적으로 이전합니다.

## 사전 요구사항

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.5+
- **권장 실행 환경:** Chrome (`flutter doctor`에서 Chrome ✓)
- iOS/Android 네이티브 실행은 Xcode·Android Studio 추가 설치 필요

## 실행

```bash
cd flutter
flutter pub get
flutter test
flutter analyze

# Chrome에서 스켈레톤 확인 (가장 간단)
flutter run -d chrome

# 연결된 기기 목록 확인
flutter devices
```

## 현재 구현

- `AcrossToolMainScreen` — 600px `LayoutBuilder` 반응형 분기
- PC: 60/40 2분할 (`JournalCalendar` + 타임라인 패널)
- 모바일: `JournalCalendar` + `showModalBottomSheet` (height 300, radius 20)
- `JournalCalendar` — `table_calendar` 기반 월별 달력, 날짜 선택 → `TaskRepository` 연동
- `TaskRepository` — Hive 기반 5슬롯 CRUD (체크·라벨 편집, 날짜별 저장)

## 마이그레이션 참고

- [docs/flutter-migration.md](../docs/flutter-migration.md)
- [docs/schemas/journal-data.schema.json](../docs/schemas/journal-data.schema.json)
