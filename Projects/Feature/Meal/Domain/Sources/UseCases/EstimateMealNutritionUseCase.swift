//
//  EstimateMealNutritionUseCase.swift
//  MealDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// AI 영양 추정 결과
public struct NutritionEstimation: Equatable, Sendable {
    public let foods: [EstimatedFoodItem]
    public let totalCalories: Int
    public let mealDescription: String?
    public let healthTip: String?
    public let error: String?

    public init(
        foods: [EstimatedFoodItem],
        totalCalories: Int,
        mealDescription: String? = nil,
        healthTip: String? = nil,
        error: String? = nil
    ) {
        self.foods = foods
        self.totalCalories = totalCalories
        self.mealDescription = mealDescription
        self.healthTip = healthTip
        self.error = error
    }
}

/// AI가 추정한 음식 항목
public struct EstimatedFoodItem: Equatable, Sendable {
    public let name: String
    public let servingSize: Double
    public let servingUnit: String
    public let calories: Int
    public let protein: Double
    public let carbs: Double
    public let fat: Double
    public let confidence: Double

    public init(
        name: String,
        servingSize: Double,
        servingUnit: String,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        confidence: Double
    ) {
        self.name = name
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.confidence = confidence
    }

    /// FoodItem으로 변환
    public func toFoodItem() -> FoodItem {
        FoodItem(
            name: name,
            servingSize: servingSize,
            servingUnit: servingUnit,
            quantity: 1.0,
            caloriesPerServing: calories,
            proteinPerServing: protein,
            carbsPerServing: carbs,
            fatPerServing: fat,
            nutritionSource: .aiEstimated,
            aiConfidence: confidence
        )
    }
}

/// 텍스트 기반 영양 추정 UseCase
public protocol EstimateMealNutritionUseCaseProtocol: Sendable {
    func execute(text: String) async throws -> NutritionEstimation
}

/// 이미지 기반 영양 추정 UseCase
public protocol AnalyzeMealImageUseCaseProtocol: Sendable {
    func execute(imageData: Data) async throws -> NutritionEstimation
}

/// AI 서비스 프로토콜 (Data layer에서 구현)
public protocol AIServiceProtocol: Sendable {
    func estimateNutrition(from text: String) async throws -> NutritionEstimation
    func analyzeImage(_ imageData: Data) async throws -> NutritionEstimation
}

public struct EstimateMealNutritionUseCase: EstimateMealNutritionUseCaseProtocol {
    private let aiService: AIServiceProtocol

    public init(aiService: AIServiceProtocol) {
        self.aiService = aiService
    }

    public func execute(text: String) async throws -> NutritionEstimation {
        try await aiService.estimateNutrition(from: text)
    }
}

public struct AnalyzeMealImageUseCase: AnalyzeMealImageUseCaseProtocol {
    private let aiService: AIServiceProtocol

    public init(aiService: AIServiceProtocol) {
        self.aiService = aiService
    }

    public func execute(imageData: Data) async throws -> NutritionEstimation {
        try await aiService.analyzeImage(imageData)
    }
}
