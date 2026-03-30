---
title: "Widget 고도화 계획서"
aliases: ["위젯 고도화"]
tags:
  - 전략
  - 전략/계획
created: 2026-03-30
updated: 2026-03-30
status: active
---

# Widget 고도화 계획서

> 작성일: 2026-03-30
> 기반: 현재 Widget 코드 분석 + PRD v2.0 목표 (Widget / Live Activity)
> 선행 작업: DailyCalorieWidget, GoalProgressWidget 구현 완료 (Phase 4)

---

## 1. 개요

SimpleCare의 Widget Extension을 iOS 최신 기능 수준으로 고도화합니다.
현재 2종(DailyCalorie, GoalProgress)의 Small/Medium 위젯만 존재하며,
신규 위젯 추가, 기존 위젯 개선, Live Activity, Interactive Widget 4개 패키지로 진행합니다.

### 현재 상태 분석

| 항목 | 현재 구현 |
|------|----------|
| 위젯 수 | 2종 (DailyCalorie, GoalProgress) |
| 지원 크기 | Small, Medium |
| 데이터 공유 | App Group UserDefaults (`WidgetDataStore`) |
| 공유 모델 | `WidgetDailySummaryData` (칼로리/매크로/운동/스트릭) |
| 갱신 주기 | 30분 or 자정 |
| 구성 방식 | `StaticConfiguration` (사용자 설정 없음) |
| 갱신 트리거 | Meal/Exercise/Home Feature에서 `reloadAllTimelines()` 호출 |

### 패키지 요약

| 패키지 | 범위 | 기능 수 | 예상 난이도 |
|--------|------|---------|------------|
| W-A: 신규 위젯 추가 | Exercise/Weight/Water 위젯 | 3개 | 중간 |
| W-B: 기존 위젯 개선 | Large/LockScreen/Intent | 3개 | 중간 |
| W-C: Live Activity | 식사/운동 Dynamic Island | 2개 | 높음 |
| W-D: Interactive Widget | 수분/체중 빠른 입력 | 2개 | 높음 |

---

## 2. Package W-A: 신규 위젯 추가 (중간 난이도, 3개)

### W-A1. 운동 요약 위젯 (ExerciseWidget)

**현재 상태**: 운동 관련 위젯 없음. 칼로리 위젯에 `exerciseCalories`만 표시.
**목표**: 오늘의 운동 세션 수, 소모 칼로리, 주간 스트릭을 보여주는 전용 위젯.

**Small 사이즈 레이아웃**:
```
┌─────────────────────┐
│  🏃 오늘의 운동       │
│                     │
│    2 세션            │
│  320 kcal 소모       │
│                     │
│  🔥 4/5일 달성       │
└─────────────────────┘
```

**Medium 사이즈 레이아웃**:
```
┌──────────────────────────────────────┐
│  🏃 오늘의 운동   │  최근 운동          │
│                  │  달리기  180kcal    │
│   2 세션          │  스쿼트  140kcal    │
│   320 kcal       │                    │
│   45분 운동       │  🔥 4/5일 달성      │
└──────────────────────────────────────┘
```

**데이터 모델 확장** (`WidgetDailySummaryData` 추가 필드):
```swift
public let exerciseSessions: Int
public let exerciseDuration: Int          // 분 단위
public let weeklyExerciseDays: Int        // 이번 주 운동한 날 수
public let weeklyExerciseGoal: Int        // 목표 (기본 5일)
public let recentExercises: [WidgetExerciseItem]  // 최근 2건
```

**신규 모델**:
```swift
public struct WidgetExerciseItem: Codable, Sendable {
    public let name: String
    public let calories: Int
}
```

**수정 파일**:
- `Projects/Feature/Base/Domain/Sources/Widget/WidgetDailySummaryData.swift` — 운동 필드 추가
- `Projects/Application/Widget/Sources/ExerciseWidget.swift` — 신규
- `Projects/Application/Widget/Sources/Views/ExerciseSmallView.swift` — 신규
- `Projects/Application/Widget/Sources/Views/ExerciseMediumView.swift` — 신규
- `Projects/Application/Widget/Sources/Models/WidgetData.swift` — `WidgetEntry`에 운동 필드 추가
- `Projects/Application/Widget/Sources/WidgetDataProvider.swift` — 운동 데이터 매핑
- `Projects/Application/Widget/Sources/SimpleCareWidgetBundle.swift` — `ExerciseWidget()` 등록
- `Projects/Application/Widget/Sources/WidgetStrings.swift` — 로컬라이제이션 키 추가
- `Projects/Application/Widget/Resources/ko.lproj/Localizable.strings` — 한국어
- `Projects/Application/Widget/Resources/en.lproj/Localizable.strings` — 영어
- `Projects/Feature/Exercise/Presentation/Sources/ExerciseFeature.swift` — `WidgetDataStore` 저장 로직 추가

**의존성**: 없음 (기존 Exercise 데이터 활용)

---

### W-A2. 체중 트렌드 위젯 (WeightTrendWidget)

**현재 상태**: 체중 관련 위젯 없음. 앱 내에서만 차트 확인 가능.
**목표**: 최근 7일 체중 미니 차트 + 목표까지 남은 kg 표시.

**Small 사이즈 레이아웃**:
```
┌─────────────────────┐
│  ⚖️ 체중 트렌드      │
│                     │
│   72.5 kg           │
│   ▁▂▃▂▃▄▃  (7일)    │
│                     │
│  목표까지 -2.5kg     │
└─────────────────────┘
```

**Medium 사이즈 레이아웃**:
```
┌──────────────────────────────────────┐
│  ⚖️ 체중 트렌드      │  현재  72.5 kg   │
│                     │  목표  70.0 kg   │
│  ▁▂▃▂▃▄▅▃  (7일)    │  변화  -0.8 kg   │
│                     │  BMI   23.1      │
│                     │  남은  -2.5 kg    │
└──────────────────────────────────────┘
```

**데이터 모델 확장** (`WidgetDailySummaryData` 추가 필드):
```swift
public let currentWeight: Double?          // 최근 체중 (kg)
public let targetWeight: Double?           // 목표 체중
public let weightChange7d: Double?         // 7일 변화량
public let bmi: Double?                    // BMI
public let recentWeights: [WidgetWeightPoint]  // 최근 7일 데이터 포인트
```

**신규 모델**:
```swift
public struct WidgetWeightPoint: Codable, Sendable {
    public let date: Date
    public let weight: Double
}
```

**수정 파일**:
- `Projects/Feature/Base/Domain/Sources/Widget/WidgetDailySummaryData.swift` — 체중 필드 추가
- `Projects/Application/Widget/Sources/WeightTrendWidget.swift` — 신규
- `Projects/Application/Widget/Sources/Views/WeightTrendSmallView.swift` — 신규 (SparkLine 뷰)
- `Projects/Application/Widget/Sources/Views/WeightTrendMediumView.swift` — 신규
- `Projects/Application/Widget/Sources/Models/WidgetData.swift` — `WidgetEntry`에 체중 필드 추가
- `Projects/Application/Widget/Sources/WidgetDataProvider.swift` — 체중 데이터 매핑
- `Projects/Application/Widget/Sources/SimpleCareWidgetBundle.swift` — `WeightTrendWidget()` 등록
- `Projects/Application/Widget/Sources/WidgetStrings.swift` — 로컬라이제이션 키 추가
- `Projects/Application/Widget/Resources/ko.lproj/Localizable.strings` — 한국어
- `Projects/Application/Widget/Resources/en.lproj/Localizable.strings` — 영어
- `Projects/Feature/Weight/Presentation/Sources/WeightFeature.swift` — `WidgetDataStore` 저장 로직 추가

**의존성**: 없음 (기존 Weight 데이터 활용)
**참고**: Small 사이즈의 SparkLine은 Swift Charts `LineMark`를 축/범례 없이 최소화하여 구현

---

### W-A3. 수분 섭취 위젯 (WaterIntakeWidget)

**현재 상태**: 수분 섭취 기능은 Meal 모듈에 구현되어 있으나 위젯 없음.
**목표**: 오늘의 수분 섭취량과 목표 달성률을 보여주는 위젯.

**Small 사이즈 레이아웃**:
```
┌─────────────────────┐
│  💧 수분 섭취        │
│                     │
│   ◔  6 / 8잔        │
│                     │
│     75%             │
└─────────────────────┘
```

**데이터 모델 확장** (`WidgetDailySummaryData` 추가 필드):
```swift
public let waterIntakeCups: Int            // 오늘 섭취한 잔 수
public let waterGoalCups: Int              // 목표 잔 수
public let waterIntakeML: Int              // mL 단위
```

**수정 파일**:
- `Projects/Feature/Base/Domain/Sources/Widget/WidgetDailySummaryData.swift` — 수분 필드 추가
- `Projects/Application/Widget/Sources/WaterIntakeWidget.swift` — 신규
- `Projects/Application/Widget/Sources/Views/WaterIntakeSmallView.swift` — 신규 (물방울 원형 프로그레스)
- `Projects/Application/Widget/Sources/Models/WidgetData.swift` — `WidgetEntry`에 수분 필드 추가
- `Projects/Application/Widget/Sources/WidgetDataProvider.swift` — 수분 데이터 매핑
- `Projects/Application/Widget/Sources/SimpleCareWidgetBundle.swift` — `WaterIntakeWidget()` 등록
- `Projects/Application/Widget/Sources/WidgetStrings.swift` — 로컬라이제이션 키 추가
- `Projects/Application/Widget/Resources/ko.lproj/Localizable.strings` — 한국어
- `Projects/Application/Widget/Resources/en.lproj/Localizable.strings` — 영어
- `Projects/Feature/Meal/Presentation/Sources/MealFeature.swift` — 수분 변경 시 `WidgetDataStore` 저장

**의존성**: 없음 (Meal 모듈의 WaterIntake 데이터 활용)

---

## 3. Package W-B: 기존 위젯 개선 (중간 난이도, 3개)

### W-B1. Large 사이즈 종합 대시보드

**현재 상태**: Small/Medium만 지원. `supportedFamilies`에 `.systemLarge` 미포함.
**목표**: 칼로리 + 매크로 + 운동 + 체중을 한 화면에 보여주는 종합 대시보드.

**Large 사이즈 레이아웃**:
```
┌──────────────────────────────────────┐
│  SimpleCare 오늘의 요약     2026.03.30│
│                                      │
│  ◔ 1,450 / 2,000 kcal  (73%)        │
│  잔여 550 kcal  |  운동 320 kcal      │
│                                      │
│  ── 영양소 ──────────────────────     │
│  P ████████░░░  72 / 120g            │
│  C ██████████░  180 / 250g           │
│  F ██████░░░░░  45 / 65g             │
│                                      │
│  ── 오늘 ───────────────────────     │
│  🏃 2세션 · 45분 · 320kcal           │
│  ⚖️ 72.5kg (목표 70.0kg)             │
│  💧 6/8잔                            │
│                                      │
│  🔥 7일 연속 기록중!                   │
└──────────────────────────────────────┘
```

**수정 파일**:
- `Projects/Application/Widget/Sources/DailyCalorieWidget.swift` — `.supportedFamilies`에 `.systemLarge` 추가
- `Projects/Application/Widget/Sources/Views/DailyCalorieLargeView.swift` — 신규 (종합 대시보드)
- `Projects/Application/Widget/Sources/DailyCalorieWidget.swift` — `DailyCalorieWidgetEntryView`에 `.systemLarge` case 추가
- `Projects/Application/Widget/Sources/WidgetStrings.swift` — 로컬라이제이션 키 추가
- `Projects/Application/Widget/Resources/ko.lproj/Localizable.strings` — 한국어
- `Projects/Application/Widget/Resources/en.lproj/Localizable.strings` — 영어

**의존성**: W-A1, W-A2, W-A3의 데이터 모델 확장 선행 필요 (운동/체중/수분 필드)

---

### W-B2. 잠금 화면 위젯 (Lock Screen Widgets)

**현재 상태**: 잠금 화면 위젯 미지원. iOS 16+ `accessory` 위젯 패밀리 미사용.
**목표**: 잠금 화면에서 빠르게 확인할 수 있는 3종 위젯.

**위젯 종류**:

| 위젯 | 패밀리 | 내용 |
|------|--------|------|
| 칼로리 원형 | `accessoryCircular` | 원형 게이지 + 잔여 칼로리 |
| 칼로리 요약 | `accessoryRectangular` | 칼로리/매크로 한 줄 요약 |
| 연속 기록 | `accessoryInline` | "🔥 7일 연속 · 550 kcal 남음" |

**accessoryCircular 레이아웃**:
```
  ┌───┐
  │◔73│  ← 칼로리 달성률 %
  │   │
  └───┘
```

**accessoryRectangular 레이아웃**:
```
┌────────────────┐
│ 🍽 1,450/2,000 │
│ P 72g C 180g   │
│ F 45g  🔥 7일  │
└────────────────┘
```

**수정 파일**:
- `Projects/Application/Widget/Sources/LockScreenWidgets.swift` — 신규 (3종 잠금 화면 위젯)
- `Projects/Application/Widget/Sources/Views/LockScreenCircularView.swift` — 신규
- `Projects/Application/Widget/Sources/Views/LockScreenRectangularView.swift` — 신규
- `Projects/Application/Widget/Sources/Views/LockScreenInlineView.swift` — 신규
- `Projects/Application/Widget/Sources/SimpleCareWidgetBundle.swift` — 3종 등록
- `Projects/Application/Widget/Sources/WidgetStrings.swift` — 로컬라이제이션 키 추가
- `Projects/Application/Widget/Resources/ko.lproj/Localizable.strings` — 한국어
- `Projects/Application/Widget/Resources/en.lproj/Localizable.strings` — 영어

**의존성**: 없음 (기존 `WidgetEntry` 데이터로 충분)
**참고**: `accessory` 위젯은 `WidgetRenderingMode`에 따라 색상 제한이 있으므로 `vibrant`/`accented` 모드 대응 필요

---

### W-B3. 사용자 설정 가능 위젯 (AppIntentConfiguration)

**현재 상태**: `StaticConfiguration` 사용 — 사용자가 표시 내용을 선택할 수 없음.
**목표**: 위젯 편집에서 표시할 데이터 유형을 선택할 수 있도록 `AppIntentConfiguration` 전환.

**설정 옵션**:

| 옵션 | 설명 | 대상 위젯 |
|------|------|----------|
| 데이터 유형 | 칼로리 / 매크로 / 운동 / 체중 중 선택 | DailyCalorie (Medium) |
| 칼로리 표시 | 섭취 칼로리 / 순 칼로리 (섭취-운동) | DailyCalorie (Small) |
| 기간 | 오늘 / 이번 주 | GoalProgress |

**구현**:
```swift
// AppIntent 정의
struct SelectWidgetDataTypeIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "표시할 데이터"

    @Parameter(title: "데이터 유형", default: .calories)
    var dataType: WidgetDataType
}

enum WidgetDataType: String, AppEnum {
    case calories = "칼로리"
    case macros = "매크로"
    case exercise = "운동"
    case weight = "체중"
}
```

**수정 파일**:
- `Projects/Application/Widget/Sources/Intents/SelectWidgetDataTypeIntent.swift` — 신규
- `Projects/Application/Widget/Sources/Intents/WidgetDataType.swift` — 신규 (AppEnum)
- `Projects/Application/Widget/Sources/DailyCalorieWidget.swift` — `StaticConfiguration` → `AppIntentConfiguration` 전환
- `Projects/Application/Widget/Sources/GoalProgressWidget.swift` — `StaticConfiguration` → `AppIntentConfiguration` 전환
- `Projects/Application/Widget/Sources/WidgetDataProvider.swift` — `AppIntentTimelineProvider` 프로토콜로 전환
- `Projects/Application/Widget/Sources/WidgetStrings.swift` — 로컬라이제이션 키 추가
- `Projects/Application/Widget/Resources/ko.lproj/Localizable.strings` — 한국어
- `Projects/Application/Widget/Resources/en.lproj/Localizable.strings` — 영어

**의존성**: W-A 패키지 완료 후 진행 권장 (모든 데이터 유형이 준비된 상태에서 설정 제공)

---

## 4. Package W-C: Live Activity (높음 난이도, 2개)

> iOS 16.1+ `ActivityKit` 기반. Dynamic Island + 잠금 화면 Live Activity.

### W-C1. 식사 기록 Live Activity

**현재 상태**: 식사 기록 중 앱을 벗어나면 진행 상황을 확인할 수 없음.
**목표**: 식사 기록 세션 중 Dynamic Island에 현재 칼로리/영양소 실시간 표시.

**시나리오**:
1. 사용자가 식사 기록 화면에서 음식 추가 시작
2. Live Activity 시작 — Dynamic Island에 현재 칼로리 표시
3. 음식 추가/수량 변경 시 실시간 업데이트
4. 식사 저장 시 Live Activity 종료 + 최종 요약 표시

**Dynamic Island 레이아웃**:

```
Compact:     🍽 1,450 kcal
Expanded:
┌──────────────────────────────────────┐
│  🍽 점심 기록 중                       │
│                                      │
│  ◔ 650 / 800 kcal                   │
│  P 35g  C 80g  F 22g                │
│                                      │
│  음식 3개 추가됨                       │
└──────────────────────────────────────┘
```

**Lock Screen Banner**:
```
┌──────────────────────────────────────┐
│  🍽 점심 기록 중 — 650 kcal (3개 음식) │
│  P 35g · C 80g · F 22g              │
└──────────────────────────────────────┘
```

**신규 모델**:
```swift
// ActivityAttributes 정의
struct MealRecordingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var totalCalories: Int
        var mealCalorieGoal: Int
        var protein: Double
        var carbs: Double
        var fat: Double
        var foodCount: Int
    }

    var mealType: String        // 아침/점심/저녁/간식
    var startTime: Date
}
```

**수정 파일**:
- `Projects/Application/Widget/Sources/LiveActivity/MealRecordingLiveActivity.swift` — 신규
- `Projects/Application/Widget/Sources/LiveActivity/MealRecordingAttributes.swift` — 신규
- `Projects/Application/Widget/Sources/Views/MealLiveActivityExpandedView.swift` — 신규
- `Projects/Application/Widget/Sources/Views/MealLiveActivityCompactView.swift` — 신규
- `Projects/Application/Widget/Sources/SimpleCareWidgetBundle.swift` — Live Activity 등록
- `Projects/Feature/Meal/Presentation/Sources/MealFeature.swift` — Live Activity 시작/업데이트/종료 로직
- `Projects/Feature/Base/Domain/Sources/Widget/WidgetConstants.swift` — Live Activity 관련 상수
- `Projects/Application/Widget/Sources/WidgetStrings.swift` — 로컬라이제이션 키 추가
- `Projects/Application/Widget/Resources/ko.lproj/Localizable.strings` — 한국어
- `Projects/Application/Widget/Resources/en.lproj/Localizable.strings` — 영어
- `Info.plist` — `NSSupportsLiveActivities: YES` 추가

**의존성**: 없음
**주의사항**:
- `ActivityKit`은 시뮬레이터에서 제한적 지원 — 실기기 테스트 필수
- Live Activity 최대 지속시간: 8시간 (시스템 제한)
- `ActivityAttributes`는 메인 앱과 Widget Extension 모두에서 접근 가능해야 함 → 공유 프레임워크 필요

---

### W-C2. 운동 기록 Live Activity

**현재 상태**: 운동 기록 중 앱을 벗어나면 경과 시간을 확인할 수 없음.
**목표**: 운동 기록 중 Dynamic Island에 경과 시간 + 실시간 칼로리 소모 표시.

**시나리오**:
1. 사용자가 운동 기록 시작 (유형/강도 선택 후)
2. Live Activity 시작 — 타이머 + 칼로리 실시간 표시
3. 시간 경과에 따라 MET 기반 칼로리 자동 업데이트
4. 운동 저장 시 Live Activity 종료 + 최종 요약

**Dynamic Island 레이아웃**:

```
Compact:     🏃 23:45 · 180 kcal
Expanded:
┌──────────────────────────────────────┐
│  🏃 달리기 (고강도)                    │
│                                      │
│     ⏱ 23:45                         │
│     🔥 180 kcal 소모                  │
│                                      │
│  [저장]                    [계속]      │
└──────────────────────────────────────┘
```

**신규 모델**:
```swift
struct ExerciseRecordingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedSeconds: Int
        var estimatedCalories: Int
    }

    var exerciseType: String     // 운동 유형명
    var intensity: String        // 강도
    var metValue: Double         // MET 값 (칼로리 계산용)
    var startTime: Date
}
```

**수정 파일**:
- `Projects/Application/Widget/Sources/LiveActivity/ExerciseRecordingLiveActivity.swift` — 신규
- `Projects/Application/Widget/Sources/LiveActivity/ExerciseRecordingAttributes.swift` — 신규
- `Projects/Application/Widget/Sources/Views/ExerciseLiveActivityExpandedView.swift` — 신규
- `Projects/Application/Widget/Sources/Views/ExerciseLiveActivityCompactView.swift` — 신규
- `Projects/Application/Widget/Sources/SimpleCareWidgetBundle.swift` — Live Activity 등록
- `Projects/Feature/Exercise/Presentation/Sources/ExerciseFeature.swift` — Live Activity 시작/업데이트/종료 로직 + 타이머
- `Projects/Feature/Base/Domain/Sources/Widget/WidgetConstants.swift` — 상수 추가
- `Projects/Application/Widget/Sources/WidgetStrings.swift` — 로컬라이제이션 키 추가
- `Projects/Application/Widget/Resources/ko.lproj/Localizable.strings` — 한국어
- `Projects/Application/Widget/Resources/en.lproj/Localizable.strings` — 영어

**의존성**: W-C1과 `Info.plist` 설정 공유
**참고**: 타이머 표시에 `Text(.now, style: .timer)` 사용 시 시스템이 자동 갱신하므로 별도 push 업데이트 불필요

---

## 5. Package W-D: Interactive Widget (높음 난이도, 2개)

> iOS 17+ `AppIntent` + `Button`/`Toggle` 기반 Interactive Widget.

### W-D1. 수분 빠른 기록 위젯

**현재 상태**: 수분 기록은 앱 내 Meal 탭에서만 가능.
**목표**: 위젯에서 버튼 탭 한 번으로 물 1잔(250mL) 추가.

**Small 사이즈 레이아웃**:
```
┌─────────────────────┐
│  💧 수분 섭취        │
│                     │
│   ◔  6 / 8잔        │
│                     │
│   [+ 1잔]  ← 탭 가능 │
└─────────────────────┘
```

**구현**:
```swift
// AppIntent: 수분 1잔 추가
struct AddWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "물 1잔 추가"

    func perform() async throws -> some IntentResult {
        // App Group UserDefaults에서 현재 수분 데이터 로드
        // +1잔 추가 후 저장
        // WidgetCenter.shared.reloadTimelines(ofKind: "WaterIntakeWidget")
        return .result()
    }
}
```

**수정 파일**:
- `Projects/Application/Widget/Sources/Intents/AddWaterIntent.swift` — 신규 (AppIntent)
- `Projects/Application/Widget/Sources/WaterIntakeWidget.swift` — W-A3에서 생성한 위젯에 `Button(intent:)` 추가
- `Projects/Application/Widget/Sources/Views/WaterIntakeSmallView.swift` — Interactive 버튼 추가
- `Projects/Feature/Base/Domain/Sources/Widget/WidgetDataStore.swift` — `addWaterCup()` 메서드 추가
- `Projects/Feature/Meal/Presentation/Sources/MealFeature.swift` — 앱 진입 시 Widget에서 추가된 수분 동기화
- `Projects/Application/Widget/Sources/WidgetStrings.swift` — 로컬라이제이션 키 추가
- `Projects/Application/Widget/Resources/ko.lproj/Localizable.strings` — 한국어
- `Projects/Application/Widget/Resources/en.lproj/Localizable.strings` — 영어

**의존성**: W-A3 (수분 위젯) 선행 필수
**주의사항**:
- Widget에서 SwiftData 직접 접근 불가 → App Group UserDefaults 경유 후 앱 진입 시 SwiftData 동기화
- `AppIntent`의 `perform()`은 Widget Extension 프로세스에서 실행됨 → 메인 앱의 SwiftData 컨텍스트 사용 불가

---

### W-D2. 빠른 체중 입력 위젯

**현재 상태**: 체중 기록은 앱 내 Weight 탭에서만 가능.
**목표**: 위젯에서 ± 버튼으로 체중을 미세 조절하여 빠르게 기록.

**Medium 사이즈 레이아웃**:
```
┌──────────────────────────────────────┐
│  ⚖️ 체중 기록                         │
│                                      │
│  [-0.1]  72.5 kg  [+0.1]            │
│                                      │
│         [저장]  ← 탭 가능              │
│  어제: 72.8 kg  |  목표: 70.0 kg      │
└──────────────────────────────────────┘
```

**구현**:
```swift
// AppIntent: 체중 조절
struct AdjustWeightIntent: AppIntent {
    static var title: LocalizedStringResource = "체중 조절"

    @Parameter(title: "변화량")
    var delta: Double  // +0.1 or -0.1

    func perform() async throws -> some IntentResult {
        // App Group UserDefaults에서 현재 임시 체중 로드
        // delta 적용 후 저장
        // WidgetCenter.shared.reloadTimelines(ofKind: "WeightQuickInputWidget")
        return .result()
    }
}

struct SaveWeightIntent: AppIntent {
    static var title: LocalizedStringResource = "체중 저장"

    func perform() async throws -> some IntentResult {
        // 임시 체중 → 확정 데이터로 저장
        // 앱 진입 시 SwiftData에 동기화
        return .result()
    }
}
```

**수정 파일**:
- `Projects/Application/Widget/Sources/Intents/AdjustWeightIntent.swift` — 신규
- `Projects/Application/Widget/Sources/Intents/SaveWeightIntent.swift` — 신규
- `Projects/Application/Widget/Sources/WeightQuickInputWidget.swift` — 신규
- `Projects/Application/Widget/Sources/Views/WeightQuickInputMediumView.swift` — 신규
- `Projects/Application/Widget/Sources/SimpleCareWidgetBundle.swift` — 등록
- `Projects/Feature/Base/Domain/Sources/Widget/WidgetDataStore.swift` — `adjustWeight()`, `saveWeight()` 메서드 추가
- `Projects/Feature/Base/Domain/Sources/Widget/WidgetConstants.swift` — 체중 입력 관련 키 추가
- `Projects/Feature/Weight/Presentation/Sources/WeightFeature.swift` — 앱 진입 시 Widget에서 저장된 체중 동기화
- `Projects/Application/Widget/Sources/WidgetStrings.swift` — 로컬라이제이션 키 추가
- `Projects/Application/Widget/Resources/ko.lproj/Localizable.strings` — 한국어
- `Projects/Application/Widget/Resources/en.lproj/Localizable.strings` — 영어

**의존성**: W-A2 (체중 트렌드 위젯) 데이터 모델 공유
**주의사항**:
- Interactive Widget은 Medium 이상 크기에서만 여러 버튼 배치 가능
- 체중 저장 시 앱 미실행 상태에서도 동작해야 함 → App Group 기반 임시 저장 후 앱 진입 시 동기화

---

## 6. 공통 인프라 변경사항

### 6.1 WidgetDailySummaryData 확장

W-A 패키지에서 추가되는 모든 필드를 한번에 정리:

```swift
// 기존 필드 유지 + 아래 추가
// Exercise 관련
public let exerciseSessions: Int
public let exerciseDuration: Int
public let weeklyExerciseDays: Int
public let weeklyExerciseGoal: Int
public let recentExercises: [WidgetExerciseItem]

// Weight 관련
public let currentWeight: Double?
public let targetWeight: Double?
public let weightChange7d: Double?
public let bmi: Double?
public let recentWeights: [WidgetWeightPoint]

// Water 관련
public let waterIntakeCups: Int
public let waterGoalCups: Int
public let waterIntakeML: Int
```

**하위 호환성**: 기존 필드는 변경 없음. 새 필드는 Optional 또는 기본값 제공으로 기존 위젯에 영향 없음.

### 6.2 WidgetEntry 확장

`WidgetEntry`에도 동일 필드 추가. `placeholder`와 `empty` 정적 프로퍼티 업데이트.

### 6.3 Info.plist

- `NSSupportsLiveActivities: YES` — W-C 패키지 필수

### 6.4 데이터 동기화 포인트

현재 `reloadAllTimelines()` 호출 위치 + 추가 필요 위치:

| Feature | 현재 호출 | 추가 필요 |
|---------|----------|----------|
| MealFeature | 식사 저장 시 ✅ | 수분 기록 시 (W-A3) |
| ExerciseFeature | 운동 저장 시 ✅ | — |
| HomeFeature | 일일 요약 로드 시 ✅ | — |
| WeightFeature | — | 체중 저장 시 (W-A2) |

---

## 7. 구현 순서 권장

```
Phase 1: Package W-A (신규 위젯) — 3개, 중간 난이도
  W-A1 (Exercise 위젯) — 독립
  W-A2 (Weight 위젯) — 독립
  W-A3 (Water 위젯) — 독립
  → 3개 모두 병렬 진행 가능

Phase 2: Package W-B (기존 개선) — 3개, 중간 난이도
  W-B2 (잠금 화면) — 독립, W-A와 병렬 가능
  W-B1 (Large 대시보드) — W-A 데이터 모델 의존
  W-B3 (Intent 설정) — W-A 완료 후 권장

Phase 3: Package W-C (Live Activity) — 2개, 높음 난이도
  W-C1 (식사 Live Activity) — 독립
  W-C2 (운동 Live Activity) — W-C1과 인프라 공유, 순차 권장

Phase 4: Package W-D (Interactive) — 2개, 높음 난이도
  W-D1 (수분 빠른 기록) — W-A3 의존
  W-D2 (체중 빠른 입력) — W-A2 의존
```

### 의존성 다이어그램

```
W-A1 ──────────────────────→ W-B1 (Large)
W-A2 ──────────────────────→ W-B1 (Large) ──→ W-B3 (Intent)
W-A3 ──────────────────────→ W-B1 (Large)
  │
  ├─→ W-D1 (수분 Interactive)
W-A2 ─→ W-D2 (체중 Interactive)

W-B2 (잠금 화면) — 독립

W-C1 (식사 Live Activity) — 독립
W-C2 (운동 Live Activity) — W-C1 인프라 공유
```

---

## 8. 총 작업 요약

| 패키지 | 기능 수 | 신규 파일 (예상) | 수정 파일 (예상) | 난이도 |
|--------|---------|-----------------|-----------------|--------|
| W-A | 3 | ~9 | ~8 | 중간 |
| W-B | 3 | ~7 | ~6 | 중간 |
| W-C | 2 | ~8 | ~5 | 높음 |
| W-D | 2 | ~5 | ~6 | 높음 |
| **합계** | **10** | **~29** | **~25** | — |

---

## 참고

### 관련 문서
- [FEATURE_ENHANCEMENT_PLAN.md](./FEATURE_ENHANCEMENT_PLAN.md) — Feature 고도화 계획서
- [ROADMAP.md](./ROADMAP.md) — 개발 로드맵
- [PRD.md](./PRD.md) — 제품 요구사항 (v2.0 Widget/Live Activity 목표)

### 기술 참고
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [ActivityKit Documentation](https://developer.apple.com/documentation/activitykit)
- [App Intents Documentation](https://developer.apple.com/documentation/appintents)
