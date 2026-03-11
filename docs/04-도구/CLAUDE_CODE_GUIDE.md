---
title: "Claude Code 설정 가이드"
aliases: ["Claude Code"]
tags:
  - 도구
  - 도구/Claude
created: 2026-02-09
updated: 2026-03-11
status: active
---

# Claude Code 설정 가이드

## 개요

이 프로젝트는 Claude Code를 활용한 AI 기반 개발 워크플로우를 지원합니다.
Claude Code가 인식하는 설정 파일과 그 역할을 정리합니다.

---

## 파일 구조

```
SimpleCare/
├── CLAUDE.md                      # 프로젝트 컨텍스트 (자동 로드)
└── .claude/
    ├── settings.local.json        # 로컬 설정 (hooks 포함)
    ├── hooks/                     # 자동화 훅 스크립트
    │   ├── doc-sync-reminder.sh   # PostToolUse hook (문서 리마인더)
    │   └── doc-sync-check.sh      # Stop hook (문서 누락 경고)
    └── commands/                   # 커스텀 슬래시 명령 (스킬)
        ├── build.md               # /build
        ├── version.md             # /version
        ├── new-feature.md         # /new-feature
        ├── review.md              # /review
        └── test.md                # /test
```

---

## CLAUDE.md (프로젝트 컨텍스트)

### 역할

Claude Code가 대화 시작 시 **자동으로 읽어들이는** 프로젝트 지침 파일입니다.

### 위치

- 프로젝트 루트: `./CLAUDE.md` (프로젝트 단위 적용)
- 글로벌: `~/.claude/CLAUDE.md` (모든 프로젝트에 적용)

### 포함 내용

- 프로젝트 개요 및 기술 스택
- 모듈 구조 및 아키텍처 패턴
- 빌드/배포 명령어
- 코딩 컨벤션 (네이밍, 코드 스타일)
- Git 커밋/브랜치 규칙
- 주요 디자인 패턴 (TCA, Coordinator, DI)

### 특징

| 항목 | 설명 |
|------|------|
| 적용 시점 | 대화 시작 시 자동 로드 |
| 호출 방식 | 별도 호출 불필요 |
| 성격 | 수동적 (배경 지식) |
| 비유 | 팀의 "컨벤션 문서" |

---

## .claude/commands/ (커스텀 슬래시 명령)

### 역할

반복 작업을 `/명령어` 형태의 슬래시 명령으로 등록하여 실행할 수 있습니다.

### 동작 원리

- `.claude/commands/` 디렉토리 안의 각 `.md` 파일이 하나의 슬래시 명령이 됩니다
- **파일명 = 명령어 이름**: `build.md` → `/build`
- 파일 내용이 Claude에게 전달되는 프롬프트(지시사항)가 됩니다
- `$ARGUMENTS` 변수로 명령어 인자를 받을 수 있습니다

### 특징

| 항목 | 설명 |
|------|------|
| 적용 시점 | 사용자가 슬래시 명령으로 호출할 때만 |
| 호출 방식 | `/명령어` 또는 `/명령어 [인자]` |
| 성격 | 능동적 (명령 실행) |
| 비유 | 팀의 "자동화 스크립트" |

### 등록된 명령어

| 명령어 | 파일 | 기능 |
|--------|------|------|
| `/build` | `build.md` | Tuist 프로젝트 생성 + 빌드 검증 |
| `/version [type]` | `version.md` | 앱 버전 관리 (major/minor/patch/build/current) |
| `/new-feature [이름]` | `new-feature.md` | Clean Architecture 기반 새 Feature 모듈 스캐폴딩 |
| `/review` | `review.md` | main 대비 변경사항 코드 리뷰 |
| `/test` | `test.md` | 유닛 테스트 실행 + 결과 분석 |

### 사용 예시

```bash
# 빌드 검증
> /build

# 현재 버전 확인
> /version current

# 패치 버전 증가
> /version patch

# 새 Feature 모듈 생성
> /new-feature Notification

# 코드 리뷰
> /review

# 테스트 실행
> /test
```

---

## CLAUDE.md vs .claude/commands/ 비교

| 항목 | CLAUDE.md | .claude/commands/ |
|------|-----------|-------------------|
| **파일 형태** | 단일 파일 | 디렉토리 내 개별 .md 파일 |
| **적용 시점** | 항상 (자동 로드) | 호출 시에만 |
| **역할** | 프로젝트 컨텍스트/규칙 | 실행 가능한 작업 정의 |
| **인식 여부** | Claude Code가 자동 인식 | Claude Code가 자동 인식 |
| **성격** | 수동적 (배경 지식) | 능동적 (명령 실행) |

> **참고**: 프로젝트 루트에 `SKILL.md` 같은 파일을 만들어도 Claude Code는 이를 인식하지 않습니다.
> 스킬(커스텀 명령)은 반드시 `.claude/commands/` 디렉토리 안에 개별 `.md` 파일로 생성해야 합니다.

---

## 새 명령어 추가 방법

1. `.claude/commands/` 디렉토리에 새 `.md` 파일 생성
2. 파일명을 원하는 명령어 이름으로 지정 (예: `deploy.md` → `/deploy`)
3. 파일 내용에 Claude가 수행할 지시사항 작성
4. 인자가 필요하면 `$ARGUMENTS` 변수 사용

### 예시: `/deploy` 명령어 추가

```markdown
<!-- .claude/commands/deploy.md -->

TestFlight에 앱을 배포합니다.

다음 단계를 수행하세요:

1. `fastlane ios current_version` 으로 현재 버전 확인
2. 사용자에게 버전 변경 필요 여부 확인
3. `fastlane ios beta` 실행하여 TestFlight에 업로드
4. 배포 결과 요약 출력
```

---

## Hooks (문서 동기화 자동화)

### 개요

Claude Code Hooks는 도구 사용이나 응답 완료 등 특정 이벤트 발생 시 **자동으로 실행되는 셸 스크립트**입니다.
이 프로젝트에서는 코드-문서 동기화를 자동으로 보장하기 위해 두 가지 hook을 사용합니다.

| 항목 | 설명 |
|------|------|
| 목적 | Swift 소스 변경 시 관련 문서 업데이트 유도 |
| 설정 파일 | `.claude/settings.local.json`의 `hooks` 섹션 |
| 스크립트 위치 | `.claude/hooks/` 디렉토리 |
| 이벤트 타입 | `PostToolUse` (도구 사용 후), `Stop` (응답 완료 시) |

### 이벤트 타입

| 이벤트 | 발생 시점 | 용도 |
|--------|----------|------|
| `PostToolUse` | `Edit` 또는 `Write` 도구 실행 직후 | 수정된 파일에 맞는 관련 문서를 안내 |
| `Stop` | Claude Code가 응답을 마칠 때 | Swift 변경이 있으나 문서 업데이트가 없으면 경고 |

---

### PostToolUse Hook: `doc-sync-reminder.sh`

#### 목적

Swift 소스 파일을 수정할 때마다 관련 문서를 확인하도록 리마인더를 출력합니다.

#### 트리거 조건

- `Edit` 또는 `Write` 도구가 사용될 때 (`matcher: "Edit|Write"`)
- 수정된 파일이 `Projects/` 하위의 `.swift` 파일인 경우에만 동작

#### 동작 흐름

```
stdin (JSON) → file_path 추출 → .swift 파일 여부 확인
  → Projects/ 하위 여부 확인 → 모듈 패턴 매칭 → 리마인더 출력
```

1. Claude Code가 stdin으로 도구 입력 JSON을 전달
2. `file_path` 필드를 추출
3. `Projects/**.swift` 패턴이 아니면 조용히 종료
4. 경로에서 모듈명을 추출하여 관련 문서 안내

#### 모듈-문서 매핑 테이블

| 경로 패턴 | 모듈 | 관련 문서 |
|-----------|------|----------|
| `Projects/Feature/Meal/` | Meal | `docs/02-설계/modules/Meal.md`, `docs/03-구현/API.md` |
| `Projects/Feature/Home/` | Home | `docs/02-설계/modules/Home.md`, `docs/01-전략/HOME_SCREEN_PLAN.md` |
| `Projects/Feature/{기타}/` | 해당 Feature | `docs/02-설계/modules/${MODULE}.md` |
| `Projects/Infrastructure/AIServiceInfra/` | AIServiceInfra | `docs/02-설계/modules/AIServiceInfra.md`, `docs/03-구현/API.md` |
| `Projects/Infrastructure/NetworkInfra/` | NetworkInfra | `docs/02-설계/modules/NetworkInfra.md`, `docs/02-설계/ARCHITECTURE.md` |
| `Projects/Infrastructure/StorageInfra/` | StorageInfra | `docs/02-설계/modules/StorageInfra.md`, `docs/03-구현/SETUP.md` |
| `Projects/Infrastructure/{기타}/` | 해당 Infra | `docs/02-설계/modules/${MODULE}.md`, `docs/02-설계/ARCHITECTURE.md` |
| `Projects/Application/` | Application | `docs/02-설계/ARCHITECTURE.md` |

#### 무시 조건

- Swift 파일이 아닌 경우 (`.md`, `.json`, `.yml` 등)
- `Projects/` 디렉토리 외부 파일 (예: `docs/`, `.claude/`)

#### 출력 예시

```
[Doc Sync] Meal 모듈 수정 → 관련 문서 확인: docs/02-설계/MODULES.md (Meal), docs/03-구현/API.md
  해당 모듈의 AGENTS.md 문서 동기화 규칙도 참고하세요.
```

---

### Stop Hook: `doc-sync-check.sh`

#### 목적

Claude Code가 응답을 마칠 때, Swift 파일이 변경되었으나 `docs/` 디렉토리에 업데이트가 없으면 경고를 출력합니다.

#### 트리거 조건

- `Stop` 이벤트 발생 시 항상 실행 (`matcher: ""` — 빈 매처)

#### 동작 흐름

```
git diff → Swift 변경 파일 카운트 (staged + unstaged + untracked)
  → docs/ 변경 파일 카운트 → 비교 → 경고 또는 통과
```

1. `git diff`, `git diff --cached`, `git ls-files --others`로 변경 파일 수집
2. `.swift` 확장자 파일 개수를 합산
3. `docs/` 경로 파일 개수를 합산
4. Swift 변경 > 0 AND docs 변경 = 0이면 경고 출력

#### 판단 로직

| 조건 | 결과 |
|------|------|
| Swift 변경 = 0 | 조용히 통과 (문서 업데이트 불필요) |
| Swift 변경 > 0 AND docs 변경 > 0 | 조용히 통과 (문서도 업데이트됨) |
| Swift 변경 > 0 AND docs 변경 = 0 | **경고 출력** |

#### 경고 출력 예시

```
[Doc Sync Warning] Swift 파일이 3개 변경되었으나 docs/ 업데이트가 없습니다.
  CLAUDE.md의 Post-Change Documentation Sync Rule 트리거 매트릭스를 확인하세요.
  문서 업데이트가 불필요한 경우(포맷팅, 내부 리팩토링 등)는 무시해도 됩니다.
```

---

### settings.local.json hooks 설정

Hook 설정은 `.claude/settings.local.json` 파일의 `hooks` 섹션에 정의됩니다.

#### 설정 구조

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/doc-sync-reminder.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/doc-sync-check.sh"
          }
        ]
      }
    ]
  }
}
```

#### 설정 필드 설명

| 필드 | 설명 |
|------|------|
| `hooks` | 최상위 키. 이벤트 타입별 hook 배열을 포함 |
| `PostToolUse` / `Stop` | 이벤트 타입. hook이 실행되는 시점 |
| `matcher` | 도구 이름 매칭 패턴. `\|`로 여러 도구 지정 가능. 빈 문자열은 모든 경우 매칭 |
| `hooks[].type` | hook 실행 방식. 현재 `"command"`만 지원 |
| `hooks[].command` | 실행할 셸 스크립트 경로 (프로젝트 루트 기준 상대 경로) |

---

### 하이브리드 구조: 3계층 문서 동기화

이 프로젝트는 코드-문서 동기화를 3계층 구조로 보장합니다.

```
┌─────────────────────────────────────────────────┐
│          1계층: CLAUDE.md (규칙 정의)             │
│  Post-Change Documentation Sync Rule            │
│  트리거 매트릭스, 프로세스, 커밋 포맷 정의          │
├─────────────────────────────────────────────────┤
│        2계층: AGENTS.md (컨텍스트 제공)            │
│  각 Feature 모듈별 문서 동기화 규칙                │
│  해당 모듈 작업 시 관련 문서 목록 즉시 확인          │
├─────────────────────────────────────────────────┤
│        3계층: Hooks (실행 보장)                    │
│  PostToolUse: 실시간 리마인더 출력                 │
│  Stop: 최종 검증 및 경고                          │
└─────────────────────────────────────────────────┘
```

| 계층 | 파일 | 역할 | 특징 |
|------|------|------|------|
| 1계층 | `CLAUDE.md` | 동기화 규칙과 트리거 매트릭스 정의 | 모든 대화에 자동 로드 |
| 2계층 | 각 모듈의 `AGENTS.md` | 모듈별 관련 문서 목록과 동기화 규칙 | 해당 모듈 작업 시 참조 |
| 3계층 | `.claude/hooks/` | 실시간 리마인더 + 최종 검증 | 셸 스크립트 자동 실행 |

> **각 계층의 상호작용**: CLAUDE.md가 "무엇을, 언제" 업데이트할지 규칙을 정의하고, AGENTS.md가 모듈별 상세 컨텍스트를 제공하며, Hooks가 이를 실행 시점에서 강제합니다.

---

### 커스터마이징 가이드

#### 새 모듈 추가 시 패턴 추가

`doc-sync-reminder.sh`에 새로운 경로 패턴을 추가합니다.

```bash
# 예: Projects/Feature/Notification/ 모듈 추가
elif [[ "$FILE_PATH" =~ Projects/Feature/Notification/ ]]; then
    MODULE="Notification"
    DOCS="docs/02-설계/MODULES.md (Notification)"
```

> **주의**: Feature 모듈의 경우, 범용 패턴 `Projects/Feature/([^/]+)/`이 이미 존재하므로 별도 패턴 추가 없이도 기본 동작합니다. 특정 문서를 추가로 안내하고 싶을 때만 전용 패턴을 추가하세요.

#### 새 hook 추가

1. `.claude/hooks/` 디렉토리에 새 스크립트 파일 생성
2. 실행 권한 부여: `chmod +x .claude/hooks/new-hook.sh`
3. `settings.local.json`의 `hooks` 섹션에 등록

```json
{
  "hooks": {
    "이벤트타입": [
      {
        "matcher": "매칭패턴",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/new-hook.sh"
          }
        ]
      }
    ]
  }
}
```
