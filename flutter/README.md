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

# 브라우저에서 http://localhost:8080 접속 (권장)
flutter run -d web-server --web-hostname=localhost --web-port=8080

# Chrome 자동 실행 (디버깅용)
flutter run -d chrome --web-port=8080
```

UI가 갱신되지 않으면 `flutter clean` 후 위 명령을 다시 실행하고, 브라우저에서 **Cmd+Shift+R**로 강력 새로고침하세요.

## 현재 구현

- `AcrossToolMainScreen` — 카테고리 탭 + 전체 너비 달력
- `CategoryTabBar` — 다이어리 스타일 탭, `+`로 카테고리 추가
- `JournalCalendar` — `table_calendar` 6주 그리드, 화면 하단까지 채움
- `TimelinePanel` — 날짜 선택 시 바텀시트 일정 UI
- `TaskRepository` — Hive 기반 일정 CRUD
- `PreferencesRepository` — 카테고리 탭·선택 탭 영속화
- `JournalDataService` — 웹↔Flutter 공유 JSON import/export

## 마이그레이션 참고

- [docs/flutter-migration.md](../docs/flutter-migration.md)
- [docs/schemas/journal-data.schema.json](../docs/schemas/journal-data.schema.json)
