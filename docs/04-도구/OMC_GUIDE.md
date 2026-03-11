---
title: "oh-my-claudecode 가이드"
aliases: ["OMC"]
tags:
  - 도구
  - 도구/OMC
created: 2026-02-09
updated: 2026-03-11
status: active
---

# oh-my-claudecode (OMC) 가이드

Claude Code에 멀티 에이전트 오케스트레이션 기능을 추가하는 플러그인입니다.
복잡한 작업을 전문 에이전트들에게 자동 위임하여 병렬로 처리합니다.

---

## 목차

1. [개요](#개요)
2. [초기 설정](#초기-설정)
3. [기본 사용법](#기본-사용법)
4. [매직 키워드](#매직-키워드)
5. [슬래시 커맨드](#슬래시-커맨드)
6. [에이전트 구조](#에이전트-구조)
7. [실행 모드](#실행-모드)
8. [프로젝트 활용 예시](#프로젝트-활용-예시)
9. [설치 범위](#설치-범위)
10. [참고 자료](#참고-자료)

---

## 개요

### OMC란?

oh-my-claudecode(OMC)는 Claude Code를 **지휘자(Conductor)** 역할로 전환하는 플러그인입니다.
사용자의 요청을 분석하여 적절한 전문 에이전트에게 작업을 위임하고, 병렬 실행 및 자동 검증까지 수행합니다.

### 핵심 특징

| 특징 | 설명 |
|------|------|
| **자동 위임** | 작업 유형에 따라 전문 에이전트 자동 선택 |
| **병렬 실행** | 독립적인 작업을 여러 에이전트가 동시 처리 |
| **모델 라우팅** | 작업 복잡도에 따라 haiku/sonnet/opus 자동 선택 |
| **자동 검증** | architect 에이전트가 결과를 검증 후 완료 |
| **제로 러닝커브** | 명령어 없이 자연어로 요청하면 자동 동작 |

---

## 초기 설정

### 설치

Claude Code 실행 후 아래 명령어를 입력합니다.

```
/oh-my-claudecode:omc-setup
```

이것이 유일하게 알아야 할 명령어입니다. 설정이 완료되면 이후 모든 기능이 자동으로 작동합니다.

### 설치 확인

문제가 발생하면 진단 도구를 실행합니다.

```
/oh-my-claudecode:doctor
```

---

## 기본 사용법

**별도 명령어를 외울 필요가 없습니다.** 자연어로 요청하면 OMC가 자동으로 감지하여 동작합니다.

| 이렇게 말하면 | OMC가 자동으로 |
|---------------|---------------|
| "Dashboard 기능 구현해줘" | 계획 → 구현 → 테스트 → 검증 (autopilot) |
| "plan API 설계해줘" | 인터뷰 기반 계획 수립 |
| "이 코드 리뷰해줘" | 전문 리뷰 에이전트가 분석 |
| "전체 빌드 에러 고쳐줘" | 병렬로 여러 파일 동시 수정 |
| "끝날 때까지 멈추지 마" | 완료될 때까지 지속 실행 (ralph) |

### 중단하기

진행 중인 작업을 중단하고 싶으면 아래 중 하나를 입력합니다.

- `cancel`
- `stop`
- `cancelomc`

---

## 매직 키워드

요청에 키워드를 포함하면 특정 실행 모드를 명시적으로 활성화할 수 있습니다.

| 키워드 | 효과 | 사용 예시 |
|--------|------|----------|
| `autopilot` | 완전 자율 실행 (계획→구현→테스트→검증) | "autopilot: 투두 앱 만들어줘" |
| `ralph` | 완료될 때까지 멈추지 않음 (ultrawork 포함) | "ralph: 버그 전부 고쳐" |
| `ulw` | 최대 병렬 처리 | "ulw API 리팩토링" |
| `eco` | 토큰 절약 모드 | "eco 에러 수정" |
| `plan` | 체계적 계획 수립 인터뷰 | "plan 새 API 설계" |
| `ralplan` | 반복 합의 기반 계획 수립 | "ralplan 인증 시스템" |

---

## 슬래시 커맨드

자주 사용하는 기능은 슬래시 커맨드로 직접 호출할 수 있습니다.

### 실행 모드

| 커맨드 | 설명 |
|--------|------|
| `/oh-my-claudecode:autopilot` | 완전 자율 실행 모드 |
| `/oh-my-claudecode:ralph` | 끝까지 완료 모드 |
| `/oh-my-claudecode:ultrawork` | 최대 병렬 실행 모드 |
| `/oh-my-claudecode:ecomode` | 토큰 절약 병렬 모드 |
| `/oh-my-claudecode:ultrapilot` | 파일 소유권 분할 병렬 autopilot |
| `/oh-my-claudecode:swarm` | N개 에이전트 협업 태스크 풀 |

### 계획 및 분석

| 커맨드 | 설명 |
|--------|------|
| `/oh-my-claudecode:plan` | 인터뷰 기반 전략적 계획 수립 |
| `/oh-my-claudecode:ralplan` | Planner + Architect + Critic 합의 계획 |
| `/oh-my-claudecode:analyze` | 심층 분석 및 조사 |
| `/oh-my-claudecode:deepsearch` | 코드베이스 심층 검색 |

### 품질 관리

| 커맨드 | 설명 |
|--------|------|
| `/oh-my-claudecode:code-review` | 코드 리뷰 |
| `/oh-my-claudecode:security-review` | 보안 취약점 리뷰 |
| `/oh-my-claudecode:tdd` | TDD 워크플로우 |
| `/oh-my-claudecode:build-fix` | 빌드/타입 에러 수정 |
| `/oh-my-claudecode:ultraqa` | QA 사이클 (테스트→검증→수정 반복) |

### 유틸리티

| 커맨드 | 설명 |
|--------|------|
| `/oh-my-claudecode:omc-setup` | 초기 설정 |
| `/oh-my-claudecode:doctor` | 설치 문제 진단 |
| `/oh-my-claudecode:help` | 전체 도움말 |
| `/oh-my-claudecode:note` | 메모 저장 (세션 간 유지) |
| `/oh-my-claudecode:cancel` | 현재 활성 모드 중단 |

---

## 에이전트 구조

OMC는 33개의 전문 에이전트를 3개 티어로 운영합니다.

### 티어별 모델 배정

| 티어 | 모델 | 용도 | 예시 |
|------|------|------|------|
| Low | Haiku | 단순 조회, 빠른 수정 | explore, executor-low, architect-low |
| Medium | Sonnet | 일반 구현, 리뷰 | executor, designer, researcher |
| High | Opus | 복잡한 분석, 설계 | architect, analyst, deep-executor |

### 주요 에이전트

| 에이전트 | 역할 |
|----------|------|
| `executor` | 코드 구현 (단일/다중 파일) |
| `architect` | 아키텍처 분석 및 디버깅 |
| `designer` | UI/UX 디자인 및 구현 |
| `researcher` | 외부 문서 조사 |
| `code-reviewer` | 코드 리뷰 |
| `security-reviewer` | 보안 취약점 검출 |
| `scientist` | 데이터 분석 및 리서치 |
| `writer` | 기술 문서 작성 |
| `explore` | 코드베이스 탐색 |
| `git-master` | Git 작업 (커밋, 리베이스) |
| `qa-tester` | QA 테스트 |
| `build-fixer` | 빌드 에러 수정 |
| `planner` | 전략적 계획 수립 |
| `critic` | 계획 리뷰 및 비평 |
| `vision` | 이미지/PDF 분석 |

---

## 실행 모드

### 모드 비교

| 모드 | 핵심 | 적합한 상황 |
|------|------|------------|
| **autopilot** | 자율 실행 | 새 기능 구현, 처음부터 끝까지 |
| **ralph** | 끝까지 완료 | 많은 버그 수정, 대규모 리팩토링 |
| **ultrawork** | 최대 병렬 | 독립적인 여러 파일 수정 |
| **ecomode** | 토큰 절약 | 비용 절감이 중요할 때 |
| **ultrapilot** | 병렬 autopilot | 대규모 기능 구현 (3-5배 빠름) |
| **swarm** | 에이전트 협업 | 여러 에이전트가 태스크 풀 공유 |

### 모드 관계

```
autopilot (자율 실행)
    ├── ralph (지속성 래퍼) ─── ultrawork 포함
    ├── ultrawork (병렬 실행)
    └── ultraqa (QA 사이클)

ecomode = 모델 라우팅 수정자 (다른 모드와 조합 가능)
```

- `ralph`은 `ultrawork`를 포함하므로 별도 조합 불필요
- `ecomode`는 실행 모드가 아닌 모델 라우팅 수정자

---

## 프로젝트 활용 예시

SimpleCare 프로젝트에서의 활용 시나리오입니다.

### 새 Feature 모듈 구현

```
autopilot: Exercise 모듈에 운동 기록 삭제 기능 추가해줘
```

자동으로 Domain(UseCase/Entity) → Data(Repository) → Presentation(View/Reducer) 순서로 구현합니다.

### 대규모 리팩토링

```
ralph: Meal 모듈 전체를 Clean Architecture 패턴에 맞게 리팩토링해줘
```

완료될 때까지 지속적으로 수정하고 빌드 검증합니다.

### 빌드 에러 일괄 수정

```
ulw 전체 모듈 빌드 에러 수정해줘
```

여러 모듈의 에러를 병렬로 동시 수정합니다.

### 코드 리뷰

```
/oh-my-claudecode:code-review
```

현재 변경사항에 대해 품질, 보안, 유지보수성 관점에서 리뷰합니다.

### 계획 수립

```
plan Weight 모듈에 목표 체중 달성 예측 기능을 추가하고 싶어
```

인터뷰를 통해 요구사항을 정리하고 구현 계획을 수립합니다.

---

## 설치 범위

### 현재 프로젝트 설정

OMC는 **프로젝트 단위**로 설치되어 있습니다.

| 위치 | 파일 | 역할 |
|------|------|------|
| 프로젝트 `.claude/CLAUDE.md` | OMC 핵심 설정 | 에이전트 오케스트레이션 규칙 |
| 프로젝트 `.claude/settings.json` | 로컬 설정 | 프로젝트별 설정 |
| 글로벌 `~/.claude/settings.json` | HUD 상태바 | 모든 프로젝트 공통 UI |

### 다른 프로젝트에 적용하기

다른 프로젝트에서도 OMC를 사용하려면 해당 프로젝트 디렉토리에서 설정을 실행합니다.

```
/oh-my-claudecode:omc-setup
```

또는 글로벌 설치로 모든 프로젝트에 적용할 수 있습니다.

```bash
cp .claude/CLAUDE.md ~/.claude/CLAUDE.md
```

---

## 참고 자료

- [oh-my-claudecode GitHub](https://github.com/Yeachan-Heo/oh-my-claudecode)
- [Claude Code 공식 문서](https://docs.anthropic.com/claude-code)
- [MCP Protocol](https://modelcontextprotocol.io/)
