//
//  HomeDailySummaryTests.swift
//  HomeTests
//
//  Created by SimpleCare on 3/18/26.
//

import XCTest
@testable import HomeDomain

final class HomeDailySummaryTests: XCTestCase {

    // MARK: - Remaining Calories

    func testRemainingCalories_noExercise() {
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 1200,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        // 2000 - 1200 + 0 = 800
        XCTAssertEqual(summary.remainingCalories, 800)
    }

    func testRemainingCalories_withExercise() {
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 1800,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0,
            exerciseCalories: 300
        )
        // 2000 - 1800 + 300 = 500
        XCTAssertEqual(summary.remainingCalories, 500)
    }

    func testRemainingCalories_exceeded() {
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 2500,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.remainingCalories, -500)
    }

    // MARK: - Calorie Progress

    func testCalorieProgress_halfWay() {
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 1000,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieProgress, 0.5, accuracy: 0.01)
    }

    func testCalorieProgress_zeroGoal() {
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 1000,
            goalCalories: 0,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieProgress, 0)
    }

    func testCalorieProgress_exceeded() {
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 2400,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieProgress, 1.2, accuracy: 0.01)
    }

    // MARK: - Calorie Status

    func testCalorieStatus_under() {
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 1000,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieStatus, .under)
    }

    func testCalorieStatus_onTrack() {
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 1900,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieStatus, .onTrack)
    }

    func testCalorieStatus_over() {
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 2300,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieStatus, .over)
    }

    func testCalorieStatus_boundary_0_8() {
        // 0.8 * 2000 = 1600 → exactly at boundary → onTrack
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 1600,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieStatus, .onTrack)
    }

    func testCalorieStatus_boundary_1_1() {
        // 1.1 * 2000 = 2200 → exactly at boundary → onTrack
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 2200,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieStatus, .onTrack)
    }

    // MARK: - Macro Progress

    func testProteinProgress_halfGoal() {
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 0,
            goalCalories: 2000,
            totalProtein: 50,
            totalCarbs: 0,
            totalFat: 0,
            proteinGoal: 100
        )
        XCTAssertEqual(summary.proteinProgress, 0.5, accuracy: 0.01)
    }

    func testProteinProgress_exceedsGoal_clampedToOne() {
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 0,
            goalCalories: 2000,
            totalProtein: 150,
            totalCarbs: 0,
            totalFat: 0,
            proteinGoal: 100
        )
        XCTAssertEqual(summary.proteinProgress, 1.0, accuracy: 0.01)
    }

    func testProteinProgress_zeroGoal() {
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 0,
            goalCalories: 2000,
            totalProtein: 50,
            totalCarbs: 0,
            totalFat: 0,
            proteinGoal: 0
        )
        XCTAssertEqual(summary.proteinProgress, 0)
    }

    // MARK: - Has Records

    func testHasRecords_withMeals() {
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 0,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0,
            meals: [HomeMealSummary(id: UUID(), mealType: .breakfast, foodNames: ["Rice"], totalCalories: 200)]
        )
        XCTAssertTrue(summary.hasRecords)
    }

    func testHasRecords_empty() {
        let summary = HomeDailySummary(
            date: Date(),
            totalCalories: 0,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertFalse(summary.hasRecords)
    }
}

// MARK: - MacroAverage Tests

final class MacroAverageTests: XCTestCase {

    func testTotal() {
        let macro = MacroAverage(protein: 100, carbs: 250, fat: 70)
        XCTAssertEqual(macro.total, 420)
    }

    func testRatios() {
        let macro = MacroAverage(protein: 100, carbs: 200, fat: 100)
        // total = 400
        XCTAssertEqual(macro.proteinRatio, 0.25, accuracy: 0.01)
        XCTAssertEqual(macro.carbsRatio, 0.50, accuracy: 0.01)
        XCTAssertEqual(macro.fatRatio, 0.25, accuracy: 0.01)
    }

    func testRatios_zeroTotal() {
        let macro = MacroAverage(protein: 0, carbs: 0, fat: 0)
        XCTAssertEqual(macro.proteinRatio, 0)
        XCTAssertEqual(macro.carbsRatio, 0)
        XCTAssertEqual(macro.fatRatio, 0)
    }

    func testRatios_sumToOne() {
        let macro = MacroAverage(protein: 80, carbs: 300, fat: 65)
        let sum = macro.proteinRatio + macro.carbsRatio + macro.fatRatio
        XCTAssertEqual(sum, 1.0, accuracy: 0.001)
    }
}

// MARK: - WeeklyReport Tests

final class WeeklyReportTests: XCTestCase {

    func testGoalAchievementRate() {
        let report = WeeklyReport(
            weekStartDate: Date(),
            avgDailyCalories: 1800,
            totalExerciseMinutes: 0,
            totalExerciseCalories: 0,
            weightChange: nil,
            streakDays: 0,
            dailyCalories: [],
            goalCalories: 2000
        )
        XCTAssertEqual(report.goalAchievementRate, 0.9, accuracy: 0.01)
    }

    func testGoalAchievementRate_zeroGoal() {
        let report = WeeklyReport(
            weekStartDate: Date(),
            avgDailyCalories: 1800,
            totalExerciseMinutes: 0,
            totalExerciseCalories: 0,
            weightChange: nil,
            streakDays: 0,
            dailyCalories: [],
            goalCalories: 0
        )
        XCTAssertEqual(report.goalAchievementRate, 0)
    }
}
