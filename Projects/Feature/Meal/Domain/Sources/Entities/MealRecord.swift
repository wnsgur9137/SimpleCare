//
//  MealRecord.swift
//  MealDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import BaseDomain

/// 식사 유형
public enum MealType: String, Codable, CaseIterable, Sendable {
    case breakfast
    case lunch
    case dinner
    case snack

    public var displayName: String {
        switch self {
        case .breakfast: return "meal.breakfast".localized
        case .lunch: return "meal.lunch".localized
        case .dinner: return "meal.dinner".localized
        case .snack: return "meal.snack".localized
        }
    }

    public var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "sunset.fill"
        case .snack: return "leaf.fill"
        }
    }
}

/// 식사 기록 엔티티
public struct MealRecord: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let userProfileId: UUID
    public var mealType: MealType
    public var date: Date
    public var foodItems: [FoodItem]
    public var notes: String?
    public var imageDataPath: String?
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        userProfileId: UUID,
        mealType: MealType,
        date: Date = Date(),
        foodItems: [FoodItem] = [],
        notes: String? = nil,
        imageDataPath: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userProfileId = userProfileId
        self.mealType = mealType
        self.date = date
        self.foodItems = foodItems
        self.notes = notes
        self.imageDataPath = imageDataPath
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var totalCalories: Int {
        foodItems.reduce(0) { $0 + $1.calories }
    }

    public var totalProtein: Double {
        foodItems.reduce(0) { $0 + $1.proteinGrams }
    }

    public var totalCarbs: Double {
        foodItems.reduce(0) { $0 + $1.carbsGrams }
    }

    public var totalFat: Double {
        foodItems.reduce(0) { $0 + $1.fatGrams }
    }
}

/// 음식 항목 엔티티
public struct FoodItem: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var brand: String?
    public var servingSize: Double
    public var servingUnit: String
    public var quantity: Double
    public var caloriesPerServing: Int
    public var proteinPerServing: Double
    public var carbsPerServing: Double
    public var fatPerServing: Double
    public var fiberPerServing: Double?
    public var sodiumPerServing: Double?
    public var sugarPerServing: Double?
    public var nutritionSource: NutritionSource
    public var aiConfidence: Double?
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        brand: String? = nil,
        servingSize: Double = 100,
        servingUnit: String = "g",
        quantity: Double = 1.0,
        caloriesPerServing: Int,
        proteinPerServing: Double,
        carbsPerServing: Double,
        fatPerServing: Double,
        fiberPerServing: Double? = nil,
        sodiumPerServing: Double? = nil,
        sugarPerServing: Double? = nil,
        nutritionSource: NutritionSource = .manual,
        aiConfidence: Double? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.quantity = quantity
        self.caloriesPerServing = caloriesPerServing
        self.proteinPerServing = proteinPerServing
        self.carbsPerServing = carbsPerServing
        self.fatPerServing = fatPerServing
        self.fiberPerServing = fiberPerServing
        self.sodiumPerServing = sodiumPerServing
        self.sugarPerServing = sugarPerServing
        self.nutritionSource = nutritionSource
        self.aiConfidence = aiConfidence
        self.createdAt = createdAt
    }

    public var calories: Int {
        Int(Double(caloriesPerServing) * quantity)
    }

    public var proteinGrams: Double {
        proteinPerServing * quantity
    }

    public var carbsGrams: Double {
        carbsPerServing * quantity
    }

    public var fatGrams: Double {
        fatPerServing * quantity
    }
}

/// 영양 정보 출처
public enum NutritionSource: String, Codable, Sendable {
    case aiEstimated
    case manual
    case database
    case barcode
}
