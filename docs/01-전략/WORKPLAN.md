---
title: "작업 계획서"
aliases: ["워크플랜"]
tags:
  - 전략
  - 전략/계획
created: 2026-01-26
updated: 2026-03-11
status: active
---

# SimpleCare 작업 계획서

> 작성일: 2026-01-26
> 최종 수정일: 2026-03-05
> 기반 문서: PRD.md, 코드베이스 분석

---

## 1. 프로젝트 개요

### 1.1 제품 목표
| 항목 | 내용 |
|------|------|
| **제품명** | SimpleCare - AI 기반 개인 건강 관리 앱 |
| **핵심 가치** | 간편함, 지능형, 시각화, 개인화 |
| **타겟 사용자** | 체중 관리를 원하는 20-40대 성인 |

### 1.2 기술 스택
| 분류 | 기술 | 상태 |
|------|------|------|
| 플랫폼 | iOS 18.0+ | ✅ |
| UI | SwiftUI | ✅ |
| 아키텍처 | Clean Architecture + TCA | ✅ 리팩토링 완료 |
| 상태 관리 | The Composable Architecture | ✅ |
| AI | OpenAI GPT-4o | ✅ 인프라 구현됨 |
| 데이터 저장 | SwiftData | ✅ |
| 차트 | Swift Charts | ✅ |
| 빌드 | Tuist | ✅ |
| CI/CD | Fastlane | ✅ |

---

## 2. 현재 구현 현황

### 2.1 Feature 구현 상태

| Feature | TCA Reducer | View | DIContainer | Client 연결 |
|---------|-------------|------|-------------|-------------|
| Splash | ✅ | ✅ | ✅ | ✅ |
| Onboarding | ✅ | ✅ | ✅ | ✅ |
| Home | ✅ | ✅ | ✅ | ✅ |
| Meal | ✅ | ✅ | ✅ | ✅ |
| Exercise | ✅ | ✅ | ✅ | ✅ |
| Weight | ✅ | ✅ | ✅ | ✅ |
| Profile | ✅ | ✅ | ✅ | ✅ |

> **Note**: 기존 Dashboard 모듈은 Home 모듈로 대체되었습니다.

### 2.2 DIContainer ↔ TCA Client 연결 완료

```
현재 상태:
DIContainer → UseCase (구현됨) → Repository (구현됨) → Storage (구현됨)
                ↓
         TCA Client (실제 구현체 연결 ✅)
```

모든 Feature의 DIContainer가 실제 UseCase/Repository/Storage와 연결 완료됨.

### 2.3 알려진 개선 사항 (Gap) - ✅ 모두 해결

| # | 이슈 | 상태 | 해결 방법 |
|---|------|------|----------|
| G1 | ExerciseClient 조회 메서드 미노출 | ✅ | `fetchExercises` 클로저 추가 및 UseCase 연결 |
| G2 | MealClient 히스토리 메서드 미노출 | ✅ | `fetchDailyMeals`, `fetchMealHistory` 클로저 추가 |
| G3 | 영양소 목표 하드코딩 | ✅ | `MacroGoals` 구조체로 UserProfile 기반 전달 |
| G4 | TabDIContainer 프로필 fetch race condition | ✅ | `ensureProfileLoaded()` + `isReady` 게이트 패턴 |
| G5 | analyzeImage 불필요한 API 호출 | ✅ | 미사용 `chatCompletion` 호출 제거 |

---

## 3. 완료된 기능 상세

### 3.1 Home AI 인사이트 ✅

| 컴포넌트 | 파일 | 상태 |
|----------|------|------|
| HomeFeature | `HomeFeature.swift` | ✅ getDailySummary + generateInsight 연결 |
| HomeInsightService | `HomeInsightService.swift` | ✅ DailyInsightService 연동 |
| HomeDIContainer | `HomeDIContainer.swift` | ✅ UseCase → Client 완전 연결 |

### 3.2 Meal 영양 추정 ✅

| 컴포넌트 | 파일 | 상태 |
|----------|------|------|
| MealFeature | `MealFeature.swift` | ✅ estimateNutrition + analyzeMealImage + recordMeal |
| AIService | `AIService.swift` | ✅ NutritionEstimationService 연동 |
| MealDIContainer | `MealDIContainer.swift` | ✅ UseCase 3개 모두 Client 연결 |

### 3.3 Weight 추세 그래프 ✅

| 컴포넌트 | 파일 | 상태 |
|----------|------|------|
| WeightFeature | `WeightFeature.swift` | ✅ recordWeight + getWeightTrend |
| WeightDIContainer | `WeightDIContainer.swift` | ✅ UseCase → Client 연결 |

### 3.4 Exercise 기록 ✅

| 컴포넌트 | 파일 | 상태 |
|----------|------|------|
| ExerciseFeature | `ExerciseFeature.swift` | ✅ recordExercise (칼로리 계산은 Entity 내부) |
| ExerciseDIContainer | `ExerciseDIContainer.swift` | ✅ UseCase → Client 연결 |

### 3.5 Profile 관리 ✅

| 컴포넌트 | 파일 | 상태 |
|----------|------|------|
| ProfileFeature | `ProfileFeature.swift` | ✅ getProfile + saveProfile + updateProfile |
| ProfileDIContainer | `ProfileDIContainer.swift` | ✅ UseCase 3개 모두 Client 연결 |

---

## 4. 우선순위 기반 작업 계획

### ~~Phase 0: 기반 연결 (Critical)~~ ✅ 완료

> DIContainer와 TCA Client 연결 - 모든 기능의 기반

| 순서 | 작업 | 상태 |
|------|------|------|
| 0.1 | HomeDIContainer - Client 연결 | ✅ 완료 |
| 0.2 | MealDIContainer - Client 연결 | ✅ 완료 |
| 0.3 | WeightDIContainer - Client 연결 | ✅ 완료 |
| 0.4 | ExerciseDIContainer - Client 연결 | ✅ 완료 |
| 0.5 | ProfileDIContainer - Client 연결 | ✅ 완료 |

### ~~Phase L: 다국어 지원~~ ✅ 완료

> 한국어(기본), 영어 지원 - 글로벌 출시 필수 요건

| 순서 | 작업 | 예상 복잡도 | 상태 |
|------|------|------------|------|
| L.1 | Localizable.strings 기반 구축 | 중간 | ✅ 완료 |
| L.2 | 기존 하드코딩 문자열 → Localizable.strings 이동 | 높음 | ✅ 완료 |
| L.3 | 시스템 언어 자동 감지 및 적용 | 낮음 | ✅ 완료 |
| L.4 | Settings 런타임 언어 변경 옵션 | 중간 | ✅ 완료 |

**구현 내역**:
- 모듈별 Localizable.strings 분리 (9개 Feature 모듈)
- LocalizationBundleRegistry: 모듈 Bundle 관리
- LocalizationManager: 런타임 언어 변경 지원
- Settings 화면에서 언어 선택 UI (시스템/한국어/English)
- 앱 재시작 없이 UI 즉시 반영

**완료 조건** ✅:
- 모든 사용자 표시 문자열이 Localizable.strings로 관리됨
- 한국어/영어 전환 시 UI 전체 반영

### Phase 1: AI 기능 활성화 🟡

> PR [#29](https://github.com/wnsgur9137/SimpleCare/pull/29) (텍스트 기반 Mock 모드)

| 순서 | 작업 | 의존성 | 상태 |
|------|------|--------|------|
| 1.1 | Home AI 인사이트 표시 | Phase 0 ✅ | ✅ Mock 서비스 연결 |
| 1.2 | Meal 텍스트 기반 영양 추정 | Phase 0 ✅ | ✅ Mock 서비스 연결 |
| 1.3 | 실제 OpenAI API 연동 | 1.1~1.2 | 🔴 Mock → Real 전환 |

**현재 상태**: Mock 모드로 텍스트 기반 기능 활성화 완료
**남은 작업**: 실제 API 전환 (이미지 분석은 Phase 5로 이동)

### ~~Phase 1.5: 알려진 Gap 수정~~ ✅ 완료

> PR [#26](https://github.com/wnsgur9137/SimpleCare/pull/26)

| 순서 | 작업 | 관련 Gap | 상태 |
|------|------|----------|------|
| 1.5.1 | 영양소 목표를 UserProfile에서 계산하여 전달 | G3 | ✅ 완료 |
| 1.5.2 | TabDIContainer 프로필 fetch 보장 | G4 | ✅ 완료 |
| 1.5.3 | analyzeImage 불필요 API 호출 제거 | G5 | ✅ 완료 |
| 1.5.4 | ExerciseClient에 조회 메서드 추가 | G1 | ✅ 완료 |
| 1.5.5 | MealClient에 히스토리 메서드 추가 | G2 | ✅ 완료 |

### ~~Phase 2: 홈 화면 개선 및 데이터 시각화~~ ✅ 완료

> 상세 계획: [HOME_SCREEN_PLAN.md](./HOME_SCREEN_PLAN.md)

| 순서 | 작업 | 상태 |
|------|------|------|
| 2.1 | 빠른 기록 버튼 (식사/운동/체중) | ✅ UI 구현 + 네비게이션 연결 |
| 2.2 | 오늘의 기록 목록 섹션 | ✅ 구현 완료 |
| 2.3 | 영양소 프로그레스 바 개선 | ✅ 구현 완료 |
| 2.4 | 스트릭 배지 (연속 기록일) | ✅ 구현 완료 |
| 2.5 | Weight 차트 목표선 (RuleMark) 추가 | ✅ 점선 RuleMark 추가 |
| 2.6 | Weight 기간 선택 (7일/30일/90일) | ✅ Segmented Picker 추가 |
| 2.7 | 주간 트렌드 섹션 | ✅ UI 구현 + 데이터 연결 |

### ~~Phase 3: 확장 기능 (PRD 예정 항목)~~ ✅ 완료

> PR [#28](https://github.com/wnsgur9137/SimpleCare/pull/28)

| 순서 | 작업 | PRD 참조 | 상태 |
|------|------|----------|------|
| 3.1 | 즐겨찾기 음식 저장/불러오기 | §3.2.4 | ✅ 완료 |
| 3.2 | 최근 기록 빠른 추가 | §3.2.4 | ✅ 완료 |
| 3.3 | 커스텀 운동 추가 | §3.2.5 | ✅ 완료 |
| 3.4 | 주간/월간 리포트 | §3.2.6 | ✅ 완료 |
| 3.5 | BMI 계산 및 표시 | §3.2.6 | ✅ 완료 |

### Phase 4: 연동 및 부가 기능 ✅ 완료

| 순서 | 작업 | PRD 참조 | 예상 복잡도 | 상태 |
|------|------|----------|------------|------|
| 4.1 | HealthKitInfra 구현 | §4.3 | 높음 | ✅ 완료 |
| 4.2 | 걸음수/활동 칼로리 연동 | §4.3 | 중간 | ✅ 완료 |
| 4.3 | 알림/리마인더 설정 | §3.2.8 | 중간 | ✅ 완료 |
| 4.4 | 데이터 내보내기 (CSV/JSON) | §3.2.7 | 중간 | ✅ PR #48 |
| 4.5 | 데이터 삭제/초기화 | §3.2.7 | 낮음 | ✅ PR #48 |
| 4.6 | 테마 설정 (다크/라이트) | §3.2.8 | 낮음 | ✅ 완료 |

**4.1 구현 내역** (PR [#34](https://github.com/wnsgur9137/SimpleCare/pull/34)):
- HealthKitInfra 모듈 생성 (Tuist framework)
- HealthKitDataType: stepCount, activeEnergy, bodyMass 타입 정의
- HealthKitManager: 권한 요청, 걸음수/활동 칼로리 조회, 체중 읽기/쓰기
- HealthKitManagerProtocol 추출 (DI/테스트 가능성)
- SimpleCare.entitlements HealthKit capability 추가
- NSHealthShareUsageDescription, NSHealthUpdateUsageDescription Info.plist 키 추가

**4.2 구현 내역** (PR [#42](https://github.com/wnsgur9137/SimpleCare/pull/42)):
- HomeFeature에 HealthKit 걸음수/활동 칼로리 연동
- 홈 화면에 걸음수 및 활동 칼로리 표시 UI 추가
- HealthKitManager를 통한 실시간 데이터 조회

**4.3 구현 내역** (PR [#43](https://github.com/wnsgur9137/SimpleCare/pull/43)):
- NotificationManager 싱글톤: 5개 카테고리별 알림 관리
- NotificationCategory: breakfast, lunch, dinner, exercise, weight
- NotificationSetting: isEnabled, hour, minute 저장
- UNUserNotificationCenter 연동: 로컬 알림 스케줄링
- UserDefaults JSON 인코딩 저장
- Settings 화면: 알림 권한 요청, 카테고리별 토글/시간 설정
- NotificationEnableBanner: 식사/운동/체중 탭에서 알림 활성화 유도
- 홈 화면 진입 시 알림 권한 요청

**4.6 구현 내역**:
- ThemeManager: 테마 상태 관리 (system/light/dark)
- Settings 테마 선택 UI (아이콘 + 체크마크)
- 앱 전역 preferredColorScheme 적용
- UserDefaults 저장으로 설정 유지

### Phase 5: 식사/운동 상세 페이지 ✅ 완료

> PR [#45](https://github.com/wnsgur9137/SimpleCare/pull/45) (Detail), PR [#46](https://github.com/wnsgur9137/SimpleCare/pull/46) (MealList), PR [#47](https://github.com/wnsgur9137/SimpleCare/pull/47) (ExerciseList)

| 순서 | 작업 | 예상 복잡도 | 상태 |
|------|------|------------|------|
| 5.0 | MealListFeature/MealListView 구현 | 중간 | ✅ 완료 |
| 5.1 | MealClient/ExerciseClient 확장 (delete, update, fetch) | 중간 | ✅ 완료 |
| 5.2 | MealDetailFeature TCA Reducer 구현 | 중간 | ✅ 완료 |
| 5.3 | MealDetailView UI 구현 | 중간 | ✅ 완료 |
| 5.4 | ExerciseDetailFeature TCA Reducer 구현 | 중간 | ✅ 완료 |
| 5.5 | ExerciseDetailView UI 구현 | 중간 | ✅ 완료 |
| 5.6 | 홈에서 상세 페이지 네비게이션 연결 | 낮음 | ✅ 완료 |
| 5.7 | 상세 페이지 로컬라이제이션 추가 | 낮음 | ✅ 완료 |
| 5.8 | 캘린더에서 상세 페이지 네비게이션 연결 | 낮음 | ✅ PR #49 |
| 5.9 | ExerciseListFeature/ExerciseListView 구현 | 중간 | ✅ 완료 |

**구현 내역**:
- MealDetailFeature/View: 영양소 요약, 음식 목록, 편집/삭제 기능
- ExerciseDetailFeature/View: 운동 정보, 강도/시간 편집, 삭제 기능
- 홈 화면에서 식사/운동 기록 탭 → 상세 페이지 이동
- MealClient: updateMeal, deleteMeal, fetchMeal 추가
- ExerciseClient: updateExercise, deleteExercise, fetchExercise 추가
- DIContainer 업데이트 (UseCase 연결)

### Phase 6: 이미지/음성 기능 (최후순위)

> 이미지 및 음성 관련 기능은 최후순위로 배치

| 순서 | 작업 | PRD 참조 | 예상 복잡도 |
|------|------|----------|------------|
| 6.1 | Meal 이미지 선택 UI (PhotosPicker) | §3.2.3 | 중간 |
| 6.2 | Meal 이미지 분석 결과 표시 | §3.2.3 | 중간 |
| 6.3 | 이미지 기반 음식 인식 | §3.2.3 | 높음 |

**완료 조건**:
- Meal에서 사진 촬영/선택 → AI 분석 → 영양소 표시

---

## 5. 기술적 리스크 및 완화 방안

| 리스크 | 영향도 | 발생 확률 | 완화 방안 |
|--------|--------|----------|----------|
| OpenAI API 비용 증가 | 높음 | 중간 | GPT-4o-mini 사용, 응답 캐싱, Rate limiting |
| Vision API 응답 지연 | 중간 | 높음 | 로딩 UI, 5초 타임아웃, 재시도 로직 |
| SwiftData 마이그레이션 | 중간 | 낮음 | 스키마 버전 관리, 마이그레이션 플랜 |
| HealthKit 권한 거부 | 중간 | 중간 | 독립 기능 보장, 권한 재요청 UI |
| TCA 의존성 복잡도 | 낮음 | 낮음 | DIContainer 패턴, 명확한 의존성 그래프 |

---

## 6. 제약 조건 체크리스트

| 요구사항 | 기준 | 현재 상태 | 액션 |
|----------|------|----------|------|
| 앱 시작 시간 | 2초 이내 (Splash 제외) | ⚠️ 미측정 | 성능 프로파일링 필요 |
| AI 응답 시간 | 5초 이내 | ✅ 타임아웃 구현됨 | - |
| API Key 보안 | Git 제외 | ✅ XCConfig + gitignore | - |
| VoiceOver | 모든 UI 접근 가능 | ⚠️ 미검증 | 접근성 레이블 검토 |
| Dynamic Type | 텍스트 크기 조절 | ⚠️ 미검증 | 폰트 스케일링 검토 |
| 색상 대비 | WCAG 2.1 AA | ⚠️ 미검증 | 색상 대비 검사 |

---

## 7. 즉시 실행 권장 작업

### 최고 ROI 작업: Phase 1.3 (실제 OpenAI API 연동)

**완료된 우선순위 작업**:
- ~~**Phase L (다국어 지원)**~~: ✅ 완료
- ~~**Phase 4.1-4.2 (HealthKit 연동)**~~: ✅ 완료
- ~~**Phase 4.6 (테마 설정)**~~: ✅ 완료
- ~~**Phase 4.3 (알림/리마인더 설정)**~~: ✅ 완료
- ~~**Phase 4.4-4.5 (데이터 내보내기/삭제)**~~: ✅ 완료 (PR #48)
- ~~**Phase 5.8 (캘린더 네비게이션)**~~: ✅ 완료 (PR #49)

**권장 순서**:
1. ~~**Phase L: 다국어 지원**~~ ✅ 완료
2. ~~**Phase 4.1: HealthKitInfra 구현**~~ ✅ 완료
3. ~~**Phase 4.2: 걸음수/활동 칼로리 연동**~~ ✅ 완료
4. ~~**Phase 4.6: 테마 설정**~~ ✅ 완료
5. ~~**Phase 4.3: 알림/리마인더 설정**~~ ✅ 완료
6. ~~**Phase 5: 식사/운동 상세 페이지**~~ ✅ 완료
7. ~~**Phase 4.4-4.5: 데이터 내보내기/삭제**~~ ✅ 완료
8. **Phase 1.3: 실제 OpenAI API 연동** ← 🟡 다음 작업
9. Phase 6: 이미지/음성 기능 (최후순위)

**Phase 1 완료 시 사용자 경험**:
- Home에서 개인화된 AI 건강 코멘트 확인
- 정확한 영양소 목표 대비 진행률 표시

---

## 8. 마일스톤

### MVP (v1.0) - PRD §7.1
- [x] Phase 0 완료 (DIContainer 연결)
- [ ] 기본 데이터 흐름 검증
- [ ] 핵심 기능 E2E 테스트

### v1.1 - PRD §7.2
- [x] Phase 1 텍스트 기반 AI 기능 (Mock 모드)
- [ ] Phase 1 이미지 분석 + 실제 API 연동 (→ Phase 5로 이동)
- [x] Phase 1.5 완료 (Gap 수정)
- [x] Phase 2 완료 (홈 화면 개선)
- [x] Phase L 완료 (다국어 지원)

### v1.2 - PRD §7.3
- [x] Phase 3 완료 (즐겨찾기/최근 기록/커스텀 운동/리포트/BMI)
- [x] Phase 4.1 완료 (HealthKitInfra)
- [x] Phase 4.2 완료 (HealthKit Feature 연동)
- [x] Phase 4.6 완료 (테마 설정)
- [x] Phase 4.3 완료 (알림)

### v1.3
- [x] Phase 5 완료 (식사/운동 상세 페이지)
- [x] Phase 4.4-4.5 완료 (데이터 내보내기/삭제) - PR #48
- [x] Phase 5.8 완료 (캘린더 네비게이션) - PR #49

### v2.0 - PRD §7.4
- [ ] Phase 6 완료 (이미지/음성 기능)
- [ ] Widget / Live Activity
- [ ] AI 맞춤 추천
- [ ] 전체 Phase 완료

---

## 부록: 관련 파일 경로

### Feature DIContainers
```
Projects/Feature/Home/Sources/HomeDIContainer.swift
Projects/Feature/Meal/Sources/MealDIContainer.swift
Projects/Feature/Weight/Sources/WeightDIContainer.swift
Projects/Feature/Exercise/Sources/ExerciseDIContainer.swift
Projects/Feature/Profile/Sources/ProfileDIContainer.swift
```

### TCA Features
```
Projects/Feature/Home/Presentation/Sources/HomeFeature.swift
Projects/Feature/Meal/Presentation/Sources/MealFeature.swift
Projects/Feature/Weight/Presentation/Sources/WeightFeature.swift
Projects/Feature/Exercise/Presentation/Sources/ExerciseFeature.swift
Projects/Feature/Profile/Presentation/Sources/ProfileFeature.swift
```

### Infrastructure
```
Projects/Infrastructure/AIServiceInfra/Sources/Services/DailyInsightService.swift
Projects/Infrastructure/AIServiceInfra/Sources/Services/NutritionEstimationService.swift
Projects/Infrastructure/StorageInfra/Sources/StorageContainer.swift
Projects/Infrastructure/HealthKitInfra/Sources/HealthKitManager.swift
Projects/Infrastructure/HealthKitInfra/Sources/HealthKitDataType.swift
```

### Tab Coordinator
```
Projects/Feature/Features/Sources/TabDIContainer.swift
```

---

*문서 버전: 3.3*
*최종 수정일: 2026-03-03*
