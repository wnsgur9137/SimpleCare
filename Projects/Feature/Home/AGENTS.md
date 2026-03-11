# Home Feature

## 관련 문서
- [MODULES.md](../../../docs/02-설계/MODULES.md) - Home 모듈 상세 정의 (Home 섹션 참고)
- [HOME_SCREEN_PLAN.md](../../../docs/01-전략/HOME_SCREEN_PLAN.md) - 홈 화면 기획 문서
- [ARCHITECTURE.md](../../../docs/02-설계/ARCHITECTURE.md) - Clean Architecture 패턴

## 구조
- Domain: HomeDailySummary, HomeMealSummary, HomeExerciseSummary, HomeReport / GetDailySummaryUseCase, GetReportUseCase, GenerateDailyInsightUseCase
- Data: HomeRepository (SwiftData) / HomeInsightService, MockHomeInsightService (AI 인사이트)
- Presentation: TCA Reducer + SwiftUI (탭 코디네이터, 일일 요약 대시보드)

## 문서 동기화 규칙
코드 변경 후 아래 문서를 확인하고 필요 시 업데이트:

| 변경 유형 | 업데이트 대상 |
|----------|-------------|
| Entity 추가/수정/삭제 | `docs/02-설계/MODULES.md` → Home 섹션 |
| UseCase 추가/수정/삭제 | `docs/02-설계/MODULES.md` → Home 섹션 |
| 화면 레이아웃 변경 | `docs/01-전략/HOME_SCREEN_PLAN.md` |
| AI 인사이트 서비스 변경 | `docs/03-구현/API.md` |
| View/Coordinator 추가 | `docs/02-설계/MODULES.md` → Home 섹션 |
