# Meal Feature

## 관련 문서
- [MODULES.md](../../../docs/02-설계/MODULES.md) - Meal 모듈 상세 정의 (Meal 섹션 참고)
- [API.md](../../../docs/03-구현/API.md) - OpenAI API 연동 명세
- [ARCHITECTURE.md](../../../docs/02-설계/ARCHITECTURE.md) - Clean Architecture 패턴

## 구조
- Domain: MealRecord, FavoriteFood / RecordMealUseCase, FetchMealUseCase, EstimateMealNutritionUseCase, DeleteMealUseCase, UpdateMealUseCase, GetMealHistoryUseCase, FavoriteFoodUseCases
- Data: MealRepository, FavoriteFoodDataRepository (SwiftData) / AIService, MockAIService (OpenAI)
- Presentation: TCA Reducer + SwiftUI
