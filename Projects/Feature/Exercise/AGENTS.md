# Exercise Feature

## 관련 문서
- [MODULES.md](../../../docs/02-설계/MODULES.md) - Exercise 모듈 상세 정의 (Exercise 섹션 참고)
- [ARCHITECTURE.md](../../../docs/02-설계/ARCHITECTURE.md) - Clean Architecture 패턴

## 구조
- Domain: ExerciseRecord, CustomExercise / ExerciseUseCases, CustomExerciseUseCases
- Data: ExerciseRepository, CustomExerciseDataRepository (SwiftData)
- Presentation: TCA Reducer + SwiftUI (MET 기반 칼로리 계산)
