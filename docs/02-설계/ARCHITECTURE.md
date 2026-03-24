---
title: "아키텍처 설계"
aliases: ["아키텍처"]
tags:
  - 설계
  - 설계/아키텍처
created: 2026-01-26
updated: 2026-03-24
status: active
---

# SimpleCare 아키텍처 문서

## 목차
1. [개요](#개요)
2. [기술 스택](#기술-스택)
3. [프로젝트 구조](#프로젝트-구조)
4. [모듈 아키텍처](#모듈-아키텍처)
5. [Clean Architecture](#clean-architecture)
6. [의존성 흐름](#의존성-흐름)
7. [디자인 패턴](#디자인-패턴)

---

## 개요

SimpleCare는 식단, 운동, 체중 관리를 위한 AI 기반 헬스케어 iOS 앱입니다.

### 핵심 기능
- **AI 영양 분석**: 텍스트/사진 입력으로 음식 영양소 자동 추정
- **운동 기록**: MET 기반 칼로리 소모량 계산
- **체중 관리**: 목표 체중 설정 및 추세 분석
- **대시보드**: 일일 칼로리/영양소 요약 시각화

### 타겟
- iOS 18.0+
- Swift 6.0
- SwiftUI

---

## 기술 스택

| 분류 | 기술 | 설명 |
|-----|------|------|
| **빌드 시스템** | Tuist | 모듈화된 Xcode 프로젝트 생성 |
| **UI 프레임워크** | SwiftUI | 선언형 UI |
| **상태 관리** | TCA (The Composable Architecture) | 단방향 데이터 흐름, Reducer 기반 |
| **데이터 저장** | SwiftData | Apple 네이티브 ORM |
| **차트** | Swift Charts | 네이티브 차트 라이브러리 |
| **AI 서비스** | Google Gemini API (Free Tier) | 영양소 추정/이미지 분석 |
| **건강 데이터** | HealthKit | Apple Health 연동 |
| **네트워크** | Moya + Alamofire | 네트워크 추상화 |
| **비동기 처리** | Swift Concurrency | async/await |

---

## 프로젝트 구조

```
SimpleCare/
├── Projects/
│   ├── Application/              # 앱 진입점
│   │   ├── Sources/
│   │   │   ├── AppCoordinator.swift
│   │   │   └── SimpleCareApp.swift
│   │   ├── Widget/              # WidgetKit Extension
│   │   │   ├── Sources/
│   │   │   └── Resources/
│   │   └── Resources/
│   │
│   ├── Feature/                  # 기능 모듈
│   │   ├── Features/             # Feature 통합 모듈
│   │   ├── Base/                 # 공통 UI/유틸리티
│   │   ├── Splash/               # 스플래시
│   │   ├── Onboarding/           # 온보딩
│   │   ├── Home/                 # 홈 (대시보드 통합)
│   │   ├── Tab/                  # 메인 탭 네비게이션
│   │   ├── Meal/                 # 식단 기록
│   │   ├── Exercise/             # 운동 기록
│   │   ├── Weight/               # 체중 관리
│   │   ├── Calendar/             # 캘린더
│   │   ├── Profile/              # 프로필/목표 설정
│   │   └── Settings/             # 설정
│   │
│   ├── Infrastructure/           # 인프라 모듈
│   │   ├── StorageInfra/         # SwiftData 저장소
│   │   ├── AIServiceInfra/       # Google Gemini API
│   │   ├── NetworkInfra/         # 네트워크 계층
│   │   └── HealthKitInfra/       # HealthKit 연동
│   │
│   ├── LibraryManager/           # 외부 라이브러리 래퍼
│   │   ├── ReactiveLibraries/
│   │   ├── NetworkLibraries/
│   │   ├── LayoutLibraries/
│   │   └── UILibraries/
│   │
│   └── InjectionManager/         # 의존성 주입
│
├── Tuist/                        # Tuist 설정
│   ├── ProjectDescriptionHelpers/
│   │   ├── Dependencies/
│   │   └── Templates/
│   └── Package.swift
│
├── XCConfig/                     # 빌드 설정
│   ├── Debug.xcconfig
│   └── Release.xcconfig
│
└── docs/                         # 문서
```

---

## 모듈 아키텍처

### Feature 모듈 구조

각 Feature 모듈은 Clean Architecture + TCA를 따르며, 4개의 레이어로 구성됩니다.

```
Feature/{FeatureName}/
├── Sources/                      # Aggregator 타겟
│   └── {FeatureName}DIContainer.swift
├── Domain/
│   └── Sources/
│       ├── Entities/             # 도메인 엔티티
│       ├── UseCases/             # 비즈니스 로직
│       └── Repositories/         # 레포지토리 프로토콜
├── Data/
│   └── Sources/
│       └── Repositories/         # 레포지토리 구현체
└── Presentation/
    └── Sources/
        ├── Coordinator.swift     # 화면 네비게이션
        ├── {FeatureName}Feature.swift  # TCA Reducer (State, Action, Effect)
        └── View.swift            # SwiftUI 뷰
```

### 모듈별 역할

| 모듈 | 역할 | 주요 컴포넌트 |
|-----|------|-------------|
| **Home** | 메인 홈 화면 (대시보드 통합) | AI 인사이트, 일일 요약, 주간 트렌드 |
| **Widget Extension** | 홈 화면 위젯 | App Group UserDefaults를 통한 데이터 공유, WidgetKit Timeline |
| **Tab** | 메인 탭 네비게이션 | 5개 탭 관리, Sheet 표시 |
| **Meal** | 식단 기록 | AI 영양 추정, 즐겨찾기 |
| **Exercise** | 운동 기록 | MET 기반 칼로리 계산, 커스텀 운동 |
| **Weight** | 체중 관리 | 목표 설정, 추세 분석, BMR/TDEE |
| **Calendar** | 캘린더 | 월별 캘린더, 일별 기록 요약 |
| **Profile** | 사용자 프로필 | 기본 정보, 목표 설정 |
| **Onboarding** | 초기 설정 | 6단계 정보 입력 |
| **Base** | 공통 컴포넌트 | Coordinator/DIContainer 프로토콜, 테마, 알림, 내보내기 |

---

### 앱 흐름도

```
AppCoordinator (ObservableObject)
├── SplashCoordinator ─── 완료 시 해제
├── OnboardingCoordinator ─── 완료 시 해제 (프로필 미존재 시)
└── TabCoordinator ─── 메인 화면
    ├── HomeCoordinator ──── 홈 탭
    ├── MealCoordinator ──── 식단 탭 (리스트/기록/상세)
    ├── ExerciseCoordinator ── 운동 탭 (리스트/기록/상세)
    ├── WeightCoordinator ── 체중 탭
    ├── CalendarCoordinator ── 캘린더 탭
    ├── ProfileCoordinator ── Sheet
    └── SettingsCoordinator ── Sheet
```

**앱 시작 흐름**:
1. `SimpleCareApp` → `AppCoordinator` 생성
2. `SplashCoordinator` → 스플래시 표시 → 완료 시 해제
3. 프로필 존재 여부 확인
   - 없음 → `OnboardingCoordinator` → 6단계 프로필 설정 → 완료
   - 있음 → 바로 다음 단계
4. `TabCoordinator` → `MainTabView` 표시 (5개 탭)
5. `ensureProfileLoaded()` → 프로필 로드 완료 후 UI 표시

---

## Clean Architecture + TCA

### 레이어 책임

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │    View     │→ │   Reducer   │→ │ Coordinator │     │
│  │  (SwiftUI)  │  │ (TCA Store) │  │             │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
├─────────────────────────────────────────────────────────┤
│                      Domain                             │
│  ┌─────────────┐  ┌─────────────────────────────────┐  │
│  │   Entity    │  │  UseCase  ←  Repository (P)     │  │
│  └─────────────┘  └─────────────────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                       Data                              │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Repository (Impl)  ←  DataSource / Storage     │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 레이어별 설명

#### Domain Layer
- **Entity**: 비즈니스 도메인 모델
- **UseCase**: 단일 비즈니스 로직 캡슐화
- **Repository Protocol**: 데이터 접근 인터페이스

```swift
// Entity 예시
public struct MealRecord: Identifiable, Equatable {
    public let id: UUID
    public let userProfileId: UUID
    public let mealType: MealType
    public let foodItems: [FoodItem]
    public let recordedAt: Date
}

// UseCase 예시
public protocol RecordMealUseCaseProtocol {
    func execute(meal: MealRecord) async throws
}

// Repository Protocol 예시
public protocol MealRepositoryProtocol {
    func save(meal: MealRecord) async throws
    func fetchMeals(for date: Date) async throws -> [MealRecord]
}
```

#### Data Layer
- **Repository Implementation**: Domain 프로토콜 구현
- **Storage/DataSource**: 실제 데이터 접근

```swift
public final class MealRepository: MealRepositoryProtocol {
    private let storage: MealStorageProtocol

    public func save(meal: MealRecord) async throws {
        try await storage.save(meal: meal)
    }
}
```

#### Presentation Layer (TCA 기반)
- **View**: SwiftUI 뷰 (TCA Store 바인딩)
- **Reducer**: State, Action, Effect 정의
- **Coordinator**: 화면 네비게이션 및 Store 생성

```swift
// TCA Reducer 예시
@Reducer
public struct MealFeature {
    @ObservableState
    public struct State: Equatable {
        public var viewState: ViewState = .idle
        public var mealType: MealType = .lunch
        public var estimatedFoods: [EstimatedFoodItem] = []
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case saveMeal
        case saveMealResponse(Result<Void, Error>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case saveCompleted
        }
    }

    @Dependency(\.mealClient) var mealClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .saveMeal:
                state.viewState = .loading
                let meal = createMeal(from: state)
                return .run { send in
                    do {
                        try await mealClient.recordMeal(meal)
                        await send(.saveMealResponse(.success(())))
                    } catch {
                        await send(.saveMealResponse(.failure(error)))
                    }
                }
            case .saveMealResponse(.success):
                state.viewState = .success
                return .send(.delegate(.saveCompleted))
            // ...
            }
        }
    }
}

// TCA Dependency 예시
public struct MealClient {
    public var recordMeal: @Sendable (MealRecord) async throws -> Void
}

extension MealClient: DependencyKey {
    public static var liveValue: MealClient { /* ... */ }
}
```

---

## 의존성 흐름

### 모듈 의존성 그래프

```
Application
    │
    ├──▶ SimpleCareWidget ──▶ BaseDomain
    │
    ▼
Tab ──────────────────────────────────────┐
    │                                      │
    ├── Home ──────┬── HomeDomain          │
    │              ├── HomeData            │
    │              └── HomePresentation    │
    │                                      │
    ├── Meal ──────┬── MealDomain          │
    │              ├── MealData            │
    │              └── MealPresentation    │
    │                                      │
    ├── Exercise ──┬── ExerciseDomain      │
    │              ├── ExerciseData        │
    │              └── ExercisePresentation│
    │                                      │
    ├── Weight ────┬── WeightDomain        │
    │              ├── WeightData          │
    │              └── WeightPresentation  │
    │                                      │
    ├── Calendar ──┬── CalendarDomain      │
    │              ├── CalendarData        │
    │              └── CalendarPresentation│
    │                                      │
    └── Profile ───┬── ProfileDomain       │
                   ├── ProfileData         │
                   └── ProfilePresentation │
                             │
                             ▼
                   ┌─────────────────────┐
                   │   Infrastructure    │
                   ├─────────────────────┤
                   │  StorageInfra       │
                   │  AIServiceInfra     │
                   │  NetworkInfra       │
                   │  HealthKitInfra     │
                   └─────────────────────┘
                             │
                             ▼
                   ┌─────────────────────┐
                   │   LibraryManager    │
                   └─────────────────────┘
```

### 의존성 규칙

1. **상위 레이어는 하위 레이어에만 의존**
   - Presentation → Domain → Data

2. **Domain 레이어는 외부 의존성 없음**
   - 순수 Swift 코드만 사용
   - Infrastructure 직접 참조 금지

3. **Feature 모듈 간 순환 의존 금지**
   - 공통 기능은 Base 모듈에 배치

---

## 디자인 패턴

### TCA (The Composable Architecture) 패턴

단방향 데이터 흐름과 명시적인 상태 관리를 제공합니다.

```
┌─────────────────────────────────────────────────────────┐
│                      View                               │
│                        │                                │
│                   send(Action)                          │
│                        ▼                                │
│  ┌─────────────────────────────────────────────────┐   │
│  │                   Reducer                        │   │
│  │  ┌───────┐    ┌────────┐    ┌────────────┐     │   │
│  │  │ State │ ←  │ Action │ →  │   Effect   │     │   │
│  │  └───────┘    └────────┘    └────────────┘     │   │
│  │       │                           │             │   │
│  │       └───────────────────────────┘             │   │
│  └─────────────────────────────────────────────────┘   │
│                        │                                │
│                  State 변경                              │
│                        ▼                                │
│                   View 업데이트                          │
└─────────────────────────────────────────────────────────┘
```

### Coordinator 패턴 (TCA Store 생성)

화면 전환 로직과 TCA Store 생성을 담당합니다.

```swift
public protocol Coordinator: AnyObject {
    associatedtype Content: View
    @MainActor @ViewBuilder func start() -> Content
}

public protocol MealCoordinatorDependency {
    var userProfileId: UUID { get }
    var mealClient: MealClient { get }
}

public final class MealCoordinator: ObservableObject, Coordinator {
    private let dependencies: MealCoordinatorDependency

    @MainActor @ViewBuilder
    public func start() -> some View {
        MealContainerView(
            userProfileId: dependencies.userProfileId,
            mealClient: dependencies.mealClient
        )
    }
}

// Container View에서 TCA Store 생성
private struct MealContainerView: View {
    @State private var store: StoreOf<MealFeature>

    init(userProfileId: UUID, mealClient: MealClient) {
        self._store = State(
            initialValue: Store(
                initialState: MealFeature.State(userProfileId: userProfileId)
            ) {
                MealFeature()
            } withDependencies: {
                $0.mealClient = mealClient
            }
        )
    }

    var body: some View {
        MealRecordView(store: store)
    }
}
```

### DIContainer 패턴 (TCA Client 제공)

UseCase를 TCA Client로 래핑하여 의존성 주입을 담당합니다.

```swift
public final class MealDIContainer: DIContainer, MealCoordinatorDependency {
    public var userProfileId: UUID { dependencies.userProfileId }

    // TCA Client 생성
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

    private func makeRecordMealUseCase() -> RecordMealUseCaseProtocol {
        RecordMealUseCase(repository: makeMealRepository())
    }
}
```

### Repository 패턴

데이터 접근 로직을 추상화합니다.

```swift
// Domain Layer - Protocol
public protocol MealRepositoryProtocol {
    func save(meal: MealRecord) async throws
    func fetchMeals(for date: Date) async throws -> [MealRecord]
}

// Data Layer - Implementation
public final class MealRepository: MealRepositoryProtocol {
    private let storage: MealStorageProtocol

    public init(storage: MealStorageProtocol) {
        self.storage = storage
    }

    public func save(meal: MealRecord) async throws {
        let model = MealRecordModel(from: meal)
        try await storage.insert(model)
    }
}
```

---

## 테스트 전략

### 단위 테스트
- **Reducer 테스트**: TCA TestStore를 활용한 상태/액션 검증
- **UseCase 테스트**: Mock Repository 주입
- **Repository 테스트**: In-memory Storage 사용

```swift
// TCA Reducer 테스트 예시
@Test
func testSaveMeal() async {
    let store = TestStore(initialState: MealFeature.State(userProfileId: UUID())) {
        MealFeature()
    } withDependencies: {
        $0.mealClient.recordMeal = { _ in }
    }

    await store.send(.saveMeal) {
        $0.viewState = .loading
    }
    await store.receive(.saveMealResponse(.success(()))) {
        $0.viewState = .success
    }
    await store.receive(.delegate(.saveCompleted))
}
```

### 통합 테스트
- Feature 모듈 빌드 검증
- API 연동 테스트

### UI 테스트
- SwiftUI Preview
- Simulator 테스트

---

## 참고 자료

- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
- [TCA Documentation](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/)
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Tuist Documentation](https://docs.tuist.io)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
