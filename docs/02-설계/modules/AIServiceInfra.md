---
title: "AIServiceInfra 모듈"
aliases: ["AIServiceInfra"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/infrastructure
created: 2026-01-26
updated: 2026-03-11
status: active
---

# AIServiceInfra

**역할**: OpenAI GPT-4o API 연동

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Module | `AIServiceInfra.swift` | 모듈 진입점 |
| **OpenAI** | | |
| Client | `OpenAIClient.swift` | OpenAI REST API 클라이언트 |
| Config | `OpenAIConfiguration.swift` | API 키/모델 설정 |
| **Prompts** | | |
| Prompt | `NutritionPrompts.swift` | 영양 추정 시스템/유저 프롬프트 |
| **Services** | | |
| Service | `NutritionEstimationService.swift` | 텍스트 기반 영양 추정 서비스 |
| Service | `DailyInsightService.swift` | AI 일일 건강 인사이트 서비스 |

**API Key 관리**:
- `XCConfig/Debug.xcconfig`에 `OPENAI_API_KEY` 저장
- `Bundle.main.infoDictionary`에서 로드
