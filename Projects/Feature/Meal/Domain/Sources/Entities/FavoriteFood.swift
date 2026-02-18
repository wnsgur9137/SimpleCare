//
//  FavoriteFood.swift
//  MealDomain
//
//  Created by SimpleCare on 2/18/26.
//

import Foundation

/// 즐겨찾기 음식 도메인 엔티티
public struct FavoriteFood: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let userProfileId: UUID
    public var name: String
    public var brand: String?
    public var servingSize: Double
    public var servingUnit: String
    public var caloriesPerServing: Int
    public var proteinPerServing: Double
    public var carbsPerServing: Double
    public var fatPerServing: Double
    public var usageCount: Int
    public var lastUsedAt: Date?

    public init(
        id: UUID = UUID(),
        userProfileId: UUID,
        name: String,
        brand: String? = nil,
        servingSize: Double = 100,
        servingUnit: String = "g",
        caloriesPerServing: Int,
        proteinPerServing: Double,
        carbsPerServing: Double,
        fatPerServing: Double,
        usageCount: Int = 0,
        lastUsedAt: Date? = nil
    ) {
        self.id = id
        self.userProfileId = userProfileId
        self.name = name
        self.brand = brand
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.caloriesPerServing = caloriesPerServing
        self.proteinPerServing = proteinPerServing
        self.carbsPerServing = carbsPerServing
        self.fatPerServing = fatPerServing
        self.usageCount = usageCount
        self.lastUsedAt = lastUsedAt
    }

    /// EstimatedFoodItem으로 변환
    public func toEstimatedFoodItem() -> EstimatedFoodItem {
        EstimatedFoodItem(
            name: name,
            servingSize: servingSize,
            servingUnit: servingUnit,
            calories: caloriesPerServing,
            protein: proteinPerServing,
            carbs: carbsPerServing,
            fat: fatPerServing,
            confidence: 1.0
        )
    }

    /// EstimatedFoodItem에서 FavoriteFood 생성
    public static func from(_ food: EstimatedFoodItem, userProfileId: UUID) -> FavoriteFood {
        FavoriteFood(
            userProfileId: userProfileId,
            name: food.name,
            servingSize: food.servingSize,
            servingUnit: food.servingUnit,
            caloriesPerServing: food.calories,
            proteinPerServing: food.protein,
            carbsPerServing: food.carbs,
            fatPerServing: food.fat
        )
    }
}
