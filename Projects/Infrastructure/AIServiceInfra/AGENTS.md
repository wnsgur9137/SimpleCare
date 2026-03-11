# AIServiceInfra

## 관련 문서
- [ARCHITECTURE.md](../../../docs/02-설계/ARCHITECTURE.md) - Clean Architecture 인프라 계층
- [API.md](../../../docs/03-구현/API.md) - OpenAI API 연동 명세

## 구조
- OpenAI: OpenAIClient, OpenAIConfiguration (GPT-4o REST API 클라이언트)
- Services: NutritionEstimationService (식사 영양 분석), DailyInsightService (일일 인사이트)
- Prompts: NutritionPrompts (AI 프롬프트 템플릿)
