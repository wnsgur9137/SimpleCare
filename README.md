# SimpleCare

AI 기반 개인 건강 관리 iOS 앱

---

## 목차

1. [제품 비전](#제품-비전)
2. [현재 버전](#현재-버전)
3. [기술 스택](#기술-스택)
4. [주요 기능](#주요-기능)
5. [개발 진행 상황](#개발-진행-상황)
6. [빠른 시작](#빠른-시작)
7. [AI 개발 도구](#ai-개발-도구)
8. [모듈 구조](#모듈-구조)
9. [아키텍처](#아키텍처)
10. [Fastlane 명령어](#fastlane-명령어)
11. [Claude Code 설정](#claude-code-설정)
12. [문서](#문서)
13. [면책 조항](#면책-조항)
14. [라이선스](#라이선스)

---

## 제품 비전

사용자가 식단, 운동, 체중을 간편하게 기록하고 AI의 도움으로 건강한 생활 습관을 형성할 수 있도록 돕는 iOS 앱

---

## 현재 버전

| 항목 | 값 |
|------|-----|
| **버전** | 0.0.1 |
| **빌드 번호** | 1 |
| **최소 iOS** | 18.0+ |
| **Swift** | 6.0 |

---

## 기술 스택

| 분류 | 기술 |
|-----|------|
| **Platform** | iOS 18.0+, Swift 6.0, SwiftUI, SwiftData |
| **Architecture** | Clean Architecture + TCA 1.22.0+ |
| **Network** | Moya, Alamofire |
| **UI Components** | Kingfisher, Lottie, IQKeyboardManager |
| **AI** | Google Gemini API (REST API, Free Tier) |
| **Health** | Apple HealthKit |
| **Build & CI/CD** | Tuist 4.x, Fastlane |
| **Lint/Format** | SwiftLint, SwiftFormat |

---

## 주요 기능

### 핵심 기능

- **AI 영양 분석**: 텍스트 입력으로 음식 영양소 자동 추정 (Gemini)
- **운동 기록**: MET 기반 칼로리 소모량 계산
- **체중 관리**: 목표 설정 및 추세 분석
- **대시보드**: 일일 영양/운동 요약 시각화

### 확장 기능

- **캘린더**: 월별 캘린더 및 일별 기록 요약
- **HealthKit 연동**: Apple 건강 앱과 데이터 동기화
- **테마 설정**: 라이트/다크/시스템 테마 지원
- **알림 기능**: 식사/운동/체중 기록 리마인더
- **데이터 내보내기**: JSON/CSV 형식 데이터 백업
- **다국어 지원**: 한국어(기본), 영어 런타임 전환

---

## 개발 진행 상황

| Phase | 상태 | 설명 |
|-------|------|------|
| Phase L: Localization | ✅ 완료 | 한국어(기본), 영어 런타임 전환 |
| Phase 0: DIContainer | ✅ 완료 | 모든 Feature DIContainer 연결 |
| Phase 1: AI Feature | ✅ 완료 | Gemini API 텍스트 분석 (이미지는 Phase 6으로 연기) |
| Phase 1.5: Known Gaps | ✅ 완료 | 알려진 갭 수정 |
| Phase 2: Home UI | ✅ 완료 | 홈 화면 시각화 |
| Phase 3: Extended Features | ✅ 완료 | 운동/체중 기능 구현 |
| Phase 4: Integration | 🟡 진행중 | 테마/HealthKit/알림/내보내기 완료, 위젯/AI 고도화 진행 예정 |
| Phase 5: Detail Pages | ✅ 완료 | 식사/운동 상세 페이지 및 목록 뷰 |
| Phase S: Stability | ✅ 완료 | 32건 이슈 수정 (CRITICAL 6, HIGH 16, MEDIUM 10) |
| Phase 6: Image/Voice | 🔵 예정 | 이미지 분석 기능 (연기됨) |

> 자세한 진행 상황은 [ROADMAP.md](./docs/01-전략/ROADMAP.md)와 [WORKPLAN.md](./docs/01-전략/WORKPLAN.md)를 참고하세요.

---

## 빠른 시작

```bash
# 1. 저장소 클론
git clone https://github.com/wnsgur9137/SimpleCare.git
cd SimpleCare

# 2. 프로젝트 생성
tuist install && tuist generate

# 3. Xcode에서 열기
open SimpleCare.xcworkspace
```

---

## AI 개발 도구

본 프로젝트는 AI 도구를 적극 활용하여 개발 생산성과 코드 품질을 향상시키고 있습니다.

### PR 리뷰 자동화

| 도구 | 용도 |
|------|------|
| **Claude Code** | 코드 작성, 리팩토링, PR 생성, GitHub MCP 연동 |
| **Gemini Code Assist** | PR 생성 시 자동 코드 리뷰 수행 |

### AI 교차검증

단일 AI에 의존하지 않고, 여러 AI 모델을 활용하여 교차검증을 진행합니다.

- **ChatGPT** (OpenAI)
- **Claude** (Anthropic)
- **Gemini** (Google)

### MCP 서버 연동

Claude Code는 MCP(Model Context Protocol)를 통해 외부 서비스와 연동됩니다.

- **GitHub MCP**: Docker 기반으로 실행되며, PR/Issue 관리 기능 제공
- **Sosumi**: Apple Developer Documentation 검색
- **Shrimp Task Manager**: 태스크 관리 (GUI 지원)

> 자세한 내용은 [AI_TOOLS.md](./docs/04-도구/AI_TOOLS.md)를 참고하세요.

---

## 모듈 구조

### 전체 의존성 그래프

![Common Graph](graphs/common-graph.png)

### Feature 모듈 (12개)

각 Feature 모듈은 Clean Architecture + TCA 패턴을 따르며, Data/Domain/Presentation 레이어로 구성됩니다.

| 모듈 | 설명 |
|------|------|
| **Splash** | 앱 시작 시 표시되는 스플래시 화면 |
| **Onboarding** | 사용자 프로필 및 목표 설정 |
| **Home** | 메인 홈 화면 (일일 요약, 빠른 기록) |
| **Tab** | 메인 탭 네비게이션 관리 |
| **Meal** | AI 기반 식단 기록 및 영양 분석 |
| **Exercise** | MET 기반 운동 기록 및 칼로리 계산 |
| **Weight** | 체중 기록 및 목표 관리 |
| **Calendar** | 월별 캘린더 및 일별 요약 |
| **Profile** | 사용자 프로필 관리 |
| **Settings** | 앱 설정 (테마, 알림, 데이터 관리) |
| **Base** | 공유 UI 컴포넌트, 색상, 유틸리티 |
| **Features** | Feature 모듈 집합 (Aggregator) |

### Infrastructure 모듈 (4개)

| 모듈 | 설명 |
|------|------|
| **StorageInfra** | SwiftData 기반 로컬 저장소 |
| **NetworkInfra** | Moya/Alamofire 기반 네트워크 레이어 |
| **AIServiceInfra** | Google Gemini API 연동 |
| **HealthKitInfra** | Apple HealthKit 연동 |

### Feature 모듈별 의존성 그래프

#### Splash
앱 시작 시 표시되는 스플래시 화면

![Splash Graph](graphs/splash-graph.png)

#### Onboarding
사용자 프로필 및 목표 설정

![Onboarding Graph](graphs/onboarding-graph.png)

#### Home
메인 홈 화면 (일일 영양/운동 요약, 주간 트렌드)

![Home Graph](graphs/home-graph.png)

#### Dashboard
일일 영양/운동 요약 시각화 (그래프, 진행률)

![Dashboard Graph](graphs/dashboard-graph.png)

#### Meal
AI 기반 식단 기록 및 영양 분석

![Meal Graph](graphs/meal-graph.png)

#### Exercise
MET 기반 운동 기록 및 칼로리 계산

![Exercise Graph](graphs/exercise-graph.png)

#### Weight
체중 기록 및 목표 관리

![Weight Graph](graphs/weight-graph.png)

#### Calendar
월별 캘린더 및 일별 요약

![Calendar Graph](graphs/calendar-graph.png)

#### Profile
사용자 프로필 관리

![Profile Graph](graphs/profile-graph.png)

#### Settings
앱 설정

![Settings Graph](graphs/settings-graph.png)

---

## 아키텍처

### Clean Architecture + TCA

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │    View     │→ │   Reducer   │→ │ Coordinator │     │
│  │  (SwiftUI)  │  │ (TCA Store) │  │             │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
├─────────────────────────────────────────────────────────┤
│                      Domain                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Entity    │  │  Use Case   │  │  Repository │     │
│  │             │  │             │  │  Protocol   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
├─────────────────────────────────────────────────────────┤
│                       Data                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ Repository  │  │    Model    │  │ Data Source │     │
│  │    Impl     │  │   (DTO)     │  │             │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
├─────────────────────────────────────────────────────────┤
│                   Infrastructure                        │
│  ┌───────────┐ ┌─────────────┐ ┌───────────┐ ┌───────┐│
│  │StorageInfra│ │AIServiceInfra│ │NetworkInfra│ │HealthKit││
│  │(SwiftData)│ │  (Gemini)   │ │  (Moya)   │ │ Infra ││
│  └───────────┘ └─────────────┘ └───────────┘ └───────┘│
└─────────────────────────────────────────────────────────┘
```

### TCA 패턴

```
┌─────────────────────────────────────────────────────────┐
│                      View                               │
│                        │                                │
│                   send(Action)                          │
│                        ▼                                │
│  ┌─────────────────────────────────────────────────┐   │
│  │                   Reducer                        │   │
│  │  ┌───────┐    ┌────────┐    ┌────────────┐     │   │
│  │  │ State │ ←  │ Action │ →  │   Effect   │     │   │
│  │  └───────┘    └────────┘    └────────────┘     │   │
│  └─────────────────────────────────────────────────┘   │
│                        │                                │
│                  State 변경                              │
│                        ▼                                │
│                   View 업데이트                          │
└─────────────────────────────────────────────────────────┘
```

---

## Fastlane 명령어

### 버전 관리

```bash
fastlane ios current_version      # 현재 버전/빌드 확인
fastlane ios bump version:X.Y.Z   # 특정 버전 설정
fastlane ios bump_major           # 메이저 버전 증가 (X.0.0)
fastlane ios bump_minor           # 마이너 버전 증가 (0.X.0)
fastlane ios bump_patch           # 패치 버전 증가 (0.0.X)
fastlane ios bump_build           # 빌드 번호 증가
fastlane ios bump build:N         # 특정 빌드 번호 설정
```

### 빌드 & 테스트

```bash
fastlane ios build_test           # 컴파일 검증 (DEV)
fastlane ios build                # Ad-hoc 빌드 (PROD)
fastlane ios test                 # 유닛 테스트 실행
```

### 배포

```bash
fastlane ios beta                 # TestFlight 배포
```

> 자세한 내용은 [FASTLANE.md](./docs/03-구현/FASTLANE.md)를 참고하세요.

---

## Claude Code 설정

이 프로젝트는 Claude Code를 활용한 AI 기반 개발 워크플로우를 지원합니다.

### 프로젝트 컨텍스트

`CLAUDE.md` 파일이 프로젝트 루트에 위치하며, Claude Code가 대화 시작 시 자동으로 읽어들여 프로젝트 구조, 컨벤션, 명령어 등을 파악합니다.

### Hooks (문서 동기화 자동화)

`.claude/hooks/` 디렉토리에 등록된 자동화 스크립트:

| Hook | 이벤트 | 기능 |
|------|--------|------|
| `doc-sync-reminder.sh` | PostToolUse | Swift 소스 수정 시 관련 문서 리마인더 출력 |
| `doc-sync-check.sh` | Stop | 응답 완료 시 문서 업데이트 누락 경고 |

### 커스텀 슬래시 명령

`.claude/commands/` 디렉토리에 등록된 명령어:

| 명령어 | 기능 |
|--------|------|
| `/build` | Tuist 프로젝트 생성 + 빌드 검증 |
| `/version [type]` | 앱 버전 관리 (major/minor/patch/build/current) |
| `/new-feature [이름]` | Clean Architecture 기반 새 Feature 모듈 스캐폴딩 |
| `/review` | main 대비 변경사항 코드 리뷰 |
| `/test` | 유닛 테스트 실행 + 결과 분석 |

> 자세한 내용은 [CLAUDE_CODE_GUIDE.md](./docs/04-도구/CLAUDE_CODE_GUIDE.md)를 참고하세요.

---

## 문서

자세한 기술 문서는 [docs/](./docs/) 폴더를 참고하세요.

| 문서 | 카테고리 | 설명 |
|-----|---------|------|
| [PRD.md](./docs/01-전략/PRD.md) | 전략 | 제품 요구사항 문서 |
| [ROADMAP.md](./docs/01-전략/ROADMAP.md) | 전략 | 개발 로드맵 및 진행 상황 |
| [WORKPLAN.md](./docs/01-전략/WORKPLAN.md) | 전략 | 작업 계획서 |
| [HOME_SCREEN_PLAN.md](./docs/01-전략/HOME_SCREEN_PLAN.md) | 전략 | 홈 화면 계획서 |
| [ARCHITECTURE.md](./docs/02-설계/ARCHITECTURE.md) | 설계 | 프로젝트 아키텍처 설계 |
| [MODULES.md](./docs/02-설계/MODULES.md) | 설계 | 모듈 상세 정의 |
| [SETUP.md](./docs/03-구현/SETUP.md) | 구현 | 개발 환경 설정 가이드 |
| [API.md](./docs/03-구현/API.md) | 구현 | AI API 연동 명세 |
| [FASTLANE.md](./docs/03-구현/FASTLANE.md) | 구현 | Fastlane 가이드 |
| [DATA_FLOW.md](./docs/03-구현/DATA_FLOW.md) | 구현 | 데이터 흐름 문서 |
| [NAVIGATION.md](./docs/03-구현/NAVIGATION.md) | 구현 | 화면 전환 흐름 |
| [TESTING.md](./docs/03-구현/TESTING.md) | 구현 | 테스트 전략 가이드 |
| [AI_TOOLS.md](./docs/04-도구/AI_TOOLS.md) | 도구 | AI 도구 활용 가이드 |
| [CLAUDE_CODE_GUIDE.md](./docs/04-도구/CLAUDE_CODE_GUIDE.md) | 도구 | Claude Code 설정 가이드 (Hooks, 슬래시 명령 포함) |
| [OMC_GUIDE.md](./docs/04-도구/OMC_GUIDE.md) | 도구 | oh-my-claudecode(OMC) 멀티 에이전트 가이드 |

---

## 면책 조항

> SimpleCare는 건강 관리를 돕기 위한 도구입니다.
> AI 추정치는 참고용이며 의료적 조언이 아닙니다.
> 건강 관련 결정은 반드시 전문가와 상담하세요.

---

## 라이선스

This project is for personal/educational use.
