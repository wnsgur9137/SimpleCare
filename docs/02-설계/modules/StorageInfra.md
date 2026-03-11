---
title: "StorageInfra 모듈"
aliases: ["StorageInfra"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/infrastructure
created: 2026-01-26
updated: 2026-03-11
status: active
---

# StorageInfra

**역할**: SwiftData 기반 로컬 데이터 영속화

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Module | `StorageInfra.swift` | 모듈 진입점 |
| Container | `StorageContainer.swift` | ModelContainer 싱글톤 관리 |
| **Models** | | |
| Model | `UserProfileModel.swift` | 사용자 프로필 SwiftData 모델 |
| Model | `MealRecordModel.swift` | 식사 기록 SwiftData 모델 |
| Model | `FoodItemModel.swift` | 음식 항목 SwiftData 모델 |
| Model | `FavoriteFoodModel.swift` | 즐겨찾기 음식 SwiftData 모델 |
| Model | `WeightRecordModel.swift` | 체중 기록 SwiftData 모델 |
| Model | `ExerciseRecordModel.swift` | 운동 기록 SwiftData 모델 |
| Model | `CustomExerciseModel.swift` | 커스텀 운동 SwiftData 모델 |
| **Repositories** | | |
| Repository | `UserProfileStorage.swift` | 프로필 데이터 접근 |
| Repository | `MealRecordRepository.swift` | 식사 기록 데이터 접근 |
| Repository | `FavoriteFoodRepository.swift` | 즐겨찾기 데이터 접근 |
| Repository | `WeightRecordRepository.swift` | 체중 기록 데이터 접근 |
| Repository | `ExerciseRecordRepository.swift` | 운동 기록 데이터 접근 |
| Repository | `CustomExerciseRepository.swift` | 커스텀 운동 데이터 접근 |

**SwiftData 모델 예시**:
```swift
@Model
public final class MealRecordModel {
    @Attribute(.unique) public var id: UUID
    public var userProfileId: UUID
    public var mealType: String
    @Relationship(deleteRule: .cascade) public var foodItems: [FoodItemModel]
    public var notes: String?
    public var recordedAt: Date
    public var totalCalories: Int
    public var totalProtein: Double
    public var totalCarbs: Double
    public var totalFat: Double
}
```
