---
title: "SimpleCare PRD"
aliases: ["PRD", "요구사항"]
tags:
  - 전략
created: 2026-01-26
updated: 2026-03-16
status: active
---

# SimpleCare PRD (Product Requirements Document)

## 1. 제품 개요

### 1.1 제품명
**SimpleCare** - AI 기반 개인 건강 관리 앱

### 1.2 제품 비전
사용자가 식단, 운동, 체중을 간편하게 기록하고 AI의 도움으로 건강한 생활 습관을 형성할 수 있도록 돕는 iOS 앱

### 1.3 타겟 사용자
- 체중 관리를 원하는 20-40대 성인
- 식단과 운동을 기록하고 싶지만 복잡한 앱은 부담스러운 사용자
- AI의 도움으로 영양 정보를 쉽게 파악하고 싶은 사용자

### 1.4 핵심 가치
| 가치 | 설명 |
|-----|------|
| **간편함** | 텍스트나 사진 한 장으로 식단 기록 완료 |
| **지능형** | AI가 영양소를 자동 추정하고 인사이트 제공 |
| **시각화** | Swift Charts를 활용한 직관적인 진행 현황 |
| **개인화** | 사용자 목표에 맞춘 맞춤형 권장량 |

---

## 2. 기술 스택

| 항목 | 선택 | 비고 |
|-----|------|------|
| **플랫폼** | iOS 18.0+ | SwiftUI, SwiftData 활용 |
| **아키텍처** | Clean Architecture + TCA | Tuist 모듈화 |
| **상태 관리** | The Composable Architecture (TCA) | 단방향 데이터 흐름, 테스트 용이 |
| **AI 서비스** | Google Gemini API (Free Tier) | 영양 추정, 음식 인식 |
| **차트** | Swift Charts | Apple 네이티브 |
| **데이터 저장** | SwiftData | 로컬 저장 |
| **건강 데이터** | HealthKit | Apple Health 연동 |

---

## 3. 기능 요구사항

### 3.1 앱 플로우

```
┌─────────────────────────────────────────────────────────────┐
│                        App Launch                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Splash Screen (1.5초)                    │
│  - 앱 로고 및 브랜딩                                          │
│  - 애니메이션 효과                                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ 온보딩 완료 여부? │
                    └─────────────────┘
                      │           │
                   No │           │ Yes
                      ▼           ▼
┌─────────────────────────┐   ┌─────────────────────────┐
│      Onboarding         │   │       Main Tab          │
│  - 기본 정보 입력         │   │  - Dashboard            │
│  - 목표 설정             │   │  - Meal                 │
│  - 활동 수준 선택         │   │  - Exercise             │
│  - HealthKit 권한        │   │  - Progress             │
└─────────────────────────┘   │  - Settings             │
            │                 └─────────────────────────┘
            └────────────────────────►
```

### 3.2 Feature 상세

#### 3.2.1 Splash (구현 완료 ✅)
| 항목 | 설명 | 상태 |
|-----|------|------|
| 최소 표시 시간 | 1.5초 | ✅ |
| 로고 애니메이션 | 페이드인 + 스케일 효과 | ✅ |
| 앱 이름 표시 | "SimpleCare" | ✅ |
| 태그라인 | "건강한 하루를 기록하세요" | ✅ |

#### 3.2.2 Onboarding (구현 완료 ✅)
| 항목 | 설명 | 상태 |
|-----|------|------|
| 기본 정보 입력 | 이름, 성별, 생년월일 | ✅ |
| 신체 정보 입력 | 키, 현재 체중 | ✅ |
| 목표 설정 | 감량/유지/증량, 목표 체중 | ✅ |
| 활동 수준 | 비활동적 ~ 매우 활동적 | ✅ |
| 권장 칼로리 계산 | BMR × 활동계수 ± 목표 보정 | ✅ |
| SwiftData 저장 | UserProfileModel | ✅ |

#### 3.2.3 Dashboard (기본 구현 ✅)
| 항목 | 설명 | 상태 |
|-----|------|------|
| 오늘 날짜 표시 | 요일, 월, 일 | ✅ |
| 칼로리 요약 카드 | 섭취/목표/남은 칼로리 | ✅ |
| 영양소 진행률 | 탄수화물/단백질/지방 프로그레스 바 | ✅ |
| 빠른 기록 버튼 | 식사/운동 기록 바로가기 | ✅ |
| 오늘 기록 목록 | 식사/운동 기록 리스트 | ✅ |
| AI 인사이트 | 하루 요약 한줄 코멘트 | 🔄 |

#### 3.2.4 Meal (기본 구현 ✅)
| 항목 | 설명 | 상태 |
|-----|------|------|
| 식사 타입 선택 | 아침/점심/저녁/간식 | ✅ |
| 텍스트 입력 | 음식명 입력 | ✅ |
| AI 영양 추정 | Gemini 기반 영양소 분석 | ✅ |
| 영양소 수동 조정 | 슬라이더로 미세 조정 | ✅ |
| 사진 입력 | 카메라/갤러리 | 🔄 |
| AI 이미지 분석 | Gemini Vision | 🔄 |
| 즐겨찾기 | 자주 먹는 음식 저장 | 📋 |
| 최근 기록 | 최근 식사 빠른 추가 | 📋 |

#### 3.2.5 Exercise (기본 구현 ✅)
| 항목 | 설명 | 상태 |
|-----|------|------|
| 운동 종류 선택 | 걷기, 달리기, 자전거 등 | ✅ |
| 운동 시간 입력 | 분 단위 | ✅ |
| MET 기반 칼로리 | 운동 강도별 소모 칼로리 계산 | ✅ |
| 운동 기록 저장 | SwiftData | ✅ |
| 커스텀 운동 추가 | 사용자 정의 운동 | 📋 |

#### 3.2.6 Weight/Progress (기본 구현 ✅)
| 항목 | 설명 | 상태 |
|-----|------|------|
| 체중 입력 | 오늘 체중 기록 | ✅ |
| 목표 대비 현황 | 시작/현재/목표 체중 비교 | ✅ |
| 추세 그래프 | Swift Charts 기반 | 🔄 |
| 주간/월간 리포트 | 기간별 통계 | 📋 |
| BMI 계산 | 체질량지수 | 📋 |

#### 3.2.7 Profile (기본 구현 ✅)
| 항목 | 설명 | 상태 |
|-----|------|------|
| 프로필 조회 | 사용자 정보 표시 | ✅ |
| 프로필 수정 | 정보 업데이트 | ✅ |
| 목표 재설정 | 목표 체중/칼로리 변경 | ✅ |
| 데이터 내보내기 | CSV/JSON 형식 | 📋 |
| 데이터 삭제 | 전체 데이터 초기화 | 📋 |

#### 3.2.8 Settings (기본 구현 ✅)
| 항목 | 설명 | 상태 |
|-----|------|------|
| 프로필 설정 링크 | Profile Feature 연결 | ✅ |
| 앱 버전 | 버전 정보 표시 | ✅ |
| 면책 문구 | AI 추정치 안내 | ✅ |
| 알림 설정 | 리마인더 On/Off | 📋 |
| HealthKit 설정 | 연동 On/Off | 📋 |
| 테마 설정 | 다크/라이트 모드 | 📋 |

---

## 4. Infrastructure 요구사항

### 4.1 StorageInfra (구현 완료 ✅)
```swift
// 구현된 모델
@Model UserProfileModel     // 사용자 프로필
@Model MealRecordModel      // 식사 기록
@Model ExerciseRecordModel  // 운동 기록
@Model WeightRecordModel    // 체중 기록

// 구현된 Storage
UserProfileStorage          // 프로필 CRUD
MealRecordStorage          // 식사 기록 CRUD
ExerciseRecordStorage      // 운동 기록 CRUD
WeightRecordStorage        // 체중 기록 CRUD
```

### 4.2 AIServiceInfra (구현 완료 ✅)
```swift
// 구현된 서비스
GeminiClient               // API 클라이언트
NutritionEstimationService // 영양 추정 서비스

// 구현 예정
ImageAnalysisService       // 이미지 분석 서비스 📋
DailyInsightService        // 일일 인사이트 생성 📋
```

### 4.3 HealthKitInfra (구현 예정 📋)
```swift
// 구현 예정
HealthKitManager           // HealthKit 권한 관리
StepCountService           // 걸음수 조회
ActiveCalorieService       // 활동 칼로리 조회
WeightSyncService          // 체중 동기화
```

---

## 5. 비기능 요구사항

### 5.1 성능
| 항목 | 요구사항 |
|-----|---------|
| 앱 시작 시간 | 2초 이내 (Splash 제외) |
| AI 응답 시간 | 5초 이내 |
| 화면 전환 | 애니메이션 포함 0.3초 이내 |

### 5.2 보안
| 항목 | 요구사항 |
|-----|---------|
| API Key 관리 | XCConfig 파일, Git 제외 |
| 데이터 저장 | 로컬 SwiftData (암호화 고려) |
| 이미지 처리 | 서버 전송 시 압축 및 익명화 |

### 5.3 접근성
| 항목 | 요구사항 |
|-----|---------|
| VoiceOver | 모든 UI 요소 접근 가능 |
| Dynamic Type | 텍스트 크기 조절 지원 |
| 색상 대비 | WCAG 2.1 AA 기준 충족 |

---

## 6. 구현 현황

### 6.1 완료된 항목 ✅

#### Phase 1: 기반 구축 + 온보딩
- [x] Tuist 모듈화 아키텍처
- [x] Clean Architecture (Data/Domain/Presentation)
- [x] Coordinator 패턴 (AppCoordinator → Splash/Onboarding/Tab)
- [x] StorageInfra (SwiftData)
- [x] AIServiceInfra (Google Gemini API)
- [x] Splash Feature
- [x] Onboarding Feature
- [x] Profile Feature

#### Phase 2: 핵심 기능
- [x] Dashboard Feature (기본)
- [x] Meal Feature (텍스트 입력 + AI 영양 추정)
- [x] Exercise Feature (MET 기반 칼로리)
- [x] Weight Feature (기본)

### 6.2 진행 중 🔄

- [ ] Dashboard AI 인사이트
- [ ] Meal 이미지 분석
- [ ] Weight 추세 그래프 (Swift Charts)

### 6.3 구현 예정 📋

#### Phase 3: 확장 기능
- [ ] 즐겨찾기/최근 기록 기능
- [ ] 커스텀 운동 추가
- [ ] 주간/월간 리포트
- [ ] AI 맞춤 추천

#### Phase 4: 연동 및 부가 기능
- [ ] HealthKitInfra 구현
- [ ] 알림/리마인더
- [ ] Widget / Live Activity
- [ ] 데이터 내보내기/삭제
- [ ] 테마 설정

---

## 7. 릴리즈 계획

### 7.1 MVP (v1.0)
- Splash → Onboarding → Main Tab 플로우
- 텍스트 기반 식단 기록 + AI 영양 추정
- 운동 기록 (MET 기반)
- 체중 기록 및 목표 관리
- 기본 대시보드

### 7.2 v1.1
- 이미지 기반 음식 인식
- Swift Charts 그래프
- AI 일일 인사이트

### 7.3 v1.2
- HealthKit 연동
- 알림/리마인더
- 즐겨찾기/최근 기록

### 7.4 v2.0
- Widget / Live Activity
- AI 맞춤 식단/운동 추천
- 소셜 기능 (선택적)

---

## 8. 성공 지표 (KPI)

| 지표 | 목표 |
|-----|------|
| 일일 활성 사용자 (DAU) | 1,000명 (출시 후 3개월) |
| 일일 식단 기록 횟수 | 평균 2회 이상 |
| 7일 리텐션 | 40% 이상 |
| 앱스토어 평점 | 4.5 이상 |
| 크래시 프리 세션 | 99.5% 이상 |

---

## 9. 리스크 및 완화 방안

| 리스크 | 영향 | 완화 방안 |
|--------|------|----------|
| AI 영양 추정 부정확 | 사용자 신뢰 하락 | 면책 문구 표시, 수동 조정 기능 |
| Gemini API 무료 티어 한도 | 기능 제한 | 캐싱, Rate limiting, 사용량 모니터링 |
| HealthKit 권한 거부 | 기능 제한 | 독립적 기능 동작 보장, 재요청 UI |
| 경쟁 앱 | 시장 점유율 | 차별화된 UX, AI 기능 강화 |

---

## 10. 부록

### 10.1 용어 정의
| 용어 | 정의 |
|-----|------|
| MET | Metabolic Equivalent of Task, 운동 강도 단위 |
| BMR | Basal Metabolic Rate, 기초대사량 |
| TDEE | Total Daily Energy Expenditure, 일일 총 소비 칼로리 |
| 탄단지 | 탄수화물, 단백질, 지방의 약칭 |

### 10.2 참고 자료
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Google Gemini API Reference](https://ai.google.dev/gemini-api/docs)
- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)

---

*문서 버전: 1.0*
*최종 수정일: 2026-01-26*
