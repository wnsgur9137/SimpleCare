---
title: "데이터 흐름"
aliases: ["데이터플로우"]
tags:
  - 구현
  - 구현/데이터
created: 2026-03-11
updated: 2026-03-16
status: active
---

# SimpleCare 데이터 흐름 문서

## 목차
1. [전체 데이터 흐름](#전체-데이터-흐름)
2. [모듈별 데이터 흐름](#모듈별-데이터-흐름)
3. [SwiftData ↔ Domain 매핑](#swiftdata--domain-매핑)
4. [외부 서비스 연동](#외부-서비스-연동)

---

## 전체 데이터 흐름

SimpleCare는 Clean Architecture + TCA 패턴에 기반한 단방향 데이터 흐름을 따릅니다.

```
SwiftUI View
    │ send(Action)
    ▼
TCA Reducer (State/Action/Effect)
    │ UseCase 호출
    ▼
Domain UseCase
    │ Repository 프로토콜
    ▼
Feature Data Repository
    │ Storage/Service 호출
    ▼
Infrastructure Layer
    ├── StorageInfra (SwiftData) ── 로컬 영속화
    ├── AIServiceInfra (Gemini) ── AI 분석
    └── HealthKitInfra ── 건강 데이터
    │
    ▼
결과 반환 (역방향)
    Storage → Repository → UseCase → Effect → State 변경 → View 업데이트
```

### TCA 데이터 흐름 상세

```
┌─────────────────────────────────────────────────────┐
│ View                                                 │
│   │ store.send(.action)                              │
│   ▼                                                  │
│ Reducer                                              │
│   ├── State 즉시 변경 (동기)                          │
│   └── Effect 반환 (비동기)                            │
│       │                                              │
│       ▼                                              │
│   TCA Client (DependencyKey)                         │
│       │                                              │
│       ▼                                              │
│   UseCase.execute()                                  │
│       │                                              │
│       ▼                                              │
│   Repository (Domain Protocol → Data Impl)           │
│       │                                              │
│       ▼                                              │
│   StorageInfra / AIServiceInfra / HealthKitInfra     │
│       │                                              │
│       ▼                                              │
│   결과 → Effect → Action → Reducer → State → View    │
└─────────────────────────────────────────────────────┘
```

### DIContainer → TCA Client 변환

```
DIContainer
    │ UseCase 생성
    ▼
UseCase (Domain Layer)
    │ 클로저로 래핑
    ▼
TCA Client (DependencyKey)
    │ withDependencies 주입
    ▼
TCA Store (Reducer에서 @Dependency로 접근)
```

**예시 (MealDIContainer)**:
```swift
public var mealClient: MealClient {
    let estimateUseCase = makeEstimateNutritionUseCase()
    let recordUseCase = makeRecordMealUseCase()
    return MealClient(
        estimateNutrition: { text in
            try await estimateUseCase.execute(text: text)
        },
        recordMeal: { meal in
            try await recordUseCase.execute(meal: meal)
        }
    )
}
```

---

## 모듈별 데이터 흐름

### Meal: 식사 기록 흐름

```
사용자 텍스트 입력 ("김치찌개, 밥 한 공기")
    │
    ▼
MealFeature.Action.estimateNutrition(text)
    │
    ▼
MealClient.estimateNutrition(text)
    │
    ▼
EstimateMealNutritionUseCase.execute(text:)
    │
    ▼
AIService → NutritionEstimationService → GeminiClient
    │ (Gemini API 호출)
    ▼
영양 추정 결과 반환 → State.estimatedFoods 업데이트
    │
    ▼
사용자 확인/수정 → MealFeature.Action.saveMeal
    │
    ▼
RecordMealUseCase.execute(meal:)
    │
    ▼
MealRepository → MealRecordRepository (StorageInfra)
    │ (SwiftData 저장)
    ▼
저장 완료 → delegate(.saveCompleted)
```

### Home: 일일 요약 흐름

```
HomeView 표시 (onAppear)
    │
    ▼
HomeFeature.Action.getDailySummary
    │
    ▼
GetDailySummaryUseCase.execute(date:)
    │
    ├── MealRecordRepository.fetchMeals(for: date)
    ├── ExerciseRecordRepository.fetchExercises(for: date)
    └── WeightRecordRepository.fetchWeight(for: date)
    │
    ▼
HomeDailySummary 조합
    │
    ▼
HomeFeature.Action.generateInsight(summary)
    │
    ▼
GenerateDailyInsightUseCase.execute(summary:)
    │
    ▼
HomeInsightService → DailyInsightService (AIServiceInfra)
    │ (Gemini API 호출)
    ▼
AI 인사이트 텍스트 → State.insight 업데이트
```

### Weight: 체중 기록 흐름

```
WeightView 체중 입력
    │
    ▼
WeightFeature.Action.recordWeight(value)
    │
    ▼
WeightUseCases.recordWeight(record:)
    │
    ▼
WeightRepository → WeightRecordRepository (StorageInfra)
    │ (SwiftData 저장)
    ▼
기록 완료 → 차트 데이터 갱신 요청
    │
    ▼
WeightUseCases.getWeightHistory(from:to:)
    │
    ▼
[WeightRecord] 반환 → State.weightHistory 업데이트 → 차트 렌더링
```

### Exercise: 운동 기록 흐름

```
ExerciseRecordView 운동 선택 및 입력
    │
    ▼
ExerciseFeature.Action.recordExercise
    │ (MET × 체중 × 시간 = 칼로리 계산)
    ▼
ExerciseUseCases.recordExercise(record:)
    │
    ▼
ExerciseRepository → ExerciseRecordRepository (StorageInfra)
    │ (SwiftData 저장)
    ▼
기록 완료 → delegate(.saveCompleted)
```

---

## SwiftData ↔ Domain 매핑

### 모델 매핑 테이블

| Domain Entity | SwiftData Model | 비고 |
|--------------|-----------------|------|
| `MealRecord` | `MealRecordModel` | `@Relationship` FoodItems |
| `FoodItem` | `FoodItemModel` | MealRecord에 cascade 관계 |
| `FavoriteFood` | `FavoriteFoodModel` | 독립 엔티티 |
| `ExerciseRecord` | `ExerciseRecordModel` | MET 기반 칼로리 포함 |
| `CustomExercise` | `CustomExerciseModel` | 사용자 정의 운동 |
| `WeightRecord` | `WeightRecordModel` | 날짜별 기록 |
| `UserProfile` | `UserProfileModel` | 앱 전역 사용자 정보 |

### 변환 방향

```
Domain Entity ──toModel()──▶ SwiftData Model ──(저장)──▶ SwiftData Store
SwiftData Store ──(조회)──▶ SwiftData Model ──toDomain()──▶ Domain Entity
```

### StorageContainer 구성

```swift
StorageContainer (싱글톤)
    │
    ├── ModelContainer
    │   ├── UserProfileModel
    │   ├── MealRecordModel
    │   ├── FoodItemModel
    │   ├── FavoriteFoodModel
    │   ├── WeightRecordModel
    │   ├── ExerciseRecordModel
    │   └── CustomExerciseModel
    │
    └── Repository Layer
        ├── UserProfileStorage
        ├── MealRecordRepository
        ├── FavoriteFoodRepository
        ├── WeightRecordRepository
        ├── ExerciseRecordRepository
        └── CustomExerciseRepository
```

---

## 외부 서비스 연동

### Google Gemini API 흐름

```
Feature Layer (Meal/Home)
    │
    ▼
Data Layer Service Adapter
    ├── AIService (Meal)
    └── HomeInsightService (Home)
    │
    ▼
AIServiceInfra
    ├── NutritionEstimationService ── 영양 추정
    └── DailyInsightService ── 일일 인사이트
    │
    ▼
GeminiClient
    │ (REST API: POST /v1beta/models/{model}:generateContent)
    │ (Model: gemini-2.5-flash / gemini-2.5-flash-lite)
    │ (System Prompt: NutritionPrompts)
    ▼
JSON 응답 파싱 → Domain Entity 변환
```

**API Key 흐름**:
```
XCConfig/DEV.xcconfig (GEMINI_API_KEY=...)
    → Info.plist (Build Setting 참조)
    → Bundle.main.infoDictionary
    → GeminiConfiguration
    → GeminiClient
```

### HealthKit 연동 흐름

```
HomeFeature / WeightFeature
    │
    ▼
HealthKitManager (HealthKitInfra)
    │
    ├── requestAuthorization() ── 권한 요청
    │   ├── HKQuantityType.stepCount
    │   ├── HKQuantityType.activeEnergyBurned
    │   └── HKQuantityType.bodyMass
    │
    ├── fetchStepCount(for: Date) → HealthKitStepData
    ├── fetchActiveEnergy(for: Date) → HealthKitActivityData
    └── fetchWeight() → HealthKitWeightData
    │
    ▼
HKHealthStore (Apple HealthKit Framework)
```

---

## 참고

### 관련 문서
- [ARCHITECTURE.md](../02-설계/ARCHITECTURE.md) - 아키텍처 설계
- [MODULES.md](../02-설계/MODULES.md) - 모듈 상세 정의
- [API.md](./API.md) - AI API 연동 명세
