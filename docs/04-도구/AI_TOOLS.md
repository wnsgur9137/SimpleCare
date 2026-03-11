# AI 도구 활용 가이드

본 문서는 SimpleCare 프로젝트에서 활용하고 있는 AI 도구들과 그 활용 방법에 대해 설명합니다.

## 목차

1. [개요](#개요)
2. [PR 리뷰 자동화](#pr-리뷰-자동화)
3. [AI 교차검증 프로세스](#ai-교차검증-프로세스)
4. [MCP 서버 구성](#mcp-서버-구성)
5. [코드 리뷰 규칙](#코드-리뷰-규칙)

---

## 개요

SimpleCare 프로젝트는 개발 생산성 향상과 코드 품질 유지를 위해 다양한 AI 도구를 활용하고 있습니다. 각 AI 도구의 장점을 살려 상호 보완적으로 운영하며, 교차검증을 통해 더 정확하고 신뢰성 있는 결과물을 도출합니다.

### 사용 중인 AI 도구

| 도구 | 용도 |
|------|------|
| **Claude Code** | 코드 작성, 리팩토링, PR 생성 |
| **Gemini Code Assist** | 자동 PR 리뷰 |
| **ChatGPT** | 교차검증 |
| **Claude** | 교차검증 |
| **Gemini** | 교차검증 |

---

## PR 리뷰 자동화

### Claude Code

Claude Code는 CLI 기반의 AI 개발 도구로, 프로젝트의 주요 개발 작업을 담당합니다.

**주요 기능:**
- 코드 작성 및 리팩토링
- 버그 수정 및 디버깅
- PR 생성 및 커밋 메시지 작성
- MCP 서버를 통한 GitHub API 연동

**설정 파일:** `.claude/settings.local.json`

```json
{
  "permissions": {
    "allow": [
      "Bash(git reset:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)"
    ]
  },
  "enableAllProjectMcpServers": true
}
```

### Gemini Code Assist

GitHub에 PR이 생성되면 Gemini Code Assist가 자동으로 코드 리뷰를 수행합니다.

**특징:**
- PR 생성 시 자동 트리거
- 우선순위별 피드백 제공 (Critical, Medium, Low)
- 코드 변경사항에 대한 인라인 코멘트
- PR 요약 및 변경사항 하이라이트

**우선순위 분류:**
- 🔴 **Critical**: 보안 취약점, 크래시 유발, 데이터 손실 가능성
- 🟠 **Medium**: 아키텍처 위반, 성능 이슈, 접근성 문제
- 🟡 **Low**: 코드 스타일, 문서화, 포매팅

**설정 파일:** `.gemini/styleguide.md`

---

## AI 교차검증 프로세스

### 교차검증이란?

단일 AI의 응답에 의존하지 않고, 여러 AI 모델의 관점을 비교·분석하여 더 정확하고 균형 잡힌 결론을 도출하는 프로세스입니다.

### 교차검증 활용 AI

- **ChatGPT** (OpenAI)
- **Claude** (Anthropic)
- **Gemini** (Google)

### 교차검증 워크플로우

```
┌─────────────────────────────────────────────────────────────────┐
│                      교차검증 프로세스                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   1. 문제 정의 및 요구사항 정리                                    │
│         │                                                       │
│         ▼                                                       │
│   ┌─────────────┬─────────────┬─────────────┐                   │
│   │   ChatGPT   │   Claude    │   Gemini    │                   │
│   └──────┬──────┴──────┬──────┴──────┬──────┘                   │
│          │             │             │                          │
│          └─────────────┼─────────────┘                          │
│                        ▼                                        │
│   2. 각 AI 응답 비교 및 분석                                       │
│         │                                                       │
│         ▼                                                       │
│   3. 공통점 추출 및 차이점 검토                                     │
│         │                                                       │
│         ▼                                                       │
│   4. 최적의 솔루션 도출                                            │
│         │                                                       │
│         ▼                                                       │
│   5. 구현 및 추가 검증                                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 교차검증 적용 시나리오

| 시나리오 | 검증 방법 | 기대 효과 |
|---------|----------|----------|
| 아키텍처 설계 | 3개 AI에 동일 요구사항 제시 후 비교 | 다양한 관점의 설계안 확보 |
| 복잡한 버그 수정 | 각 AI에 문제 상황 설명 후 해결책 비교 | 근본 원인 파악 및 최적 해결책 도출 |
| 성능 최적화 | 현재 코드 분석 요청 후 개선안 비교 | 다각도 최적화 전략 수립 |
| 보안 검토 | 코드 보안 취약점 분석 요청 | 누락된 취약점 발견 가능성 증가 |

### 교차검증 체크리스트

- [ ] 최소 2개 이상의 AI에 동일한 질문/요청 수행
- [ ] 각 AI의 응답에서 공통되는 핵심 포인트 추출
- [ ] 상충되는 의견이 있는 경우 근거 비교 분석
- [ ] 최종 결정에 대한 이유 문서화
- [ ] 구현 후 결과 검증

---

## MCP 서버 구성

MCP(Model Context Protocol)는 Claude Code가 외부 서비스와 연동하기 위한 프로토콜입니다.

**설정 파일:** `.mcp.json`

### GitHub MCP Server

GitHub API와 연동하여 PR, Issue, Repository 관리 기능을 제공합니다.

**실행 환경:** Docker 컨테이너

```json
{
  "github": {
    "type": "stdio",
    "command": "docker",
    "args": [
      "run",
      "-i",
      "--rm",
      "-e",
      "GITHUB_PERSONAL_ACCESS_TOKEN",
      "ghcr.io/github/github-mcp-server"
    ],
    "env": {
      "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
    }
  }
}
```

**주요 기능:**
- PR 생성, 조회, 업데이트
- Issue 관리
- 리뷰 코멘트 조회
- 브랜치 관리
- 워크플로우 실행

**Docker 사용 이유:**
- 환경 격리를 통한 보안 강화
- 일관된 실행 환경 보장
- 의존성 관리 간소화
- 쉬운 버전 업데이트

### Sosumi (Apple Developer Documentation)

Apple 개발자 문서 검색 및 조회 기능을 제공합니다.

```json
{
  "sosumi": {
    "command": "npx",
    "args": [
      "-y",
      "mcp-remote",
      "https://sosumi.ai/mcp"
    ]
  }
}
```

**주요 기능:**
- Apple Developer Documentation 검색
- Human Interface Guidelines 조회
- SwiftUI, UIKit API 문서 참조

### Shrimp Task Manager

프로젝트 태스크 관리를 위한 MCP 서버입니다.

```json
{
  "shrimp-task-manager": {
    "command": "npx",
    "args": ["-y", "mcp-shrimp-task-manager"],
    "env": {
      "DATA_DIR": "/Users/junhyeok/shrimp_data",
      "TEMPLATES_USE": "ko",
      "ENABLE_GUI": "true",
      "WEB_PORT": "3000"
    }
  }
}
```

**주요 기능:**
- 태스크 생성 및 관리
- 의존성 추적
- GUI 웹 인터페이스 (localhost:3000)

---

## 코드 리뷰 규칙

자동화된 코드 리뷰에 적용되는 규칙들입니다.

**설정 파일:** `.github/universal-codereview-config.json`

### 아키텍처 검증

| 레이어 | 허용 컴포넌트 | 의존 방향 |
|--------|-------------|----------|
| Data | Repository, DataSource, DTO, Model | → Domain |
| Domain | UseCase, Entity, Repository, Service | (독립) |
| Presentation | ViewController, ViewModel, View, Coordinator | → Domain |

### Swift 컨벤션

| 항목 | 규칙 |
|------|------|
| Classes/Structs | PascalCase |
| Variables/Functions | camelCase |
| Enum Cases | camelCase |
| Protocols | PascalCase |

### 금지 패턴

- `forEach { ... addSubview }` 사용 금지
- UI에 하드코딩된 문자열 금지
- 프로덕션 코드에서 force unwrap 금지
- Strong retain cycle 금지

### 리뷰 가중치

| 카테고리 | 가중치 |
|---------|-------|
| 아키텍처 준수 | 30% |
| 코드 품질 | 25% |
| UI 일관성 | 20% |
| 유지보수성 | 15% |
| 보안 | 10% |

---

## 참고 자료

- [Claude Code 공식 문서](https://docs.anthropic.com/claude-code)
- [Gemini Code Assist](https://cloud.google.com/gemini/docs/codeassist)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
- [MCP Protocol](https://modelcontextprotocol.io/)
