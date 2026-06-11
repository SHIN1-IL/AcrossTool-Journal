# AcrossTool Journal

날짜 단위로 일과(루틴·할 일)를 기록하고 확인하는 저널 앱입니다.

## 프로젝트 구조

```
AcrossTool Journal/
├── docs/
│   ├── PRD.md                         # 제품 요구사항
│   ├── flutter-migration.md           # Flutter 마이그레이션 분석
│   └── schemas/journal-data.schema.json
├── flutter/                           # Flutter 목표 앱 (스켈레톤)
└── ui/timeline-panel/                 # 웹 MVP (현재 기능 완성본)
```

## 웹 MVP 실행

```bash
cd ui/timeline-panel
npm install
npm run dev      # http://localhost:5173
npm test         # 36 tests
npm run lint
npm run build
```

## Flutter 앱 실행

Flutter SDK 3.5+ 필요. 자세한 내용은 [`flutter/README.md`](flutter/README.md) 및 [`docs/flutter-migration.md`](docs/flutter-migration.md) 참고.

```bash
cd flutter
flutter pub get
flutter run
flutter test
```

## 현재 구현 상태 (요약)

| 영역 | 상태 |
|------|------|
| 웹 MVP | 달력, 5줄 타임라인, 카테고리 필터, 완료율 마커, IndexedDB |
| CI | GitHub Actions — lint / test / build |
| Flutter | `AcrossToolMainScreen` 스켈레톤 (반응형 600px 분기) |

## 핵심 화면 동작 (웹 MVP)

- **PC/태블릿 (≥600px):** 좌측 60% 달력 + 우측 40% 타임라인
- **모바일 (<600px):** 달력 전체 화면, 날짜 터치 시 300px Bottom Sheet
- **카테고리:** 사용자 정의 추가/삭제, 필터 상태 IndexedDB 영속화
- **완료율 마커:** 0%/low/medium/high 티어, ARIA 라벨
