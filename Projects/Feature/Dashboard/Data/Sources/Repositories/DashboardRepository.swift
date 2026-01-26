//
//  DashboardRepository.swift
//  DashboardData
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import DashboardDomain
import StorageInfra
import AIServiceInfra

/// Dashboard Repository 구현
public final class DashboardRepository: DashboardRepositoryProtocol, @unchecked Sendable {
    private let mealStorage: MealRecordRepository
    private let exerciseStorage: ExerciseRecordRepository
    private let insightService: DailyInsightService

    public init(
        mealStorage: MealRecordRepository = MealRecordRepository(),
        exerciseStorage: ExerciseRecordRepository = ExerciseRecordRepository(),
        insightService: DailyInsightService? = nil
    ) {
        self.mealStorage = mealStorage
        self.exerciseStorage = exerciseStorage
        self.insightService = insightService ?? DailyInsightService()
    }

    public func getDailySummary(for date: Date, userProfileId: UUID, goalCalories: Int) async throws -> DailySummary {
        // 식사 기록 조회
        let meals = try await mealStorage.fetchMeals(for: date, userProfileId: userProfileId)

        // 운동 기록 조회
        let exercises = try await exerciseStorage.fetchExercises(for: date, userProfileId: userProfileId)

        // 총 섭취량 계산
        var totalCalories = 0
        var totalProtein = 0.0
        var totalCarbs = 0.0
        var totalFat = 0.0

        for meal in meals {
            totalCalories += meal.totalCalories
            totalProtein += meal.totalProtein
            totalCarbs += meal.totalCarbs
            totalFat += meal.totalFat
        }

        // 운동 칼로리
        let exerciseCalories = exercises.reduce(0) { $0 + $1.caloriesBurned }

        return DailySummary(
            date: date,
            totalCalories: totalCalories,
            goalCalories: goalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            mealCount: meals.count,
            exerciseCalories: exerciseCalories
        )
    }

    public func generateDailyInsight(for summary: DailySummary, mealNames: [String]) async throws -> DailyInsight {
        let input = DailySummaryInput(
            totalCalories: summary.totalCalories,
            totalProtein: summary.totalProtein,
            totalCarbs: summary.totalCarbs,
            totalFat: summary.totalFat,
            goalCalories: summary.goalCalories,
            mealNames: mealNames
        )

        let result = try await insightService.generateInsight(from: input)
        return DailyInsight(comment: result.comment, emoji: result.emoji)
    }
}
