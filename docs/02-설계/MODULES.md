---
title: "모듈 상세 정의"
aliases: ["모듈"]
tags:
  - 설계
  - 설계/모듈
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

### Dashboard

**역할**: 일일 영양/운동 요약 대시보드

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Entity | `DailySummary.swift` | 일일 요약 데이터 |
| UseCase | `GetDailySummaryUseCase.swift` | 하루 요약 조회 |
| UseCase | `GenerateDailyInsightUseCase.swift` | AI 코멘트 생성 |
| UseCase | `CalculateRemainingNutritionUseCase.swift` | 남은 영양소 계산 |
| ViewModel | `DashboardViewModel.swift` | 대시보드 상태 관리 |
| View | `DashboardView.swift` | 대시보드 UI |
| Coordinator | `DashboardCoordinator.swift` | 화면 네비게이션 |
| DIContainer | `DashboardDIContainer.swift` | 의존성 조립 |

**화면 구성**:
- 일일 칼로리 섭취/소모 현황
- 탄수화물/단백질/지방 비율 차트
- AI 한줄 코멘트
- 최근 식사/운동 기록 요약

---

### Meal

**역할**: 식단 기록 및 AI 영양 분석

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Entity | `MealRecord.swift` | 식사 기록 |
| Entity | `FoodItem.swift` | 음식 항목 |
| Entity | `EstimatedFoodItem.swift` | AI 추정 음식 |
| Entity | `MealType.swift` | 식사 유형 (아침/점심/저녁/간식) |
| UseCase | `EstimateMealNutritionUseCase.swift` | 텍스트 → 영양 추정 |
| UseCase | `AnalyzeMealImageUseCase.swift` | 이미지 → 음식 분석 |
| UseCase | `RecordMealUseCase.swift` | 식사 기록 저장 |
| UseCase | `GetMealHistoryUseCase.swift` | 기록 조회 |
| Repository | `MealRepositoryProtocol.swift` | 레포지토리 인터페이스 |
| Repository | `MealRepository.swift` | 레포지토리 구현 |
| ViewModel | `MealRecordViewModel.swift` | 식사 기록 상태 관리 |
| View | `MealRecordView.swift` | 식사 기록 UI |
| Coordinator | `MealCoordinator.swift` | 화면 네비게이션 |
| DIContainer | `MealDIContainer.swift` | 의존성 조립 |

**주요 플로우**:
```
사용자 입력 (텍스트/사진)
         │
         ▼
    AI 영양 추정
         │
         ▼
   추정 결과 확인/수정
         │
         ▼
      식사 기록 저장
```

---

### Exercise

**역할**: 운동 기록 및 칼로리 소모 계산

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Entity | `ExerciseRecord.swift` | 운동 기록 |
| Entity | `ExerciseType.swift` | 운동 종류 |
| Entity | `ExerciseCategory.swift` | 운동 카테고리 |
| Entity | `ExerciseIntensity.swift` | 운동 강도 |
| UseCase | `RecordExerciseUseCase.swift` | 운동 기록 저장 |
| UseCase | `EstimateCalorieBurnUseCase.swift` | MET 기반 칼로리 계산 |
| Repository | `ExerciseRepositoryProtocol.swift` | 레포지토리 인터페이스 |
| Repository | `ExerciseRepository.swift` | 레포지토리 구현 |
| ViewModel | `ExerciseRecordViewModel.swift` | 운동 기록 상태 관리 |
| View | `ExerciseRecordView.swift` | 운동 기록 UI |
| Coordinator | `ExerciseCoordinator.swift` | 화면 네비게이션 |
| DIContainer | `ExerciseDIContainer.swift` | 의존성 조립 |

**MET (Metabolic Equivalent of Task) 계산**:
```
소모 칼로리 = MET × 체중(kg) × 시간(h)
```

| 운동 | 강도 | MET |
|-----|------|-----|
| 걷기 | 보통 | 3.5 |
| 달리기 | 보통 | 8.0 |
| 자전거 | 보통 | 7.0 |
| 수영 | 보통 | 6.0 |
| 근력운동 | 보통 | 5.0 |

---

### Weight

**역할**: 체중 기록 및 목표 관리

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Entity | `WeightRecord.swift` | 체중 기록 |
| Entity | `WeightGoal.swift` | 목표 체중 |
| UseCase | `RecordWeightUseCase.swift` | 체중 기록 저장 |
| UseCase | `CalculateWeightTrendUseCase.swift` | 추세 계산 |
| UseCase | `CalculateBMRUseCase.swift` | 기초대사량 계산 |
| UseCase | `CalculateTDEEUseCase.swift` | 일일 소비 칼로리 |
| UseCase | `GetWeightHistoryUseCase.swift` | 기록 조회 |
| Repository | `WeightRepositoryProtocol.swift` | 레포지토리 인터페이스 |
| Repository | `WeightRepository.swift` | 레포지토리 구현 |
| ViewModel | `WeightRecordViewModel.swift` | 체중 기록 상태 관리 |
| View | `WeightRecordView.swift` | 체중 기록 UI |
| Coordinator | `WeightCoordinator.swift` | 화면 네비게이션 |
| DIContainer | `WeightDIContainer.swift` | 의존성 조립 |

**BMR 계산 (Mifflin-St Jeor)**:
```
남성: BMR = 10×체중(kg) + 6.25×키(cm) - 5×나이 + 5
여성: BMR = 10×체중(kg) + 6.25×키(cm) - 5×나이 - 161
```

**TDEE 계산**:
```
TDEE = BMR × 활동계수
- 좌식: 1.2
- 가벼운 활동: 1.375
- 보통 활동: 1.55
- 활발한 활동: 1.725
- 매우 활발: 1.9
```

---

### Profile

**역할**: 사용자 프로필 및 목표 설정

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Entity | `UserProfile.swift` | 사용자 프로필 |
| Entity | `Gender.swift` | 성별 |
| Entity | `ActivityLevel.swift` | 활동 수준 |
| Entity | `GoalType.swift` | 목표 유형 |
| UseCase | `SaveUserProfileUseCase.swift` | 프로필 저장 |
| UseCase | `GetUserProfileUseCase.swift` | 프로필 조회 |
| UseCase | `UpdateGoalUseCase.swift` | 목표 업데이트 |
| Repository | `UserProfileRepositoryProtocol.swift` | 레포지토리 인터페이스 |
| Repository | `UserProfileRepository.swift` | 레포지토리 구현 |
| ViewModel | `ProfileViewModel.swift` | 프로필 상태 관리 |
| View | `ProfileView.swift` | 프로필 UI |
| Coordinator | `ProfileCoordinator.swift` | 화면 네비게이션 |
| DIContainer | `ProfileDIContainer.swift` | 의존성 조립 |

**프로필 정보**:
- 이름, 나이, 성별
- 키, 체중
- 활동 수준
- 목표 (감량/증량/유지)
- 목표 체중

---

### Onboarding

**역할**: 앱 첫 실행 시 초기 설정

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| ViewModel | `OnboardingViewModel.swift` | 온보딩 상태 관리 |
| View | `OnboardingView.swift` | 온보딩 UI |
| Coordinator | `OnboardingCoordinator.swift` | 화면 네비게이션 |
| DIContainer | `OnboardingDIContainer.swift` | 의존성 조립 |

**온보딩 단계**:
1. 환영 화면
2. 기본 정보 입력 (이름, 성별, 생년월일)
3. 신체 정보 입력 (키, 체중)
4. 활동 수준 선택
5. 목표 설정 (감량/증량/유지)
6. 완료

---

### Base

**역할**: 공통 컴포넌트 및 유틸리티

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Protocol | `Coordinator.swift` | Coordinator 프로토콜 |
| Protocol | `DIContainer.swift` | DIContainer 프로토콜 |
| View | `LoadingView.swift` | 로딩 인디케이터 |
| View | `ErrorView.swift` | 에러 표시 |

---

### Features (Aggregator)

**역할**: Feature 모듈 통합 및 탭 관리

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Enum | `Tab.swift` | 앱 탭 정의 |
| View | `MainTabView.swift` | 메인 탭 뷰 |
| View | `TabCoordinatorView.swift` | 탭 코디네이터 뷰 |
| Coordinator | `TabCoordinator.swift` | 탭 네비게이션 |
| DIContainer | `TabDIContainer.swift` | 탭 의존성 조립 |

**탭 구성**:
```swift
public enum AppTab: Hashable {
    case dashboard      // 대시보드
    case meal           // 식단
    case exercise       // 운동
    case progress       // 진행 현황 (체중)
    case settings       // 설정
}
```

---

## Infrastructure 모듈

### StorageInfra

**역할**: SwiftData 기반 로컬 데이터 저장

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Container | `StorageContainer.swift` | ModelContainer 싱글톤 |
| Model | `MealRecordModel.swift` | 식사 기록 모델 |
| Model | `FoodItemModel.swift` | 음식 항목 모델 |
| Model | `ExerciseRecordModel.swift` | 운동 기록 모델 |
| Model | `WeightRecordModel.swift` | 체중 기록 모델 |
| Model | `UserProfileModel.swift` | 사용자 프로필 모델 |
| Storage | `MealStorage.swift` | 식사 데이터 접근 |
| Storage | `ExerciseStorage.swift` | 운동 데이터 접근 |
| Storage | `WeightStorage.swift` | 체중 데이터 접근 |
| Storage | `UserProfileStorage.swift` | 프로필 데이터 접근 |

**SwiftData 모델 예시**:
```swift
@Model
public final class MealRecordModel {
    @Attribute(.unique) public var id: UUID
    public var userProfileId: UUID
    public var mealType: String
    @Relationship(deleteRule: .cascade) public var foodItems: [FoodItemModel]
    public var notes: String?
    public var recordedAt: Date
    public var totalCalories: Int
    public var totalProtein: Double
    public var totalCarbs: Double
    public var totalFat: Double
}
```

---

### AIServiceInfra

**역할**: OpenAI API 연동

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Client | `OpenAIClient.swift` | API 클라이언트 |
| Service | `NutritionEstimationService.swift` | 영양 추정 서비스 |
| Service | `ImageAnalysisService.swift` | 이미지 분석 서비스 |
| Prompt | `NutritionEstimationPrompt.swift` | 영양 추정 프롬프트 |
| Prompt | `ImageAnalysisPrompt.swift` | 이미지 분석 프롬프트 |
| DTO | `NutritionEstimationResponse.swift` | 응답 DTO |
| Config | `OpenAIConfiguration.swift` | API 설정 |

**API Key 관리**:
- `XCConfig/Debug.xcconfig`에 `OPENAI_API_KEY` 저장
- `Bundle.main.infoDictionary`에서 로드

---

### NetworkInfra

**역할**: 네트워크 통신 추상화

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Client | `NetworkClient.swift` | Moya 기반 클라이언트 |
| Plugin | `LoggingPlugin.swift` | 로깅 플러그인 |
| Error | `NetworkError.swift` | 네트워크 에러 |

---

## UseCase 정의

### Meal Feature

| UseCase | 입력 | 출력 | 설명 |
|---------|------|------|------|
| `EstimateMealNutritionUseCase` | `String` (텍스트) | `MealEstimationResult` | 텍스트로 영양 추정 |
| `AnalyzeMealImageUseCase` | `Data` (이미지) | `MealEstimationResult` | 이미지로 음식 분석 |
| `RecordMealUseCase` | `MealRecord` | `Void` | 식사 기록 저장 |
| `GetMealHistoryUseCase` | `Date`, `Date` | `[MealRecord]` | 기간별 기록 조회 |
| `GetDailyMealsUseCase` | `Date` | `[MealRecord]` | 일별 기록 조회 |

### Exercise Feature

| UseCase | 입력 | 출력 | 설명 |
|---------|------|------|------|
| `RecordExerciseUseCase` | `ExerciseRecord` | `Void` | 운동 기록 저장 |
| `EstimateCalorieBurnUseCase` | 운동정보, 체중 | `Int` | 칼로리 소모 계산 |
| `GetExerciseHistoryUseCase` | `Date`, `Date` | `[ExerciseRecord]` | 기간별 기록 조회 |

### Weight Feature

| UseCase | 입력 | 출력 | 설명 |
|---------|------|------|------|
| `RecordWeightUseCase` | `WeightRecord` | `Void` | 체중 기록 저장 |
| `GetWeightHistoryUseCase` | `Date`, `Date` | `[WeightRecord]` | 기간별 기록 조회 |
| `CalculateWeightTrendUseCase` | `[WeightRecord]` | `WeightTrend` | 추세 계산 |
| `CalculateBMRUseCase` | 프로필 정보 | `Double` | 기초대사량 계산 |
| `CalculateTDEEUseCase` | BMR, 활동수준 | `Double` | 일일 소비량 계산 |

### Dashboard Feature

| UseCase | 입력 | 출력 | 설명 |
|---------|------|------|------|
| `GetDailySummaryUseCase` | `Date` | `DailySummary` | 일일 요약 조회 |
| `GenerateDailyInsightUseCase` | `DailySummary` | `String` | AI 코멘트 생성 |
| `CalculateRemainingNutritionUseCase` | 요약, 목표 | `RemainingNutrition` | 남은 영양소 계산 |

---

## 데이터 모델

### Domain Entity ↔ SwiftData Model 매핑

| Domain Entity | SwiftData Model | 변환 메서드 |
|--------------|-----------------|------------|
| `MealRecord` | `MealRecordModel` | `toModel()` / `toDomain()` |
| `FoodItem` | `FoodItemModel` | `toModel()` / `toDomain()` |
| `ExerciseRecord` | `ExerciseRecordModel` | `toModel()` / `toDomain()` |
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
