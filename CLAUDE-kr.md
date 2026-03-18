# SimpleCare - Claude Code 프로젝트 지침

> 원본 문서: [CLAUDE.md](./CLAUDE.md)
>
> **동기화 규칙**: `CLAUDE.md`가 업데이트되면 이 문서(`CLAUDE-kr.md`)도 동일한 내용으로 함께 업데이트해야 합니다.

## 프로젝트 개요

SimpleCare는 AI 기반 개인 건강 관리 iOS 앱입니다.
사용자가 식사, 운동, 체중을 기록하고 AI(Google Gemini)를 활용하여 건강한 생활 습관을 개발할 수 있도록 돕습니다.

## 현재 진행 상황

> 상세 계획: [WORKPLAN.md](./docs/01-전략/WORKPLAN.md) | [ROADMAP.md](./docs/01-전략/ROADMAP.md)

| Phase | 상태 | 설명 |
|-------|------|------|
| Phase L: 다국어 지원 | ✅ 완료 | 한국어(기본), 영어 지원 + 런타임 언어 변경 |
| Phase 0: DIContainer-Client 연결 | ✅ 완료 | 모든 Feature DIContainer에 실제 UseCase 연결 |
| Phase 1: AI 기능 활성화 | ✅ 완료 | Gemini API 실제 연동 (텍스트), 이미지 Phase 6로 이동 |
| Phase 1.5: 알려진 Gap 수정 | ✅ 완료 | PR [#26](https://github.com/wnsgur9137/SimpleCare/pull/26) |
| Phase 2: 홈 화면 개선 및 시각화 | ✅ 완료 | PR [#27](https://github.com/wnsgur9137/SimpleCare/pull/27) |
| Phase 3: 확장 기능 | ✅ 완료 | PR [#28](https://github.com/wnsgur9137/SimpleCare/pull/28) |
| Phase 4: 연동 및 부가 기능 | ✅ 완료 | 테마/HealthKit/알림/내보내기 모두 완료 |
| Phase 5: 상세 페이지 | ✅ 완료 | 식사/운동 상세, 목록 뷰, 캘린더 네비게이션 |
| Phase S: 안정성 및 보안 강화 | ✅ 완료 | 32건 수정 (CRITICAL 6, HIGH 16, MEDIUM 10) |
| Phase 6: 이미지/음성 기능 | 🔵 최후순위 | Meal 이미지 선택/분석 (후순위 배치) |

## 기술 스택

- **플랫폼**: iOS 18.0+ / Swift 6.0 / SwiftUI
- **아키텍처**: Clean Architecture + TCA (The Composable Architecture) 1.22.0+
- **영속화**: SwiftData
- **빌드 시스템**: Tuist 4.x (모듈화)
- **네트워크**: Moya + Alamofire
- **AI**: Google Gemini API (REST API, Free Tier)
- **CI/CD**: Fastlane
- **Lint/Format**: SwiftLint + SwiftFormat

## 모듈 구조

```
Projects/
├── Application/          # 앱 진입점 (AppCoordinator)
├── Feature/              # 기능 모듈 (10개)
│   ├── Splash            # 스플래시 화면
│   ├── Onboarding        # 사용자 프로필/목표 설정
│   ├── Home              # 탭 코디네이터 (메인 네비게이션)
│   ├── Dashboard         # 일일 영양/운동 요약
│   ├── Meal              # AI 식사 추적 & 영양 분석
│   ├── Exercise          # MET 기반 운동 기록
│   ├── Weight            # 체중 추적 & 목표 관리
│   ├── Profile           # 사용자 프로필
│   ├── Settings          # 앱 설정
│   └── Base              # 공유 UI 컴포넌트, 색상, 유틸리티
├── Infrastructure/       # 인프라 모듈 (3개)
│   ├── StorageInfra      # SwiftData 영속화 계층
│   ├── NetworkInfra      # 네트워크 통신 (Moya/Alamofire)
│   └── AIServiceInfra    # Google Gemini API 통합
├── LibraryManager/       # 외부 라이브러리 래퍼 (4개)
│   ├── NetworkLibraries  # Alamofire, Moya
│   ├── UILibraries       # Kingfisher, Lottie, IQKeyboardManager
│   ├── LayoutLibraries   # SnapKit
│   └── ReactiveLibraries # TCA, CombineCocoa
└── InjectionManager/     # 의존성 주입 관리
```

### Feature 모듈 내부 구조 (Clean Architecture)

```
Feature/[Name]/
├── Domain/
│   └── Sources/
│       ├── Entities/        # 비즈니스 모델
│       └── UseCases/        # 비즈니스 로직 + Repository 프로토콜
├── Data/
│   └── Sources/
│       ├── Repositories/    # Repository 구현
│       └── Services/        # 외부 서비스 어댑터
└── Presentation/
    └── Sources/             # View, Reducer(Feature), Coordinator
```

## 빌드 명령어

```bash
tuist install                        # SPM 의존성 다운로드
tuist generate                       # Xcode 프로젝트 생성
make generate                        # 생성 + 의존성 그래프
```

## Fastlane 명령어

```bash
fastlane ios current_version         # 현재 버전/빌드 확인
fastlane ios build_test              # 컴파일 확인 (DEV)
fastlane ios build                   # Ad-hoc 빌드 (PROD)
fastlane ios beta                    # TestFlight 배포
fastlane ios test                    # 유닛 테스트 실행
fastlane ios bump version:X.Y.Z     # 특정 버전 지정
fastlane ios bump_major              # 메이저 버전 증가
fastlane ios bump_minor              # 마이너 버전 증가
fastlane ios bump_patch              # 패치 버전 증가
fastlane ios bump_build              # 빌드 번호 증가
```

## 코딩 컨벤션

### 네이밍

| 종류 | 규칙 | 예시 |
|------|------|------|
| 클래스/구조체 | `PascalCase` | `MealRecord`, `FoodItem` |
| 함수/변수 | `camelCase` | `estimateMealNutrition()` |
| 프로토콜 | `~Protocol` 접미사 | `MealRepositoryProtocol` |
| UseCase | 동사+명사+`UseCase` | `EstimateMealNutritionUseCase` |
| View | `~View` 접미사 | `DashboardView` |
| Coordinator | `~Coordinator` 접미사 | `MealCoordinator` |
| DIContainer | `~DIContainer` 접미사 | `MealDIContainer` |

### 코드 스타일

- 들여쓰기: **4 스페이스**
- 줄 길이: 120자 경고 / 150자 에러
- 파일 길이: 500줄 경고 / 1000줄 에러
- 함수 본문: 60줄 경고 / 100줄 에러

## Git 컨벤션

### 커밋 메시지

```
✨ Feat:     새로운 기능
🔧 Fix:      버그 수정
📝 Docs:     문서
♻️  Refactor: 리팩토링
🔖 Version:  버전 변경
📌 Merge:    머지
🏗️  Chore:   빌드/인프라
```

### 브랜치 전략

- `main`: 메인 브랜치
- `feat/*`: 기능 브랜치
- `docs/*`: 문서 브랜치
- PR 기반 워크플로우 (Gemini Code Assist 자동 리뷰)

### Pull Request

PR 생성 시 **GitHub MCP**를 사용합니다 (`gh` CLI가 아님). `.github/PULL_REQUEST_TEMPLATE.md`에 정의된 템플릿을 따릅니다.
- **📌 개요**: 관련 링크와 함께 간략한 요약 (스레드, 기획서, 피그마, QA 티켓)
- **📋 변경사항**: 리뷰어를 위한 변경 목록, 해당하는 경우 작업 전/후 스크린샷 포함
- **🙏 참고사항**: 리뷰어를 위한 참고 내용 및 선택적 리뷰 희망 기한

### 커밋 세분화

커밋은 논리적 작업 단위별로 세분화하여 작성해야 합니다. 관련 없는 변경사항을 하나의 커밋에 묶지 않습니다.
- 버그 수정, 기능 추가, 리팩토링 단위별로 각각 커밋
- 문서 변경은 별도 커밋으로 분리
- 예시: 독립적인 Gap 5건을 수정하는 경우, 1개가 아닌 5개의 개별 커밋으로 작성

### 작업 관리 (Shrimp Task Manager + 문서)

**세션 내 작업 관리**는 **Shrimp Task Manager MCP**를 사용합니다.
Claude Code 내장 Task 도구(TaskCreate/TaskUpdate/TodoWrite)는 사용하지 않습니다.

**세션 워크플로우** (Shrimp Task Manager):
1. `plan_task` → 작업을 태스크로 분할
2. `split_tasks` → 필요 시 하위 태스크 생성
3. `execute_task` → 각 태스크 실행
4. `verify_task` → 완료 검증
5. `list_tasks` / `query_task` → 진행 상태 확인

**영구적 작업 추적** (ROADMAP.md / WORKPLAN.md):
- 작업 완료 후 [`ROADMAP.md`](./docs/01-전략/ROADMAP.md) 및/또는 [`WORKPLAN.md`](./docs/01-전략/WORKPLAN.md)의 체크리스트/상태를 업데이트합니다
- 이 문서들이 세션/머신 간 작업 추적의 **단일 진실 소스(source of truth)** 입니다
- Shrimp Task Manager 데이터는 로컬 전용이며 머신 간 유지되지 않습니다

**규칙**:
- 모든 비자명(non-trivial) 작업(2개 이상 파일 수정 또는 15분 이상 소요)은 세션 중 Shrimp Task Manager에서 추적합니다
- 작업 완료 후 반드시 [`ROADMAP.md`](./docs/01-전략/ROADMAP.md) / [`WORKPLAN.md`](./docs/01-전략/WORKPLAN.md)에 상태를 동기화합니다
- 복잡한 작업은 계획 전에 `analyze_task`를 사용합니다

### GitHub MCP

**모든 Git 관련 작업**(PR 생성/수정, 이슈 관리, 브랜치 작업 등)은 `gh` CLI 대신 **GitHub MCP**를 사용합니다.
GitHub MCP는 `.mcp.json`을 통해 설정되며 Docker 컨테이너로 실행됩니다.

### PR 리뷰 코멘트 처리

Gemini Code Assist가 PR에 리뷰 코멘트를 남긴 경우:

1. **코멘트 확인**: GitHub MCP로 PR 코멘트 확인 (`get_pull_request_review_comments`)
2. **이슈 수정**: 각 코멘트에 대해 적절한 코드 수정
3. **수정 커밋**: 수정 사항 커밋 (커밋 메시지에 리뷰 참조)
4. **해결 기록**: 아래 템플릿으로 PR에 코멘트 추가

#### 리뷰 피드백 응답 템플릿

```markdown
리뷰 피드백 반영 완료 ✅

@gemini-code-assist 님의 리뷰 피드백을 반영하였습니다.

1. **[심각도]: [이슈 제목]** ✅
   - 문제: [문제에 대한 간략한 설명]
   - 해결: [어떻게 해결했는지]
   - 파일: `path/to/file.swift`

2. **[심각도]: [이슈 제목]** ✅
   - 문제: [간략한 설명]
   - 해결: [해결 방법]
   - 파일: `path/to/file.swift`

커밋: [커밋 해시]
```

#### 심각도 수준
- **Critical**: 보안 취약점, 크래시, 데이터 손실
- **High**: 설계 원칙 위반 (SOLID), 주요 버그
- **Medium**: 코드 품질 문제, 에러 처리 누락
- **Low**: 스타일 이슈, 소소한 개선

## 주요 패턴

### TCA Reducer

```swift
@Reducer
struct FeatureReducer {
    struct State { ... }
    enum Action { ... }
    var body: some ReducerOf<Self> {
        Reduce { state, action in ... }
    }
}
```

### Coordinator

- `ObservableObject` 기반 상태 관리
- `@ViewBuilder`로 화면 구성
- 계층: `AppCoordinator` → `Splash/Onboarding/Tab` → 각 Feature

### 의존성 주입

- 생성자 주입 (DIContainer 패턴)
- Factory 패턴으로 Coordinator/ViewModel 생성

## 앱 식별자

- 개발: `com.junhyeok.SimpleCare-Dev`
- 프로덕션: `com.junhyeok.SimpleCare`

## 문서

문서는 `/docs/` 디렉토리를 Obsidian vault로 관리합니다:

```
docs/
├── INDEX.md            # MOC (Map of Contents)
├── 01-전략/            # PRD, ROADMAP, WORKPLAN, HOME_SCREEN_PLAN
├── 02-설계/            # ARCHITECTURE, MODULES
├── 03-구현/            # SETUP, API, FASTLANE
├── 04-도구/            # AI_TOOLS, CLAUDE_CODE_GUIDE, OMC_GUIDE
└── _templates/         # Obsidian 템플릿
```

### 코드-문서 참조 규칙

코드 변경 작업 시, 구현 전에 관련 docs/ 문서를 먼저 확인합니다:

| 작업 대상 | 먼저 읽을 문서 |
|-----------|---------------|
| 모든 Feature 모듈 | `docs/02-설계/ARCHITECTURE.md`, `docs/02-설계/MODULES.md` (해당 섹션) |
| Meal Feature | `docs/03-구현/API.md` (AI API 연동) |
| Home Feature | `docs/01-전략/HOME_SCREEN_PLAN.md` |
| Infrastructure | `docs/02-설계/ARCHITECTURE.md` |
| Build / CI | `docs/03-구현/FASTLANE.md` |
| 새 기능 기획 | `docs/01-전략/PRD.md`, `docs/01-전략/ROADMAP.md` |

> **양방향 규칙**: 구현 전에 관련 문서를 먼저 읽고, 변경 후에는 문서화된 인터페이스, 구조, 워크플로우에 영향이 있으면 문서도 업데이트합니다.

### 코드 변경 후 문서 동기화 규칙

코드 변경 완료 후, 커밋 전에 문서 업데이트가 필요한지 확인합니다.

#### 트리거 매트릭스

| 코드 변경 유형 | 영향받는 문서 | 업데이트 액션 |
|---------------|-------------|-------------|
| Entity/UseCase 추가/이름변경/삭제 | `docs/02-설계/MODULES.md` | 모듈 테이블 행 추가/수정/삭제 |
| View/Coordinator 추가/이름변경/삭제 | `docs/02-설계/MODULES.md` | 컴포넌트 행 추가/수정/삭제 |
| 새 Feature 모듈 추가 | `docs/02-설계/MODULES.md`, `docs/02-설계/ARCHITECTURE.md` | 모듈 섹션 추가, 트리 업데이트 |
| 의존성 그래프 변경 (Tuist) | `docs/02-설계/ARCHITECTURE.md` | 의존성 흐름 섹션 업데이트 |
| API 엔드포인트/프롬프트 추가/변경 | `docs/03-구현/API.md` | 엔드포인트/프롬프트 섹션 업데이트 |
| Fastlane lane 추가/변경 | `docs/03-구현/FASTLANE.md` | lane 테이블 업데이트 |
| 빌드 설정 / Tuist 변경 | `docs/03-구현/SETUP.md` | 설정 가이드 업데이트 |
| Phase 완료 또는 상태 변경 | `docs/01-전략/ROADMAP.md`, `docs/01-전략/WORKPLAN.md` | Phase 상태 업데이트 |
| 홈 화면 레이아웃 변경 | `docs/01-전략/HOME_SCREEN_PLAN.md` | 화면 기획 업데이트 |
| docs/ 내 문서 추가/삭제 | `docs/INDEX.md`, 루트 `README.md` | MOC 및 README 문서 테이블 업데이트 |

#### 제외 조건 (문서 업데이트 불필요)

- 순수 포맷팅/공백/주석만 변경한 경우
- SwiftLint/SwiftFormat 자동 수정
- 테스트 파일 변경 (새로운 public API가 드러나지 않는 한)
- public 인터페이스 변경 없는 내부 리팩토링

#### 프로세스

1. 코드 편집 후, 트리거 매트릭스 확인
2. 해당하는 문서 업데이트
3. YAML frontmatter의 `updated` 필드를 오늘 날짜로 변경
4. 문서 업데이트는 별도 커밋으로 분리

#### 자동화된 실행 보장

문서 동기화는 Claude Code hooks를 통해 자동으로 실행이 보장됩니다:
- **PostToolUse hook**: Swift 소스 파일 수정 시 관련 문서를 리마인드
- **Stop hook**: Swift 파일이 변경되었으나 docs/ 업데이트가 없으면 경고

Hook 스크립트는 `.claude/hooks/`에 위치하며, `.claude/settings.local.json`에서 설정됩니다.

#### 커밋 형식
`📝 Docs: [모듈명] 코드 변경에 따른 문서 동기화`

### 문서 관리 규칙

1. **원본 = vault**: Obsidian vault(`docs/`)가 모든 프로젝트 문서의 원본입니다
2. **Frontmatter 필수**: 모든 문서에 YAML frontmatter 포함 (title, aliases, tags, created, updated, status)
3. **마크다운 링크**: 상대 경로의 표준 마크다운 링크 `[텍스트](경로)` 사용 (Wikilink 사용 금지)
4. **템플릿 사용**: 새 문서 작성 시 `docs/_templates/`의 템플릿 활용
5. **README 동기화**: `docs/`에 문서 추가/삭제 시 루트 `README.md`의 문서 테이블도 업데이트
6. **updated 필드 갱신**: 문서 수정 시 frontmatter의 `updated` 필드를 현재 날짜로 변경

## 언어

- 코드 내 주석/변수명: **영어**
- 문서/커밋 메시지: **한국어**
- 지원 리전: 한국어(기본), 영어
