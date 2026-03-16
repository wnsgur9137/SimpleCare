---
title: "AIServiceInfra 모듈"
aliases: ["AIServiceInfra"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/infrastructure
created: 2026-01-26
updated: 2026-03-16
status: active
---

# AIServiceInfra

**역할**: Google Gemini API 연동 (무료 티어)

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Module | `AIServiceInfra.swift` | 모듈 진입점 |
| **Gemini** | | |
| Client | `GeminiClient.swift` | Gemini REST API 클라이언트 |
| Config | `GeminiConfiguration.swift` | API 키/모델 설정 |
| **OpenAI (레거시)** | | |
| Client | `OpenAIClient.swift` | OpenAI REST API 클라이언트 (미사용, 보존) |
| Config | `OpenAIConfiguration.swift` | API 키/모델 설정 (미사용, 보존) |
| **Prompts** | | |
| Prompt | `NutritionPrompts.swift` | 영양 추정 시스템/유저 프롬프트 |
| **Services** | | |
| Service | `NutritionEstimationService.swift` | 텍스트 기반 영양 추정 서비스 |
| Service | `DailyInsightService.swift` | AI 일일 건강 인사이트 서비스 |

**API Key 관리**:
- `XCConfig/DEV.xcconfig`에 `GEMINI_API_KEY` 저장
- `Bundle.main.infoDictionary`에서 로드
- [Google AI Studio](https://aistudio.google.com/)에서 무료 키 발급

**모델 선택**:
- 영양 추정: `gemini-2.5-flash` (빠르고 정확)
- 일일 인사이트: `gemini-2.5-flash-lite` (경량, 빠른 응답)
