# SimpleCare - Claude Code Project Instructions

> Korean translation: [CLAUDE-kr.md](./CLAUDE-kr.md)
>
> **Sync Rule**: When `CLAUDE.md` is updated, `CLAUDE-kr.md` must also be updated to reflect the same changes.

## Project Overview

SimpleCare is an AI-powered personal health management iOS app.
Users can log meals, exercises, and weight while leveraging AI (GPT-4o) to develop healthy lifestyle habits.

## Current Progress

> Detailed plans: [WORKPLAN.md](./docs/WORKPLAN.md) | [ROADMAP.md](./docs/ROADMAP.md)

| Phase | Status | Description |
|-------|--------|-------------|
| Phase L: Localization | ✅ Done | Korean (default), English support with runtime switching |
| Phase 0: DIContainer-Client Wiring | ✅ Done | All Feature DIContainers connected to real UseCases |
| Phase 1: AI Feature Activation | 🟡 In Progress | Text mock done (PR #29), image deferred to Phase 5 |
| Phase 1.5: Known Gap Fixes | ✅ Done | PR [#26](https://github.com/wnsgur9137/SimpleCare/pull/26) |
| Phase 2: Home UI & Visualization | ✅ Done | PR [#27](https://github.com/wnsgur9137/SimpleCare/pull/27) |
| Phase 3: Extended Features | ✅ Done | PR [#28](https://github.com/wnsgur9137/SimpleCare/pull/28) |
| Phase 4: Integration & Extras | 🟡 In Progress | Theme/HealthKit done, notifications/export pending |
| Phase 5: Image/Voice Features | 🔵 Low Priority | Meal image picker/analysis (deferred) |

## Tech Stack

- **Platform**: iOS 18.0+ / Swift 6.0 / SwiftUI
- **Architecture**: Clean Architecture + TCA (The Composable Architecture) 1.22.0+
- **Persistence**: SwiftData
- **Build System**: Tuist 4.x (Modular)
- **Network**: Moya + Alamofire
- **AI**: OpenAI GPT-4o (REST API)
- **CI/CD**: Fastlane
- **Lint/Format**: SwiftLint + SwiftFormat

## Module Structure

```
Projects/
├── Application/          # App entry point (AppCoordinator)
├── Feature/              # Feature modules (10)
│   ├── Splash            # Splash screen
│   ├── Onboarding        # User profile & goal setup
│   ├── Home              # Tab coordinator (main navigation)
│   ├── Dashboard         # Daily nutrition/exercise summary
│   ├── Meal              # AI meal tracking & nutrition analysis
│   ├── Exercise          # MET-based exercise recording
│   ├── Weight            # Weight tracking & goal management
│   ├── Profile           # User profile
│   ├── Settings          # App settings
│   └── Base              # Shared UI components, colors, utilities
├── Infrastructure/       # Infrastructure modules (3)
│   ├── StorageInfra      # SwiftData persistence layer
│   ├── NetworkInfra      # Network communication (Moya/Alamofire)
│   └── AIServiceInfra    # OpenAI API integration
├── LibraryManager/       # External library wrappers (4)
│   ├── NetworkLibraries  # Alamofire, Moya
│   ├── UILibraries       # Kingfisher, Lottie, IQKeyboardManager
│   ├── LayoutLibraries   # SnapKit
│   └── ReactiveLibraries # TCA, CombineCocoa
└── InjectionManager/     # Dependency injection management
```

### Feature Module Internal Structure (Clean Architecture)

```
Feature/[Name]/
├── Domain/
│   └── Sources/
│       ├── Entities/        # Business models
│       └── UseCases/        # Business logic + Repository protocols
├── Data/
│   └── Sources/
│       ├── Repositories/    # Repository implementations
│       └── Services/        # External service adapters
└── Presentation/
    └── Sources/             # Views, Reducers(Feature), Coordinators
```

## Build Commands

```bash
tuist install                        # Download SPM dependencies
tuist generate                       # Generate Xcode project
make generate                        # Generate + create dependency graphs
```

## Fastlane Commands

```bash
fastlane ios current_version         # Check current version/build
fastlane ios build_test              # Compile check (DEV)
fastlane ios build                   # Ad-hoc build (PROD)
fastlane ios beta                    # Deploy to TestFlight
fastlane ios test                    # Run unit tests
fastlane ios bump version:X.Y.Z     # Set specific version
fastlane ios bump_major              # Bump major version
fastlane ios bump_minor              # Bump minor version
fastlane ios bump_patch              # Bump patch version
fastlane ios bump_build              # Increment build number
```

## Coding Conventions

### Naming

| Type | Rule | Example |
|------|------|---------|
| Class/Struct | `PascalCase` | `MealRecord`, `FoodItem` |
| Function/Variable | `camelCase` | `estimateMealNutrition()` |
| Protocol | `~Protocol` suffix | `MealRepositoryProtocol` |
| UseCase | Verb+Noun+`UseCase` | `EstimateMealNutritionUseCase` |
| View | `~View` suffix | `DashboardView` |
| Coordinator | `~Coordinator` suffix | `MealCoordinator` |
| DIContainer | `~DIContainer` suffix | `MealDIContainer` |

### Code Style

- Indentation: **4 spaces**
- Line length: 120 warning / 150 error
- File length: 500 lines warning / 1000 lines error
- Function body: 60 lines warning / 100 lines error

## Git Conventions

### Commit Messages

```
✨ Feat:     New feature
🔧 Fix:      Bug fix
📝 Docs:     Documentation
♻️  Refactor: Refactoring
🔖 Version:  Version change
📌 Merge:    Merge
🏗️  Chore:   Build/infrastructure
```

### Branch Strategy

- `main`: Main branch
- `feat/*`: Feature branches
- `docs/*`: Documentation branches
- PR-based workflow (Gemini Code Assist auto-review)

### Pull Request

When creating a PR, use **GitHub MCP** (not `gh` CLI). Follow the template defined in `.github/PULL_REQUEST_TEMPLATE.md`.
- **📌 개요**: Brief summary with relevant links (thread, design doc, Figma, QA ticket)
- **📋 변경사항**: List of changes for reviewers, with before/after screenshots if applicable
- **🙏 참고사항**: Notes for reviewers and optional review deadline

### Commit Granularity

Commits must be split per logical unit of work. Do NOT bundle unrelated changes into a single commit.
- One commit per bug fix, feature addition, or refactoring unit
- Documentation changes should be a separate commit
- Example: If fixing 5 independent gaps, create 5 separate commits (not 1 combined commit)

### GitHub MCP

Use GitHub MCP for **all Git-related operations** (PR creation/update, issue management, branch operations, etc.) instead of the `gh` CLI.
GitHub MCP is configured via `.mcp.json` and runs as a Docker container.

### PR Review Comment Handling

When Gemini Code Assist leaves review comments on a PR:

1. **Review comments**: Check PR comments using GitHub MCP (`get_pull_request_review_comments`)
2. **Fix issues**: Address each comment with appropriate code changes
3. **Commit fixes**: Create a commit with the fixes (reference the review in commit message)
4. **Request re-review**: Run `/gemini review` to trigger Gemini Code Assist re-review
5. **Document resolution**: Add a comment to the PR using the template below

#### Review Feedback Response Template

```markdown
리뷰 피드백 반영 완료 ✅

@gemini-code-assist 님의 리뷰 피드백을 반영하였습니다.

1. **[Severity]: [Issue Title]** ✅
   - 문제: [Brief description of the issue]
   - 해결: [How it was resolved]
   - 파일: `path/to/file.swift`

2. **[Severity]: [Issue Title]** ✅
   - 문제: [Brief description]
   - 해결: [Resolution]
   - 파일: `path/to/file.swift`

커밋: [commit hash]
```

#### Severity Levels
- **Critical**: Security vulnerabilities, crashes, data loss
- **High**: Design principle violations (SOLID), major bugs
- **Medium**: Code quality issues, missing error handling
- **Low**: Style issues, minor improvements

## Key Patterns

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

- `ObservableObject`-based state management
- `@ViewBuilder` for view composition
- Hierarchy: `AppCoordinator` → `Splash/Onboarding/Tab` → Each Feature

### Dependency Injection

- Constructor injection (DIContainer pattern)
- Factory pattern for creating Coordinators/ViewModels

## App Identifiers

- Development: `com.junhyeok.SimpleCare-Dev`
- Production: `com.junhyeok.SimpleCare`

## Documentation

Detailed documentation is stored in the `/docs/` directory:
README.md, ARCHITECTURE.md, MODULES.md, API.md, PRD.md, FASTLANE.md, CLAUDE_CODE_GUIDE.md, etc.

### Documentation Update Rules

When adding, modifying, or deleting documents in the `/docs/` directory, the document list table in the root `README.md` must also be updated accordingly.
- On addition: Add the document link and description to the table
- On deletion: Remove the corresponding entry from the table
- On description change: Update the description column in the table

## Language

- Code comments/variable names: **English**
- Documentation/commit messages: **Korean**
- Supported regions: Korean (default), English
