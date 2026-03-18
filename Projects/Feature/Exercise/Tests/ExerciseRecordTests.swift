//
//  ExerciseRecordTests.swift
//  ExerciseTests
//
//  Created by SimpleCare on 3/18/26.
//

import XCTest
@testable import ExerciseDomain

final class ExerciseRecordTests: XCTestCase {

    // MARK: - Calculate Calories (MET-based)

    func testCalculateCalories_running_moderate() {
        // Running baseMET = 8.0, moderate multiplier = 1.0
        // 8.0 * 1.0 * 70 * (30/60) = 8 * 70 * 0.5 = 280
        let calories = ExerciseRecord.calculateCalories(
            exerciseType: .running,
            intensity: .moderate,
            durationMinutes: 30,
            weightKg: 70
        )
        XCTAssertEqual(calories, 280)
    }

    func testCalculateCalories_walking_light() {
        // Walking baseMET = 3.5, light multiplier = 0.75
        // 3.5 * 0.75 * 60 * (60/60) = 2.625 * 60 * 1 = 157.5 → 157
        let calories = ExerciseRecord.calculateCalories(
            exerciseType: .walking,
            intensity: .light,
            durationMinutes: 60,
            weightKg: 60
        )
        XCTAssertEqual(calories, 157)
    }

    func testCalculateCalories_yoga_vigorous() {
        // Yoga baseMET = 2.5, vigorous multiplier = 1.3
        // 2.5 * 1.3 * 65 * (45/60) = 3.25 * 65 * 0.75 = 158.4375 → 158
        let calories = ExerciseRecord.calculateCalories(
            exerciseType: .yoga,
            intensity: .vigorous,
            durationMinutes: 45,
            weightKg: 65
        )
        XCTAssertEqual(calories, 158)
    }

    func testCalculateCalories_customMET() {
        // Custom MET = 6.0, moderate = 1.0
        // 6.0 * 1.0 * 80 * (30/60) = 6 * 80 * 0.5 = 240
        let calories = ExerciseRecord.calculateCalories(
            exerciseType: .other,
            intensity: .moderate,
            durationMinutes: 30,
            weightKg: 80,
            customMET: 6.0
        )
        XCTAssertEqual(calories, 240)
    }

    func testCalculateCalories_zeroDuration() {
        let calories = ExerciseRecord.calculateCalories(
            exerciseType: .running,
            intensity: .moderate,
            durationMinutes: 0,
            weightKg: 70
        )
        XCTAssertEqual(calories, 0)
    }

    // MARK: - Exercise Type Category

    func testCategory_cardio() {
        XCTAssertEqual(ExerciseType.running.category, .cardio)
        XCTAssertEqual(ExerciseType.swimming.category, .cardio)
        XCTAssertEqual(ExerciseType.cycling.category, .cardio)
    }

    func testCategory_strength() {
        XCTAssertEqual(ExerciseType.weightLifting.category, .strength)
        XCTAssertEqual(ExerciseType.bodyweightExercise.category, .strength)
    }

    func testCategory_flexibility() {
        XCTAssertEqual(ExerciseType.yoga.category, .flexibility)
        XCTAssertEqual(ExerciseType.stretching.category, .flexibility)
    }

    func testCategory_sports() {
        XCTAssertEqual(ExerciseType.basketball.category, .sports)
        XCTAssertEqual(ExerciseType.soccer.category, .sports)
        XCTAssertEqual(ExerciseType.tennis.category, .sports)
    }

    // MARK: - Adjusted MET

    func testAdjustedMET_light() {
        XCTAssertEqual(ExerciseType.running.adjustedMET(for: .light), 8.0 * 0.75, accuracy: 0.01)
    }

    func testAdjustedMET_moderate() {
        XCTAssertEqual(ExerciseType.running.adjustedMET(for: .moderate), 8.0, accuracy: 0.01)
    }

    func testAdjustedMET_vigorous() {
        XCTAssertEqual(ExerciseType.running.adjustedMET(for: .vigorous), 8.0 * 1.3, accuracy: 0.01)
    }

    // MARK: - Effective Base MET

    func testEffectiveBaseMET_standardType() {
        let record = ExerciseRecord(
            userProfileId: UUID(),
            exerciseType: .running,
            durationMinutes: 30,
            userWeightKg: 70
        )
        XCTAssertEqual(record.effectiveBaseMET, 8.0)
    }

    func testEffectiveBaseMET_customType() {
        let record = ExerciseRecord(
            userProfileId: UUID(),
            exerciseType: .other,
            durationMinutes: 30,
            userWeightKg: 70,
            customMET: 5.5
        )
        XCTAssertEqual(record.effectiveBaseMET, 5.5)
    }

    func testEffectiveBaseMET_otherWithoutCustom() {
        let record = ExerciseRecord(
            userProfileId: UUID(),
            exerciseType: .other,
            durationMinutes: 30,
            userWeightKg: 70
        )
        XCTAssertEqual(record.effectiveBaseMET, ExerciseType.other.baseMET)
    }

    // MARK: - Auto Calorie Calculation in Init

    func testInit_autoCalculatesCalories() {
        let record = ExerciseRecord(
            userProfileId: UUID(),
            exerciseType: .running,
            intensity: .moderate,
            durationMinutes: 60,
            userWeightKg: 70
        )
        // 8.0 * 1.0 * 70 * 1.0 = 560
        XCTAssertEqual(record.caloriesBurned, 560)
    }

    func testInit_providedCaloriesOverride() {
        let record = ExerciseRecord(
            userProfileId: UUID(),
            exerciseType: .running,
            durationMinutes: 60,
            caloriesBurned: 999,
            userWeightKg: 70
        )
        XCTAssertEqual(record.caloriesBurned, 999)
    }
}
