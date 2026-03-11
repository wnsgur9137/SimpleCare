---
title: "Onboarding 모듈"
aliases: ["Onboarding"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/feature
created: 2026-01-26
updated: 2026-03-11
status: active
---

# Onboarding

**역할**: 앱 첫 실행 시 사용자 프로필 초기 설정

| 레이어 | 파일 | 설명 |
|--------|------|------|
| **Domain** | | |
| Entity | `OnboardingStep.swift` | 온보딩 단계 정의 |
| **Data** | | |
| - | `Source.swift` | 플레이스홀더 |
| **Presentation** | | |
| Coordinator | `OnboardingCoordinator.swift` | 온보딩 네비게이션 |
| Reducer | `OnboardingFeature.swift` | 온보딩 TCA Reducer |
| View | `OnboardingView.swift` | 메인 온보딩 뷰 |
| Component | `OnboardingComponents.swift` | 공통 온보딩 UI 컴포넌트 |
| Client | `SaveUserProfileClient.swift` | 프로필 저장 TCA Client |
| Step View | `WelcomeStepView.swift` | 1단계: 환영 화면 |
| Step View | `BasicInfoStepView.swift` | 2단계: 기본 정보 (이름, 성별, 생년월일) |
| Step View | `BodyInfoStepView.swift` | 3단계: 신체 정보 (키, 체중) |
| Step View | `ActivityLevelStepView.swift` | 4단계: 활동 수준 선택 |
| Step View | `GoalSettingStepView.swift` | 5단계: 목표 설정 (감량/증량/유지) |
| Step View | `SummaryStepView.swift` | 6단계: 설정 요약 및 완료 |
| **Aggregator** | | |
| DIContainer | `OnboardingDIContainer.swift` | 의존성 조립 |

**온보딩 단계**:
1. 환영 화면
2. 기본 정보 입력 (이름, 성별, 생년월일)
3. 신체 정보 입력 (키, 체중)
4. 활동 수준 선택
5. 목표 설정 (감량/증량/유지)
6. 설정 요약 및 완료
