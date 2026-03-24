//
//  AIService.swift
//  MealData
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import MealDomain
import AIServiceInfra

/// AI 서비스 구현 - AIServiceInfra를 사용
public final class AIService: AIServiceProtocol, Sendable {
    private let nutritionService: NutritionEstimationService

    public init(nutritionService: NutritionEstimationService? = nil) {
        self.nutritionService = nutritionService ?? NutritionEstimationService()
    }

    public func estimateNutrition(from text: String) async throws -> NutritionEstimation {
        let result = try await nutritionService.estimateNutrition(from: text)
        return result.toDomainModel()
    }

    public func analyzeImage(_ imageData: Data) async throws -> NutritionEstimation {
        let result = try await nutritionService.analyzeImage(imageData)
        return result.toDomainModel()
    }
}

// MARK: - Mapping

extension NutritionEstimationResult {
    func toDomainModel() -> NutritionEstimation {
        NutritionEstimation(
            foods: foods.map { $0.toDomainModel() },
            totalCalories: totalCalories,
            mealDescription: mealDescription,
            healthTip: healthTip,
            error: error
        )
    }
}

extension EstimatedFood {
    func toDomainModel() -> EstimatedFoodItem {
        EstimatedFoodItem(
            name: name,
            servingSize: servingSize,
            servingUnit: servingUnit,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            sodium: sodium,
            sugar: sugar,
            confidence: confidence
        )
    }
}
