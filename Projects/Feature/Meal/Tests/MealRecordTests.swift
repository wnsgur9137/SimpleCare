//
//  MealRecordTests.swift
//  MealTests
//
//  Created by SimpleCare on 3/18/26.
//

import XCTest
@testable import MealDomain

final class MealRecordTests: XCTestCase {

    // MARK: - FoodItem Calculations

    func testFoodItem_calories_singleServing() {
        let food = FoodItem(
            name: "Rice",
            caloriesPerServing: 200,
            proteinPerServing: 4.0,
            carbsPerServing: 45.0,
            fatPerServing: 0.5
        )
        XCTAssertEqual(food.calories, 200)
    }

    func testFoodItem_calories_multipleServings() {
        let food = FoodItem(
            name: "Rice",
            quantity: 2.0,
            caloriesPerServing: 200,
            proteinPerServing: 4.0,
            carbsPerServing: 45.0,
            fatPerServing: 0.5
        )
        XCTAssertEqual(food.calories, 400)
    }

    func testFoodItem_macros_withQuantity() {
        let food = FoodItem(
            name: "Chicken Breast",
            quantity: 1.5,
            caloriesPerServing: 165,
            proteinPerServing: 31.0,
            carbsPerServing: 0.0,
            fatPerServing: 3.6
        )
        XCTAssertEqual(food.proteinGrams, 46.5, accuracy: 0.01)
        XCTAssertEqual(food.carbsGrams, 0.0)
        XCTAssertEqual(food.fatGrams, 5.4, accuracy: 0.01)
    }

    func testFoodItem_fractionalQuantity() {
        let food = FoodItem(
            name: "Egg",
            quantity: 0.5,
            caloriesPerServing: 78,
            proteinPerServing: 6.0,
            carbsPerServing: 0.6,
            fatPerServing: 5.0
        )
        XCTAssertEqual(food.calories, 39)
        XCTAssertEqual(food.proteinGrams, 3.0, accuracy: 0.01)
    }

    // MARK: - MealRecord Totals

    func testMealRecord_totalCalories() {
        let meal = MealRecord(
            userProfileId: UUID(),
            mealType: .lunch,
            foodItems: [
                FoodItem(name: "Rice", caloriesPerServing: 200, proteinPerServing: 4, carbsPerServing: 45, fatPerServing: 0.5),
                FoodItem(name: "Chicken", caloriesPerServing: 165, proteinPerServing: 31, carbsPerServing: 0, fatPerServing: 3.6),
            ]
        )
        XCTAssertEqual(meal.totalCalories, 365)
    }

    func testMealRecord_totalMacros() {
        let meal = MealRecord(
            userProfileId: UUID(),
            mealType: .dinner,
            foodItems: [
                FoodItem(name: "A", caloriesPerServing: 100, proteinPerServing: 10, carbsPerServing: 20, fatPerServing: 5),
                FoodItem(name: "B", caloriesPerServing: 200, proteinPerServing: 15, carbsPerServing: 30, fatPerServing: 8),
            ]
        )
        XCTAssertEqual(meal.totalProtein, 25.0, accuracy: 0.01)
        XCTAssertEqual(meal.totalCarbs, 50.0, accuracy: 0.01)
        XCTAssertEqual(meal.totalFat, 13.0, accuracy: 0.01)
    }

    func testMealRecord_emptyFoodItems() {
        let meal = MealRecord(
            userProfileId: UUID(),
            mealType: .breakfast,
            foodItems: []
        )
        XCTAssertEqual(meal.totalCalories, 0)
        XCTAssertEqual(meal.totalProtein, 0)
        XCTAssertEqual(meal.totalCarbs, 0)
        XCTAssertEqual(meal.totalFat, 0)
    }

    func testMealRecord_multipleQuantityFoods() {
        let meal = MealRecord(
            userProfileId: UUID(),
            mealType: .snack,
            foodItems: [
                FoodItem(name: "Cookie", quantity: 3.0, caloriesPerServing: 80, proteinPerServing: 1, carbsPerServing: 12, fatPerServing: 4),
            ]
        )
        XCTAssertEqual(meal.totalCalories, 240)
        XCTAssertEqual(meal.totalProtein, 3.0, accuracy: 0.01)
    }
}
