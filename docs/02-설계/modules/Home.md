---
title: "Home 모듈"
aliases: ["Home"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/feature
created: 2026-01-26
updated: 2026-03-11
status: active
---

# Home

**역할**: 메인 홈 화면 — 일일 요약, AI 인사이트, 빠른 기록, 주간 트렌드

| 레이어 | 파일 | 설명 |
|--------|------|------|
| **Domain** | | |
| Entity | `HomeDailySummary.swift` | 일일 요약 데이터 (칼로리/영양소/운동) |
| Entity | `HomeMealSummary.swift` | 식사 요약 데이터 |
| Entity | `HomeExerciseSummary.swift` | 운동 요약 데이터 |
| Entity | `HomeReport.swift` | 주간/월간 리포트 데이터 |
| UseCase | `GetDailySummaryUseCase.swift` | 하루 요약 조회 |
| UseCase | `GenerateDailyInsightUseCase.swift` | AI 건강 인사이트 생성 |
| UseCase | `GetReportUseCase.swift` | 주간/월간 리포트 조회 |
| **Data** | | |
| Repository | `HomeRepository.swift` | 홈 데이터 레포지토리 구현 |
| Service | `HomeInsightService.swift` | AI 인사이트 서비스 어댑터 |
| Service | `MockHomeInsightService.swift` | Mock 인사이트 서비스 |
| **Presentation** | | |
| Coordinator | `HomeCoordinator.swift` | 홈 화면 네비게이션 |
| Reducer | `HomeFeature.swift` | TCA Reducer (State/Action/Effect) |
| View | `HomeView.swift` | 메인 홈 화면 |
| View | `ReportView.swift` | 리포트 화면 |
| Component | `HomeTodayRecordsSection.swift` | 오늘의 기록 섹션 |
| Component | `HomeNutritionSection.swift` | 영양소 프로그레스 바 |
| Component | `HomeQuickActionButtons.swift` | 빠른 기록 버튼 (식사/운동/체중) |
| Component | `HomeStreakBadge.swift` | 연속 기록일 배지 |
| Component | `HomeWeeklyTrendView.swift` | 주간 트렌드 차트 |
| **Aggregator** | | |
| DIContainer | `HomeDIContainer.swift` | 의존성 조립 |

**화면 구성**:
- AI 건강 인사이트 (Gemini 기반)
- 일일 칼로리 섭취/소모 현황
- 탄수화물/단백질/지방 비율 프로그레스
- 오늘의 식사/운동 기록 목록
- 빠른 기록 버튼 (식사/운동/체중)
- 연속 기록일 스트릭 배지
- 주간 트렌드 차트

> **Note**: 기존 Dashboard 모듈의 기능이 Home으로 통합되었습니다.
