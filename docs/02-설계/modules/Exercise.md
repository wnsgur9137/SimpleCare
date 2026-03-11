---
title: "Exercise 모듈"
aliases: ["Exercise"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/feature
created: 2026-01-26
updated: 2026-03-11
status: active
---

# Exercise

**역할**: MET 기반 운동 기록 및 칼로리 소모 계산

| 레이어 | 파일 | 설명 |
|--------|------|------|
| **Domain** | | |
| Entity | `ExerciseRecord.swift` | 운동 기록 (운동 종류, 강도, 시간, 칼로리) |
| Entity | `CustomExercise.swift` | 사용자 정의 운동 |
| UseCase | `ExerciseUseCases.swift` | 운동 CRUD (기록/조회/수정/삭제) |
| UseCase | `CustomExerciseUseCases.swift` | 커스텀 운동 CRUD |
| **Data** | | |
| Repository | `ExerciseRepository.swift` | 운동 레포지토리 구현 |
| Repository | `CustomExerciseDataRepository.swift` | 커스텀 운동 레포지토리 구현 |
| **Presentation** | | |
| Coordinator | `ExerciseCoordinator.swift` | 운동 화면 네비게이션 |
| Reducer | `ExerciseFeature.swift` | 운동 기록 TCA Reducer |
| Reducer | `ExerciseListFeature.swift` | 운동 목록 TCA Reducer |
| Reducer | `ExerciseDetailFeature.swift` | 운동 상세 TCA Reducer |
| View | `ExerciseRecordView.swift` | 운동 기록 UI |
| View | `ExerciseListView.swift` | 운동 목록 UI |
| View | `ExerciseDetailView.swift` | 운동 상세 UI (편집/삭제) |
| **Aggregator** | | |
| DIContainer | `ExerciseDIContainer.swift` | 의존성 조립 |

**MET (Metabolic Equivalent of Task) 계산**:
```
소모 칼로리 = MET × 체중(kg) × 시간(h)
```

| 운동 | 강도 | MET |
|-----|------|-----|
| 걷기 | 보통 | 3.5 |
| 달리기 | 보통 | 8.0 |
| 자전거 | 보통 | 7.0 |
| 수영 | 보통 | 6.0 |
| 근력운동 | 보통 | 5.0 |
