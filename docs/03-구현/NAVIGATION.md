---
title: "화면 전환 흐름"
aliases: ["네비게이션"]
tags:
  - 구현
  - 구현/네비게이션
created: 2026-03-11
updated: 2026-03-11
status: active
---

# SimpleCare 화면 전환 흐름 문서

## 목차
1. [Coordinator 계층 구조](#coordinator-계층-구조)
2. [앱 시작 흐름](#앱-시작-흐름)
3. [탭 구조](#탭-구조)
4. [Feature 내부 네비게이션](#feature-내부-네비게이션)
5. [Coordinator 패턴 설명](#coordinator-패턴-설명)

---

## Coordinator 계층 구조

```
AppCoordinator (ObservableObject)
│
├── SplashCoordinator
│   └── SplashView → 완료 시 해제
│
├── OnboardingCoordinator
│   └── OnboardingView (6 Steps) → 완료 시 해제
│
└── TabCoordinator (ObservableObject)
    │
    ├── [Tab: Home] HomeCoordinator
    │   ├── HomeView (메인)
    │   └── ReportView (주간/월간 리포트)
    │
    ├── [Tab: Meal] MealCoordinator
    │   ├── MealListView (목록)
    │   ├── MealRecordView (기록) ── Sheet
    │   └── MealDetailView (상세) ── Sheet
    │
    ├── [Tab: Exercise] ExerciseCoordinator
    │   ├── ExerciseListView (목록)
    │   ├── ExerciseRecordView (기록) ── Sheet
    │   └── ExerciseDetailView (상세) ── Sheet
    │
    ├── [Tab: Weight] WeightCoordinator
    │   └── WeightView (기록/차트)
    │
    ├── [Tab: Calendar] CalendarCoordinator
    │   └── CalendarContentView (캘린더)
    │
    ├── [Sheet] ProfileCoordinator
    │   └── ProfileView
    │
    └── [Sheet] SettingsCoordinator
        └── SettingsView (테마/알림/데이터/언어)
```

---

## 앱 시작 흐름

```
SimpleCareApp (@main)
    │
    ▼
AppCoordinator 생성 (AppDIContainer 주입)
    │
    ▼
┌─── isSplashCompleted == false ───┐
│                                   │
│  SplashCoordinator.start()        │
│  └── SplashView 표시              │
│      └── 완료 → completeSplash()  │
│          └── splashCoordinator = nil
│                                   │
└───────────────────────────────────┘
    │
    ▼
┌─── isOnboardingCompleted == false ───┐
│                                       │
│  OnboardingCoordinator.start()        │
│  └── OnboardingView 표시              │
│      ├── Step 1: 환영                 │
│      ├── Step 2: 기본 정보            │
│      ├── Step 3: 신체 정보            │
│      ├── Step 4: 활동 수준            │
│      ├── Step 5: 목표 설정            │
│      └── Step 6: 요약 → 완료          │
│          └── completeOnboarding()     │
│              └── UserDefaults 저장    │
│                                       │
└───────────────────────────────────────┘
    │
    ▼
TabCoordinator.start()
    │
    ▼
MainTabView 표시
    │ .task { ensureProfileLoaded() }
    ▼
프로필 로드 완료 → isReady = true → 탭 UI 표시
```

---

## 탭 구조

### 메인 탭 (5개)

| 탭 | AppTab | 아이콘 | Coordinator | 화면 |
|----|--------|--------|-------------|------|
| 홈 | `.home` | house.fill | HomeCoordinator | HomeView |
| 식단 | `.meal` | fork.knife | MealCoordinator | MealListView |
| 운동 | `.exercise` | figure.run | ExerciseCoordinator | ExerciseListView |
| 체중 | `.progress` | chart.line.uptrend.xyaxis | WeightCoordinator | WeightView |
| 캘린더 | `.calendar` | calendar | CalendarCoordinator | CalendarContentView |

### Sheet 화면

| 트리거 | 화면 | 설명 |
|--------|------|------|
| 홈 → 설정 아이콘 | SettingsCoordinator | 앱 설정 |
| 홈 → 프로필 아이콘 | ProfileCoordinator | 사용자 프로필 |
| 식단 탭 → 기록 추가 | MealRecordView | 식사 기록 Sheet |
| 홈/캘린더 → 식사 기록 탭 | MealDetailView | 식사 상세 Sheet |
| 운동 탭 → 기록 추가 | ExerciseRecordView | 운동 기록 Sheet |
| 홈/캘린더 → 운동 기록 탭 | ExerciseDetailView | 운동 상세 Sheet |

---

## Feature 내부 네비게이션

### Home

```
HomeView
├── 빠른 기록 버튼
│   ├── 식사 → selectedTab = .meal
│   ├── 운동 → selectedTab = .exercise
│   └── 체중 → selectedTab = .progress
├── 오늘의 기록 탭
│   ├── 식사 기록 → showingMealDetail (Sheet)
│   └── 운동 기록 → showingExerciseDetail (Sheet)
├── 설정 아이콘 → showSettings (Sheet)
├── 프로필 아이콘 → showProfile (Sheet)
└── 리포트 버튼 → ReportView (NavigationLink)
```

### Meal

```
MealListView (NavigationStack)
├── 기록 추가 버튼 → MealRecordView (Sheet)
│   └── AI 영양 추정 → 결과 확인 → 저장 → Sheet 닫기
└── 기록 탭 → MealDetailView (Sheet)
    ├── 영양소 상세 정보
    ├── 편집 기능
    └── 삭제 기능
```

### Exercise

```
ExerciseListView (NavigationStack)
├── 기록 추가 버튼 → ExerciseRecordView (Sheet)
│   └── 운동 선택 → 시간/강도 입력 → 저장 → Sheet 닫기
└── 기록 탭 → ExerciseDetailView (Sheet)
    ├── 운동 정보 상세
    ├── 편집 기능
    └── 삭제 기능
```

### Calendar

```
CalendarContentView
├── 월별 캘린더 (날짜 선택)
└── 선택 날짜의 기록 목록
    ├── 식사 기록 탭 → showingMealDetail (Sheet)
    └── 운동 기록 탭 → showingExerciseDetail (Sheet)
```

---

## Coordinator 패턴 설명

### 기본 패턴

SimpleCare의 Coordinator는 `ObservableObject` 기반 상태 관리와 `@ViewBuilder` 뷰 컴포지션을 사용합니다.

```swift
// Coordinator 프로토콜 (Base 모듈)
public protocol Coordinator: AnyObject {
    associatedtype Content: View
    @MainActor @ViewBuilder func start() -> Content
}
```

### DIContainer → Coordinator → View 생성 흐름

```
AppDIContainer
    │ make{Feature}DIContainer()
    ▼
FeatureDIContainer (CoordinatorDependency 프로토콜 채택)
    │ 생성자 주입
    ▼
FeatureCoordinator (ObservableObject)
    │ start() → ContainerView 반환
    ▼
ContainerView
    │ TCA Store 생성 (withDependencies)
    ▼
FeatureView (Store 바인딩)
```

### 화면 전환 방식

| 방식 | 사용처 | 구현 |
|------|--------|------|
| **Tab 전환** | 메인 탭 간 이동 | `selectedTab` 바인딩 |
| **Sheet** | 기록 추가, 상세 보기, 설정, 프로필 | `.sheet(isPresented:)` |
| **NavigationStack** | 각 탭 내부 네비게이션 | `NavigationStack` + `NavigationLink` |
| **콜백 클로저** | Coordinator 간 통신 | `onNavigateToMeal`, `onSaveComplete` 등 |

### Coordinator 간 통신 패턴

```swift
// TabCoordinator에서 HomeCoordinator 콜백 설정
coordinator.onNavigateToMeal = { [weak self] in
    self?.selectedTab = .meal
}
coordinator.onNavigateToMealDetail = { [weak self] mealId in
    self?.selectedMealId = mealId
    self?.showingMealDetail = true
}
```

---

## 참고

### 관련 문서
- [ARCHITECTURE.md](../02-설계/ARCHITECTURE.md) - 아키텍처 설계
- [MODULES.md](../02-설계/MODULES.md) - 모듈 상세 정의

### 주요 소스 파일
- `Projects/Application/Sources/AppCoordinator.swift`
- `Projects/Application/Sources/AppCoordinatorView.swift`
- `Projects/Feature/Tab/Sources/TabCoordinator.swift`
- `Projects/Feature/Tab/Sources/MainTabView.swift`
