---
title: "Splash 모듈"
aliases: ["Splash"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/feature
created: 2026-01-26
updated: 2026-03-11
status: active
---

# Splash

**역할**: 앱 시작 시 스플래시 화면

| 레이어 | 파일 | 설명 |
|--------|------|------|
| Domain | `SplashDomain.swift` | 스플래시 도메인 정의 |
| Data | `SplashData.swift` | 스플래시 데이터 레이어 |
| Coordinator | `SplashCoordinator.swift` | 스플래시 네비게이션 |
| Reducer | `SplashFeature.swift` | 스플래시 TCA Reducer |
| View | `SplashView.swift` | 스플래시 UI |
| Aggregator | `Splash.swift` | 모듈 진입점 |
| DIContainer | `SplashDIContainer.swift` | 의존성 조립 |

**화면 구성**:
- 그라데이션 배경 (teal → purple)
- 로고 + 글래스 카드 효과 애니메이션
- "SimpleCare" 앱 이름 페이드인
- 태그라인 페이드인
- 최소 표시 시간 1.5초 후 자동 전환

**동작 방식**: 타이머 기반 → 완료 delegate → AppCoordinator로 화면 전환
