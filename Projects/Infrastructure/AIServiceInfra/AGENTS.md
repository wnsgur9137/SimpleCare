# AIServiceInfra

## 관련 문서
- [ARCHITECTURE.md](../../../docs/02-설계/ARCHITECTURE.md) - Clean Architecture 인프라 계층
- [API.md](../../../docs/03-구현/API.md) - Google Gemini API 연동 명세

## 구조
- Gemini: GeminiClient, GeminiConfiguration (Gemini REST API 클라이언트)
- OpenAI (레거시): OpenAIClient, OpenAIConfiguration (미사용, 보존)
- Services: NutritionEstimationService (식사 영양 분석), DailyInsightService (일일 인사이트)
- Prompts: NutritionPrompts (AI 프롬프트 템플릿)

## 문서 동기화 규칙
코드 변경 후 아래 문서를 확인하고 필요 시 업데이트:

| 변경 유형 | 업데이트 대상 |
|----------|-------------|
| API 클라이언트 변경 | `docs/03-구현/API.md` |
| 서비스 추가/수정 | `docs/02-설계/ARCHITECTURE.md` |
| 프롬프트 템플릿 변경 | `docs/03-구현/API.md` |
| Configuration 변경 | `docs/03-구현/SETUP.md` |
