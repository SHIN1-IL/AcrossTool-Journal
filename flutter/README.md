# AcrossTool Journal (Flutter)

PRD 목표 플랫폼용 Flutter 앱 스켈레톤입니다. 웹 MVP(`ui/timeline-panel`) 기능을 단계적으로 이전합니다.

## 사전 요구사항

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.5+

## 실행

```bash
cd flutter
flutter pub get
flutter run
flutter test
flutter analyze
```

## 현재 구현

- `AcrossToolMainScreen` — 600px `LayoutBuilder` 반응형 분기
- PC: 60/40 2분할 (달력 placeholder + 타임라인 placeholder)
- 모바일: 달력 placeholder + `showModalBottomSheet` (height 300, radius 20)

## 마이그레이션 참고

- [docs/flutter-migration.md](../docs/flutter-migration.md)
- [docs/schemas/journal-data.schema.json](../docs/schemas/journal-data.schema.json)
