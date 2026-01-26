# SimpleCare 작업 계획서

> 작성일: 2026-01-26
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

---

## 2. 현재 구현 현황

### 2.1 Feature 구현 상태

| Feature | TCA Reducer | View | DIContainer | Client 연결 |
|---------|-------------|------|-------------|-------------|
| Splash | ✅ | ✅ | ✅ | ✅ |
| Onboarding | ✅ | ✅ | ✅ | ✅ |
| Dashboard | ✅ | ✅ | ⚠️ placeholder | ❌ |
| Meal | ✅ | ✅ | ⚠️ placeholder | ❌ |
| Exercise | ✅ | ✅ | ⚠️ placeholder | ❌ |
| Weight | ✅ | ✅ | ⚠️ placeholder | ❌ |
| Profile | ✅ | ✅ | ⚠️ placeholder | ❌ |

### 2.2 핵심 문제점

#### 구조적 문제: DIContainer ↔ TCA Client 연결 미완성

```
현재 상태:
DIContainer → UseCase (구현됨) → Repository (구현됨) → Storage (구현됨)
                ↓
         TCA Client (liveValue = placeholder ❌)
```

모든 TCA Client의 `liveValue`가 placeholder 상태로, 실제 비즈니스 로직이 연결되지 않음.

---

## 3. 진행 중 기능 (🔄) 상세 분석

### 3.1 Dashboard AI 인사이트

| 컴포넌트 | 파일 | 상태 |
|----------|------|------|
| DashboardFeature | `DashboardFeature.swift` | ✅ generateDailyInsight 의존성 존재 |
| DailyInsightService | `DailyInsightService.swift` | ✅ GPT-4o-mini 연동 구현됨 |
| DashboardDIContainer | `DashboardDIContainer.swift` | ❌ AI 서비스 미연결 |

**필요 작업**: DIContainer에서 DailyInsightService를 DashboardClient에 주입

### 3.2 Meal 이미지 분석

| 컴포넌트 | 파일 | 상태 |
|----------|------|------|
| MealFeature | `MealFeature.swift` | ✅ analyzeMealImage 액션 존재 |
| NutritionEstimationService | `NutritionEstimationService.swift` | ✅ analyzeImage() 구현됨 |
| OpenAIClient | `OpenAIClient.swift` | ✅ chatCompletionWithVision() 구현됨 |
| MealView | `MealRecordView.swift` | ❌ 이미지 선택 UI 미구현 |
| MealDIContainer | `MealDIContainer.swift` | ❌ Vision 서비스 미연결 |

**필요 작업**:
1. PhotosPicker UI 추가
2. DIContainer에서 analyzeImage 연결

### 3.3 Weight 추세 그래프

| 컴포넌트 | 파일 | 상태 |
|----------|------|------|
| WeightView | `WeightView.swift` | ✅ Swift Charts 구현됨 |
| WeightFeature | `WeightFeature.swift` | ✅ getWeightTrend 의존성 존재 |
| WeightDIContainer | `WeightDIContainer.swift` | ❌ Storage 미연결 |

**필요 작업**: DIContainer에서 WeightRecordStorage를 WeightClient에 주입

---

## 4. 우선순위 기반 작업 계획

### Phase 0: 기반 연결 (Critical) 🔴

> DIContainer와 TCA Client 연결 - 모든 기능의 기반

| 순서 | 작업 | 파일 | 예상 복잡도 |
|------|------|------|------------|
| 0.1 | DashboardDIContainer - Client 연결 | `DashboardDIContainer.swift` | 낮음 |
| 0.2 | MealDIContainer - Client 연결 | `MealDIContainer.swift` | 낮음 |
| 0.3 | WeightDIContainer - Client 연결 | `WeightDIContainer.swift` | 낮음 |
| 0.4 | ExerciseDIContainer - Client 연결 | `ExerciseDIContainer.swift` | 낮음 |
| 0.5 | ProfileDIContainer - Client 연결 | `ProfileDIContainer.swift` | 낮음 |

**완료 조건**: 각 Feature에서 실제 데이터 CRUD 동작 확인

### Phase 1: AI 기능 활성화 🟡

| 순서 | 작업 | 의존성 | 예상 복잡도 |
|------|------|--------|------------|
| 1.1 | Dashboard AI 인사이트 표시 UI 개선 | Phase 0.1 | 낮음 |
| 1.2 | Meal 이미지 선택 UI (PhotosPicker) | Phase 0.2 | 중간 |
| 1.3 | Meal 이미지 분석 결과 표시 | 1.2 | 중간 |

**완료 조건**:
- Dashboard에서 AI 코멘트 표시
- Meal에서 사진 촬영/선택 → AI 분석 → 영양소 표시

### Phase 2: 데이터 시각화 개선 🟢

| 순서 | 작업 | 의존성 | 예상 복잡도 |
|------|------|--------|------------|
| 2.1 | Weight 차트 목표선 (RuleMark) 추가 | Phase 0.3 | 낮음 |
| 2.2 | Weight 기간 선택 (7일/30일/90일) | 2.1 | 낮음 |
| 2.3 | Dashboard 영양소 프로그레스 바 개선 | Phase 0.1 | 중간 |

### Phase 3: 확장 기능 (📋 PRD 예정 항목)

| 순서 | 작업 | PRD 참조 | 예상 복잡도 |
|------|------|----------|------------|
| 3.1 | 즐겨찾기 음식 저장/불러오기 | §3.2.4 | 중간 |
| 3.2 | 최근 기록 빠른 추가 | §3.2.4 | 중간 |
| 3.3 | 커스텀 운동 추가 | §3.2.5 | 중간 |
| 3.4 | 주간/월간 리포트 | §3.2.6 | 높음 |
| 3.5 | BMI 계산 및 표시 | §3.2.6 | 낮음 |

### Phase 4: 연동 및 부가 기능

| 순서 | 작업 | PRD 참조 | 예상 복잡도 |
|------|------|----------|------------|
| 4.1 | HealthKitInfra 구현 | §4.3 | 높음 |
| 4.2 | 걸음수/활동 칼로리 연동 | §4.3 | 중간 |
| 4.3 | 알림/리마인더 설정 | §3.2.8 | 중간 |
| 4.4 | 데이터 내보내기 (CSV/JSON) | §3.2.7 | 중간 |
| 4.5 | 데이터 삭제/초기화 | §3.2.7 | 낮음 |
| 4.6 | 테마 설정 (다크/라이트) | §3.2.8 | 낮음 |

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
| API Key 보안 | Git 제외 | ✅ XCConfig 사용 | - |
| VoiceOver | 모든 UI 접근 가능 | ⚠️ 미검증 | 접근성 레이블 검토 |
| Dynamic Type | 텍스트 크기 조절 | ⚠️ 미검증 | 폰트 스케일링 검토 |
| 색상 대비 | WCAG 2.1 AA | ⚠️ 미검증 | 색상 대비 검사 |

---

## 7. 즉시 실행 권장 작업

### 최고 ROI 작업: Phase 0 (DIContainer-Client 연결)

**이유**:
- 낮은 복잡도 (기존 코드 연결만 필요)
- 높은 영향도 (모든 Feature 활성화)
- 빠른 완료 가능

**완료 시 활성화되는 기능**:
- ✅ Dashboard AI 인사이트 자동 표시
- ✅ Weight 추세 그래프 데이터 표시
- ✅ Meal 텍스트 기반 영양 추정 작동
- ✅ Exercise 칼로리 계산 및 저장
- ✅ Profile 정보 수정 및 저장

---

## 8. 마일스톤

### MVP (v1.0) - PRD §7.1
- [ ] Phase 0 완료 (DIContainer 연결)
- [ ] 기본 데이터 흐름 검증
- [ ] 핵심 기능 E2E 테스트

### v1.1 - PRD §7.2
- [ ] Phase 1 완료 (AI 기능)
- [ ] Phase 2 완료 (차트 개선)
- [ ] 이미지 기반 음식 인식

### v1.2 - PRD §7.3
- [ ] Phase 3.1-3.2 완료 (즐겨찾기/최근 기록)
- [ ] Phase 4.1-4.2 완료 (HealthKit)
- [ ] Phase 4.3 완료 (알림)

### v2.0 - PRD §7.4
- [ ] Widget / Live Activity
- [ ] AI 맞춤 추천
- [ ] 전체 Phase 완료

---

## 부록: 관련 파일 경로

### Feature DIContainers
```
Projects/Feature/Dashboard/Sources/DashboardDIContainer.swift
Projects/Feature/Meal/Sources/MealDIContainer.swift
Projects/Feature/Weight/Sources/WeightDIContainer.swift
Projects/Feature/Exercise/Sources/ExerciseDIContainer.swift
Projects/Feature/Profile/Sources/ProfileDIContainer.swift
```

### TCA Features
```
Projects/Feature/Dashboard/Presentation/Sources/DashboardFeature.swift
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
```

---

*문서 버전: 1.0*
*최종 수정일: 2026-01-26*
