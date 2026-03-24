---
title: "Widget 모듈"
aliases: ["Widget", "WidgetExtension"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/extension
created: 2026-03-23
updated: 2026-03-24
status: done
---

# Widget

**역할**: WidgetKit 기반 홈 화면 위젯 — 일일 칼로리 요약, 목표 달성률 표시

## 개요

SimpleCare의 핵심 건강 데이터를 iOS 홈 화면 위젯으로 제공합니다. 사용자가 앱을 열지 않아도 오늘의 칼로리 섭취/목표, 영양소 달성률, 연속 기록 일수를 한눈에 확인할 수 있습니다.

## 위젯 종류

| 위젯 | 지원 크기 | 표시 데이터 |
|------|----------|------------|
| 일일 칼로리 요약 | small, medium | 섭취/목표 칼로리, 남은 칼로리, 운동 소모 칼로리, 원형 프로그레스 |
| 목표 달성률 | small, medium | 칼로리 달성률(%), P/C/F 프로그레스 바, 연속 기록 일수 |

## 아키텍처

### 데이터 공유 전략

Widget Extension은 별도 프로세스에서 실행되므로 메인 앱의 SwiftData에 직접 접근할 수 없습니다. **App Group + UserDefaults** 방식으로 데이터를 공유합니다.

```
[메인 앱]                              [Widget Extension]
HomeFeature                            SimpleCareWidgetBundle
    │                                       │
    ├─ getDailySummary() 성공              ├─ TimelineProvider
    │       │                               │       │
    │       ▼                               │       ▼
    │  WidgetDataStore.save()              │  WidgetDataStore.load()
    │       │                               │       │
    │       ▼                               │       ▼
    └── UserDefaults ◄──────────────────── └── UserDefaults
         (App Group)                         (App Group)
         group.com.junhyeok.SimpleCare
```

### 갱신 트리거

| 트리거 | 메커니즘 |
|--------|----------|
| 식사/운동 기록 변경 | `WidgetCenter.shared.reloadAllTimelines()` |
| 주기적 갱신 | TimelineProvider에서 30분 간격, `.atEnd` 정책 |
| 날짜 변경 (자정) | Timeline entry에 자정 시각 포함 |

## 디렉토리 구조

```
Projects/Application/
├── Widget/
│   ├── Sources/
│   │   ├── SimpleCareWidgetBundle.swift    # @main WidgetBundle 진입점
│   │   ├── DailyCalorieWidget.swift       # 일일 칼로리 위젯 (TimelineProvider + Widget)
│   │   ├── GoalProgressWidget.swift       # 목표 달성률 위젯 (TimelineProvider + Widget)
│   │   ├── WidgetDataProvider.swift       # SharedDefaults 데이터 로드 헬퍼
│   │   ├── WidgetStrings.swift            # Localization 키 관리
│   │   ├── Models/
│   │   │   └── WidgetData.swift           # TimelineEntry 정의
│   │   └── Views/
│   │       ├── DailyCalorieSmallView.swift
│   │       ├── DailyCalorieMediumView.swift
│   │       ├── GoalProgressSmallView.swift
│   │       ├── GoalProgressMediumView.swift
│   │       └── WidgetHelpers.swift        # 프로그레스 색상 + View.if extension
│   └── Resources/
│       ├── Assets.xcassets
│       ├── ko.lproj/
│       │   └── Localizable.strings
│       └── en.lproj/
│           └── Localizable.strings
├── SimpleCare.entitlements                 # App Group 추가
└── SimpleCareWidget.entitlements           # Widget용 App Group
```

## 파일 상세

| 레이어 | 파일 | 설명 |
|--------|------|------|
| **진입점** | | |
| Bundle | `SimpleCareWidgetBundle.swift` | @main WidgetBundle (2개 위젯 등록) |
| **데이터** | | |
| Model | `WidgetData.swift` | TimelineEntry 정의 |
| Provider | `WidgetDataProvider.swift` | App Group UserDefaults에서 데이터 로드 |
| **위젯 1: 일일 칼로리** | | |
| Widget | `DailyCalorieWidget.swift` | TimelineProvider + Widget 정의 |
| View | `DailyCalorieSmallView.swift` | Small 크기 — 원형 프로그레스 + 칼로리 |
| View | `DailyCalorieMediumView.swift` | Medium 크기 — 프로그레스 + 운동/잔여 상세 |
| **위젯 2: 목표 달성률** | | |
| Widget | `GoalProgressWidget.swift` | TimelineProvider + Widget 정의 |
| View | `GoalProgressSmallView.swift` | Small 크기 — 달성률(%) + streak |
| View | `GoalProgressMediumView.swift` | Medium 크기 — P/C/F 프로그레스 바 + streak |
| **Localization** | | |
| Strings | `WidgetStrings.swift` | 9개 Localization 키 + streakDays 포맷 함수 |
| Resource | `ko.lproj/Localizable.strings` | 한국어 번역 |
| Resource | `en.lproj/Localizable.strings` | 영어 번역 |
| **공통** | | |
| Helper | `WidgetHelpers.swift` | 프로그레스 색상 함수 + View.if() extension |

## 공유 데이터 모델

`BaseDomain` 모듈에 위치하여 메인 앱과 Widget Extension 모두에서 접근 가능합니다.

### WidgetDailySummaryData (Codable)

| 필드 | 타입 | 설명 |
|------|------|------|
| `date` | Date | 날짜 |
| `totalCalories` | Int | 섭취한 총 칼로리 |
| `goalCalories` | Int | 목표 칼로리 |
| `remainingCalories` | Int | 남은 칼로리 |
| `calorieProgress` | Double | 칼로리 진행률 (0.0~1.0+) |
| `exerciseCalories` | Int | 운동 소모 칼로리 |
| `totalProtein` | Double | 섭취 단백질 (g) |
| `totalCarbs` | Double | 섭취 탄수화물 (g) |
| `totalFat` | Double | 섭취 지방 (g) |
| `proteinGoal` | Double | 단백질 목표 (g) |
| `carbsGoal` | Double | 탄수화물 목표 (g) |
| `fatGoal` | Double | 지방 목표 (g) |
| `streakDays` | Int | 연속 기록 일수 |
| `lastUpdated` | Date | 마지막 갱신 시각 |

### WidgetDataStore

| 메서드 | 설명 |
|--------|------|
| `save(_:)` | WidgetDailySummaryData를 JSON으로 인코딩하여 App Group UserDefaults에 저장 |
| `load()` | App Group UserDefaults에서 WidgetDailySummaryData를 디코딩하여 반환 |
| `sharedDefaults` | `UserDefaults(suiteName: "group.com.junhyeok.SimpleCare")` |

### WidgetConstants

| 메서드/상수 | 설명 |
|------------|------|
| `appGroupID` | App Group 식별자 (`group.com.junhyeok.SimpleCare`) |
| `dailySummaryKey` | UserDefaults 키 |
| `bundleIdSuffix` | Widget 번들 ID 접미사 |

## 의존성

```
SimpleCareWidget (.appExtension)
  └── BaseDomain (staticFramework)
        └── WidgetDailySummaryData, WidgetDataStore
```

- StorageInfra, TCA, Moya 등 무거운 프레임워크에 의존하지 않음
- Widget 번들 크기와 메모리 사용량 최소화

## Tuist 설정

- **Product**: `.appExtension`
- **번들 ID (PROD)**: `com.junhyeok.SimpleCare.Widget`
- **번들 ID (DEV)**: `com.junhyeok.SimpleCare-Dev.Widget`
- **Entitlements**: `SimpleCareWidget.entitlements` (App Group)
- **의존성**: `BaseDomain`만

## 앱 측 연동

위젯 데이터 동기화는 다음 위치에서 수행됩니다:

| 위치 | 동작 |
|------|------|
| `HomeFeature.swift` | `getDailySummary` 성공 시 `WidgetDataStore.save()` + `reloadAllTimelines()` |
| `MealFeature.swift` | 식사 저장/삭제 후 `reloadAllTimelines()` |
| `ExerciseFeature.swift` | 운동 저장/삭제 후 `reloadAllTimelines()` |

## 위젯 UI 명세

### 일일 칼로리 요약 — Small

```
┌──────────────┐
│   ╭──────╮   │
│   │ 1200 │   │
│   │/2000 │   │
│   ╰──────╯   │
│  남은: 800    │
└──────────────┘
  (원형 프로그레스)
```

### 일일 칼로리 요약 — Medium

```
┌────────────────────────────────┐
│  ╭──────╮  │ 운동 소모  320kcal │
│  │ 1200 │  │ 남은 칼로리 800    │
│  │/2000 │  │ 진행률     60%    │
│  ╰──────╯  │                   │
└────────────────────────────────┘
```

### 목표 달성률 — Small

```
┌──────────────┐
│    60%       │
│  달성률      │
│              │
│  🔥 7일 연속  │
└──────────────┘
```

### 목표 달성률 — Medium

```
┌────────────────────────────────┐
│ 칼로리 60%  ████████░░░░       │
│ 단백질 75%  ██████████░░       │
│ 탄수화물 45% ██████░░░░░░      │
│ 지방   80%  ██████████░░  🔥7일 │
└────────────────────────────────┘
```

## Localization

Widget Extension은 별도 번들이므로 메인 앱의 Localizable.strings와 독립적으로 관리합니다.

### 지원 언어

| 언어 | 파일 |
|------|------|
| 한국어 (ko) | `Resources/ko.lproj/Localizable.strings` |
| 영어 (en) | `Resources/en.lproj/Localizable.strings` |

### WidgetStrings

| 키 | 한국어 | 영어 |
|----|--------|------|
| `widget.dailyCalorie.title` | 일일 칼로리 | Daily Calories |
| `widget.dailyCalorie.description` | 오늘의 칼로리 섭취량과 목표를 확인합니다. | Check today's calorie intake and goal. |
| `widget.remaining` | 남은: | Left: |
| `widget.exerciseBurned` | 운동 소모 | Exercise |
| `widget.remainingCalories` | 남은 칼로리 | Remaining |
| `widget.progressRate` | 진행률 | Progress |
| `widget.goalProgress.title` | 목표 달성률 | Goal Progress |
| `widget.goalProgress.description` | 칼로리와 영양소 목표 달성률을 확인합니다. | Check calorie and nutrition goal progress. |
| `widget.achievementRate` | 달성률 | Progress |
| `widget.streakDays` | %d일 연속 | %d day streak |

## 참고

- [Home 모듈](./Home.md) — 위젯 데이터의 원본 소스
- [StorageInfra 모듈](./StorageInfra.md) — SwiftData 영속화
- [Base 모듈](./Base.md) — 공유 DTO 위치
- [ARCHITECTURE](../ARCHITECTURE.md) — 전체 아키텍처
