---
title: "SimpleCare 문서 허브"
aliases: ["MOC", "문서 목차"]
tags:
  - MOC
created: 2026-03-11
updated: 2026-03-23
status: active
---

# SimpleCare 문서 허브

프로젝트의 모든 문서를 카테고리별로 탐색할 수 있는 Map of Contents(MOC)입니다.

---

## 01-전략

프로젝트 방향성, 요구사항, 로드맵 관련 문서

| 문서 | 설명 |
|------|------|
| [PRD](./01-전략/PRD.md) | 제품 요구사항 문서 |
| [ROADMAP](./01-전략/ROADMAP.md) | 개발 로드맵 및 진행 상황 |
| [WORKPLAN](./01-전략/WORKPLAN.md) | 작업 계획서 |
| [HOME_SCREEN_PLAN](./01-전략/HOME_SCREEN_PLAN.md) | 홈 화면 계획서 |
| [FEATURE_ENHANCEMENT_PLAN](./01-전략/FEATURE_ENHANCEMENT_PLAN.md) | Feature 고도화 계획서 |

## 02-설계

아키텍처, 모듈 구조 등 설계 관련 문서

| 문서 | 설명 |
|------|------|
| [ARCHITECTURE](./02-설계/ARCHITECTURE.md) | 프로젝트 아키텍처 설계 |
| [MODULES](./02-설계/MODULES.md) | 모듈 상세 정의 (MOC) |
| ↳ [Home](./02-설계/modules/Home.md) | 메인 홈 화면 모듈 |
| ↳ [Tab](./02-설계/modules/Tab.md) | 탭 네비게이션 모듈 |
| ↳ [Calendar](./02-설계/modules/Calendar.md) | 캘린더 모듈 |
| ↳ [Meal](./02-설계/modules/Meal.md) | 식단 기록 모듈 |
| ↳ [Exercise](./02-설계/modules/Exercise.md) | 운동 기록 모듈 |
| ↳ [Weight](./02-설계/modules/Weight.md) | 체중 관리 모듈 |
| ↳ [Profile](./02-설계/modules/Profile.md) | 프로필 모듈 |
| ↳ [Onboarding](./02-설계/modules/Onboarding.md) | 온보딩 모듈 |
| ↳ [Splash](./02-설계/modules/Splash.md) | 스플래시 모듈 |
| ↳ [Base](./02-설계/modules/Base.md) | 공통 UI/유틸리티 모듈 |
| ↳ [Settings](./02-설계/modules/Settings.md) | 설정 모듈 |
| ↳ [Features](./02-설계/modules/Features.md) | Feature 통합 모듈 |
| ↳ [Widget](./02-설계/modules/Widget.md) | WidgetKit 홈 화면 위젯 모듈 |
| ↳ [StorageInfra](./02-설계/modules/StorageInfra.md) | SwiftData 영속화 모듈 |
| ↳ [AIServiceInfra](./02-설계/modules/AIServiceInfra.md) | AI API 연동 모듈 |
| ↳ [NetworkInfra](./02-설계/modules/NetworkInfra.md) | 네트워크 통신 모듈 |
| ↳ [HealthKitInfra](./02-설계/modules/HealthKitInfra.md) | HealthKit 연동 모듈 |

## 03-구현

개발 환경 설정, API 연동, 빌드 관련 문서

| 문서 | 설명 |
|------|------|
| [SETUP](./03-구현/SETUP.md) | 개발 환경 설정 가이드 |
| [API](./03-구현/API.md) | AI API 연동 명세 |
| [FASTLANE](./03-구현/FASTLANE.md) | Fastlane 가이드 |
| [DATA_FLOW](./03-구현/DATA_FLOW.md) | 데이터 흐름 문서 (SwiftData ↔ UseCase ↔ Reducer) |
| [NAVIGATION](./03-구현/NAVIGATION.md) | 화면 전환 흐름 (Coordinator 계층 구조) |
| [TESTING](./03-구현/TESTING.md) | 테스트 전략 가이드 (TCA TestStore 패턴) |

## 04-도구

AI 도구, Claude Code, OMC 등 개발 도구 관련 문서

| 문서 | 설명 |
|------|------|
| [AI_TOOLS](./04-도구/AI_TOOLS.md) | AI 도구 활용 가이드 |
| [CLAUDE_CODE_GUIDE](./04-도구/CLAUDE_CODE_GUIDE.md) | Claude Code 설정 가이드 (Hooks, 슬래시 명령 포함) |
| [OMC_GUIDE](./04-도구/OMC_GUIDE.md) | oh-my-claudecode 멀티 에이전트 가이드 |
