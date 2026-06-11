# AcrossTool Journal

날짜 단위로 일과(루틴·할 일)를 기록하고 확인하는 저널 앱입니다.

## PRD 기준 MVP

이 저장소의 첫 번째 이터레이션은 `docs/PRD.md`의 권장 구현 순서 1~3단계에 집중합니다.

- 하루 5줄 일과 데이터 모델 + `localStorage` 영속화
- 달력 날짜 선택 ↔ 타임라인 패널 연동
- 600px 브레이크포인트 반응형 레이아웃 (PC 2분할 / 모바일 Bottom Sheet)

## 기술 스택 (MVP)

| 영역 | 선택 | 비고 |
|------|------|------|
| 프론트엔드 | React 19 + TypeScript + Vite | PRD 최종 목표는 Flutter 멀티플랫폼 |
| 스타일 | Tailwind CSS 4 | 반응형 레이아웃 |
| 데이터 | 브라우저 `localStorage` | 서버/DB 없음 (PRD TBD) |
| 테스트 | Vitest + Testing Library | 단위/컴포넌트 테스트 |
| 린트/포맷 | ESLint 9 + Prettier | 일관된 코드 스타일 |

> **아키텍처 노트:** PRD는 Flutter(`AcrossToolMainScreen`)를 최종 플랫폼으로 명시합니다. 현재 환경에서 Flutter SDK가 없어, 동일 UX 요구사항을 웹 MVP로 먼저 구현했습니다. 추후 `lib/` Flutter 앱으로 이전하거나 병행할 수 있습니다.

## 프로젝트 구조

```
AcrossTool Journal/
├── docs/PRD.md              # 제품 요구사항 문서
└── ui/timeline-panel/       # 웹 MVP 앱
    ├── src/
    │   ├── App.tsx          # 메인 화면 (반응형 분기)
    │   ├── components/      # Calendar, TimelinePanel, BottomSheet 등
    │   ├── hooks/           # useTaskStore
    │   └── models/          # taskStore (데이터 + localStorage)
    └── package.json
```

## 실행 방법

```bash
cd ui/timeline-panel
npm install
npm run dev      # 개발 서버 (http://localhost:5173)
npm run build    # 프로덕션 빌드
npm test         # 테스트 실행
npm run lint     # ESLint 검사
npm run format   # Prettier 포맷 적용
```

## 핵심 화면 동작

- **PC/태블릿 (≥600px):** 좌측 60% 달력 + 우측 40% 5줄 타임라인
- **모바일 (<600px):** 달력 전체 화면, 날짜 터치 시 300px Bottom Sheet
- **카테고리 필터:** AppBar 필터 버튼 → 카테고리 선택 (세션 내 유지)
- **데이터 저장:** 체크/텍스트 변경 시 `localStorage`에 자동 저장
