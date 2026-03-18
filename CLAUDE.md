# SimpleCare - Claude Code Project Instructions

> Korean translation: [CLAUDE-kr.md](./CLAUDE-kr.md)
>
> **Sync Rule**: When `CLAUDE.md` is updated, `CLAUDE-kr.md` must also be updated to reflect the same changes.

## Project Overview

SimpleCare is an AI-powered personal health management iOS app.
Users can log meals, exercises, and weight while leveraging AI (Google Gemini) to develop healthy lifestyle habits.

## Current Progress

> Detailed plans: [WORKPLAN.md](./docs/01-전략/WORKPLAN.md) | [ROADMAP.md](./docs/01-전략/ROADMAP.md)

| Phase | Status | Description |
|-------|--------|-------------|
| Phase L: Localization | ✅ Done | Korean (default), English support with runtime switching |
| Phase 0: DIContainer-Client Wiring | ✅ Done | All Feature DIContainers connected to real UseCases |
| Phase 1: AI Feature Activation | ✅ Done | Gemini API live (text), image deferred to Phase 6 |
| Phase 1.5: Known Gap Fixes | ✅ Done | PR [#26](https://github.com/wnsgur9137/SimpleCare/pull/26) |
| Phase 2: Home UI & Visualization | ✅ Done | PR [#27](https://github.com/wnsgur9137/SimpleCare/pull/27) |
| Phase 3: Extended Features | ✅ Done | PR [#28](https://github.com/wnsgur9137/SimpleCare/pull/28) |
| Phase 4: Integration & Extras | ✅ Done | Theme/HealthKit/Notifications/Export all complete |
| Phase 5: Detail Pages | ✅ Done | Meal/Exercise detail, list views, calendar navigation |
| Phase S: Stability & Security | ✅ Done | 32 issues fixed (CRITICAL 6, HIGH 16, MEDIUM 10) |
| Phase 6: Image/Voice Features | 🔵 Low Priority | Meal image picker/analysis (deferred) |

## Tech Stack

- **Platform**: iOS 18.0+ / Swift 6.0 / SwiftUI
- **Architecture**: Clean Architecture + TCA (The Composable Architecture) 1.22.0+
- **Persistence**: SwiftData
- **Build System**: Tuist 4.x (Modular)
- **Network**: Moya + Alamofire
- **AI**: Google Gemini API (REST API, Free Tier)
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
│   └── AIServiceInfra    # Google Gemini API integration
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

### Task Management (Shrimp Task Manager + Docs)

Use **Shrimp Task Manager MCP** for **session-level task management** (planning, tracking, execution, verification).
Do NOT use Claude Code built-in Task tools (TaskCreate/TaskUpdate/TodoWrite) — always use Shrimp Task Manager instead.

**Session Workflow** (Shrimp Task Manager):
1. `plan_task` → Break down work into tasks
2. `split_tasks` → Create subtasks if needed
3. `execute_task` → Execute each task
4. `verify_task` → Verify completion
5. `list_tasks` / `query_task` → Check progress

**Permanent Work Tracking** (ROADMAP.md / WORKPLAN.md):
- After completing a task, update the corresponding checklist/status in [`ROADMAP.md`](./docs/01-전략/ROADMAP.md) and/or [`WORKPLAN.md`](./docs/01-전략/WORKPLAN.md)
- These documents are the **source of truth** for cross-session/cross-machine work tracking
- Shrimp Task Manager data is local and session-scoped — it does NOT persist across machines

**Rules**:
- Every non-trivial task (modifying 2+ files or taking 15+ minutes) must be tracked in Shrimp Task Manager during the session
- After task completion, always sync status to [`ROADMAP.md`](./docs/01-전략/ROADMAP.md) / [`WORKPLAN.md`](./docs/01-전략/WORKPLAN.md)
- Use `analyze_task` for complex tasks before planning

### GitHub MCP

Use GitHub MCP for **all Git-related operations** (PR creation/update, issue management, branch operations, etc.) instead of the `gh` CLI.
GitHub MCP is configured via `.mcp.json` and runs as a Docker container.

### PR Review Comment Handling

When Gemini Code Assist leaves review comments on a PR:

1. **Review comments**: Check PR comments using GitHub MCP (`get_pull_request_review_comments`)
2. **Fix issues**: Address each comment with appropriate code changes
3. **Commit fixes**: Create a commit with the fixes (reference the review in commit message)
4. **Document resolution**: Add a comment to the PR using the template below

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

Documentation is managed as an Obsidian vault in the `/docs/` directory:

```
docs/
├── INDEX.md            # MOC (Map of Contents)
├── 01-전략/            # PRD, ROADMAP, WORKPLAN, HOME_SCREEN_PLAN
├── 02-설계/            # ARCHITECTURE, MODULES
├── 03-구현/            # SETUP, API, FASTLANE
├── 04-도구/            # AI_TOOLS, CLAUDE_CODE_GUIDE, OMC_GUIDE
└── _templates/         # Obsidian templates
```

### Code-Documentation Reference Rule

When working on code changes, read the relevant docs/ before implementation:

| Working on | Read first |
|-----------|-----------|
| Any Feature module | `docs/02-설계/ARCHITECTURE.md`, `docs/02-설계/MODULES.md` (relevant section) |
| Meal Feature | `docs/03-구현/API.md` (AI API integration) |
| Home Feature | `docs/01-전략/HOME_SCREEN_PLAN.md` |
| Infrastructure | `docs/02-설계/ARCHITECTURE.md` |
| Build / CI | `docs/03-구현/FASTLANE.md` |
| New feature planning | `docs/01-전략/PRD.md`, `docs/01-전략/ROADMAP.md` |

> **Bidirectional rule**: Read the relevant docs BEFORE implementation, and update them AFTER if changes affect documented interfaces, structures, or workflows.

### Post-Change Documentation Sync Rule

After completing code changes, BEFORE committing, check if documentation updates are needed.

#### Trigger Matrix

| Code Change Type | Affected Docs | Update Action |
|-----------------|---------------|---------------|
| New/renamed/deleted Entity or UseCase | `docs/02-설계/MODULES.md` | Add/update/remove row in module table |
| New/renamed/deleted View/Coordinator | `docs/02-설계/MODULES.md` | Add/update/remove component row |
| New Feature module added | `docs/02-설계/MODULES.md`, `docs/02-설계/ARCHITECTURE.md` | Add module section, update tree |
| Dependency graph change (Tuist) | `docs/02-설계/ARCHITECTURE.md` | Update dependency flow section |
| New/changed API endpoint or prompt | `docs/03-구현/API.md` | Update endpoint/prompt section |
| Fastlane lane added/changed | `docs/03-구현/FASTLANE.md` | Update lane table |
| Build config / Tuist change | `docs/03-구현/SETUP.md` | Update setup instructions |
| Phase completion or status change | `docs/01-전략/ROADMAP.md`, `docs/01-전략/WORKPLAN.md` | Update phase status |
| Home screen layout change | `docs/01-전략/HOME_SCREEN_PLAN.md` | Update screen plan |
| Doc added/removed in docs/ | `docs/INDEX.md`, root `README.md` | Update MOC and README doc table |

#### Exclusions (do NOT trigger doc updates)

- Pure formatting/whitespace/comment-only changes
- SwiftLint/SwiftFormat auto-fixes
- Test file changes (unless new public API revealed)
- Internal refactoring with no public interface change

#### Process

1. After code edits, review the trigger matrix
2. Update matching doc(s)
3. Update `updated` field in YAML frontmatter to today's date
4. Create a SEPARATE commit for doc updates

#### Automated Enforcement

Documentation sync is enforced via Claude Code hooks:
- **PostToolUse hook**: Reminds about relevant docs when Swift source files are edited
- **Stop hook**: Warns if Swift files changed but no docs/ updates were made

Hook scripts are located in `.claude/hooks/` and configured in `.claude/settings.local.json`.

#### Commit Format
`📝 Docs: [모듈명] 코드 변경에 따른 문서 동기화`

### Documentation Management Rules

1. **Source of truth**: The Obsidian vault (`docs/`) is the canonical source for all project documentation
2. **Frontmatter required**: Every document must have YAML frontmatter (title, aliases, tags, created, updated, status)
3. **Markdown links**: Use standard markdown links `[text](path)` with relative paths (not Wikilinks)
4. **Templates**: New documents should use templates from `docs/_templates/`
5. **README sync**: When adding/removing documents in `docs/`, update the document table in root `README.md`
6. **Updated field**: When modifying a document, update the `updated` field in frontmatter to the current date

## Language

- Code comments/variable names: **English**
- Documentation/commit messages: **Korean**
- Supported regions: Korean (default), English
