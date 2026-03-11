# Meal Feature

## 관련 문서
- [MODULES.md](../../../docs/02-설계/MODULES.md) - Meal 모듈 상세 정의 (Meal 섹션 참고)
- [API.md](../../../docs/03-구현/API.md) - OpenAI API 연동 명세
- [ARCHITECTURE.md](../../../docs/02-설계/ARCHITECTURE.md) - Clean Architecture 패턴

## 구조
- Domain: MealRecord, FavoriteFood / RecordMealUseCase, FetchMealUseCase, EstimateMealNutritionUseCase, DeleteMealUseCase, UpdateMealUseCase, GetMealHistoryUseCase, FavoriteFoodUseCases
- Data: MealRepository, FavoriteFoodDataRepository (SwiftData) / AIService, MockAIService (OpenAI)
- Presentation: TCA Reducer + SwiftUI

## 문서 동기화 규칙
코드 변경 후 아래 문서를 확인하고 필요 시 업데이트:

| 변경 유형 | 업데이트 대상 |
|----------|-------------|
| Entity 추가/수정/삭제 | `docs/02-설계/MODULES.md` → Meal 섹션 |
| UseCase 추가/수정/삭제 | `docs/02-설계/MODULES.md` → Meal 섹션 |
| AI 프롬프트 변경 | `docs/03-구현/API.md` |
| API 응답 스키마 변경 | `docs/03-구현/API.md` |
| View/Coordinator 추가 | `docs/02-설계/MODULES.md` → Meal 섹션 |
