---
title: "Meal 모듈"
aliases: ["Meal"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/feature
created: 2026-01-26
updated: 2026-03-11
status: active
---

# Meal

**역할**: AI 기반 식단 기록 및 영양 분석

| 레이어 | 파일 | 설명 |
|--------|------|------|
| **Domain** | | |
| Entity | `MealRecord.swift` | 식사 기록 (MealType, FoodItem 포함) |
| Entity | `FavoriteFood.swift` | 즐겨찾기 음식 |
| UseCase | `EstimateMealNutritionUseCase.swift` | 텍스트 → 영양 추정 (AI) |
| UseCase | `RecordMealUseCase.swift` | 식사 기록 저장 |
| UseCase | `GetMealHistoryUseCase.swift` | 기간별 기록 조회 |
| UseCase | `FetchMealUseCase.swift` | 단일 식사 조회 |
| UseCase | `UpdateMealUseCase.swift` | 식사 기록 수정 |
| UseCase | `DeleteMealUseCase.swift` | 식사 기록 삭제 |
| UseCase | `FavoriteFoodUseCases.swift` | 즐겨찾기 CRUD |
| **Data** | | |
| Repository | `MealRepository.swift` | 식사 레포지토리 구현 |
| Repository | `FavoriteFoodDataRepository.swift` | 즐겨찾기 레포지토리 구현 |
| Service | `AIService.swift` | AI 영양 추정 서비스 어댑터 |
| Service | `MockAIService.swift` | Mock AI 서비스 |
| **Presentation** | | |
| Coordinator | `MealCoordinator.swift` | 식사 화면 네비게이션 |
| Reducer | `MealFeature.swift` | 식사 기록 TCA Reducer |
| Reducer | `MealListFeature.swift` | 식사 목록 TCA Reducer |
| Reducer | `MealDetailFeature.swift` | 식사 상세 TCA Reducer |
| View | `MealRecordView.swift` | 식사 기록 UI |
| View | `MealListView.swift` | 식사 목록 UI |
| View | `MealDetailView.swift` | 식사 상세 UI (영양소, 편집/삭제) |
| **Aggregator** | | |
| DIContainer | `MealDIContainer.swift` | 의존성 조립 |

**주요 플로우**:
```
사용자 텍스트 입력
       │
       ▼
  AI 영양 추정 (EstimateMealNutritionUseCase)
       │
       ▼
 추정 결과 확인/수정
       │
       ▼
    식사 기록 저장 (RecordMealUseCase)
```
