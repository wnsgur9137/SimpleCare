---
title: "개발 로드맵"
aliases: ["로드맵"]
tags:
  - 전략
  - 전략/로드맵
created: 2026-01-26
updated: 2026-03-17
review-date: 2026-03-16
status: active
---

# SimpleCare 개발 로드맵

## 목차
1. [Phase L: 다국어 지원 (최우선순위)](#phase-l-다국어-지원-최우선순위)
2. [Phase 1: 기반 구축](#phase-1-기반-구축)
3. [Phase 2: 핵심 기능](#phase-2-핵심-기능)
4. [Phase 3: 확장 기능](#phase-3-확장-기능)
5. [Phase 4: 연동 및 부가 기능](#phase-4-연동-및-부가-기능)
6. [Phase 5: 식사/운동 상세 페이지](#phase-5-식사운동-상세-페이지-)
7. [Phase S: 안정성 및 보안 강화](#phase-s-안정성-및-보안-강화-)
8. [Phase 6: 이미지/음성 기능 (최후순위)](#phase-6-이미지음성-기능-최후순위)
9. [구현 상태](#구현-상태)

---

## Phase L: 다국어 지원 (최우선순위) ✅

### 목표
한국어(기본), 영어 지원 - 글로벌 출시 필수 요건

### 작업 목록

#### Localization 기반 구축
- [x] Localizable.strings 파일 생성 (ko, en)
- [x] String Catalog 또는 기존 방식 선택
- [x] 공통 문자열 키 네이밍 규칙 정의

#### 기존 문자열 마이그레이션
- [x] 모든 Feature 모듈 하드코딩 문자열 추출
- [x] Localizable.strings로 이동
- [x] NSLocalizedString 또는 String(localized:) 적용

#### 시스템 언어 연동
- [x] Bundle.main.preferredLocalizations 기반 자동 감지
- [x] 앱 시작 시 시스템 언어 적용

#### 런타임 언어 변경
- [x] Settings 화면 언어 선택 UI
- [x] UserDefaults 기반 언어 설정 저장
- [x] 앱 전체 UI 즉시 반영 (재시작 불필요 권장)

---

## Phase 1: 기반 구축

### 목표
프로젝트 인프라 및 사용자 기본 설정 기능 구현

### 작업 목록

#### Infrastructure
- [x] Tuist 프로젝트 구조 설정
- [x] StorageInfra (SwiftData) 구현
  - [x] StorageContainer 싱글톤
  - [x] UserProfileModel
  - [x] UserProfileStorage
- [x] NetworkInfra 기본 구조

#### Profile Feature
- [x] Domain Layer
  - [x] UserProfile Entity
  - [x] Gender, ActivityLevel, GoalType Enum
  - [x] UserProfileRepositoryProtocol
  - [x] SaveUserProfileUseCase
  - [x] GetUserProfileUseCase
- [x] Data Layer
  - [x] UserProfileRepository
- [x] Presentation Layer
  - [x] ProfileViewModel
  - [x] ProfileView
  - [x] ProfileCoordinator
  - [x] ProfileDIContainer

#### Onboarding Feature
- [x] Presentation Layer
  - [x] OnboardingViewModel
  - [x] OnboardingView (단계별 입력)
  - [x] OnboardingCoordinator
  - [x] OnboardingDIContainer

#### Base Feature
- [x] Coordinator 프로토콜
- [x] DIContainer 프로토콜

---

## Phase 2: 핵심 기능

### 목표
식단 기록 및 AI 영양 분석, 대시보드 구현

### 작업 목록

#### AIServiceInfra
- [x] Google Gemini API 클라이언트
- [x] NutritionEstimationService
- [x] ImageAnalysisService
- [x] API Key 관리 (XCConfig)

#### Meal Feature
- [x] Domain Layer
  - [x] MealRecord, FoodItem Entity
  - [x] MealType, EstimatedFoodItem
  - [x] MealRepositoryProtocol
  - [x] EstimateMealNutritionUseCase
  - [x] AnalyzeMealImageUseCase
  - [x] RecordMealUseCase
- [x] Data Layer
  - [x] MealRepository
  - [x] MealRecordModel (SwiftData)
  - [x] FoodItemModel (SwiftData)
  - [x] MealStorage
- [x] Presentation Layer
  - [x] MealRecordViewModel
  - [x] MealRecordView
  - [x] MealCoordinator
  - [x] MealDIContainer

#### Dashboard Feature
- [x] Domain Layer
  - [x] DailySummary Entity
  - [x] NutritionSummary Entity
  - [x] DashboardRepositoryProtocol
  - [x] GetDailySummaryUseCase
- [x] Data Layer
  - [x] DashboardRepository
- [x] Presentation Layer
  - [x] DashboardViewModel
  - [x] DashboardView
  - [x] 칼로리/영양소 차트 (Swift Charts)
  - [x] DashboardCoordinator
  - [x] DashboardDIContainer

---

## Phase 3: 확장 기능

### 목표
운동 기록 및 체중 관리 기능 구현

### 작업 목록

#### Exercise Feature
- [x] Domain Layer
  - [x] ExerciseRecord Entity
  - [x] ExerciseType, ExerciseCategory
  - [x] ExerciseIntensity
  - [x] ExerciseRepositoryProtocol
  - [x] RecordExerciseUseCase
  - [x] EstimateCalorieBurnUseCase
- [x] Data Layer
  - [x] ExerciseRepository
  - [x] ExerciseRecordModel (SwiftData)
  - [x] ExerciseStorage
- [x] Presentation Layer
  - [x] ExerciseRecordViewModel
  - [x] ExerciseRecordView
  - [x] ExerciseCoordinator
  - [x] ExerciseDIContainer

#### Weight Feature
- [x] Domain Layer
  - [x] WeightRecord Entity
  - [x] WeightRepositoryProtocol
  - [x] RecordWeightUseCase
  - [x] GetWeightHistoryUseCase
  - [x] CalculateBMRUseCase
  - [x] CalculateTDEEUseCase
- [x] Data Layer
  - [x] WeightRepository
  - [x] WeightRecordModel (SwiftData)
  - [x] WeightStorage
- [x] Presentation Layer
  - [x] WeightRecordViewModel
  - [x] WeightRecordView
  - [x] 체중 추세 차트 (Swift Charts)
  - [x] WeightCoordinator
  - [x] WeightDIContainer

---

## Phase 4: 연동 및 부가 기능

### 목표
HealthKit 연동, 알림, 위젯 등 부가 기능 구현

### 작업 목록

#### HealthKitInfra
- [x] HealthKit 권한 요청
- [x] 걸음수 읽기
- [x] 활동 칼로리 읽기
- [x] 체중 데이터 동기화

#### Notification Feature
- [x] 리마인더 알림 설정
- [x] 로컬 알림 스케줄링
- [x] 식사/운동 기록 알림

#### Widget
- [ ] 일일 칼로리 요약 위젯
- [ ] 목표 달성률 위젯

#### Settings 완성
- [x] 데이터 내보내기 (CSV/JSON)
- [x] 데이터 삭제
- [x] 알림 설정
- [x] 테마 설정

#### AI 고도화
- [ ] 개인화된 추천 기능
- [ ] 식단 패턴 분석
- [ ] 목표 달성 예측

---

## Phase 5: 식사/운동 상세 페이지 ✅

### 목표
기록된 식사/운동 데이터 상세 보기 및 편집 기능 구현

### 작업 목록

#### MealList 화면
- [x] MealListFeature TCA Reducer 구현 (WIP)
- [x] MealListView UI 구현 (WIP)
- [x] MealCoordinator 네비게이션 연결
- [x] TabCoordinator 식사 탭 연동
- [x] 로컬라이제이션 추가 (ko/en)
- [x] 날짜별 섹션 헤더 UI/UX 개선 (상대 날짜, 일일 칼로리/매크로 요약)
- [x] MealRowView 개선 (식사 시간 표시, 개별 매크로 표시)

#### MealDetail 화면
- [x] MealClient 확장 (delete, update, copy)
- [x] MealDetailFeature TCA Reducer 구현
- [x] MealDetailView UI 구현

#### ExerciseDetail 화면
- [x] ExerciseClient 확장 (delete, update, copy)
- [x] ExerciseDetailFeature TCA Reducer 구현
- [x] ExerciseDetailView UI 구현

#### 공통
- [x] 캘린더/홈에서 상세 페이지 네비게이션 연결
- [x] 공통 컴포넌트 추출 (DetailHeaderView, SummaryCard)

---

## Phase S: 안정성 및 보안 강화 🔴

> 코드 품질 리뷰 (2026-03-16)에서 발견된 67개 이슈 기반. CRITICAL/HIGH 우선 수정.

### 목표
코드 리뷰에서 발견된 CRITICAL/HIGH 이슈 수정 및 보안 강화

### Sprint S.1: CRITICAL 버그 수정 (6건)

즉시 수정 — 데이터 손실, 크래시, 보안 문제

- [x] `StorageContainer` 스키마 마이그레이션 graceful fallback (`fatalError` 제거)
- [x] `GeminiClient` 에러 핸들링 catch 로직 버그 수정
- [x] `extractJSON` 파싱 범위 버그 수정 (`NutritionEstimation` + `DailyInsight`)
- [x] `MealClient.liveValue` 빈 스텁 → `unimplemented()` 적용
- [x] `ExerciseClient.liveValue` 빈 스텁 → `unimplemented()` 적용
- [x] `WeightClient.liveValue` 빈 스텁 → `unimplemented()` 적용

### Sprint S.2: HIGH 안정성 수정 (12건)

기능/데이터 관련 안정성 이슈

- [ ] `ForEach` id `\.element.name` → 중복 음식명 UI 버그 (`EstimatedFoodItem` `Identifiable`)
- [ ] `MealContainerView` `delegate(.saveCompleted)` 미연결
- [ ] `MealDIContainer` 매번 새 인스턴스 → 캐싱 적용
- [ ] `ExerciseDIContainer` 매번 새 repository 인스턴스 → 캐싱 적용
- [ ] `WeightDIContainer` 매번 새 인스턴스 → 캐싱 적용
- [ ] `ExerciseContainerView` `onSaveComplete` 미연결
- [ ] `WeightRepository` update/delete 100개 fetch 제한 → `fetchWeight(id:)` 추가
- [ ] Weight `getWeights(limit:)` HealthKit 미병합
- [ ] `ExerciseRecord` `updateModel` date/weight 미업데이트
- [ ] `ReportView` `dailyCalories[index]` 범위 초과 크래시 방어
- [ ] `HomeFeature` `selectWeekDay` 요일 계산 off-by-one 수정
- [ ] Report error가 Home `viewState` 덮어쓰기 → 별도 state 분리

### Sprint S.3: HIGH 보안 수정 (4건)

- [ ] ATS 활성화 (`NSAllowsArbitraryLoads: true` 제거)
- [ ] API 키 `Keychain` 저장 + `SwiftData` 파일 보호
- [ ] AI 프롬프트 입력 길이 제한 + 응답 값 검증
- [ ] 내보내기 임시 파일 보호 + 정리

### Sprint S.4: MEDIUM 품질 개선 (10건 선별)

- [ ] 한국어 하드코딩 → 로컬라이제이션 (`displayName` 등 전체)
- [ ] `Alert` `.constant()` binding → TCA `AlertState` 패턴
- [ ] `DateFormatter` 인라인 생성 → `static let` 캐싱
- [ ] `WeightTrend` `progressToGoal` 체중 증가 목표 미지원
- [ ] `HomeView` `NotificationManager` 사이드이펙트 → Reducer로 이동
- [ ] `MockHomeInsightService` → 실제 서비스 전환 확인
- [ ] `@unchecked Sendable` 정리 (Meal/Home/Exercise/Weight)
- [ ] `NutritionEstimation.totalCalories` 중복 필드 정리
- [ ] OpenAI 데드코드 제거
- [ ] `ExerciseListView`/`DetailView` `categoryColor` 불일치 수정

### Sprint S.5: LOW + 나머지 (추후)

LOW 14건 + 나머지 MEDIUM 10건은 관련 Feature 작업 시 함께 처리.
별도 Sprint로 추적하지 않고 "기술 부채" 섹션에 기록.

---

## Phase 6: 이미지/음성 기능 (최후순위)

### 목표
이미지 및 음성 기반 AI 기능 구현 (최후순위로 배치)

### 작업 목록

#### Meal 이미지 기능
- [ ] PhotosPicker UI 구현
- [ ] 이미지 분석 결과 표시 UI
- [ ] 이미지 기반 음식 인식
- [ ] 카메라 촬영 지원

#### 음성 기능 (추후 검토)
- [ ] 음성 입력 UI
- [ ] 음성 → 텍스트 변환
- [ ] 음성 기반 식사/운동 기록

---

## 구현 상태

### 모듈별 진행률

| 모듈 | 상태 | 진행률 |
|-----|------|-------|
| **Base** | 완료 | 100% |
| **Profile** | 완료 | 100% |
| **Onboarding** | 완료 | 100% |
| **Dashboard** | 완료 | 100% |
| **Meal** | 완료 | 100% |
| **Exercise** | 완료 | 100% |
| **Weight** | 완료 | 100% |
| **StorageInfra** | 완료 | 100% |
| **AIServiceInfra** | 완료 | 100% |
| **NetworkInfra** | 기본 완료 | 80% |
| **HealthKitInfra** | 완료 | 100% |
| **Notification** | 완료 | 100% |
| **Widget** | 미시작 | 0% |
| **Home** | 완료 | 100% |
| **Tab** | 완료 | 100% |
| **Calendar** | 완료 | 100% |
| **Settings** | 주요 기능 완료 | 80% |
| **Splash** | 완료 | 100% |

### 전체 진행률
```
Phase L: ████████████████████ 100% ✅
Phase 1: ████████████████████ 100%
Phase 2: ████████████████████ 100%
Phase 3: ████████████████████ 100%
Phase 4: ██████████████████░░  90%
Phase 5: ████████████████████ 100% ✅
Phase S: ░░░░░░░░░░░░░░░░░░░░   0% 🔴
---------------------------------
Total:   ████████████████░░░░  82%
```

---

## 우선순위 정의

| 우선순위 | 설명 | 포함 기능 |
|---------|------|----------|
| **P-L** | 최우선순위 | 다국어 지원 (한국어/영어) ✅ |
| **P0** | 필수 기능 | Dashboard, Meal, AI서비스 ✅ |
| **P1** | 핵심 기능 | Exercise, Weight, Profile ✅ |
| **P2** | 부가 기능 | HealthKit, Notification, Widget |
| **P3** | 상세 페이지 | 식사/운동 상세 보기, 편집/삭제 ✅ |
| **P-S** | 안정성/보안 | CRITICAL/HIGH 버그 수정, 보안 강화 (Phase 6 이전 필수) 🔴 |
| **P4** | 고도화 | AI 추천, 분석 |
| **P5** | 최후순위 | 이미지/음성 기능 |

---

## 기술 부채

### 해결된 이슈
1. ~~DIContainer가 Presentation 레이어에 위치~~ → **해결됨** (Feature 루트로 이동)
2. ~~Coordinator가 DIContainer 직접 의존~~ → **해결됨** (Delegate 패턴 적용)
3. Dashboard → Home 통합 완료
4. Splash 화면 구현 완료 (SplashCoordinator)

### 코드 리뷰 발견 이슈 (2026-03-16)

> 전체 67건 (CRITICAL 6, HIGH 22, MEDIUM 25, LOW 14)
> CRITICAL/HIGH는 Phase S에서 추적. 아래는 Phase S에 포함되지 않은 나머지 항목.

#### MEDIUM (Phase S.4 미포함 10건)
- ExerciseType MET 값 정확도 검증 필요
- Weight 차트 데이터 포인트 0건 시 빈 차트 UX
- Home 주간 트렌드 데이터 없음 시 placeholder 부재
- MealRecord foodItems 빈 배열 허용 (유효성 검증 없음)
- ExerciseRecord duration 음수 방어 없음
- StorageContainer 동시 접근 시 thread safety
- HealthKit 백그라운드 동기화 미구현
- Settings 데이터 삭제 확인 다이얼로그 UX 개선
- Coordinator 메모리 누수 가능성 (retain cycle 점검)
- NetworkInfra 재시도 로직 미구현

#### LOW (14건)
- 매직 넘버 상수화 (padding, spacing 등)
- 불필요한 import 정리
- 접근성(Accessibility) 레이블 누락
- 일부 View에서 하드코딩된 색상 → Asset Color 전환
- 코드 주석 보강 (복잡한 비즈니스 로직)
- SwiftLint 경고 해소 (미사용 변수 등)
- 테스트 코드 작성 (Unit/Integration)
- 에러 메시지 사용자 친화적 개선
- 다크모드 일부 컴포넌트 대비 부족
- 애니메이션 성능 최적화 (LazyVStack 등)
- Tuist 미사용 타겟 정리
- 빌드 시간 최적화 (모듈 의존성 정리)
- 로깅/디버깅 인프라 구축
- CI 파이프라인 테스트 자동화

### 리팩토링 계획
- [ ] 미사용 모듈 정리 (Settings 골격 상태)
- [ ] 테스트 코드 작성
- [ ] 에러 처리 고도화
- [ ] 접근성(Accessibility) 개선

---

## 검증 체크리스트

### 빌드 검증
```bash
# Tuist 프로젝트 생성 및 빌드
tuist generate && xcodebuild build

# 특정 Feature 모듈만 빌드
xcodebuild build -scheme Meal -destination 'platform=iOS Simulator,name=iPhone 16'
```

### 기능 검증
- [ ] 온보딩 플로우 완료
- [ ] 프로필 설정 저장/조회
- [ ] 식사 기록 (텍스트 입력)
- [ ] 식사 기록 (사진 입력)
- [ ] 운동 기록
- [ ] 체중 기록
- [ ] 대시보드 요약 표시
- [ ] 차트 시각화

### AI 검증
- [ ] 텍스트 → 영양 추정 정확도
- [ ] 이미지 → 음식 인식 정확도
- [ ] API 에러 처리
- [ ] 네트워크 오프라인 처리

---

## 참고

### 관련 문서
- [ARCHITECTURE.md](../02-설계/ARCHITECTURE.md) - 아키텍처 설계
- [MODULES.md](../02-설계/MODULES.md) - 모듈 상세 정의
- [API.md](../03-구현/API.md) - API 명세

### 외부 참고
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Swift Charts Documentation](https://developer.apple.com/documentation/charts)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Google Gemini API Documentation](https://ai.google.dev/gemini-api/docs)
