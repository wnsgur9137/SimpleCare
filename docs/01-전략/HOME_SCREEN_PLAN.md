# SimpleCare 홈 화면 계획서

> 작성일: 2026-01-26
> 기반: PRD.md, 현재 Dashboard 구현, UX 베스트 프랙티스

---

## 1. 현재 구현 분석

### 1.1 현재 Dashboard 구성

| 섹션 | 내용 | 상태 |
|------|------|------|
| 날짜 네비게이션 | 좌우 화살표로 날짜 이동 | ✅ |
| AI 인사이트 | 이모지 + 한줄 코멘트 | ✅ (placeholder) |
| 칼로리 원형 차트 | 섭취/목표/남은 칼로리 | ✅ |
| 영양소 바 차트 | 단백질/탄수화물/지방 | ✅ |
| 오늘의 기록 | 식사 횟수, 운동 칼로리 | ✅ (간략) |

### 1.2 부족한 요소

- 빠른 기록 버튼 (Quick Actions)
- 오늘의 식사/운동 기록 목록
- 주간 트렌드/스트릭
- 목표 진행률 시각화

---

## 2. 홈 화면 디자인 원칙

### 2.1 2025 Health App UX 베스트 프랙티스

| 원칙 | 적용 방안 |
|------|----------|
| **한눈에 진행 상황 파악** | 칼로리 링 + 영양소 바 유지 |
| **One action per screen** | 빠른 기록 버튼 명확히 분리 |
| **개인화된 피드백** | AI 인사이트 강화 |
| **스트릭/배지 표시** | 연속 기록일 표시 추가 |
| **Dark mode 지원** | 시스템 설정 연동 |

### 2.2 Apple HIG 준수

- Swift Charts 활용한 데이터 시각화
- SF Symbols 아이콘 일관성
- Dynamic Type 지원
- VoiceOver 접근성

---

## 3. 홈 화면 와이어프레임

```
┌─────────────────────────────────────────────┐
│  SimpleCare              오늘 • 1월 26일 (일)  │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  💪 "단백질 섭취가 좋아요! 저녁엔      │   │
│  │      채소를 추가해보세요"              │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │         ╭──────────╮                │   │
│  │        ╱            ╲               │   │
│  │       │   1,450     │   🔥 7일 연속  │   │
│  │       │  ────────   │               │   │
│  │       │  2,000 kcal │               │   │
│  │        ╲            ╱               │   │
│  │         ╰──────────╯                │   │
│  │                                      │   │
│  │   남은 550 kcal  │  운동 +200 kcal   │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─ 영양소 ────────────────────────────┐   │
│  │  단백질  ████████░░░░  80g / 100g   │   │
│  │  탄수화물 ██████░░░░░░ 150g / 250g   │   │
│  │  지방    ████░░░░░░░░  40g / 70g    │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─ 빠른 기록 ─────────────────────────┐   │
│  │  🍽️ 식사    🏃 운동    ⚖️ 체중     │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─ 오늘의 기록 ───────────────────────┐   │
│  │  🌅 아침  │ 토스트, 계란프라이  420kcal │   │
│  │  ☀️ 점심  │ 비빔밥             650kcal │   │
│  │  🏃 운동  │ 달리기 30분       -200kcal │   │
│  │                                      │   │
│  │           + 기록 추가                │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─ 이번 주 트렌드 ────────────────────┐   │
│  │   월  화  수  목  금  토  일         │   │
│  │   ●   ●   ●   ●   ●   ●   ○         │   │
│  │  적정 적정 초과 적정 부족 적정        │   │
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 4. 섹션별 상세 계획

### 4.1 헤더 섹션

| 요소 | 내용 | 우선순위 |
|------|------|----------|
| 앱 타이틀 | "SimpleCare" | P0 |
| 날짜 표시 | 오늘 / M월 d일 (요일) | ✅ 완료 |
| 날짜 네비게이션 | 좌우 화살표 | ✅ 완료 |

### 4.2 AI 인사이트 카드

| 요소 | 현재 | 개선안 | 우선순위 |
|------|------|--------|----------|
| 이모지 | 단일 이모지 | 유지 | - |
| 코멘트 | 한 줄 | 두 줄까지 허용 | P1 |
| 배경색 | 고정 파란색 | 상태별 색상 (적정=초록, 초과=빨강) | P2 |
| 탭 액션 | 없음 | 상세 인사이트 바텀시트 | P3 |

**개선된 디자인:**
```swift
// 상태별 배경색
var insightBackgroundColor: Color {
    switch calorieStatus {
    case .under: return .orange.opacity(0.15)
    case .onTrack: return .green.opacity(0.15)
    case .over: return .red.opacity(0.15)
    }
}
```

### 4.3 칼로리 요약 카드

| 요소 | 현재 | 개선안 | 우선순위 |
|------|------|--------|----------|
| 원형 프로그레스 | ✅ | 유지 | - |
| 스트릭 배지 | ❌ | 🔥 N일 연속 표시 추가 | P1 |
| 남은/운동 칼로리 | ✅ | 유지 | - |
| 애니메이션 | 기본 | 숫자 카운트업 애니메이션 | P2 |

**스트릭 배지 디자인:**
```swift
// 연속 기록일 표시
HStack(spacing: 4) {
    Text("🔥")
    Text("\(streakDays)일 연속")
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(.orange)
}
.padding(.horizontal, 8)
.padding(.vertical, 4)
.background(Color.orange.opacity(0.15))
.clipShape(Capsule())
```

### 4.4 영양소 섹션

| 요소 | 현재 | 개선안 | 우선순위 |
|------|------|--------|----------|
| 표시 방식 | Bar Chart | **수평 프로그레스 바** | P1 |
| 목표 대비 | 없음 | N g / 목표 g 표시 | P1 |
| 목표값 설정 | 없음 | 사용자 맞춤 (Profile에서) | P2 |

**개선된 디자인:**
```swift
struct NutritionProgressRow: View {
    let label: String
    let current: Double
    let goal: Double
    let color: Color

    var progress: Double {
        min(current / goal, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(current))g / \(Int(goal))g")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
        }
    }
}
```

### 4.5 빠른 기록 버튼 (신규)

| 버튼 | 아이콘 | 액션 | 우선순위 |
|------|--------|------|----------|
| 식사 | 🍽️ fork.knife | Meal Feature 이동 | P0 |
| 운동 | 🏃 figure.run | Exercise Feature 이동 | P0 |
| 체중 | ⚖️ scalemass | Weight Feature 이동 | P0 |

**디자인:**
```swift
struct QuickActionButtons: View {
    let onMealTap: () -> Void
    let onExerciseTap: () -> Void
    let onWeightTap: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            QuickActionButton(
                icon: "fork.knife",
                label: "식사",
                color: .green,
                action: onMealTap
            )

            QuickActionButton(
                icon: "figure.run",
                label: "운동",
                color: .orange,
                action: onExerciseTap
            )

            QuickActionButton(
                icon: "scalemass",
                label: "체중",
                color: .blue,
                action: onWeightTap
            )
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(label)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
```

### 4.6 오늘의 기록 목록 (신규)

| 요소 | 설명 | 우선순위 |
|------|------|----------|
| 식사 기록 | 시간대 아이콘 + 음식명 + 칼로리 | P0 |
| 운동 기록 | 운동 아이콘 + 운동명 + 소모 칼로리 | P0 |
| 기록 추가 버튼 | 하단 "+" 버튼 | P1 |
| 빈 상태 | "아직 기록이 없어요" + CTA | P1 |
| 스와이프 삭제 | 좌측 스와이프로 삭제 | P2 |

**식사 기록 행:**
```swift
struct MealRecordRow: View {
    let meal: MealSummary

    var mealTypeIcon: String {
        switch meal.mealType {
        case .breakfast: return "sunrise"
        case .lunch: return "sun.max"
        case .dinner: return "moon"
        case .snack: return "leaf"
        }
    }

    var body: some View {
        HStack {
            Image(systemName: mealTypeIcon)
                .foregroundStyle(.orange)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(meal.mealType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(meal.foodNames.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text("\(meal.totalCalories) kcal")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 8)
    }
}
```

**빈 상태:**
```swift
struct EmptyRecordView: View {
    let onAddTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("아직 기록이 없어요")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("첫 식사 기록하기", action: onAddTap)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}
```

### 4.7 주간 트렌드 (신규)

| 요소 | 설명 | 우선순위 |
|------|------|----------|
| 7일 도트 | 칼로리 상태별 색상 (초록/주황/빨강) | P2 |
| 요일 라벨 | 월~일 | P2 |
| 탭 액션 | 해당 날짜로 이동 | P3 |

**디자인:**
```swift
struct WeeklyTrendView: View {
    let weeklyStatus: [CalorieStatus?]  // 7일, nil = 기록 없음
    let onDayTap: (Int) -> Void

    private let weekdays = ["월", "화", "수", "목", "금", "토", "일"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("이번 주 트렌드")
                .font(.headline)

            HStack {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 8) {
                        Circle()
                            .fill(dotColor(for: weeklyStatus[index]))
                            .frame(width: 12, height: 12)

                        Text(weekdays[index])
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        onDayTap(index)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func dotColor(for status: CalorieStatus?) -> Color {
        guard let status = status else {
            return .gray.opacity(0.3)
        }
        switch status {
        case .under: return .orange
        case .onTrack: return .green
        case .over: return .red
        }
    }
}
```

---

## 5. 데이터 모델 확장

### 5.1 DailySummary 확장

```swift
// DashboardDomain/Sources/Entities/DailySummary.swift

public struct DailySummary: Equatable, Sendable {
    // 기존 필드
    public let date: Date
    public let totalCalories: Int
    public let goalCalories: Int
    public let totalProtein: Double
    public let totalCarbs: Double
    public let totalFat: Double
    public let mealCount: Int
    public let exerciseCalories: Int

    // 신규 필드
    public let meals: [MealSummary]           // 식사 기록 목록
    public let exercises: [ExerciseSummary]   // 운동 기록 목록
    public let streakDays: Int                // 연속 기록일

    // 영양소 목표 (Profile에서 계산)
    public let proteinGoal: Double
    public let carbsGoal: Double
    public let fatGoal: Double
}
```

### 5.2 MealSummary 추가

```swift
// DashboardDomain/Sources/Entities/MealSummary.swift

public struct MealSummary: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let mealType: MealType
    public let foodNames: [String]
    public let totalCalories: Int
    public let recordedAt: Date

    public init(
        id: UUID,
        mealType: MealType,
        foodNames: [String],
        totalCalories: Int,
        recordedAt: Date
    ) {
        self.id = id
        self.mealType = mealType
        self.foodNames = foodNames
        self.totalCalories = totalCalories
        self.recordedAt = recordedAt
    }
}
```

### 5.3 ExerciseSummary 추가

```swift
// DashboardDomain/Sources/Entities/ExerciseSummary.swift

public struct ExerciseSummary: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let exerciseName: String
    public let duration: Int  // minutes
    public let caloriesBurned: Int
    public let recordedAt: Date

    public init(
        id: UUID,
        exerciseName: String,
        duration: Int,
        caloriesBurned: Int,
        recordedAt: Date
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.duration = duration
        self.caloriesBurned = caloriesBurned
        self.recordedAt = recordedAt
    }
}
```

### 5.4 DashboardFeature State 확장

```swift
// DashboardPresentation/Sources/DashboardFeature.swift

@ObservableState
public struct State: Equatable {
    // 기존 필드...

    // 신규 필드
    public var weeklyStatus: [CalorieStatus?] = Array(repeating: nil, count: 7)

    // 네비게이션
    @Presents var mealSheet: MealFeature.State?
    @Presents var exerciseSheet: ExerciseFeature.State?
    @Presents var weightSheet: WeightFeature.State?
}
```

---

## 6. 구현 우선순위

### Phase A: 핵심 개선 (P0) - MVP 필수

| 순서 | 작업 | 파일 |
|------|------|------|
| A.1 | 빠른 기록 버튼 컴포넌트 | `QuickActionButtons.swift` |
| A.2 | DailySummary에 meals/exercises 필드 추가 | `DailySummary.swift` |
| A.3 | MealSummary, ExerciseSummary 엔티티 생성 | `MealSummary.swift`, `ExerciseSummary.swift` |
| A.4 | 오늘의 기록 목록 섹션 | `TodayRecordsSection.swift` |
| A.5 | DashboardView에 새 섹션 통합 | `DashboardView.swift` |

### Phase B: UX 개선 (P1)

| 순서 | 작업 | 파일 |
|------|------|------|
| B.1 | 영양소 프로그레스 바 컴포넌트 | `NutritionProgressRow.swift` |
| B.2 | AI 인사이트 두 줄 지원 | `DashboardView.swift` |
| B.3 | 스트릭 배지 컴포넌트 | `StreakBadge.swift` |
| B.4 | 빈 상태 UI | `EmptyRecordView.swift` |
| B.5 | 기록 추가 버튼 | `DashboardView.swift` |

### Phase C: 고급 기능 (P2-P3)

| 순서 | 작업 | 파일 |
|------|------|------|
| C.1 | 주간 트렌드 섹션 | `WeeklyTrendView.swift` |
| C.2 | 인사이트 배경색 상태 연동 | `DashboardView.swift` |
| C.3 | 숫자 카운트업 애니메이션 | `AnimatedNumber.swift` |
| C.4 | 스와이프 삭제 | `TodayRecordsSection.swift` |
| C.5 | 인사이트 상세 바텀시트 | `InsightDetailSheet.swift` |

---

## 7. 기술적 고려사항

| 항목 | 고려사항 |
|------|----------|
| **성능** | 기록 목록 `LazyVStack` 사용 |
| **애니메이션** | `withAnimation` + `matchedGeometryEffect` |
| **접근성** | 모든 버튼 `accessibilityLabel` 추가 |
| **다크모드** | `Color(.systemBackground)` 사용 |
| **메모리** | 이미지 캐싱 불필요 (텍스트 위주) |

---

## 8. 테스트 계획

### 8.1 Unit Tests

| 테스트 | 대상 |
|--------|------|
| DailySummary 계산 | calorieProgress, remainingCalories |
| 스트릭 계산 | 연속 기록일 로직 |
| 주간 상태 | weeklyStatus 매핑 |

### 8.2 UI Tests

| 테스트 | 시나리오 |
|--------|----------|
| 빠른 기록 버튼 | 탭 → 해당 Feature 이동 |
| 날짜 네비게이션 | 좌우 화살표 동작 |
| 빈 상태 | 기록 없을 때 UI 표시 |

---

## 참고 자료

- [Best Fitness App Design: UI/UX Practices](https://madappgang.com/blog/the-best-fitness-app-design-examples-and-typical-mistakes/)
- [How to Design a Fitness App: UX/UI Best Practices](https://www.zfort.com/blog/How-to-Design-a-Fitness-App-UX-UI-Best-Practices-for-Engagement-and-Retention)
- [Health App Design: Improving UI/UX](https://topflightapps.com/ideas/healthcare-mobile-app-design/)
- [Fitness App UI Design: Key Principles](https://stormotion.io/blog/fitness-app-ux/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

*문서 버전: 1.0*
*최종 수정일: 2026-01-26*
