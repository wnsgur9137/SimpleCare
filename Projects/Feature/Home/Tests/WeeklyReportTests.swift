//
//  WeeklyReportTests.swift
//  HomeTests
//
//  Created by SimpleCare on 3/18/26.
//

import XCTest
@testable import HomeDomain

final class WeeklyReportTests: XCTestCase {

    private let fixedDate = Date(timeIntervalSince1970: 1710720000) // 2024-03-18 00:00:00 GMT

    func test_목표달성률() {
        let report = WeeklyReport(
            weekStartDate: fixedDate,
            avgDailyCalories: 1800,
            totalExerciseMinutes: 0,
            totalExerciseCalories: 0,
            weightChange: nil,
            streakDays: 0,
            dailyCalories: [],
            goalCalories: 2000
        )
        XCTAssertEqual(report.goalAchievementRate, 1800.0 / 2000.0, accuracy: 0.01)
    }

    func test_목표달성률_목표0() {
        let report = WeeklyReport(
            weekStartDate: fixedDate,
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
