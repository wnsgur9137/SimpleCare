---
title: "테스트 전략 가이드"
aliases: ["테스트"]
tags:
  - 구현
  - 구현/테스트
created: 2026-03-11
updated: 2026-03-11
status: active
---

# SimpleCare 테스트 전략 가이드

## 목차
1. [테스트 전략 개요](#테스트-전략-개요)
2. [TCA TestStore 패턴](#tca-teststore-패턴)
3. [테스트 실행 방법](#테스트-실행-방법)
4. [테스트 커버리지 현황](#테스트-커버리지-현황)

---

## 테스트 전략 개요

SimpleCare는 Clean Architecture + TCA 기반으로 각 레이어별 테스트 전략을 적용합니다.

### 테스트 피라미드

```
        ┌─────────┐
        │  E2E    │  ← UI 테스트 (SwiftUI Preview + Simulator)
        ├─────────┤
        │ 통합    │  ← 모듈 간 연동 테스트
        ├─────────┤
        │ 단위    │  ← Reducer, UseCase, Repository
        └─────────┘
```

### 레이어별 테스트 전략

| 레이어 | 테스트 대상 | 테스트 방법 | Mock/Stub |
|--------|-----------|------------|-----------|
| **Presentation** | TCA Reducer | `TestStore` | Mock Client (DependencyKey) |
| **Domain** | UseCase | 단위 테스트 | Mock Repository |
| **Data** | Repository | 단위 테스트 | In-memory Storage |
| **Infrastructure** | Storage/Service | 통합 테스트 | In-memory ModelContainer |

### TCA 의존성 주입과 테스트

TCA의 `@Dependency` 시스템을 활용하여 테스트 시 모든 외부 의존성을 Mock으로 교체합니다.

```swift
// 프로덕션 코드
@Dependency(\.mealClient) var mealClient

// 테스트 코드
TestStore(...) {
    MealFeature()
} withDependencies: {
    $0.mealClient.recordMeal = { _ in }  // Mock
    $0.mealClient.estimateNutrition = { _ in .mock }
}
```

---

## TCA TestStore 패턴

### 기본 패턴: State → Action → State 검증

```swift
@Test
func testRecordMeal() async {
    // 1. TestStore 초기화
    let store = TestStore(
        initialState: MealFeature.State(userProfileId: UUID())
    ) {
        MealFeature()
    } withDependencies: {
        // 2. Mock 의존성 주입
        $0.mealClient.recordMeal = { _ in }
    }

    // 3. Action 전송 → State 변경 검증
    await store.send(.saveMeal) {
        $0.viewState = .loading
    }

    // 4. Effect 결과 수신 → State 변경 검증
    await store.receive(.saveMealResponse(.success(()))) {
        $0.viewState = .success
    }

    // 5. Delegate Action 수신
    await store.receive(.delegate(.saveCompleted))
}
```

### Effect 테스트 (비동기 작업)

```swift
@Test
func testEstimateNutrition() async {
    let expectedFoods: [EstimatedFoodItem] = [.mock]

    let store = TestStore(
        initialState: MealFeature.State(userProfileId: UUID())
    ) {
        MealFeature()
    } withDependencies: {
        $0.mealClient.estimateNutrition = { _ in expectedFoods }
    }

    await store.send(.estimateNutrition("김치찌개")) {
        $0.viewState = .loading
    }

    await store.receive(.estimateNutritionResponse(.success(expectedFoods))) {
        $0.viewState = .idle
        $0.estimatedFoods = expectedFoods
    }
}
```

### 에러 핸들링 테스트

```swift
@Test
func testEstimateNutritionFailure() async {
    let store = TestStore(
        initialState: MealFeature.State(userProfileId: UUID())
    ) {
        MealFeature()
    } withDependencies: {
        $0.mealClient.estimateNutrition = { _ in
            throw NSError(domain: "test", code: -1)
        }
    }

    await store.send(.estimateNutrition("test")) {
        $0.viewState = .loading
    }

    await store.receive(\.estimateNutritionResponse.failure) {
        $0.viewState = .error("추정에 실패했습니다")
    }
}
```

### Binding Action 테스트

```swift
@Test
func testBindingAction() async {
    let store = TestStore(
        initialState: MealFeature.State(userProfileId: UUID())
    ) {
        MealFeature()
    }

    await store.send(\.binding.mealType, .dinner) {
        $0.mealType = .dinner
    }
}
```

---

## 테스트 실행 방법

### Fastlane

```bash
# 전체 유닛 테스트 실행
fastlane ios test

# 컴파일 검증 (빌드만, 테스트 미실행)
fastlane ios build_test
```

### Xcode

```bash
# xcodebuild로 직접 테스트 실행
xcodebuild test \
    -workspace SimpleCare.xcworkspace \
    -scheme SimpleCare-DEV \
    -destination 'platform=iOS Simulator,name=iPhone 16'
```

### 테스트 파일 위치

```
Projects/
├── Application/
│   └── Tests/
│       └── Test.swift          # 앱 레벨 테스트
├── Feature/
│   └── {Feature}/
│       └── Tests/              # Feature별 테스트 (Tuist 자동 생성)
└── Infrastructure/
    └── {Infra}/
        └── Tests/              # Infrastructure 테스트
```

---

## 테스트 커버리지 현황

### 현재 상태

| 모듈 | 단위 테스트 | 통합 테스트 | 비고 |
|------|-----------|-----------|------|
| Meal | 기본 골격 | - | Reducer 테스트 패턴 정립 필요 |
| Exercise | 기본 골격 | - | |
| Weight | 기본 골격 | - | |
| Home | 기본 골격 | - | |
| Profile | 기본 골격 | - | |
| StorageInfra | - | - | In-memory 테스트 계획 |
| AIServiceInfra | - | - | Mock 서비스 활용 |

### 향후 테스트 계획

1. **Reducer 테스트 강화**: 모든 Feature의 핵심 Action/Effect 테스트
2. **UseCase 단위 테스트**: Mock Repository 기반
3. **Repository 테스트**: In-memory SwiftData 활용
4. **UI 스냅샷 테스트**: SwiftUI Preview 기반 검증
5. **E2E 테스트**: 핵심 사용자 플로우 (온보딩 → 기록 → 조회)

---

## 참고

### 관련 문서
- [ARCHITECTURE.md](../02-설계/ARCHITECTURE.md) - 아키텍처 설계
- [FASTLANE.md](./FASTLANE.md) - Fastlane 가이드

### 외부 참고
- [TCA Testing Guide](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/testing)
- [Swift Testing Framework](https://developer.apple.com/documentation/testing)
