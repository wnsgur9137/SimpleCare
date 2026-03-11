---
title: "모듈 상세 정의"
aliases: ["모듈"]
tags:
  - 설계
  - 설계/모듈
  - MOC
created: 2026-01-26
updated: 2026-03-11
status: active
---

# SimpleCare 모듈 상세 문서

## 목차
1. [Feature 모듈](#feature-모듈)
2. [Infrastructure 모듈](#infrastructure-모듈)
3. [UseCase 정의](#usecase-정의)
4. [데이터 모델](#데이터-모델)

---

## Feature 모듈

> SimpleCare는 12개의 Feature 모듈로 구성됩니다.
> 기존 Dashboard 모듈은 Home 모듈로 통합되었습니다.

| 모듈 | 역할 |
|------|------|
| [Home](./modules/Home.md) | 메인 홈 화면 — 일일 요약, AI 인사이트, 빠른 기록, 주간 트렌드 |
| [Tab](./modules/Tab.md) | 메인 탭 네비게이션 관리 |
| [Calendar](./modules/Calendar.md) | 월별 캘린더 및 일별 기록 요약 |
| [Meal](./modules/Meal.md) | AI 기반 식단 기록 및 영양 분석 |
| [Exercise](./modules/Exercise.md) | MET 기반 운동 기록 및 칼로리 소모 계산 |
| [Weight](./modules/Weight.md) | 체중 기록 및 목표 관리 |
| [Profile](./modules/Profile.md) | 사용자 프로필 및 목표 설정 |
| [Onboarding](./modules/Onboarding.md) | 앱 첫 실행 시 사용자 프로필 초기 설정 |
| [Splash](./modules/Splash.md) | 앱 시작 시 스플래시 화면 |
| [Base](./modules/Base.md) | 공통 UI 컴포넌트, 프로토콜, 유틸리티 |
| [Settings](./modules/Settings.md) | 앱 설정 (모듈 골격 + 실제 UI는 Tab/Base에서 구현) |
| [Features](./modules/Features.md) | Feature 모듈 통합 우산 모듈 (Aggregator) |

## Infrastructure 모듈

| 모듈 | 역할 |
|------|------|
| [StorageInfra](./modules/StorageInfra.md) | SwiftData 기반 로컬 데이터 영속화 |
| [AIServiceInfra](./modules/AIServiceInfra.md) | OpenAI GPT-4o API 연동 |
| [NetworkInfra](./modules/NetworkInfra.md) | 네트워크 통신 추상화 (최소 골격 상태) |
| [HealthKitInfra](./modules/HealthKitInfra.md) | Apple HealthKit 연동 |

---

## UseCase 정의

### Home Feature

| UseCase | 입력 | 출력 | 설명 |
|---------|------|------|------|
| `GetDailySummaryUseCase` | `Date` | `HomeDailySummary` | 일일 요약 조회 |
| `GenerateDailyInsightUseCase` | `HomeDailySummary` | `String` | AI 건강 인사이트 생성 |
| `GetReportUseCase` | `Date`, 기간 | `HomeReport` | 주간/월간 리포트 조회 |

### Meal Feature

| UseCase | 입력 | 출력 | 설명 |
|---------|------|------|------|
| `EstimateMealNutritionUseCase` | `String` (텍스트) | 영양 추정 결과 | 텍스트로 영양 추정 |
| `RecordMealUseCase` | `MealRecord` | `Void` | 식사 기록 저장 |
| `GetMealHistoryUseCase` | `Date`, `Date` | `[MealRecord]` | 기간별 기록 조회 |
| `FetchMealUseCase` | `UUID` | `MealRecord` | 단일 식사 조회 |
| `UpdateMealUseCase` | `MealRecord` | `Void` | 식사 기록 수정 |
| `DeleteMealUseCase` | `UUID` | `Void` | 식사 기록 삭제 |
| `FavoriteFoodUseCases` | 다양 | 다양 | 즐겨찾기 음식 CRUD |

### Exercise Feature

| UseCase | 입력 | 출력 | 설명 |
|---------|------|------|------|
| `ExerciseUseCases` | 다양 | 다양 | 운동 기록 CRUD + MET 칼로리 계산 |
| `CustomExerciseUseCases` | 다양 | 다양 | 커스텀 운동 CRUD |

### Weight Feature

| UseCase | 입력 | 출력 | 설명 |
|---------|------|------|------|
| `WeightUseCases` | 다양 | 다양 | 체중 기록 CRUD + BMR/TDEE/추세 계산 |

### Profile Feature

| UseCase | 입력 | 출력 | 설명 |
|---------|------|------|------|
| `GetUserProfileUseCase` | `UUID` | `UserProfile` | 프로필 조회 |
| `SaveUserProfileUseCase` | `UserProfile` | `Void` | 프로필 저장 |
| `UpdateUserProfileUseCase` | `UserProfile` | `Void` | 프로필 업데이트 |

---

## 데이터 모델

### Domain Entity ↔ SwiftData Model 매핑

| Domain Entity | SwiftData Model | 변환 메서드 |
|--------------|-----------------|------------|
| `MealRecord` | `MealRecordModel` | `toModel()` / `toDomain()` |
| `FoodItem` | `FoodItemModel` | `toModel()` / `toDomain()` |
| `FavoriteFood` | `FavoriteFoodModel` | `toModel()` / `toDomain()` |
| `ExerciseRecord` | `ExerciseRecordModel` | `toModel()` / `toDomain()` |
| `CustomExercise` | `CustomExerciseModel` | `toModel()` / `toDomain()` |
| `WeightRecord` | `WeightRecordModel` | `toModel()` / `toDomain()` |
| `UserProfile` | `UserProfileModel` | `toModel()` / `toDomain()` |

**매핑 예시**:
```swift
// Domain Entity → SwiftData Model
extension MealRecord {
    func toModel() -> MealRecordModel {
        MealRecordModel(
            id: id,
            userProfileId: userProfileId,
            mealType: mealType.rawValue,
            foodItems: foodItems.map { $0.toModel() },
            recordedAt: recordedAt
        )
    }
}

// SwiftData Model → Domain Entity
extension MealRecordModel {
    func toDomain() -> MealRecord {
        MealRecord(
            id: id,
            userProfileId: userProfileId,
            mealType: MealType(rawValue: mealType) ?? .lunch,
            foodItems: foodItems.map { $0.toDomain() },
            recordedAt: recordedAt
        )
    }
}
```
