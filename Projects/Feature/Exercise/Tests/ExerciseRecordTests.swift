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

    func test_칼로리계산_달리기_중강도() {
        // Running baseMET = 8.0, moderate multiplier = 1.0
        let calories = ExerciseRecord.calculateCalories(
            exerciseType: .running,
            intensity: .moderate,
            durationMinutes: 30,
            weightKg: 70
        )
        let expected = Int(8.0 * 1.0 * 70.0 * (30.0 / 60.0))
        XCTAssertEqual(calories, expected)
    }

    func test_칼로리계산_걷기_저강도() {
        // Walking baseMET = 3.5, light multiplier = 0.75
        let calories = ExerciseRecord.calculateCalories(
            exerciseType: .walking,
            intensity: .light,
            durationMinutes: 60,
            weightKg: 60
        )
        let expected = Int(3.5 * 0.75 * 60.0 * (60.0 / 60.0))
        XCTAssertEqual(calories, expected)
    }

    func test_칼로리계산_요가_고강도() {
        // Yoga baseMET = 2.5, vigorous multiplier = 1.3
        let calories = ExerciseRecord.calculateCalories(
            exerciseType: .yoga,
            intensity: .vigorous,
            durationMinutes: 45,
            weightKg: 65
        )
        let expected = Int(2.5 * 1.3 * 65.0 * (45.0 / 60.0))
        XCTAssertEqual(calories, expected)
    }

    func test_칼로리계산_커스텀MET() {
        // Custom MET = 6.0, moderate = 1.0
        let calories = ExerciseRecord.calculateCalories(
            exerciseType: .other,
            intensity: .moderate,
            durationMinutes: 30,
            weightKg: 80,
            customMET: 6.0
        )
        let expected = Int(6.0 * 1.0 * 80.0 * (30.0 / 60.0))
        XCTAssertEqual(calories, expected)
    }

    func test_칼로리계산_0분운동() {
        let calories = ExerciseRecord.calculateCalories(
            exerciseType: .running,
            intensity: .moderate,
            durationMinutes: 0,
            weightKg: 70
        )
        XCTAssertEqual(calories, 0)
    }

    // MARK: - Exercise Type Category

    func test_카테고리_유산소() {
        XCTAssertEqual(ExerciseType.running.category, .cardio)
        XCTAssertEqual(ExerciseType.swimming.category, .cardio)
        XCTAssertEqual(ExerciseType.cycling.category, .cardio)
    }

    func test_카테고리_근력() {
        XCTAssertEqual(ExerciseType.weightLifting.category, .strength)
        XCTAssertEqual(ExerciseType.bodyweightExercise.category, .strength)
    }

    func test_카테고리_유연성() {
        XCTAssertEqual(ExerciseType.yoga.category, .flexibility)
        XCTAssertEqual(ExerciseType.stretching.category, .flexibility)
    }

    func test_카테고리_스포츠() {
        XCTAssertEqual(ExerciseType.basketball.category, .sports)
        XCTAssertEqual(ExerciseType.soccer.category, .sports)
        XCTAssertEqual(ExerciseType.tennis.category, .sports)
    }

    // MARK: - Adjusted MET

    func test_조정MET_저강도() {
        XCTAssertEqual(ExerciseType.running.adjustedMET(for: .light), 8.0 * 0.75, accuracy: 0.01)
    }

    func test_조정MET_중강도() {
        XCTAssertEqual(ExerciseType.running.adjustedMET(for: .moderate), 8.0, accuracy: 0.01)
    }

    func test_조정MET_고강도() {
        XCTAssertEqual(ExerciseType.running.adjustedMET(for: .vigorous), 8.0 * 1.3, accuracy: 0.01)
    }

    // MARK: - Effective Base MET

    func test_기본MET_표준운동타입() {
        let record = ExerciseRecord(
            userProfileId: UUID(),
            exerciseType: .running,
            durationMinutes: 30,
            userWeightKg: 70
        )
        XCTAssertEqual(record.effectiveBaseMET, 8.0)
    }

    func test_기본MET_커스텀타입() {
        let record = ExerciseRecord(
            userProfileId: UUID(),
            exerciseType: .other,
            durationMinutes: 30,
            userWeightKg: 70,
            customMET: 5.5
        )
        XCTAssertEqual(record.effectiveBaseMET, 5.5)
    }

    func test_기본MET_기타타입_커스텀없음() {
        let record = ExerciseRecord(
            userProfileId: UUID(),
            exerciseType: .other,
            durationMinutes: 30,
            userWeightKg: 70
        )
        XCTAssertEqual(record.effectiveBaseMET, ExerciseType.other.baseMET)
    }

    // MARK: - Auto Calorie Calculation in Init

    func test_초기화시_자동칼로리계산() {
        let record = ExerciseRecord(
            userProfileId: UUID(),
            exerciseType: .running,
            intensity: .moderate,
            durationMinutes: 60,
            userWeightKg: 70
        )
        let expected = Int(8.0 * 1.0 * 70.0 * (60.0 / 60.0))
        XCTAssertEqual(record.caloriesBurned, expected)
    }

    func test_초기화시_제공된칼로리_우선() {
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
