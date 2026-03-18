//
//  HomeDailySummaryTests.swift
//  HomeTests
//
//  Created by SimpleCare on 3/18/26.
//

import XCTest
@testable import HomeDomain

final class HomeDailySummaryTests: XCTestCase {

    private let fixedDate = Date(timeIntervalSince1970: 1710720000) // 2024-03-18 00:00:00 GMT

    // MARK: - Remaining Calories

    func test_잔여칼로리_운동없음() {
        let summary = HomeDailySummary(
            date: fixedDate,
            totalCalories: 1200,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.remainingCalories, 2000 - 1200 + 0)
    }

    func test_잔여칼로리_운동포함() {
        let summary = HomeDailySummary(
            date: fixedDate,
            totalCalories: 1800,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0,
            exerciseCalories: 300
        )
        XCTAssertEqual(summary.remainingCalories, 2000 - 1800 + 300)
    }

    func test_잔여칼로리_초과() {
        let summary = HomeDailySummary(
            date: fixedDate,
            totalCalories: 2500,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.remainingCalories, -500)
    }

    // MARK: - Calorie Progress

    func test_칼로리진행률_절반() {
        let summary = HomeDailySummary(
            date: fixedDate,
            totalCalories: 1000,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieProgress, 0.5, accuracy: 0.01)
    }

    func test_칼로리진행률_목표0() {
        let summary = HomeDailySummary(
            date: fixedDate,
            totalCalories: 1000,
            goalCalories: 0,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieProgress, 0)
    }

    func test_칼로리진행률_초과() {
        let summary = HomeDailySummary(
            date: fixedDate,
            totalCalories: 2400,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieProgress, 1.2, accuracy: 0.01)
    }

    // MARK: - Calorie Status

    func test_칼로리상태_부족() {
        let summary = HomeDailySummary(
            date: fixedDate,
            totalCalories: 1000,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieStatus, .under)
    }

    func test_칼로리상태_적정() {
        let summary = HomeDailySummary(
            date: fixedDate,
            totalCalories: 1900,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieStatus, .onTrack)
    }

    func test_칼로리상태_초과() {
        let summary = HomeDailySummary(
            date: fixedDate,
            totalCalories: 2300,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieStatus, .over)
    }

    func test_칼로리상태_경계값_0_8() {
        // 0.8 * 2000 = 1600 → exactly at boundary → onTrack
        let summary = HomeDailySummary(
            date: fixedDate,
            totalCalories: 1600,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieStatus, .onTrack)
    }

    func test_칼로리상태_경계값_1_1() {
        // 1.1 * 2000 = 2200 → exactly at boundary → onTrack
        let summary = HomeDailySummary(
            date: fixedDate,
            totalCalories: 2200,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertEqual(summary.calorieStatus, .onTrack)
    }

    // MARK: - Macro Progress

    func test_단백질진행률_절반() {
        let summary = HomeDailySummary(
            date: fixedDate,
            totalCalories: 0,
            goalCalories: 2000,
            totalProtein: 50,
            totalCarbs: 0,
            totalFat: 0,
            proteinGoal: 100
        )
        XCTAssertEqual(summary.proteinProgress, 0.5, accuracy: 0.01)
    }

    func test_단백질진행률_초과시_1로제한() {
        let summary = HomeDailySummary(
            date: fixedDate,
            totalCalories: 0,
            goalCalories: 2000,
            totalProtein: 150,
            totalCarbs: 0,
            totalFat: 0,
            proteinGoal: 100
        )
        XCTAssertEqual(summary.proteinProgress, 1.0, accuracy: 0.01)
    }

    func test_단백질진행률_목표0() {
        let summary = HomeDailySummary(
            date: fixedDate,
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

    func test_기록여부_식사있음() {
        let summary = HomeDailySummary(
            date: fixedDate,
            totalCalories: 0,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0,
            meals: [HomeMealSummary(id: UUID(), mealType: .breakfast, foodNames: ["Rice"], totalCalories: 200)]
        )
        XCTAssertTrue(summary.hasRecords)
    }

    func test_기록여부_비어있음() {
        let summary = HomeDailySummary(
            date: fixedDate,
            totalCalories: 0,
            goalCalories: 2000,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
        XCTAssertFalse(summary.hasRecords)
    }
}
