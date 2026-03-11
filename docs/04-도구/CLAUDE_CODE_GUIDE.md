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
    ├── settings.local.json        # 로컬 설정
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
