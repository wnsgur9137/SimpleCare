//
//  WeightRecordTests.swift
//  WeightTests
//
//  Created by SimpleCare on 3/18/26.
//

import XCTest
@testable import WeightDomain

final class WeightRecordTests: XCTestCase {

    // MARK: - Display Strings

    func testWeightDisplayString() {
        let record = WeightRecord(userProfileId: UUID(), weightKg: 72.5)
        XCTAssertEqual(record.weightDisplayString, "72.5 kg")
    }

    func testBodyFatDisplayString_hasValue() {
        let record = WeightRecord(userProfileId: UUID(), weightKg: 70, bodyFatPercentage: 18.5)
        XCTAssertEqual(record.bodyFatDisplayString, "18.5%")
    }

    func testBodyFatDisplayString_nil() {
        let record = WeightRecord(userProfileId: UUID(), weightKg: 70)
        XCTAssertNil(record.bodyFatDisplayString)
    }

    // MARK: - Weight Trend

    func testRemainingToGoal_weightLoss() {
        let trend = WeightTrend(currentWeight: 75, targetWeight: 70)
        XCTAssertEqual(trend.remainingToGoal, 5.0, accuracy: 0.01)
    }

    func testRemainingToGoal_weightGain() {
        let trend = WeightTrend(currentWeight: 60, targetWeight: 70)
        XCTAssertEqual(trend.remainingToGoal, -10.0, accuracy: 0.01)
    }

    func testRemainingToGoal_atTarget() {
        let trend = WeightTrend(currentWeight: 70, targetWeight: 70)
        XCTAssertEqual(trend.remainingToGoal, 0.0, accuracy: 0.01)
    }

    // MARK: - Progress To Goal

    func testProgressToGoal_weightLoss_halfWay() {
        // Start 80, target 70, current 75 → 50% progress
        let trend = WeightTrend(currentWeight: 75, targetWeight: 70)
        XCTAssertEqual(trend.progressToGoal(from: 80), 0.5, accuracy: 0.01)
    }

    func testProgressToGoal_weightLoss_complete() {
        let trend = WeightTrend(currentWeight: 70, targetWeight: 70)
        XCTAssertEqual(trend.progressToGoal(from: 80), 1.0, accuracy: 0.01)
    }

    func testProgressToGoal_weightGain_halfWay() {
        // Start 60, target 70, current 65 → 50% progress
        let trend = WeightTrend(currentWeight: 65, targetWeight: 70)
        XCTAssertEqual(trend.progressToGoal(from: 60), 0.5, accuracy: 0.01)
    }

    func testProgressToGoal_noChangeNeeded() {
        // Start == target → 1.0
        let trend = WeightTrend(currentWeight: 70, targetWeight: 70)
        XCTAssertEqual(trend.progressToGoal(from: 70), 1.0, accuracy: 0.01)
    }

    func testProgressToGoal_clampsToZero() {
        // Start 80, target 70, current 85 (went wrong direction) → clamped to 0
        let trend = WeightTrend(currentWeight: 85, targetWeight: 70)
        XCTAssertEqual(trend.progressToGoal(from: 80), 0.0, accuracy: 0.01)
    }

    func testProgressToGoal_clampsToOne() {
        // Start 80, target 70, current 65 (overshot) → clamped to 1.0
        let trend = WeightTrend(currentWeight: 65, targetWeight: 70)
        XCTAssertEqual(trend.progressToGoal(from: 80), 1.0, accuracy: 0.01)
    }
}
