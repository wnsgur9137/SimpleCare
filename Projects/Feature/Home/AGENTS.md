# Home Feature

## 관련 문서
- [MODULES.md](../../../docs/02-설계/MODULES.md) - Home 모듈 상세 정의 (Home 섹션 참고)
- [HOME_SCREEN_PLAN.md](../../../docs/01-전략/HOME_SCREEN_PLAN.md) - 홈 화면 기획 문서
- [ARCHITECTURE.md](../../../docs/02-설계/ARCHITECTURE.md) - Clean Architecture 패턴

## 구조
- Domain: HomeDailySummary, HomeMealSummary, HomeExerciseSummary, HomeReport / GetDailySummaryUseCase, GetReportUseCase, GenerateDailyInsightUseCase
- Data: HomeRepository (SwiftData) / HomeInsightService, MockHomeInsightService (AI 인사이트)
- Presentation: TCA Reducer + SwiftUI (탭 코디네이터, 일일 요약 대시보드)
