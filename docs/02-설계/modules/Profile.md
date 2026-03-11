---
title: "Profile 모듈"
aliases: ["Profile"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/feature
created: 2026-01-26
updated: 2026-03-11
status: active
---

# Profile

**역할**: 사용자 프로필 및 목표 설정

| 레이어 | 파일 | 설명 |
|--------|------|------|
| **Domain** | | |
| Entity | `UserProfile.swift` | 사용자 프로필 (이름, 나이, 성별, 키, 체중, 활동수준, 목표) |
| UseCase | `GetUserProfileUseCase.swift` | 프로필 조회 |
| UseCase | `SaveUserProfileUseCase.swift` | 프로필 저장 |
| UseCase | `UpdateUserProfileUseCase.swift` | 프로필 업데이트 |
| **Data** | | |
| Repository | `ProfileRepository.swift` | 프로필 레포지토리 구현 |
| **Presentation** | | |
| Coordinator | `ProfileCoordinator.swift` | 프로필 화면 네비게이션 |
| Reducer | `ProfileFeature.swift` | 프로필 TCA Reducer |
| View | `ProfileView.swift` | 프로필 UI |
| **Aggregator** | | |
| DIContainer | `ProfileDIContainer.swift` | 의존성 조립 |

**프로필 정보**:
- 이름, 나이(10–120), 성별(남/여)
- 키, 현재 체중, 목표 체중
- 활동 수준 (좌식 ~ 매우 활발)
- 목표 유형 (감량/증량/유지) + 아이콘

**자동 계산 항목**:
- BMR (Mifflin-St Jeor), TDEE, 일일 권장 칼로리
- 일일 권장 단백질(체중 × 1.6g), 탄수화물(50%), 지방(25%)
- BMI + 카테고리 (저체중/정상/과체중/비만) + 색상 코딩
- 목표별 칼로리 조정 (감량: −500kcal, 증량: +300kcal)

**화면 구성**: 폼 기반 프로필 에디터, 실시간 계산 업데이트, 건강 면책 조항 표시
