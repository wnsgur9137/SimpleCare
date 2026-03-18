//
//  UserProfileTests.swift
//  ProfileTests
//
//  Created by SimpleCare on 3/18/26.
//

import XCTest
@testable import ProfileDomain

final class UserProfileTests: XCTestCase {

    // MARK: - BMR (Mifflin-St Jeor)

    func testBMR_male() {
        let profile = UserProfile(
            heightCm: 175,
            currentWeightKg: 70,
            age: 30,
            biologicalSex: .male
        )
        // (10 * 70) + (6.25 * 175) - (5 * 30) + 5 = 700 + 1093.75 - 150 + 5 = 1648.75
        XCTAssertEqual(profile.bmr, 1648.75, accuracy: 0.01)
    }

    func testBMR_female() {
        let profile = UserProfile(
            heightCm: 160,
            currentWeightKg: 55,
            age: 25,
            biologicalSex: .female
        )
        // (10 * 55) + (6.25 * 160) - (5 * 25) - 161 = 550 + 1000 - 125 - 161 = 1264
        XCTAssertEqual(profile.bmr, 1264.0, accuracy: 0.01)
    }

    // MARK: - TDEE

    func testTDEE_sedentary() {
        let profile = UserProfile(
            heightCm: 175,
            currentWeightKg: 70,
            age: 30,
            biologicalSex: .male,
            activityLevel: .sedentary
        )
        XCTAssertEqual(profile.tdee, profile.bmr * 1.2, accuracy: 0.01)
    }

    func testTDEE_extraActive() {
        let profile = UserProfile(
            heightCm: 175,
            currentWeightKg: 70,
            age: 30,
            biologicalSex: .male,
            activityLevel: .extraActive
        )
        XCTAssertEqual(profile.tdee, profile.bmr * 1.9, accuracy: 0.01)
    }

    // MARK: - Recommended Daily Calories

    func testRecommendedCalories_weightLoss() {
        let profile = UserProfile(
            heightCm: 175,
            currentWeightKg: 70,
            age: 30,
            biologicalSex: .male,
            activityLevel: .moderatelyActive,
            goalType: .weightLoss
        )
        XCTAssertEqual(profile.recommendedDailyCalories, Int(profile.tdee - 500))
    }

    func testRecommendedCalories_weightGain() {
        let profile = UserProfile(
            heightCm: 175,
            currentWeightKg: 70,
            age: 30,
            biologicalSex: .male,
            activityLevel: .moderatelyActive,
            goalType: .weightGain
        )
        XCTAssertEqual(profile.recommendedDailyCalories, Int(profile.tdee + 300))
    }

    func testRecommendedCalories_maintenance() {
        let profile = UserProfile(
            heightCm: 175,
            currentWeightKg: 70,
            age: 30,
            biologicalSex: .male,
            activityLevel: .moderatelyActive,
            goalType: .maintenance
        )
        XCTAssertEqual(profile.recommendedDailyCalories, Int(profile.tdee))
    }

    // MARK: - Effective Calorie Goal

    func testEffectiveGoal_customOverridesRecommended() {
        let profile = UserProfile(
            dailyCalorieGoal: 1800
        )
        XCTAssertEqual(profile.effectiveDailyCalorieGoal, 1800)
    }

    func testEffectiveGoal_fallsBackToRecommended() {
        let profile = UserProfile(
            dailyCalorieGoal: nil
        )
        XCTAssertEqual(profile.effectiveDailyCalorieGoal, profile.recommendedDailyCalories)
    }

    // MARK: - Macro Recommendations

    func testRecommendedProtein() {
        let profile = UserProfile(currentWeightKg: 70)
        // 70 * 1.6 = 112
        XCTAssertEqual(profile.recommendedDailyProtein, 112)
    }

    func testRecommendedCarbs() {
        let profile = UserProfile(dailyCalorieGoal: 2000)
        // 2000 * 0.5 / 4.0 = 250
        XCTAssertEqual(profile.recommendedDailyCarbs, 250)
    }

    func testRecommendedFat() {
        let profile = UserProfile(dailyCalorieGoal: 2000)
        // 2000 * 0.25 / 9.0 = 55.5... → 55
        XCTAssertEqual(profile.recommendedDailyFat, 55)
    }

    // MARK: - BMI

    func testBMI_normalWeight() {
        let profile = UserProfile(heightCm: 175, currentWeightKg: 70)
        // 70 / (1.75 * 1.75) = 70 / 3.0625 = 22.857...
        XCTAssertEqual(profile.bmi, 22.857, accuracy: 0.01)
    }

    func testBMI_zeroHeight_returnsZero() {
        let profile = UserProfile(heightCm: 0, currentWeightKg: 70)
        XCTAssertEqual(profile.bmi, 0)
    }

    // MARK: - Activity Level Multiplier

    func testActivityLevelMultipliers() {
        XCTAssertEqual(ActivityLevel.sedentary.multiplier, 1.2)
        XCTAssertEqual(ActivityLevel.lightlyActive.multiplier, 1.375)
        XCTAssertEqual(ActivityLevel.moderatelyActive.multiplier, 1.55)
        XCTAssertEqual(ActivityLevel.veryActive.multiplier, 1.725)
        XCTAssertEqual(ActivityLevel.extraActive.multiplier, 1.9)
    }
}
