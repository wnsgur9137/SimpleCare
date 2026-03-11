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

> SimpleCare는 12개의 Feature 모듈로 구성됩니다.
> 기존 Dashboard 모듈은 Home 모듈로 통합되었습니다.

### Home

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
- AI 건강 인사이트 (GPT-4o 기반)
- 일일 칼로리 섭취/소모 현황
- 탄수화물/단백질/지방 비율 프로그레스
- 오늘의 식사/운동 기록 목록
- 빠른 기록 버튼 (식사/운동/체중)
- 연속 기록일 스트릭 배지
- 주간 트렌드 차트

> **Note**: 기존 Dashboard 모듈의 기능이 Home으로 통합되었습니다.

---

### Tab

**역할**: 메인 탭 네비게이션 관리

| 레이어 | 파일 | 설명 |
|--------|------|------|
| Aggregator | `Tab.swift` | 모듈 진입점 |
| Coordinator | `TabCoordinator.swift` | 탭 네비게이션 및 자식 Coordinator 관리 |
| DIContainer | `TabDIContainer.swift` | 모든 Feature DIContainer 생성 |
| View | `MainTabView.swift` | 메인 탭 뷰 (5개 탭) |

**탭 구성**:
```swift
public enum AppTab: Hashable {
    case home       // 홈
    case meal       // 식단
    case exercise   // 운동
    case progress   // 체중
    case calendar   // 캘린더
}
```

**Sheet 화면**: Settings, Profile, MealDetail, ExerciseDetail

---

### Calendar

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

---

### Meal

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

---

### Exercise

**역할**: MET 기반 운동 기록 및 칼로리 소모 계산

| 레이어 | 파일 | 설명 |
|--------|------|------|
| **Domain** | | |
| Entity | `ExerciseRecord.swift` | 운동 기록 (운동 종류, 강도, 시간, 칼로리) |
| Entity | `CustomExercise.swift` | 사용자 정의 운동 |
| UseCase | `ExerciseUseCases.swift` | 운동 CRUD (기록/조회/수정/삭제) |
| UseCase | `CustomExerciseUseCases.swift` | 커스텀 운동 CRUD |
| **Data** | | |
| Repository | `ExerciseRepository.swift` | 운동 레포지토리 구현 |
| Repository | `CustomExerciseDataRepository.swift` | 커스텀 운동 레포지토리 구현 |
| **Presentation** | | |
| Coordinator | `ExerciseCoordinator.swift` | 운동 화면 네비게이션 |
| Reducer | `ExerciseFeature.swift` | 운동 기록 TCA Reducer |
| Reducer | `ExerciseListFeature.swift` | 운동 목록 TCA Reducer |
| Reducer | `ExerciseDetailFeature.swift` | 운동 상세 TCA Reducer |
| View | `ExerciseRecordView.swift` | 운동 기록 UI |
| View | `ExerciseListView.swift` | 운동 목록 UI |
| View | `ExerciseDetailView.swift` | 운동 상세 UI (편집/삭제) |
| **Aggregator** | | |
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

| 레이어 | 파일 | 설명 |
|--------|------|------|
| **Domain** | | |
| Entity | `WeightRecord.swift` | 체중 기록 |
| UseCase | `WeightUseCases.swift` | 체중 CRUD + BMR/TDEE/추세 계산 |
| **Data** | | |
| Repository | `WeightRepository.swift` | 체중 레포지토리 구현 |
| **Presentation** | | |
| Coordinator | `WeightCoordinator.swift` | 체중 화면 네비게이션 |
| Reducer | `WeightFeature.swift` | 체중 기록 TCA Reducer |
| View | `WeightView.swift` | 체중 기록/차트 UI |
| **Aggregator** | | |
| DIContainer | `WeightDIContainer.swift` | 의존성 조립 |

**BMR 계산 (Mifflin-St Jeor)**:
```
남성: BMR = 10×체중(kg) + 6.25×키(cm) - 5×나이 + 5
여성: BMR = 10×체중(kg) + 6.25×키(cm) - 5×나이 - 161
```

**TDEE 계산**:
```
TDEE = BMR × 활동계수
- 좌식: 1.2  |  가벼운 활동: 1.375  |  보통 활동: 1.55
- 활발한 활동: 1.725  |  매우 활발: 1.9
```

---

### Profile

**역할**: 사용자 프로필 및 목표 설정

| 레이어 | 파일 | 설명 |
|--------|------|------|
| **Domain** | | |
| Entity | `UserProfile.swift` | 사용자 프로필 (이름, 나이, 성별, 키, 체중, 활동수준, 목표) |
| UseCase | `GetUserProfileUseCase.swift` | 프로필 조회 |
| UseCase | `SaveUserProfileUseCase.swift` | 프로필 저장 |
| UseCase | `UpdateUserProfileUseCase.swift` | 프로필 업데이트 |
| **Data** | | |
| Repository | `ProfileRepository.swift` | 프로필 레포지토리 구현 |
| **Presentation** | | |
| Coordinator | `ProfileCoordinator.swift` | 프로필 화면 네비게이션 |
| Reducer | `ProfileFeature.swift` | 프로필 TCA Reducer |
| View | `ProfileView.swift` | 프로필 UI |
| **Aggregator** | | |
| DIContainer | `ProfileDIContainer.swift` | 의존성 조립 |

**프로필 정보**:
- 이름, 나이(10–120), 성별(남/여)
- 키, 현재 체중, 목표 체중
- 활동 수준 (좌식 ~ 매우 활발)
- 목표 유형 (감량/증량/유지) + 아이콘

**자동 계산 항목**:
- BMR (Mifflin-St Jeor), TDEE, 일일 권장 칼로리
- 일일 권장 단백질(체중 × 1.6g), 탄수화물(50%), 지방(25%)
- BMI + 카테고리 (저체중/정상/과체중/비만) + 색상 코딩
- 목표별 칼로리 조정 (감량: −500kcal, 증량: +300kcal)

**화면 구성**: 폼 기반 프로필 에디터, 실시간 계산 업데이트, 건강 면책 조항 표시

---

### Onboarding

**역할**: 앱 첫 실행 시 사용자 프로필 초기 설정

| 레이어 | 파일 | 설명 |
|--------|------|------|
| **Domain** | | |
| Entity | `OnboardingStep.swift` | 온보딩 단계 정의 |
| **Data** | | |
| - | `Source.swift` | 플레이스홀더 |
| **Presentation** | | |
| Coordinator | `OnboardingCoordinator.swift` | 온보딩 네비게이션 |
| Reducer | `OnboardingFeature.swift` | 온보딩 TCA Reducer |
| View | `OnboardingView.swift` | 메인 온보딩 뷰 |
| Component | `OnboardingComponents.swift` | 공통 온보딩 UI 컴포넌트 |
| Client | `SaveUserProfileClient.swift` | 프로필 저장 TCA Client |
| Step View | `WelcomeStepView.swift` | 1단계: 환영 화면 |
| Step View | `BasicInfoStepView.swift` | 2단계: 기본 정보 (이름, 성별, 생년월일) |
| Step View | `BodyInfoStepView.swift` | 3단계: 신체 정보 (키, 체중) |
| Step View | `ActivityLevelStepView.swift` | 4단계: 활동 수준 선택 |
| Step View | `GoalSettingStepView.swift` | 5단계: 목표 설정 (감량/증량/유지) |
| Step View | `SummaryStepView.swift` | 6단계: 설정 요약 및 완료 |
| **Aggregator** | | |
| DIContainer | `OnboardingDIContainer.swift` | 의존성 조립 |

**온보딩 단계**:
1. 환영 화면
2. 기본 정보 입력 (이름, 성별, 생년월일)
3. 신체 정보 입력 (키, 체중)
4. 활동 수준 선택
5. 목표 설정 (감량/증량/유지)
6. 설정 요약 및 완료

---

### Splash

**역할**: 앱 시작 시 스플래시 화면

| 레이어 | 파일 | 설명 |
|--------|------|------|
| Domain | `SplashDomain.swift` | 스플래시 도메인 정의 |
| Data | `SplashData.swift` | 스플래시 데이터 레이어 |
| Coordinator | `SplashCoordinator.swift` | 스플래시 네비게이션 |
| Reducer | `SplashFeature.swift` | 스플래시 TCA Reducer |
| View | `SplashView.swift` | 스플래시 UI |
| Aggregator | `Splash.swift` | 모듈 진입점 |
| DIContainer | `SplashDIContainer.swift` | 의존성 조립 |

**화면 구성**:
- 그라데이션 배경 (teal → purple)
- 로고 + 글래스 카드 효과 애니메이션
- "SimpleCare" 앱 이름 페이드인
- 태그라인 페이드인
- 최소 표시 시간 1.5초 후 자동 전환

**동작 방식**: 타이머 기반 → 완료 delegate → AppCoordinator로 화면 전환

---

### Base

**역할**: 공통 UI 컴포넌트, 프로토콜, 유틸리티

| 레이어 | 파일 | 설명 |
|--------|------|------|
| **Domain** | | |
| Extension | `String+Localization.swift` | 다국어 문자열 확장 |
| **Presentation** | | |
| Protocol | `Coordinator.swift` | Coordinator 프로토콜 |
| Protocol | `DIContainer.swift` | DIContainer 프로토콜 |
| **Debug** | | |
| View | `DebugFloatingButton.swift` | 디버그 플로팅 버튼 |
| Modifier | `DebugOverlayModifier.swift` | 디버그 오버레이 |
| View | `DebugSettingsView.swift` | 디버그 설정 화면 |
| **Extensions** | | |
| Extension | `Color+SimpleCare.swift` | 앱 커스텀 색상 |
| Extension | `View+DismissKeyboard.swift` | 키보드 닫기 |
| Extension | `View+GlassCard.swift` | 글래스모피즘 카드 스타일 |
| **Localization** | | |
| Manager | `LocalizationManager.swift` | 런타임 언어 변경 관리 |
| **Theme** | | |
| Manager | `ThemeManager.swift` | 테마 관리 (system/light/dark) |
| **Notification** | | |
| View | `NotificationEnableBanner.swift` | 알림 활성화 유도 배너 |
| Manager | `NotificationManager.swift` | 로컬 알림 스케줄링 관리 |
| **Data** | | |
| Manager | `DataExportManager.swift` | JSON/CSV 데이터 내보내기 |

**하위 시스템별 기능**:
- **ThemeManager**: system/light/dark 전환, UserDefaults 영속화, 실시간 `ColorScheme` 반영
- **LocalizationManager**: system/한국어/영어 런타임 전환, 모듈별 Bundle 관리, 재시작 불필요
- **NotificationManager**: 5개 카테고리별 알림 (아침/점심/저녁 식사, 운동, 체중), 시간 설정, `UNUserNotificationCenter` 연동
- **DataExportManager**: JSON/CSV 내보내기 (CSV injection 방지), 전체 데이터 삭제
- **Color+SimpleCare**: Primary(teal) / Secondary(blue) / Accent(purple), 영양소별 색상, BMI 색상 매핑
- **View+GlassCard**: 글래스모피즘 카드/버튼/캡슐 스타일
- **Debug**: 디바이스 정보, 캐시/UserDefaults 초기화, 강제 크래시 (DEBUG 전용)

---

### Settings

**역할**: 앱 설정 (모듈 골격 + 실제 UI는 Tab/Base 모듈에서 구현)

| 레이어 | 파일 | 설명 |
|--------|------|------|
| Domain | `Source.swift` | 플레이스홀더 |
| Data | `Source.swift` | 플레이스홀더 |
| Presentation | `Source.swift` | 플레이스홀더 |
| Aggregator | `Source.swift` | 플레이스홀더 |

> **Note**: Settings 모듈 자체는 골격 상태입니다.
> 설정 UI(`SettingsCoordinator`, `SettingsView`)는 Tab 모듈에, 실제 로직(ThemeManager, LocalizationManager, NotificationManager, DataExportManager)은 Base 모듈에 구현되어 있습니다.

**화면 구성** (Tab 모듈 `SettingsCoordinator` / Base 모듈 매니저):
- 테마 설정: system/light/dark 선택 (체크마크 표시)
- 언어 설정: system/한국어/English 선택 (체크마크 표시)
- 알림 설정: 권한 요청 버튼, 카테고리별 토글 + 시간 선택기
- 데이터 관리: 내보내기 형식 선택 시트 (JSON/CSV), 전체 삭제 + 확인 알림
- 앱 정보: 버전 표시, 건강 면책 조항

---

### Features (Aggregator)

**역할**: Feature 모듈 통합 — 개별 Feature를 하나의 타겟으로 묶는 우산 모듈

> Features 모듈은 별도의 소스 파일 없이 Tuist 의존성 그래프에서
> 모든 Feature 모듈을 통합하는 역할을 합니다.
> TabDIContainer, TabCoordinator 등은 현재 Tab 모듈에 위치합니다.

---

## Infrastructure 모듈

### StorageInfra

**역할**: SwiftData 기반 로컬 데이터 영속화

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Module | `StorageInfra.swift` | 모듈 진입점 |
| Container | `StorageContainer.swift` | ModelContainer 싱글톤 관리 |
| **Models** | | |
| Model | `UserProfileModel.swift` | 사용자 프로필 SwiftData 모델 |
| Model | `MealRecordModel.swift` | 식사 기록 SwiftData 모델 |
| Model | `FoodItemModel.swift` | 음식 항목 SwiftData 모델 |
| Model | `FavoriteFoodModel.swift` | 즐겨찾기 음식 SwiftData 모델 |
| Model | `WeightRecordModel.swift` | 체중 기록 SwiftData 모델 |
| Model | `ExerciseRecordModel.swift` | 운동 기록 SwiftData 모델 |
| Model | `CustomExerciseModel.swift` | 커스텀 운동 SwiftData 모델 |
| **Repositories** | | |
| Repository | `UserProfileStorage.swift` | 프로필 데이터 접근 |
| Repository | `MealRecordRepository.swift` | 식사 기록 데이터 접근 |
| Repository | `FavoriteFoodRepository.swift` | 즐겨찾기 데이터 접근 |
| Repository | `WeightRecordRepository.swift` | 체중 기록 데이터 접근 |
| Repository | `ExerciseRecordRepository.swift` | 운동 기록 데이터 접근 |
| Repository | `CustomExerciseRepository.swift` | 커스텀 운동 데이터 접근 |

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

**역할**: OpenAI GPT-4o API 연동

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Module | `AIServiceInfra.swift` | 모듈 진입점 |
| **OpenAI** | | |
| Client | `OpenAIClient.swift` | OpenAI REST API 클라이언트 |
| Config | `OpenAIConfiguration.swift` | API 키/모델 설정 |
| **Prompts** | | |
| Prompt | `NutritionPrompts.swift` | 영양 추정 시스템/유저 프롬프트 |
| **Services** | | |
| Service | `NutritionEstimationService.swift` | 텍스트 기반 영양 추정 서비스 |
| Service | `DailyInsightService.swift` | AI 일일 건강 인사이트 서비스 |

**API Key 관리**:
- `XCConfig/Debug.xcconfig`에 `OPENAI_API_KEY` 저장
- `Bundle.main.infoDictionary`에서 로드

---

### NetworkInfra

**역할**: 네트워크 통신 추상화 (최소 골격 상태)

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Module | `Source.swift` | 플레이스홀더 |

> **Note**: 현재 네트워크 통신은 AIServiceInfra에서 직접 처리합니다.
> Moya/Alamofire 래퍼는 향후 확장 시 구현 예정입니다.

---

### HealthKitInfra

**역할**: Apple HealthKit 연동

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Manager | `HealthKitManager.swift` | HealthKit 권한 요청 및 데이터 읽기/쓰기 |
| Type | `HealthKitDataType.swift` | HealthKit 데이터 타입 정의 (stepCount, activeEnergy, bodyMass) |
| **Models** | | |
| Model | `HealthKitWeightData.swift` | HealthKit 체중 데이터 |
| Model | `HealthKitStepData.swift` | HealthKit 걸음수 데이터 |
| Model | `HealthKitActivityData.swift` | HealthKit 활동 칼로리 데이터 |

**지원 데이터 타입**:
- `stepCount` — 일일 걸음수 (`HKQuantityType`)
- `activeEnergy` — 활동 칼로리 (kcal)
- `bodyMass` — 체중 (kg, 읽기+쓰기)

**주요 기능**:
- 권한 요청 (읽기: stepCount, activeEnergy, bodyMass / 쓰기: bodyMass만)
- 일일 걸음수/활동 칼로리 조회 (날짜 범위 기반)
- 체중 기록 조회 (기간별) + 최신 체중 조회
- 체중 저장 (HealthKit에 쓰기)
- 디바이스 HealthKit 지원 여부 확인

**에러 처리**: `notAvailable`, `authorizationDenied`, `queryFailed`

**연동**: HomeFeature(걸음수/활동 칼로리 표시), WeightFeature(체중 동기화)

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
