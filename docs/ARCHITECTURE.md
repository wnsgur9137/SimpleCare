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
| **데이터 저장** | SwiftData | Apple 네이티브 ORM |
| **차트** | Swift Charts | 네이티브 차트 라이브러리 |
| **AI 서비스** | OpenAI API (GPT-4o) | 영양소 추정/이미지 분석 |
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
│   │   └── Resources/
│   │
│   ├── Feature/                  # 기능 모듈
│   │   ├── Features/             # Feature 통합 모듈
│   │   ├── Base/                 # 공통 UI/유틸리티
│   │   ├── Dashboard/            # 대시보드
│   │   ├── Meal/                 # 식단 기록
│   │   ├── Exercise/             # 운동 기록
│   │   ├── Weight/               # 체중 관리
│   │   ├── Profile/              # 프로필/목표 설정
│   │   ├── Onboarding/           # 온보딩
│   │   ├── Settings/             # 설정
│   │   ├── Splash/               # 스플래시
│   │   └── Home/                 # 홈 (미사용)
│   │
│   ├── Infrastructure/           # 인프라 모듈
│   │   ├── StorageInfra/         # SwiftData 저장소
│   │   ├── AIServiceInfra/       # OpenAI API
│   │   └── NetworkInfra/         # 네트워크 계층
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

각 Feature 모듈은 Clean Architecture를 따르며, 4개의 레이어로 구성됩니다.

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
        ├── ViewModel.swift       # 프레젠테이션 로직
        └── View.swift            # SwiftUI 뷰
```

### 모듈별 역할

| 모듈 | 역할 | 주요 컴포넌트 |
|-----|------|-------------|
| **Dashboard** | 일일 요약 대시보드 | 칼로리/영양소 시각화, AI 코멘트 |
| **Meal** | 식단 기록 | AI 영양 추정, 이미지 분석 |
| **Exercise** | 운동 기록 | MET 기반 칼로리 계산 |
| **Weight** | 체중 관리 | 목표 설정, 추세 분석 |
| **Profile** | 사용자 프로필 | 기본 정보, 목표 설정 |
| **Onboarding** | 초기 설정 | 단계별 정보 입력 |
| **Base** | 공통 컴포넌트 | Coordinator 프로토콜, 공통 UI |

---

## Clean Architecture

### 레이어 책임

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │    View     │→ │  ViewModel  │→ │ Coordinator │     │
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

#### Presentation Layer
- **View**: SwiftUI 뷰 (UI만 담당)
- **ViewModel**: @Published 상태 관리, UseCase 호출
- **Coordinator**: 화면 네비게이션

```swift
@MainActor
public final class MealRecordViewModel: ObservableObject {
    @Published public private(set) var state: ViewState = .idle

    private let recordMealUseCase: RecordMealUseCaseProtocol

    public func saveMeal() async {
        state = .loading
        do {
            try await recordMealUseCase.execute(meal: meal)
            state = .success
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
```

---

## 의존성 흐름

### 모듈 의존성 그래프

```
Application
    │
    ▼
Features ─────────────────────────────────┐
    │                                      │
    ├── Dashboard ──┬── DashboardDomain    │
    │               ├── DashboardData      │
    │               └── DashboardPresentation
    │                                      │
    ├── Meal ───────┬── MealDomain         │
    │               ├── MealData           │
    │               └── MealPresentation   │
    │                                      │
    ├── Exercise ───┬── ExerciseDomain     │
    │               ├── ExerciseData       │
    │               └── ExercisePresentation
    │                                      │
    ├── Weight ─────┬── WeightDomain       │
    │               ├── WeightData         │
    │               └── WeightPresentation │
    │                                      │
    └── Profile ────┬── ProfileDomain      │
                    ├── ProfileData        │
                    └── ProfilePresentation
                              │
                              ▼
                    ┌─────────────────────┐
                    │   Infrastructure    │
                    ├─────────────────────┤
                    │  StorageInfra       │
                    │  AIServiceInfra     │
                    │  NetworkInfra       │
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

### Coordinator 패턴

화면 전환 로직을 View에서 분리하여 관리합니다.

```swift
public protocol Coordinator: AnyObject {
    associatedtype Content: View
    @MainActor @ViewBuilder func start() -> Content
}

public protocol CoordinatorDependency {
    @MainActor func makeViewModel() -> SomeViewModel
}

public final class MealCoordinator: ObservableObject, Coordinator {
    private let dependencies: MealCoordinatorDependency

    public init(dependencies: MealCoordinatorDependency) {
        self.dependencies = dependencies
    }

    @MainActor @ViewBuilder
    public func start() -> some View {
        MealRecordView(viewModel: dependencies.makeMealRecordViewModel())
    }
}
```

### DIContainer 패턴

의존성 조립 및 주입을 담당합니다.

```swift
public final class MealDIContainer: DIContainer, MealCoordinatorDependency {
    private let storageContainer: StorageContainer
    private let aiService: AIServiceProtocol

    @MainActor
    public func makeMealRecordViewModel() -> MealRecordViewModel {
        MealRecordViewModel(
            estimateNutritionUseCase: makeEstimateNutritionUseCase(),
            analyzeMealImageUseCase: makeAnalyzeMealImageUseCase(),
            recordMealUseCase: makeRecordMealUseCase()
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
- UseCase 테스트: Mock Repository 주입
- ViewModel 테스트: Mock UseCase 주입
- Repository 테스트: In-memory Storage 사용

### 통합 테스트
- Feature 모듈 빌드 검증
- API 연동 테스트

### UI 테스트
- SwiftUI Preview
- Simulator 테스트

---

## 참고 자료

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Tuist Documentation](https://docs.tuist.io)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
