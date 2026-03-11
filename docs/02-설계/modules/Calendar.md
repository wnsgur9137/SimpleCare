---
title: "Calendar 모듈"
aliases: ["Calendar"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/feature
created: 2026-01-26
updated: 2026-03-11
status: active
---

# Calendar

**역할**: 월별 캘린더 및 일별 기록 요약

| 레이어 | 파일 | 설명 |
|--------|------|------|
| Domain | `CalendarDomain.swift` | 캘린더 도메인 정의 |
| Data | `CalendarData.swift` | 캘린더 데이터 레이어 |
| Coordinator | `CalendarCoordinator.swift` | 캘린더 네비게이션 |
| View | `CalendarContentView.swift` | 캘린더 뷰 |

**화면 구성**:
- 월별 캘린더 그리드 (이전/다음 월 네비게이션)
- 선택 날짜 하이라이트 (파란 원), 오늘 날짜 표시 (파란 테두리)
- 미래 날짜 비활성화
- 선택 날짜의 식사/운동 기록 목록 (칼로리 표시)
- 기록 탭 시 상세 화면 이동 (MealDetail / ExerciseDetail)
- 빈 상태 / 에러 상태 / 로딩 표시

**의존성**: HomeClient를 통해 일일 요약 데이터(`HomeDailySummary`) 조회
