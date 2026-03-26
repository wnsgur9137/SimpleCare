---
title: "Feature 고도화 계획서"
aliases: ["기능 고도화"]
tags:
  - 전략
  - 전략/계획
created: 2026-03-26
updated: 2026-03-26
status: active
---

# Feature 고도화 계획서

> 작성일: 2026-03-26
> 기반: 코드 분석 + 경쟁 앱 레퍼런스 (MyFitnessPal, Strava, Withings, Apple Fitness)
> 선행 작업: Meal 기능 고도화 10개 항목 완료 (PR #81, #82, #83)

---

## 1. 개요

SimpleCare의 Exercise, Weight, Home, Profile 모듈을 경쟁 앱 수준으로 고도화합니다.
4개 패키지로 분리하여 독립적으로 진행 가능합니다.

### 패키지 요약

| 패키지 | 범위 | 기능 수 | 예상 난이도 |
|--------|------|---------|------------|
| A: Quick Wins | Exercise + Weight + Home | 6개 | ✅ 완료 |
| B: Exercise 고도화 | Exercise 모듈 | 3개 | 중간 |
| C: Weight 고도화 | Weight 모듈 | 3개 | 중간 |
| D: AI 고도화 | AIServiceInfra + Home | 3개 | 중간~높음 |

---

## 2. Package A: Quick Wins (낮음 난이도, 6개) ✅ 완료

> PR #84 (Exercise), #85 (Weight), #86 (Home) — 2026-03-26 병합 완료

### A-1. Exercise 히스토리 기간 선택 (E-1)

**현재 상태**: `ExerciseListFeature`가 30일 고정 (`mealHistoryFetchDays = 30`)
**목표**: Weight 모듈과 동일한 7/30/90일 기간 선택 Picker 추가

**수정 파일**:
- `Projects/Feature/Exercise/Presentation/Sources/ExerciseListFeature.swift`
  - State에 `selectedPeriod: TrendPeriod` 추가 (7/30/90일)
  - `loadExercises` Action에서 `selectedPeriod`에 따라 startDate 계산
  - `selectPeriod(TrendPeriod)` Action 추가
- `Projects/Feature/Exercise/Presentation/Sources/ExerciseListView.swift`
  - 상단에 `Picker` (segmented) 추가

**의존성**: 없음 (ExerciseClient.fetchExerciseHistory 이미 startDate/endDate 파라미터 지원)
**구현 참고**: Weight 모듈의 `TrendPeriod` enum 패턴 재사용

---

### A-2. Exercise 스트릭/주간 목표 (E-3)

**현재 상태**: Home에만 `streakDays` 표시, Exercise 모듈에는 스트릭 없음
**목표**: 운동 목록 상단에 "이번 주 X/Y일 운동" 뱃지 표시

**수정 파일**:
- `Projects/Feature/Exercise/Presentation/Sources/ExerciseListFeature.swift`
  - State에 `weeklyExerciseDays: Int` 계산 속성 추가 (groupedExercises에서 이번 주 고유 날짜 수)
- `Projects/Feature/Exercise/Presentation/Sources/ExerciseListView.swift`
  - 목록 상단에 주간 운동 일수 뱃지 + 원형 프로그레스 링 추가
- 로컬라이제이션 키 추가 (ko/en)

**의존성**: 없음 (기존 exercises 배열에서 계산)

---

### A-3. Exercise 기간 합계 요약 헤더 (E-4)

**현재 상태**: 바로 날짜별 섹션으로 시작, 기간 합계 없음
**목표**: "총 12회 | 2,400kcal | 6시간 30분" 요약 바 표시

**수정 파일**:
- `Projects/Feature/Exercise/Presentation/Sources/ExerciseListFeature.swift`
  - State에 계산 속성 추가: `totalSessions`, `totalCalories`, `totalMinutes`
- `Projects/Feature/Exercise/Presentation/Sources/ExerciseListView.swift`
  - 기간 Picker 아래에 요약 카드 (HStack, 3개 VStack) 추가

**의존성**: A-1 (기간 선택) 완료 후 구현하면 기간별 합계가 의미 있음

---

### A-4. Weight 골격근량 입력/표시 (W-1)

**현재 상태**: `WeightRecord.skeletalMuscleMassKg: Double?` 도메인 필드 존재, UI 없음
**목표**: 체중 입력 폼에 골격근량 슬라이더 추가, 트렌드 차트에 선택적 표시

**수정 파일**:
- `Projects/Feature/Weight/Presentation/Sources/WeightFeature.swift`
  - State에 `skeletalMuscleMass: Double?` 추가
  - `recordWeight` Action에서 `skeletalMuscleMassKg` 포함하여 저장
- `Projects/Feature/Weight/Presentation/Sources/WeightView.swift`
  - 체지방률 입력 아래에 골격근량 슬라이더 추가 (10~60kg, 0.1 step)
  - 체중 기록 저장 시 값 전달
- 로컬라이제이션 키 추가 (ko/en)

**의존성**: 없음 (도메인 + StorageInfra 이미 지원)

---

### A-5. Weight 목표 달성 프로그레스 바 (W-3)

**현재 상태**: `WeightTrend.progressToGoal(from:)` 메서드 존재, UI에서 미사용
**목표**: 체중 차트 위에 시작 → 현재 → 목표 프로그레스 바 표시

**수정 파일**:
- `Projects/Feature/Weight/Presentation/Sources/WeightFeature.swift`
  - State에 `startWeight: Double?` 추가 (최초 기록 또는 목표 설정 시점의 체중)
  - `loadWeights` 응답에서 가장 오래된 기록의 체중을 startWeight로 설정
- `Projects/Feature/Weight/Presentation/Sources/WeightView.swift`
  - 차트 상단에 `ProgressView` 또는 커스텀 바 추가
  - 시작 체중, 현재 체중, 목표 체중 라벨 표시
- 로컬라이제이션 키 추가 (ko/en)

**의존성**: 없음 (WeightTrend.progressToGoal 이미 구현됨)

---

### A-6. Home 순 칼로리 밸런스 표시 (H-3)

**현재 상태**: 칼로리 링에 "섭취/목표" 표시, 운동 칼로리는 별도 섹션
**목표**: "순 잔여 = 목표 - 섭취 + 운동소모" 표시 추가

**수정 파일**:
- `Projects/Feature/Home/Presentation/Sources/HomeView.swift`
  - `calorieSummarySection` 내부에 순 잔여 칼로리 텍스트 추가
  - `HomeDailySummary`의 `remainingCalories` + `exerciseCalories`로 계산
- 로컬라이제이션 키 추가 (ko/en)

**의존성**: 없음 (HomeDailySummary에 모든 데이터 존재)
**구현**: 순수 UI 변경, 약 30분

---

## 3. Package B: Exercise 고도화 (중간 난이도, 3개)

### B-1. 운동 칼로리 트렌드 차트 (E-2)

**현재 상태**: 운동 모듈에 차트 없음 (Weight는 Swift Charts 사용)
**목표**: 기간별 일일 소모 칼로리 바 차트 추가

**수정 파일**:
- `Projects/Feature/Exercise/Presentation/Sources/ExerciseListFeature.swift`
  - State에 `dailyCalories: [(date: Date, calories: Int)]` 계산 속성 추가
  - exercises 배열을 날짜별로 그룹화하여 일일 칼로리 합계 산출
- `Projects/Feature/Exercise/Presentation/Sources/ExerciseListView.swift`
  - 요약 헤더 아래에 `Chart` 추가 (BarMark, x: 날짜, y: 칼로리)
  - 기간에 따라 바 너비 조절 (7일: 넓게, 90일: 좁게)
- `Projects/Feature/Exercise/Project.swift`
  - Swift Charts는 이미 OS 내장이므로 별도 의존성 불필요

**의존성**: A-1 (기간 선택) 완료 후 구현 권장
**참고**: Weight 모듈의 `Chart` 사용 패턴 참조

---

### B-2. 최근/자주 사용 운동 바로가기 (E-5)

**현재 상태**: 매번 카테고리 → 운동 유형 → 강도 순으로 선택해야 함
**목표**: 기록 폼 상단에 "최근 운동" 섹션 (최근 5개 운동 유형)

**수정 파일**:
- `Projects/Feature/Exercise/Presentation/Sources/ExerciseFeature.swift`
  - State에 `recentExerciseTypes: [(ExerciseType, ExerciseIntensity)]` 추가
  - `loadRecentExercises` Action 추가
  - ExerciseClient에 `fetchRecentTypes` 추가 (최근 5개 고유 운동 유형)
- `Projects/Feature/Exercise/Presentation/Sources/ExerciseRecordView.swift`
  - 카테고리 선택 위에 "최근 운동" 가로 스크롤 칩 추가
  - 탭하면 카테고리/유형/강도 자동 선택
- `Projects/Feature/Exercise/Sources/ExerciseDIContainer.swift`
  - 새 Client 메서드 와이어링
- 로컬라이제이션 키 추가 (ko/en)

**의존성**: ExerciseClient 확장 필요

---

### B-3. 상세에서 운동 유형 수정 (E-6)

**현재 상태**: `ExerciseDetailFeature`에서 강도/시간/메모만 수정 가능
**목표**: 운동 유형도 수정 가능하도록 Picker 추가

**수정 파일**:
- `Projects/Feature/Exercise/Presentation/Sources/ExerciseDetailFeature.swift`
  - 편집 모드 시 `exerciseType` 바인딩 추가
  - `saveChanges`에서 변경된 유형 반영
- `Projects/Feature/Exercise/Presentation/Sources/ExerciseDetailView.swift`
  - `isEditing` 상태에서 운동 유형 Picker 표시 (카테고리 → 유형)

**의존성**: 없음

---

## 4. Package C: Weight 고도화 (중간 난이도, 3개)

### C-1. 목표 달성 예상 날짜 (W-4)

**현재 상태**: 주간/월간 체중 변화량 표시, 예상 날짜 없음
**목표**: "현재 속도로 목표 체중까지 약 X주 (YYYY.MM.DD 예상)"

**수정 파일**:
- `Projects/Feature/Weight/Domain/Sources/Entities/WeightTrend.swift`
  - `estimatedGoalDate(currentWeight:targetWeight:weeklyChange:) -> Date?` 계산 속성 추가
  - weeklyChange가 0이거나 방향이 반대면 nil 반환
- `Projects/Feature/Weight/Presentation/Sources/WeightFeature.swift`
  - State에 `estimatedGoalDate: Date?` 추가
  - 트렌드 로드 시 계산
- `Projects/Feature/Weight/Presentation/Sources/WeightView.swift`
  - 프로그레스 바 아래에 예상 날짜 텍스트 표시
  - 방향이 반대이면 경고 메시지 ("현재 추세가 목표와 반대 방향입니다")
- 로컬라이제이션 키 추가 (ko/en)

**의존성**: A-5 (프로그레스 바)와 함께 표시하면 좋음

---

### C-2. 체지방률 트렌드 차트 (W-5)

**현재 상태**: 체중 라인 차트만 존재, 체지방률 입력은 있으나 차트 없음
**목표**: 차트 토글로 체중/체지방률 전환 또는 이중 축 표시

**수정 파일**:
- `Projects/Feature/Weight/Presentation/Sources/WeightFeature.swift`
  - State에 `chartMode: ChartMode` 추가 (enum: weight, bodyFat, both)
  - `selectChartMode(ChartMode)` Action 추가
- `Projects/Feature/Weight/Presentation/Sources/WeightView.swift`
  - 차트 상단에 chartMode Picker (segmented) 추가
  - bodyFat 모드: 체지방률 LineMark (다른 색상)
  - both 모드: 이중 축 (왼: 체중 kg, 오른: 체지방 %)
- 로컬라이제이션 키 추가 (ko/en)

**의존성**: 없음 (WeightRecord에 bodyFatPercentage 이미 존재)

---

### C-3. HealthKit 체중 동기화 활성화 (W-6)

**현재 상태**: `WeightClient`에 `syncWeightToHealthKit`, `isHealthKitAvailable` 스텁 존재, 미연결
**목표**: 체중 기록 시 HealthKit에 자동 동기화 + 설정에서 토글

**수정 파일**:
- `Projects/Feature/Weight/Presentation/Sources/WeightFeature.swift`
  - `recordWeight` 성공 후 `syncWeightToHealthKit` 호출
  - State에 `isHealthKitSyncEnabled: Bool` 추가
- `Projects/Feature/Weight/Presentation/Sources/WeightView.swift`
  - 차트 하단에 "HealthKit 동기화" 토글 추가
- `Projects/Feature/Weight/Sources/WeightDIContainer.swift`
  - HealthKit 관련 Client 메서드 실제 구현 연결
- `Projects/Infrastructure/HealthKitInfra/` — 체중 쓰기 메서드 확인/구현

**의존성**: HealthKitInfra 모듈의 체중 쓰기 지원 여부 확인 필요

---

## 5. Package D: AI 고도화 (ROADMAP 미완료 3개)

### D-1. 개인화된 추천 기능

**현재 상태**: AI 인사이트가 당일 요약 기반 일회성 코멘트
**목표**: 사용자의 식습관 패턴 기반 개인화된 식사/운동 추천

**구현 방향**:
- 최근 7일 식사 데이터를 Gemini API에 전달
- 영양소 불균형, 반복 식단, 부족 영양소 파악
- "오늘 단백질이 부족했습니다. 저녁에 닭가슴살이나 두부를 추천합니다" 형태

**수정 파일**:
- `Projects/Infrastructure/AIServiceInfra/Sources/Prompts/NutritionPrompts.swift` — 추천 프롬프트 추가
- `Projects/Infrastructure/AIServiceInfra/Sources/Services/` — `PersonalizedRecommendationService` 신규
- `Projects/Feature/Home/Domain/Sources/Entities/` — `PersonalizedRecommendation` 엔티티
- `Projects/Feature/Home/Presentation/Sources/HomeView.swift` — 추천 카드 UI
- `Projects/Feature/Home/Presentation/Sources/HomeFeature.swift` — 추천 로드 Action

**의존성**: Gemini API Free Tier 토큰 한도 고려 필요

---

### D-2. 식단 패턴 분석

**현재 상태**: 주간/월간 리포트에 평균 칼로리/매크로만 표시
**목표**: "주로 탄수화물 위주", "저녁에 과식 경향", "주말 칼로리 초과" 등 패턴 인사이트

**구현 방향**:
- 30일 식사 데이터를 분석하여 패턴 추출
- 식사 시간대별, 요일별, 매크로 비율별 분석
- Gemini API 또는 로컬 계산 (간단한 패턴은 로컬, 복잡한 인사이트는 AI)

**수정 파일**:
- `Projects/Feature/Home/Domain/Sources/Entities/` — `DietPattern` 엔티티
- `Projects/Feature/Home/Presentation/Sources/ReportView.swift` — 패턴 섹션 추가
- `Projects/Feature/Home/Data/Sources/` — 패턴 분석 서비스

**의존성**: D-1과 프롬프트 구조 공유 가능

---

### D-3. 목표 달성 예측

**현재 상태**: 현재 체중과 목표 체중 차이만 표시
**목표**: "현재 추세 유지 시 목표 달성 예상: 2026년 5월 15일"

**구현 방향**:
- 체중 변화 추세 + 칼로리 섭취/소모 패턴 통합 분석
- 선형 회귀 또는 이동 평균 기반 예측
- Weight 모듈의 C-1과 연계 (C-1은 단순 계산, D-3는 AI 보강)

**수정 파일**:
- `Projects/Feature/Home/Presentation/Sources/ReportView.swift` — 예측 섹션
- `Projects/Infrastructure/AIServiceInfra/Sources/Services/` — 예측 서비스
- `Projects/Feature/Home/Domain/Sources/Entities/` — `GoalPrediction` 엔티티

**의존성**: C-1 (Weight 예상 날짜)과 데이터 공유

---

## 6. 구현 순서 권장

```
Phase 1: Package A (Quick Wins) — 6개, 낮음 난이도
  A-1 → A-3 → A-2 (Exercise 관련, 순서 의존)
  A-4, A-5, A-6 (독립, 병렬 가능)

Phase 2: Package B + C (Exercise + Weight 고도화) — 6개, 중간 난이도
  B-1 (차트, A-1 의존)
  B-2, B-3 (독립)
  C-1, C-2, C-3 (독립, 병렬 가능)

Phase 3: Package D (AI 고도화) — 3개, 중간~높음 난이도
  D-1 → D-2 → D-3 (프롬프트 구조 공유, 순차 권장)
```

---

## 7. 검증 방법

1. `tuist generate` 성공
2. `xcodebuild` 빌드 성공 (코드 사이닝 없이)
3. 각 기능별 동작 검증:
   - Exercise 기간 선택: Picker 변경 → 목록 갱신
   - Exercise 차트: 바 차트 표시 + 기간별 데이터 반영
   - Weight 프로그레스: 시작/현재/목표 바 표시
   - Weight 예상 날짜: 추세 기반 날짜 계산 정확성
   - Home 순 칼로리: 섭취 - 소모 = 순 잔여 계산 정확성
   - AI 추천: Gemini API 호출 → 개인화 결과 표시
4. 문서 업데이트 (ROADMAP.md, WORKPLAN.md, MODULES.md)

---

## 8. 코드 분석에서 발견된 추가 기회

> 에이전트 분석 (2026-03-26) 결과, 기존 코드에서 미활용 인프라와 추가 개선점을 발견했습니다.

### Exercise 모듈 추가 발견

| # | 발견 사항 | 난이도 | 설명 |
|---|----------|--------|------|
| E-8 | `fetchExercises` (단일 날짜) 미사용 | — | DIContainer에 와이어링되었으나 Reducer에서 호출 안 함. 캘린더 연동 시 활용 가능 |
| E-9 | CustomExercise `iconName` 미활용 | 낮음 | 엔티티에 SF Symbol 아이콘 필드 있으나 UI에서 선택 불가, RecordView에서 category.icon fallback |
| E-10 | CustomExercise 수정 불가 | 중간 | 생성/삭제만 가능, `updateCustomExercise` UseCase 필요 |
| E-11 | 운동 날짜 백데이팅 불가 | 낮음 | `ExerciseRecord.date`가 생성 시점 고정, DatePicker 추가로 해결 가능 |
| E-12 | 미사용 로컬라이제이션 3개 | — | `exercise.intensity.low/medium/high` 키가 코드에서 미사용 (light/moderate/vigorous 사용) |
| E-13 | 접근성 하드코딩 | 낮음 | ExerciseListView에서 `"kcal"` 하드코딩 → `"unit.kcal".localized` 필요 |

### Weight 모듈 추가 발견

| # | 발견 사항 | 난이도 | 설명 |
|---|----------|--------|------|
| W-8 | `bodyFatPercentage` State에 있으나 UI 없음 | 낮음 | WeightFeature.State에 필드 존재, WeightView에 입력 슬라이더 미구현 |
| W-9 | `updateWeight`/`deleteWeight` Repository 구현 완료 | 중간 | Repository에 메서드 있으나 UseCase 미래핑, Client 미노출 |
| W-10 | `weight.highest/lowest/average` 로컬라이제이션 미사용 | 낮음 | 키 정의되어 있으나 StatBox에서 미표시 |
| W-11 | HealthKit 체중 읽기 미구현 | 중간 | `getWeights(limit:)` 메서드에서 HealthKit 병합 로직 미구현 (Phase S에서 "HealthKit 미병합" 수정되었으나 재확인 필요) |

### Home 모듈 추가 발견

| # | 발견 사항 | 난이도 | 설명 |
|---|----------|--------|------|
| H-5 | `reportError` 미표시 | 낮음 | State에 저장되나 UI에서 표시 안 함 |
| H-6 | MonthlyReport에 `totalExerciseCalories` 누락 | 낮음 | WeeklyReport에는 있으나 Monthly에 없음 |
| H-7 | 일부 리포트 로컬라이제이션 키 누락 | 낮음 | `report.days`, `report.times` 등 HomeDomain strings에 미정의 (BaseDomain 확인 필요) |

### Profile 모듈 추가 발견

| # | 발견 사항 | 난이도 | 설명 |
|---|----------|--------|------|
| P-6 | ProfileFeature에 delegate Action 없음 | 낮음 | 저장 후 네비게이션 (pop) 등의 제어 불가 |
| P-7 | `dailyCalorieGoal` 수동 설정 UI 없음 | 낮음 | `effectiveDailyCalorieGoal`은 계산값만 사용, 직접 입력 불가 |
| P-8 | MacroGoals 커스터마이징 UI 없음 | 중간 | `MacroGoals`가 `.default` (P100/C250/F70) 고정, 프로필에서 조정 불가 |

---

## 9. 우선순위 재평가 (코드 분석 반영)

### 최우선 (기존 인프라 활용, UI만 추가)

| 항목 | 이유 |
|------|------|
| W-8 체지방률 입력 UI | State 필드 있음, 슬라이더만 추가 |
| W-10 최고/최저/평균 StatBox | 로컬라이제이션 키 있음, 계산만 추가 |
| E-13 접근성 하드코딩 수정 | 1줄 수정 |
| H-5 reportError UI 표시 | State 있음, Alert만 추가 |

### 고가치 (기존 Repository 활용)

| 항목 | 이유 |
|------|------|
| W-9 체중 기록 편집/삭제 | Repository 이미 구현, UseCase + Client + UI만 추가 |
| P-7 칼로리 목표 수동 설정 | UserProfile에 `dailyCalorieGoal` 필드 있음, Stepper UI만 추가 |
