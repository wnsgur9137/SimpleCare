# SimpleCare - Claude Code 프로젝트 지침

> 원본 문서: [CLAUDE.md](./CLAUDE.md)
>
> **동기화 규칙**: `CLAUDE.md`가 업데이트되면 이 문서(`CLAUDE-kr.md`)도 동일한 내용으로 함께 업데이트해야 합니다.

## 프로젝트 개요

SimpleCare는 AI 기반 개인 건강 관리 iOS 앱입니다.
사용자가 식사, 운동, 체중을 기록하고 AI(GPT-4o)를 활용하여 건강한 생활 습관을 개발할 수 있도록 돕습니다.

## 현재 진행 상황

> 상세 계획: [WORKPLAN.md](./docs/WORKPLAN.md) | [ROADMAP.md](./docs/ROADMAP.md)

| Phase | 상태 | 설명 |
|-------|------|------|
| Phase L: 다국어 지원 | ✅ 완료 | 한국어(기본), 영어 지원 + 런타임 언어 변경 |
| Phase 0: DIContainer-Client 연결 | ✅ 완료 | 모든 Feature DIContainer에 실제 UseCase 연결 |
| Phase 1: AI 기능 활성화 | 🟡 진행 중 | 텍스트 Mock 완료 (PR #29), 이미지 Phase 5로 이동 |
| Phase 1.5: 알려진 Gap 수정 | ✅ 완료 | PR [#26](https://github.com/wnsgur9137/SimpleCare/pull/26) |
| Phase 2: 홈 화면 개선 및 시각화 | ✅ 완료 | PR [#27](https://github.com/wnsgur9137/SimpleCare/pull/27) |
| Phase 3: 확장 기능 | ✅ 완료 | PR [#28](https://github.com/wnsgur9137/SimpleCare/pull/28) |
| Phase 4: 연동 및 부가 기능 | 🟡 진행 중 | 테마/HealthKit 완료, 알림/내보내기 대기 |
| Phase 5: 이미지/음성 기능 | 🔵 최후순위 | Meal 이미지 선택/분석 (후순위 배치) |

## 기술 스택

- **플랫폼**: iOS 18.0+ / Swift 6.0 / SwiftUI
- **아키텍처**: Clean Architecture + TCA (The Composable Architecture) 1.22.0+
- **영속화**: SwiftData
- **빌드 시스템**: Tuist 4.x (모듈화)
- **네트워크**: Moya + Alamofire
- **AI**: OpenAI GPT-4o (REST API)
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
│   └── AIServiceInfra    # OpenAI API 통합
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

### GitHub MCP

**모든 Git 관련 작업**(PR 생성/수정, 이슈 관리, 브랜치 작업 등)은 `gh` CLI 대신 **GitHub MCP**를 사용합니다.
GitHub MCP는 `.mcp.json`을 통해 설정되며 Docker 컨테이너로 실행됩니다.

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

`/docs/` 디렉토리에 상세 문서 보관:
README.md, ARCHITECTURE.md, MODULES.md, API.md, PRD.md, FASTLANE.md, CLAUDE_CODE_GUIDE.md 등

### 문서 업데이트 규칙

`/docs/` 디렉토리의 문서를 추가, 수정, 삭제한 경우 반드시 루트 `README.md`의 문서 목록 테이블도 함께 업데이트해야 합니다.
- 문서 추가 시: 테이블에 해당 문서의 링크와 설명 추가
- 문서 삭제 시: 테이블에서 해당 항목 제거
- 문서 설명 변경 시: 테이블의 설명 컬럼 업데이트

## 언어

- 코드 내 주석/변수명: **영어**
- 문서/커밋 메시지: **한국어**
- 지원 리전: 한국어(기본), 영어
