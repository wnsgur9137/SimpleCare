//
//  MockAIService.swift
//  MealData
//
//  Created by SimpleCare on 2/18/26.
//

import Foundation
import MealDomain

/// Mock AI Service - API 호출 없이 샘플 데이터 반환
public final class MockAIService: AIServiceProtocol, Sendable {

    public init() {}

    public func estimateNutrition(from text: String) async throws -> NutritionEstimation {
        // Simulate network delay
        try await Task.sleep(for: .milliseconds(800))

        let foods = parseTextToFoods(text)
        let totalCalories = foods.reduce(0) { $0 + $1.calories }

        return NutritionEstimation(
            foods: foods,
            totalCalories: totalCalories,
            mealDescription: "'\(text)' 분석 결과",
            healthTip: generateHealthTip(foods: foods)
        )
    }

    public func analyzeImage(_ imageData: Data) async throws -> NutritionEstimation {
        NutritionEstimation(
            foods: [],
            totalCalories: 0,
            error: "이미지 분석은 아직 지원되지 않습니다."
        )
    }

    // MARK: - Private

    private func parseTextToFoods(_ text: String) -> [EstimatedFoodItem] {
        let knownFoods = Self.foodDatabase
        var matched: [EstimatedFoodItem] = []

        let normalized = text.lowercased()
            .replacingOccurrences(of: ",", with: " ")
            .replacingOccurrences(of: "과", with: " ")
            .replacingOccurrences(of: "와", with: " ")
            .replacingOccurrences(of: "이랑", with: " ")

        for (keyword, food) in knownFoods {
            if normalized.contains(keyword) {
                if !matched.contains(food) {
                    matched.append(food)
                }
            }
        }

        if matched.isEmpty {
            matched.append(EstimatedFoodItem(
                name: text.trimmingCharacters(in: .whitespacesAndNewlines),
                servingSize: 1,
                servingUnit: "인분",
                calories: 450,
                protein: 15,
                carbs: 55,
                fat: 18,
                confidence: 0.5
            ))
        }

        return matched
    }

    private func generateHealthTip(foods: [EstimatedFoodItem]) -> String {
        let totalProtein = foods.reduce(0.0) { $0 + $1.protein }
        let totalCalories = foods.reduce(0) { $0 + $1.calories }

        if totalProtein < 15 {
            return "단백질이 부족해 보여요. 계란이나 두부를 추가해보세요!"
        } else if totalCalories > 800 {
            return "칼로리가 높은 식사예요. 다음 식사는 가볍게 드시는 것을 추천해요."
        } else {
            return "균형 잡힌 식사네요! 잘 하고 계세요."
        }
    }

    // MARK: - Food Database

    // swiftlint:disable line_length
    private static let foodDatabase: [(String, EstimatedFoodItem)] = [
        ("김치찌개", EstimatedFoodItem(name: "김치찌개", servingSize: 300, servingUnit: "g", calories: 210, protein: 12, carbs: 15, fat: 11, confidence: 0.9)),
        ("된장찌개", EstimatedFoodItem(name: "된장찌개", servingSize: 300, servingUnit: "g", calories: 180, protein: 10, carbs: 12, fat: 9, confidence: 0.9)),
        ("비빔밥", EstimatedFoodItem(name: "비빔밥", servingSize: 450, servingUnit: "g", calories: 550, protein: 18, carbs: 80, fat: 15, confidence: 0.85)),
        ("불고기", EstimatedFoodItem(name: "불고기", servingSize: 200, servingUnit: "g", calories: 340, protein: 28, carbs: 12, fat: 20, confidence: 0.85)),
        ("삼겹살", EstimatedFoodItem(name: "삼겹살", servingSize: 200, servingUnit: "g", calories: 520, protein: 24, carbs: 0, fat: 46, confidence: 0.9)),
        ("공기밥", EstimatedFoodItem(name: "공기밥", servingSize: 210, servingUnit: "g", calories: 310, protein: 5, carbs: 68, fat: 0.5, confidence: 0.95)),
        ("밥", EstimatedFoodItem(name: "공기밥", servingSize: 210, servingUnit: "g", calories: 310, protein: 5, carbs: 68, fat: 0.5, confidence: 0.95)),
        ("계란", EstimatedFoodItem(name: "계란프라이", servingSize: 60, servingUnit: "g", calories: 90, protein: 6, carbs: 1, fat: 7, confidence: 0.9)),
        ("계란프라이", EstimatedFoodItem(name: "계란프라이", servingSize: 60, servingUnit: "g", calories: 90, protein: 6, carbs: 1, fat: 7, confidence: 0.9)),
        ("토스트", EstimatedFoodItem(name: "토스트", servingSize: 60, servingUnit: "g", calories: 160, protein: 5, carbs: 28, fat: 3, confidence: 0.85)),
        ("우유", EstimatedFoodItem(name: "우유", servingSize: 200, servingUnit: "ml", calories: 130, protein: 6, carbs: 10, fat: 7, confidence: 0.95)),
        ("커피", EstimatedFoodItem(name: "아메리카노", servingSize: 355, servingUnit: "ml", calories: 5, protein: 0, carbs: 1, fat: 0, confidence: 0.9)),
        ("아메리카노", EstimatedFoodItem(name: "아메리카노", servingSize: 355, servingUnit: "ml", calories: 5, protein: 0, carbs: 1, fat: 0, confidence: 0.9)),
        ("라떼", EstimatedFoodItem(name: "카페라떼", servingSize: 355, servingUnit: "ml", calories: 180, protein: 8, carbs: 15, fat: 9, confidence: 0.85)),
        ("김치", EstimatedFoodItem(name: "김치", servingSize: 50, servingUnit: "g", calories: 15, protein: 1, carbs: 2, fat: 0.5, confidence: 0.9)),
        ("라면", EstimatedFoodItem(name: "라면", servingSize: 550, servingUnit: "g", calories: 500, protein: 10, carbs: 70, fat: 18, confidence: 0.9)),
        ("떡볶이", EstimatedFoodItem(name: "떡볶이", servingSize: 300, servingUnit: "g", calories: 380, protein: 8, carbs: 65, fat: 10, confidence: 0.85)),
        ("치킨", EstimatedFoodItem(name: "후라이드 치킨", servingSize: 200, servingUnit: "g", calories: 480, protein: 30, carbs: 15, fat: 35, confidence: 0.85)),
        ("피자", EstimatedFoodItem(name: "피자 1조각", servingSize: 150, servingUnit: "g", calories: 300, protein: 12, carbs: 35, fat: 12, confidence: 0.8)),
        ("샐러드", EstimatedFoodItem(name: "샐러드", servingSize: 200, servingUnit: "g", calories: 120, protein: 4, carbs: 10, fat: 7, confidence: 0.8)),
        ("두부", EstimatedFoodItem(name: "두부", servingSize: 150, servingUnit: "g", calories: 110, protein: 12, carbs: 3, fat: 6, confidence: 0.9)),
        ("제육볶음", EstimatedFoodItem(name: "제육볶음", servingSize: 200, servingUnit: "g", calories: 350, protein: 22, carbs: 18, fat: 20, confidence: 0.85)),
        ("김밥", EstimatedFoodItem(name: "김밥 1줄", servingSize: 250, servingUnit: "g", calories: 380, protein: 10, carbs: 55, fat: 12, confidence: 0.85)),
        ("순두부찌개", EstimatedFoodItem(name: "순두부찌개", servingSize: 350, servingUnit: "g", calories: 200, protein: 14, carbs: 10, fat: 12, confidence: 0.85)),
        ("갈비탕", EstimatedFoodItem(name: "갈비탕", servingSize: 500, servingUnit: "g", calories: 450, protein: 30, carbs: 10, fat: 30, confidence: 0.85)),
        ("냉면", EstimatedFoodItem(name: "냉면", servingSize: 500, servingUnit: "g", calories: 480, protein: 15, carbs: 75, fat: 10, confidence: 0.85)),
        ("볶음밥", EstimatedFoodItem(name: "볶음밥", servingSize: 350, servingUnit: "g", calories: 480, protein: 12, carbs: 65, fat: 18, confidence: 0.85)),
        ("고구마", EstimatedFoodItem(name: "고구마", servingSize: 150, servingUnit: "g", calories: 130, protein: 2, carbs: 30, fat: 0.2, confidence: 0.9)),
        ("바나나", EstimatedFoodItem(name: "바나나", servingSize: 120, servingUnit: "g", calories: 105, protein: 1.3, carbs: 27, fat: 0.4, confidence: 0.95)),
        ("사과", EstimatedFoodItem(name: "사과", servingSize: 200, servingUnit: "g", calories: 95, protein: 0.5, carbs: 25, fat: 0.3, confidence: 0.95)),
    ]
    // swiftlint:enable line_length
}
